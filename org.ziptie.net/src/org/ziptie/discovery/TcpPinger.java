/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/10/06 22:18:44 $
 * $Revision: 1.11 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/TcpPinger.java,v $e
 */

package org.ziptie.discovery;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.rmi.dgc.VMID;
import java.util.Date;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.Semaphore;

import org.apache.log4j.Logger;
import org.ziptie.addressing.IPAddress;
import org.ziptie.net.common.NILConstants;
import org.ziptie.net.common.NILProperties;

/**
 * NIO based TCP port scan used to determine if a host is alive. <br>
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
class TcpPinger extends AbstractPinger
{
    private static Logger USER_LOG = Logger.getLogger(NILConstants.LOGGER_CATEGORY);

    private Semaphore semaphore;
    private SelectingThread connector;
    private int[] ports;
    private ConcurrentHashMap<VMID, PortReporter> trackingMap;
    private IPAddress localIp;

    /**
     * @param engine
     */
    public TcpPinger(DiscoveryEngine engine)
    {
        super(engine);
        init();
    }

    /**
     * @see org.ziptie.discovery.AbstractPinger#getActivePings()
     */
    @Override
    int getActivePings()
    {
        return trackingMap.size();
    }

    /**
     * @see org.ziptie.discovery.AbstractPinger#ping(org.ziptie.addressing.IPAddress,
     *      boolean, boolean)
     */
    @Override
    void ping(IPAddress ipAddress, boolean fromInventorySource, boolean extendUsingNeighbors)
    {
        if (isRunning() && !ipAddress.equals(localIp))
        {
            VMID id = new VMID();
            super.ping(ipAddress, fromInventorySource, extendUsingNeighbors);
            try
            {
                trackingMap.put(id, new PortReporter(ports.length));
                for (int i = 0; i < ports.length; i++)
                {
                    semaphore.acquire();
                    Target target = new Target(ipAddress, id, ports[i], fromInventorySource, extendUsingNeighbors);
                    connector.add(target);
                }
            }
            catch (UnknownHostException e)
            {
                trackingMap.remove(id);
                USER_LOG.warn("Invalid IP Address sent to the pinger: " + ipAddress + ".");
            }
            catch (InterruptedException e)
            {
                trackingMap.remove(id);
                USER_LOG.error("Pinger has been interrupted.", e);
            }
        }
    }

    /**
     * Clear out the trackingMap in addition to the higher level stop method.  This will make sure
     * we don't ever hang when the pinger gets stopped.
     */
    @Override
    void stop()
    {
        super.stop();
        trackingMap.clear();
    }

    /**
     * Only bubble up the failure on to the DiscoveryEngine if all socket
     * connections have failed.
     * 
     * @param id
     * @param ipAddress
     */
    protected void onFailure(Target target)
    {
        PortReporter reporter = trackingMap.get(target.getId());
        if (reporter != null)
        {
        	synchronized (reporter) 
        	{
        		reporter.incrementFinishedPorts();
        		if (reporter.isDone())
        		{
        			if (!reporter.isSuccessReported())
        			{
        				super.onFailure(target.getIpAddress());
        			}
        			trackingMap.remove(target.getId());
        		}
        	}
        }
        semaphore.release();
    }

    /**
     * When a TCP socket is connected it gets reported here. This method will
     * track if the overall success has already been reported or not.
     * 
     * @param id
     * @param ipAddress
     */
    protected void onSuccess(Target target)
    {
        PortReporter reporter = trackingMap.get(target.getId());
        if (reporter != null)
        {
        	synchronized (reporter)
        	{
        		reporter.incrementFinishedPorts();
        		if (!reporter.isSuccessReported())
        		{
        			reporter.setSuccessReported(true);
        			super.onSuccess(target.getIpAddress(), target.isFromInventorySource(), target.isExtendUsingNeighbors());
        		}

        		if (reporter.isDone())
        		{
        			trackingMap.remove(target.getId());
        		}
        	}
        }
        semaphore.release();
    }

    /**
     * Starts up the NIO {@link Selector}
     * 
     */
    private void init()
    {
        try
        {
            NILProperties nilProperties = NILProperties.getInstance();
            int semaphoreCount = nilProperties.getInt(NILProperties.DISCOVERY_TCPPING_CONNECTIONS);
            semaphore = new Semaphore(semaphoreCount);
            ports = nilProperties.getIntArray(NILProperties.DISCOVERY_TCPPING_PORTS);
            trackingMap = new ConcurrentHashMap<VMID, PortReporter>();
            connector = new SelectingThread(this);
            connector.start();
            localIp = new IPAddress(InetAddress.getLocalHost().getHostAddress());
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Houses the {@link Selector} as a private variable. All modifications to
     * the {@link Selector} are done within this thread.
     * 
     * @author rkruse
     */
    @SuppressWarnings("nls")
    private static class SelectingThread extends Thread
    {
        private static final long ONE_SECOND = 1000L;
        private Selector selector;
        private LinkedBlockingQueue<Target> pendingTargets;
        private boolean shutdown;
        private TcpPinger pinger;

        SelectingThread(TcpPinger pinger) throws IOException
        {
            this.pinger = pinger;
            selector = Selector.open();
            pendingTargets = new LinkedBlockingQueue<Target>();
            setName("TCP Ping");
        }

        /**
         * Connect to the given target and configure non-blocking.
         * 
         * @param target
         */
        void add(Target target)
        {
            SocketChannel socketChannel = null;
            try
            {
                socketChannel = SocketChannel.open();
                socketChannel.configureBlocking(false);
                socketChannel.socket().setReuseAddress(true);
                socketChannel.connect(target.getSocketAddress());
                target.setChannel(socketChannel);
                pendingTargets.add(target);
                selector.wakeup();
            }
            catch (IOException e)
            {
                USER_LOG.warn("Discovery ping error for " + target.getIpAddress() + ". " + e.getMessage());
                pinger.onFailure(target);
            }
        }

        /**
         * @see java.lang.Thread#run()
         */
        @Override
        public void run()
        {
            try
            {
                while (!shutdown)
                {
                    if (selector.select(ONE_SECOND) > 0)
                    {
                        processSelectedKeys();
                    }
                    processPendingTargets();
                    purgeExpiredTargets();
                }
                selector.close();
            }
            catch (IOException e)
            {
                USER_LOG.error(e.getMessage());
            }
        }

        /**
         * Cancels any channels that haven't been connected within the allowed
         * timeout.
         */
        private void purgeExpiredTargets()
        {
            Date now = new Date();
            Set<SelectionKey> keys = selector.keys();
            for (SelectionKey key : keys)
            {
                Target target = (Target) key.attachment();
                SocketChannel channel = (SocketChannel) key.channel();
                if (!channel.isConnected() && now.after(target.getExpiredTime()))
                {
                    key.cancel();

                    // Close the channel to drop the SYN_SENT
                    try
                    {
                        channel.close();
                    }
                    catch (IOException e)
                    {
                        USER_LOG.error("Error closing the channel on a timeout of " + target + ". " + e.getMessage());
                    }

                    // Report the failure
                    pinger.onFailure(target);
                }
            }

        }

        /**
         * Any interesting {@link SelectionKey} objects that have been returned
         * by the {@link Selector} are processed here. Those that have finished
         * connecting will be added to the validResponses hash.
         * 
         * @throws IOException
         */
        private void processSelectedKeys() throws IOException
        {
            Set<SelectionKey> selectedKeys = selector.selectedKeys();
            for (SelectionKey key : selectedKeys)
            {
                Target target = (Target) key.attachment();
                SocketChannel channel = (SocketChannel) key.channel();
                try
                {
                    if (channel.finishConnect())
                    {
                        pinger.onSuccess(target);
                        key.cancel();
                        channel.close();
                    }
                }
                catch (IOException e)
                {
                    pinger.onFailure(target);
                    channel.close();
                }
            }
            selectedKeys.clear();
        }

        /**
         * Pull off targets that are waiting in the {@link #pendingTargets}
         * <code>LinkedList</code> and register their channels with the
         * {@link Selector}
         * 
         * @throws IOException
         */
        private void processPendingTargets() throws IOException
        {
            int timeout = pinger.getEngine().getDiscoveryConfig().getPingTimeout();
            while (pendingTargets.size() > 0)
            {
                Target target = pendingTargets.poll();
                target.setExpiredTime(new Date(System.currentTimeMillis() + timeout));
                target.getChannel().register(selector, SelectionKey.OP_CONNECT, target);
            }
        }
    }

    /**
     * Houses the {@link SocketChannel} that will be connecting to this
     * host/port.
     * 
     * @author rkruse
     */
    private class Target
    {
        private InetSocketAddress socketAddress;
        private SocketChannel channel;
        private IPAddress ipAddress;
        private VMID id;
        private boolean fromInventorySource;
        private boolean extendUsingNeighbors;
        private Date expiredTime;

        Target(IPAddress ipAddress, VMID id, int port, boolean fromInventorySource, boolean extendUsingNeighbors)
            throws UnknownHostException
        {
            this.ipAddress = ipAddress;
            this.id = id;
            this.socketAddress = new InetSocketAddress(InetAddress.getByName(ipAddress.getIPAddress()), port);
            this.fromInventorySource = fromInventorySource;
            this.extendUsingNeighbors = extendUsingNeighbors;
        }

        /**
         * @return the channel
         */
        public SocketChannel getChannel()
        {
            return channel;
        }

        /**
         * @param channel the channel to set
         */
        public void setChannel(SocketChannel channel)
        {
            this.channel = channel;
        }

        /**
         * @return the address
         */
        public InetSocketAddress getSocketAddress()
        {
            return socketAddress;
        }

        /**
         * @param address the address to set
         */
        public void setSocketAddress(InetSocketAddress socketAddress)
        {
            this.socketAddress = socketAddress;
        }

        /**
         * @return
         */
        public IPAddress getIpAddress()
        {
            return ipAddress;
        }

        /**
         * @return the id
         */
        public VMID getId()
        {
            return id;
        }

        /**
         * @param id the id to set
         */
        public void setId(VMID id)
        {
            this.id = id;
        }

        /**
         * @return the extendUsingNeighbors
         */
        public boolean isExtendUsingNeighbors()
        {
            return extendUsingNeighbors;
        }

        /**
         * @return the fromInventorySource
         */
        public boolean isFromInventorySource()
        {
            return fromInventorySource;
        }

        /**
         * The time when this socket connection can be considered a timeout
         * 
         * @return the expiredTime
         */
        public Date getExpiredTime()
        {
            return expiredTime;
        }

        /**
         * The time when this socket connection can be considered a timeout
         * 
         * @param expiredTime the expiredTime to set
         */
        public void setExpiredTime(Date expiredTime)
        {
            this.expiredTime = expiredTime;
        }
    }

    /**
     * This class will test if a host is alive by checking one or more TCP ports
     * to see if a socket connection is successful. This class is used to track
     * the status of all ports. If one port is up then we want to report that
     * success only once. Likewise if teh first port does not connect we don't
     * want to report a failure until we know that all sockets won't connect.
     * 
     * @author rkruse
     */
    private class PortReporter
    {
        private int totalPorts;
        private int finishedPorts;
        private boolean successReported;

        PortReporter(int totalPorts)
        {
            this.totalPorts = totalPorts;
        }

        /**
         * Have all of the ports been reported on yet?
         * 
         * @return
         */
        public synchronized boolean isDone()
        {
            return (finishedPorts >= totalPorts);
        }

        /**
         * Report that a port has finished.
         */
        public synchronized void incrementFinishedPorts()
        {
            this.finishedPorts++;
        }

        /**
         * @param successReported the successReported to set
         */
        public void setSuccessReported(boolean successReported)
        {
            this.successReported = successReported;
        }

        /**
         * @return the successReported
         */
        public boolean isSuccessReported()
        {
            return successReported;
        }
    }
}
