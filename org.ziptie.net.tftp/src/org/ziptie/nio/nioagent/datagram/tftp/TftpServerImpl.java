package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.Inet4Address;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.nio.channels.DatagramChannel;
import java.nio.channels.SelectionKey;
import java.util.Enumeration;
import java.util.Properties;

import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.WrapperException;
import org.ziptie.nio.nioagent.Interfaces.ChannelSelector;
import org.ziptie.nio.nioagent.Interfaces.KeyAttachment;
import org.ziptie.nio.nioagent.datagram.ChannelUtils;
import org.ziptie.nio.nioagent.datagram.ServerDatagramAttachment;

/**
 * Implementation of a TFTP server on top of the NIO agent framework. To get the
 * singleton instance of the server call {@link #getInstance()}. To start the
 * server using the default settings call {@link #start() start}.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 */
public class TftpServerImpl implements TftpServer, PacketConstants
{
    // -- fields

    public static final String IP_ADDRESS = "ipAddress";
    public static final String PORT = "port";
    public static final String ROOT_DIRECTORY = "rootDirectory";
    public static final String DEFAULT_TIMEOUT_INTERVAL = "defaultTimeoutInterval";
    public static final String RETRANSMIT_DELAY = "retransmitDelay";
    public static final String RETRANSMIT_COUNT = "retransmitCount";
    public static final String BUFFER_SIZE = "bufferSize";
    public static final String REQUIRED_FILE_EXISTS = "requireFileExists";
    public static final String START_SERVER = "startServer";
    private static final String WINDOWS_STRING = "indows"; //$NON-NLS-1$

    private static final int DEFAULT_RETRANSMIT_COUNT = 3;
    private static final int DEFAULT_BUFFER_SIZE = 2048;

    private final String ipAddress;
    private final int port;
    private final String dir;
    private final ILogger logger;
    private final int defaultTimeoutInterval;
    private final long retransmitDelay;
    private final int retransmitCount;
    private final int bufferSize;
    private boolean requireFileExists;

    private ServerCodec.Factory serverCodecFactory;
    private DatagramChannel datagramChannel;

    private String osName;

    // -- constructors
    /**
     * @param ipAddress
     * @param port
     * @param rootDirectory
     * @param logger
     * @param defaultTimeoutInterval
     * @param retransmitDelay
     * @param retransmitCount pass in null to use the default (3)
     * @param bufferSize pass in null to use the default (2048)
     * @param requiredFileExists if true, will startup with a {@link FileBasedSecurityManager}
     */
    public TftpServerImpl(final String ipAddress, final int port, final String rootDirectory, final ILogger logger, final int defaultTimeoutInterval,
            final long retransmitDelay, final Integer retransmitCount, final Integer bufferSize, final boolean requiredFileExists)
    {
        this.osName = System.getProperty("os.name"); //$NON-NLS-1$
        this.ipAddress = ipAddress;
        this.port = port;
        this.dir = rootDirectory;
        this.logger = logger;
        this.defaultTimeoutInterval = defaultTimeoutInterval;
        this.retransmitDelay = retransmitDelay;
        this.retransmitCount = retransmitCount == null ? DEFAULT_RETRANSMIT_COUNT : retransmitCount;
        this.bufferSize = bufferSize == null ? DEFAULT_BUFFER_SIZE : bufferSize;
        this.requireFileExists = requiredFileExists;

        SecurityManager securityManager = null;
        if (requiredFileExists)
        {
            securityManager = new FileBasedSecurityManager(rootDirectory);
        }
        else
        {
            securityManager = new BasicSecurity();
        }

        this.serverCodecFactory = new ServerCodec.Factory(new FileDataConsumer.Factory(this.dir), new FileDataProducer.Factory(this.dir), securityManager,
                                                          new BasicListener(), logger, this.defaultTimeoutInterval);
    }

    public TftpServerImpl(final String ipAddress, final int port, final String rootDirectory, final ILogger logger, final int defaultTimeoutInterval,
            final long retransmitDelay)
    {
        this(ipAddress, port, rootDirectory, logger, defaultTimeoutInterval, retransmitDelay, DEFAULT_RETRANSMIT_COUNT, DEFAULT_BUFFER_SIZE, false);
    }

    public TftpServerImpl(Properties p, final ILogger logger)
    {
        this(p.getProperty(IP_ADDRESS, "0.0.0.0"), getOptionalInt(p, PORT, 69), p.getProperty(ROOT_DIRECTORY), logger, getOptionalInt(p,
                                                                                                                                      DEFAULT_TIMEOUT_INTERVAL,
                                                                                                                                      5000),
             getOptionalLong(p, RETRANSMIT_DELAY, 3), getOptionalInt(p, RETRANSMIT_COUNT), getOptionalInt(p, BUFFER_SIZE),
             getOptionalBoolean(p, REQUIRED_FILE_EXISTS));
    }

    private static long getOptionalLong(Properties p, String key, long defualt)
    {
        String val = p.getProperty(key);
        return val == null ? defualt : Long.parseLong(val);
    }

    private static int getOptionalInt(Properties p, String key, int defualt)
    {
        Integer val = getOptionalInt(p, key);
        return val == null ? defualt : val;
    }

    private static Integer getOptionalInt(Properties p, String key)
    {
        String val = p.getProperty(key);
        return null == val ? null : Integer.parseInt(val);
    }

    /**
     * By default this method returns false.  If the property being asked for does exist then
     * this method returns the boolean value of that property.
     * 
     * @param p the props
     * @param key the name of the prob
     * @return the parsed out boolean value of the matching property
     */
    private static boolean getOptionalBoolean(Properties p, String key)
    {
        String val = p.getProperty(key);
        return null == val ? false : Boolean.parseBoolean(val);
    }

    // -- public methods
    public synchronized void start()
    {
        if (null == datagramChannel || !datagramChannel.isOpen())
        {
            datagramChannel = ChannelUtils.openInit(logger);
            bind();
            ChannelSelector channelSelector = ChannelSelectorImpl.getInstance(logger);
            channelSelector.start();
            channelSelector.register(datagramChannel, SelectionKey.OP_READ, att());
        }
    }

    public synchronized void restart(DataConsumer.Factory consumerFactory, DataProducer.Factory producerFactory, SecurityManager manager, EventListener listener)
    {
        stop();
        serverCodecFactory = new ServerCodec.Factory(consumerFactory, producerFactory, manager, listener, logger, defaultTimeoutInterval);
        start();
    }

    public synchronized void stop()
    {
        if (null != datagramChannel && datagramChannel.isOpen())
        {
            ChannelUtils.close(datagramChannel, logger);
        }
    }

    public String getDirectory()
    {
        return dir;
    }

    public String getIpAddress()
    {
        String determinedIpAddress = ipAddress;

        try
        {
            if ("0.0.0.0".equals(ipAddress))
            {
                InetAddress localHost = getMyAddress();
                determinedIpAddress = localHost.getHostAddress();
            }
        }
        catch (UnknownHostException e)
        {
            throw new RuntimeException(e);
        }

        return determinedIpAddress;
    }

    /**
     * Attempts to retrieve the IPv6 address for the TFTP server.  If an IP address is specified in the
     * configuration file for the TFTP server, that will take precedence above all else.  Otherwise, we
     * will test to see if the TFTP server is running locally and if so, we will attempt to get the IPv6
     * address for the local machine.
     * 
     * @return The IPv6 address of the local machine running the TFTP server or an IPv4/IPv6 address specified
     * in the TFTP server configuration file.
     */
    public String getIpV6Address()
    {
        // TODO: As of JDK6, accessing an IPv4 socket with an IPv6 address and vice versa does not work on
        // Windows XP/2003/Vista.  NIO-based channels do no work in an IPv6 environment on Microsoft Windows, either,
        // which greatly affects our TFTP server since it is NIO-based.
        //
        // It doesn't work on XP/2003 because they share the same separate stack implementation
        // of IPv6 and the dual-stack implementation on Vista is not fully supported.  This will be resolved
        // in JDK7, at least on Vista.  Until then, we should just use the IPv4 address on Windows XP/2003/Vista.
        //
        // Here is the official Sun bug related to this issue: http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=6230761
        if (osName.contains(WINDOWS_STRING))
        {
            return getIpAddress();
        }

        // Initialize the determined IP address to what may have already been specified in the configuration file
        String determinedIpAddress = ipAddress;

        try
        {
            // If we have tried to bind the TFTP to a wildcard address, attempt to retrieve the IPv6 address
            // of the local host.
            if ("0.0.0.0".equals(ipAddress))
            {
                // Get all of the IP addresses associated with the canonical host name of the local machine
                InetAddress localHost = InetAddress.getLocalHost();
                InetAddress[] allByName = InetAddress.getAllByName(localHost.getCanonicalHostName());

                // Iterate through all of the addresses and find the IPv6 address
                boolean foundV6Addr = false;
                for (InetAddress currAddr : allByName)
                {
                    // Test to see if the current InetAddress object represents and IPv6 address.
                    // If so, it is the one we want to use.
                    if (currAddr instanceof Inet6Address)
                    {
                        determinedIpAddress = currAddr.getHostAddress();
                        foundV6Addr = true;
                        break;
                    }
                }

                // If no IPv6 address was found, default to IPv4
                if (!foundV6Addr)
                {
                    determinedIpAddress = localHost.getHostAddress();
                }
            }
        }
        catch (UnknownHostException e)
        {
            throw new RuntimeException(e);
        }

        return determinedIpAddress;
    }

    public int getPort()
    {
        return port;
    }

    // private methods
    private void bind()
    {
        try
        {
            datagramChannel.socket().bind(new InetSocketAddress(ipAddress, port));
            logger.info("TFTP server listening at address: " + ipAddress + ", port: " + port + ".");
        }
        catch (SocketException e)
        {
            logger.error("Failed to bind TFTP server to address: " + ipAddress + ", port: " + port + ".", e);
            throw new WrapperException(e);
        }
    }

    private KeyAttachment att()
    {
        return ServerDatagramAttachment.create(serverCodecFactory, retransmitDelay, retransmitCount, logger, bufferSize);
    }

    public boolean isRequiredFileExists()
    {
        return requireFileExists;
    }
    

    /**
     * Get the best local IP address that isn't a loopback.
     * 
     * Returns IPv4 always if the local hostname maps to a loopback.
     * 
     * @return the best address
     * @throws UnknownHostException if an address can't get found
     */
    private static InetAddress getMyAddress() throws UnknownHostException
    {
        InetAddress localHost = InetAddress.getLocalHost();
        if (localHost.isLoopbackAddress())
        {
            Enumeration<NetworkInterface> networkInterfaces;
            try
            {
                networkInterfaces = NetworkInterface.getNetworkInterfaces();

                while (networkInterfaces.hasMoreElements())
                {
                    NetworkInterface iface = networkInterfaces.nextElement();
                    Enumeration<InetAddress> inetAddresses = iface.getInetAddresses();
                    while (inetAddresses.hasMoreElements())
                    {
                        InetAddress address = inetAddresses.nextElement();
                        if (!address.isLoopbackAddress() && address instanceof Inet4Address)
                        {
                            return address;
                        }
                    }
                }
                return localHost;
            }
            catch (SocketException e)
            {
                return localHost;
            }
        }
        else
        {
            return localHost;
        }
    }

}
