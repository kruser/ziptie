/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/07/09 19:24:12 $
 * $Revision: 1.6 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/AbstractPinger.java,v $e
 */

package org.ziptie.discovery;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Semaphore;

import org.apache.log4j.Logger;
import org.ziptie.addressing.IPAddress;
import org.ziptie.logging.LoggingConstants;
import org.ziptie.net.common.NILProperties;

/**
 * Tells the <code>DiscoveryEngine</code> how it should ping hosts when
 * needed.
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
abstract class AbstractPinger
{
    protected static final String THREAD_NAME = "DISCOVERY-PINGER";
    private static Logger LOGGER = Logger.getLogger(LoggingConstants.DISCOVERY);
    private DiscoveryEngine engine;
    private boolean running = true;
    private Semaphore maxRunnables;
    private ConcurrentHashMap<IPAddress, DiscoveryHost> discoveryHosts;

    /**
     * Super constructor.
     * 
     * @param engine
     */
    AbstractPinger(DiscoveryEngine engine)
    {
        this.engine = engine;
        int semaphoreCount = NILProperties.getInstance().getInt(NILProperties.DISCOVERY_PING_SEMAPHORES);
        maxRunnables = new Semaphore(semaphoreCount);
        discoveryHosts = new ConcurrentHashMap<IPAddress, DiscoveryHost>();
    }

    /**
     * @return the engine
     */
    public DiscoveryEngine getEngine()
    {
        return engine;
    }

    /**
     * @param engine the engine to set
     */
    public void setEngine(DiscoveryEngine engine)
    {
        this.engine = engine;
    }

    /**
     * @return the running
     */
    public boolean isRunning()
    {
        return running;
    }

    /**
     * @param running the running to set
     */
    public void setRunning(boolean running)
    {
        this.running = running;
    }

    /**
     * The implementation of this method will run a system specific ping to
     * check host availability. It is up to the implementor to decide on what
     * makes a device "pingable". This could be an ICMP ping or a TCP port check
     * on the echo port (7). Virtually anything. <br>
     * <br>
     * implementors of this method should call
     * {@link #onSuccess(IPAddress, boolean, boolean, boolean)} for those
     * addresses that respond to a ping.
     * 
     * @param ipAddress
     * @param fromInventorySource
     * @param extendUsingNeighbors
     */
    void ping(IPAddress ipAddress, boolean fromInventorySource, boolean extendUsingNeighbors)
    {
        try
        {
            maxRunnables.acquire();
            if (LOGGER.isDebugEnabled())
            {
                LOGGER.debug("Ping check of " + ipAddress);
            }
        }
        catch (InterruptedException e)
        {
            throw new RuntimeException("Interrupted while pinging for discovery.", e);
        }
    }

    /**
     * Returns 0 if there is no local activity
     * 
     * @return
     */
    abstract int getActivePings();

    /**
     * Ping using a {@link DiscoveryHost}. The DiscoveryHost may contain more
     * details such as system name, system description, etc.
     * 
     * On a successful ping the host will be redirected back to the {@link DiscoveryEngine}.
     * 
     * @param host
     * @param fromInventorySource
     * @param extendUsingNeighbors
     */
    void ping(DiscoveryHost host, boolean fromInventorySource, boolean extendUsingNeighbors)
    {
        discoveryHosts.put(host.getIpAddress(), host);
        ping(host.getIpAddress(), fromInventorySource, extendUsingNeighbors);
    }

    /**
     * Sets the status of the pinger to stopped. All extensions to this class
     * should not allow new pings in when the status is stopped.
     * 
     */
    void stop()
    {
        running = false;
    }

    /**
     * Sets the status of the pinger to 'running'. This has no effect if the
     * pinger is already running.
     */
    void start()
    {
        running = true;
    }

    /**
     * Must be called for each successful ping. This method will throw the
     * {@link IPAddress} back on the {@link DiscoveryEngine}
     * 
     * @param ipAddress
     * @param fromInventorySource
     * @param extendUsingNeighbors
     */
    protected void onSuccess(IPAddress ipAddress, boolean fromInventorySource, boolean extendUsingNeighbors)
    {
        maxRunnables.release();
        if (LOGGER.isDebugEnabled())
        {
            LOGGER.debug("Ping successful for " + ipAddress + ".  Moving to deeper scan.");
        }
        DiscoveryHost host = new DiscoveryHost(ipAddress);
        if (discoveryHosts.containsKey(ipAddress))
        {
            host = discoveryHosts.remove(ipAddress);
        }

        try
        {
            engine.discover(host, false, fromInventorySource, extendUsingNeighbors, true);
        }
        catch (NoFutureException e)
        {
            return;
        }
    }

    /**
     * Increments the addresses analyzed counter in the {@link DiscoveryEngine}
     * since the engine won't be looking at this device any longer.
     * 
     * @param ipAddress
     */
    protected void onFailure(IPAddress ipAddress)
    {
        maxRunnables.release();
        if (LOGGER.isDebugEnabled())
        {
            LOGGER.debug("Ping failed for " + ipAddress + ".  Dropping from discovery engine.");
        }
        discoveryHosts.remove(ipAddress);
        engine.incrementAddressesAnalyzed();
    }
}
