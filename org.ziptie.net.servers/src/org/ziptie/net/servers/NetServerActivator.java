package org.ziptie.net.servers;

import java.io.File;
import java.io.FileInputStream;
import java.net.URI;
import java.util.Properties;

import org.apache.ftpserver.FtpConfigImpl;
import org.apache.ftpserver.config.PropertiesConfiguration;
import org.apache.ftpserver.interfaces.IFtpConfig;
import org.apache.log4j.Logger;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.ziptie.net.ftp.Server;
import org.ziptie.nio.common.Log4jLogger;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServerImpl;

/**
 * Activator that starts the standard Network Servers like TFTP and FTP.
 */
@SuppressWarnings("nls")
public class NetServerActivator implements BundleActivator
{
    private static final Logger LOGGER = Logger.getLogger(NetServerActivator.class);

    private static final String TFTP_SERVER_IP_ENV = "TFTP_SERVER_IP"; //$NON-NLS-1$
    private static final String TFTP_SERVER_IP_V6_ENV = "TFTP_SERVER_IP_V6"; //$NON-NLS-1$
    private static final String TFTP_SERVER_PORT_ENV = "TFTP_SERVER_PORT"; //$NON-NLS-1$
    private static final String TFTP_SERVER_DIR_ENV = "TFTP_SERVER_DIR"; //$NON-NLS-1$

    private static final String FTP_SERVER_IP_ENV = "FTP_SERVER_IP"; //$NON-NLS-1$
    private static final String FTP_SERVER_IP_V6_ENV = "FTP_SERVER_IP_V6"; //$NON-NLS-1$
    private static final String FTP_SERVER_PORT_ENV = "FTP_SERVER_PORT"; //$NON-NLS-1$
    private static final String FTP_SERVER_DIR_ENV = "FTP_SERVER_DIR"; //$NON-NLS-1$

    private static final String WINDOWS_STRING = "indows"; //$NON-NLS-1$

    private static TftpServerImpl tftpServer;

    private String osName;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        // Retrieve the OS name
        osName = System.getProperty("os.name"); //$NON-NLS-1$
        String configArea = System.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        startTftpd(configArea);
        startFtpd(configArea);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        try
        {
            tftpServer.stop();
            tftpServer = null;
            LOGGER.info("TFTP stopped.");

            Server.stop();
            LOGGER.info("FTP stopped.");
        }
        catch (Exception e)
        {
            LOGGER.error("Error stopping net servers.", e);
        }
    }

    /**
     * Retrieves the TFTP Server object that represents the ZipTie TFTP server.
     * 
     * @return The {@link TftpServerImpl} object that represents the ZipTie TFTP server.
     */
    public static TftpServerImpl getTftpServer()
    {
        return tftpServer;
    }

    private void startFtpd(String configArea)
    {
        try
        {
            Properties ftpProps = new Properties();
            ftpProps.load(new FileInputStream(new File(URI.create(configArea + "/network/ftpd.properties")))); //$NON-NLS-1$

            // Special case:  On Windows, make sure we bind to port 21
            // TODO dwhite: Remove this hack when we are sure the the ftpd.properties file is setup
            if (osName.contains(WINDOWS_STRING))
            {
                ftpProps.setProperty("config.socket-factory.port", "21");  //$NON-NLS-1$//$NON-NLS-2$
            }

            if (Boolean.parseBoolean(ftpProps.getProperty("config.start-server"))) //$NON-NLS-1$
            {
                // Create a FTP config from the properties and start the FTP server
                IFtpConfig ftpConfig = new FtpConfigImpl(new PropertiesConfiguration(ftpProps));
                Server.start(ftpConfig);

                // Now that the FTP server has started successfully, let's "publish" information about our FTP server
                // to some well defined environment variables
                publishFTPInformation();
                LOGGER.info("FTP Server started.");
            }
            else
            {
                LOGGER.info("FTP Server is disabled.");
            }
        }
        catch (Exception e)
        {
            LOGGER.error("FTP start failed.", e);
        }
    }

    private void startTftpd(String configArea)
    {
        try
        {
            URI configRoot = URI.create(configArea);
            URI scratchURI = URI.create(configArea + "/scratch"); //$NON-NLS-1$

            Log4jLogger tftpLogger = new Log4jLogger("TFTPServer"); //$NON-NLS-1$

            // Grab the TFTP properties file
            // Create a new TftpProperties object using the TFTP properties file
            Properties tftpProps = new Properties();

            URI tftpConfigURI = URI.create(configRoot.toASCIIString() + "/network/tftp.properties"); //$NON-NLS-1$
            tftpProps.load(new FileInputStream(new File(tftpConfigURI)));

            File tftpRootDir;

            String dir = tftpProps.getProperty(TftpServerImpl.ROOT_DIRECTORY);
            if (dir != null)
            {
                tftpRootDir = new File(dir);
            }
            else
            {
                // Specifiy the root directory for the TFTP server if there is no property set for it,
                // which will be the "scratch/tftp" directory within the conf bundle.s
                //
                // If a different root directory has been specified within the TFTP properties file, use that.
                // Other wise, use the ZipTie specific TFTP server root directory.
                URI tftpRootURI = URI.create(scratchURI.toASCIIString() + "/tftp"); //$NON-NLS-1$
                tftpRootDir = new File(tftpRootURI);
                if (!tftpRootDir.exists())
                {
                    LOGGER.info("TFTP root directory, '" + tftpRootDir.getAbsolutePath() + "' doesn't exist....creating.");
                    tftpRootDir.mkdirs();
                }

                // Make sure to set the TFTP root dir as a property
                tftpProps.setProperty(TftpServerImpl.ROOT_DIRECTORY, tftpRootDir.getAbsolutePath());
            }

            // If the TFTP scratch directory does not exist within the configuration root directory, then create it
            if (!tftpRootDir.exists() || !tftpRootDir.isDirectory())
            {
                tftpRootDir.mkdir();
            }

            // Special case:  On Windows, make sure we bind to port 69
            // TODO dwhite: Remove this hack when we are sure the the tftp.properties file is setup
            if (osName.contains(WINDOWS_STRING))
            {
                tftpProps.setProperty(TftpServerImpl.PORT, "69"); //$NON-NLS-1$
            }

            if (Boolean.parseBoolean(tftpProps.getProperty(TftpServerImpl.START_SERVER)))
            {
                // Create a basic TFTP server and start it
                tftpServer = new TftpServerImpl(tftpProps, tftpLogger);
                tftpServer.start();

                // Now that the TFTP server has started successfully, let's "publish" information about our TFTP server
                // to some well defined environment variables
                String returnAddress = tftpProps.getProperty("returnAddress"); //$NON-NLS-1$
                if (returnAddress == null)
                {
                    returnAddress = tftpServer.getIpAddress();
                }

                publishTFTPInformation(tftpServer.getDirectory(), returnAddress, tftpServer.getPort());

                LOGGER.info("TFTP server started.");
            }
            else
            {
                LOGGER.info("TFTP server is disabled.");
            }

        }
        catch (Exception e)
        {
            LOGGER.error("TFTP start failed", e);
        }
    }

    /**
     * Attempts to "publish" information about the FTP server to the world through environment variables.  Specifically,
     * the FTP server IP address will be published to <code>FTP_SERVER_IP</code>, the FTP server port will be published
     * to <code>FTP_SERVER_PORT</code>, and the FTP server directory will be published to <code>FTP_SERVER_DIR</code>.
     */
    private void publishFTPInformation()
    {
        String dir = Server.getAdminUserHomeDirectory();
        String ipAddress = Server.getIpAddress();
        int port = Server.getPort();

        if (dir != null)
        {
            System.setProperty(FTP_SERVER_DIR_ENV, dir);
        }

        if (ipAddress != null)
        {
            System.setProperty(FTP_SERVER_IP_ENV, ipAddress);
        }
        
        String ipV6Address = Server.getIpV6Address();
        if (ipV6Address != null)
        {
            System.setProperty(FTP_SERVER_IP_V6_ENV, ipV6Address);
        }

        System.setProperty(FTP_SERVER_PORT_ENV, Integer.toString(port));
    }

    /**
     * Attempts to "publish" information about the TFTP server to the world through environment variables.  Specifically,
     * the TFTP server IP address will be published to <code>TFTP_SERVER_IP</code>, the TFTP server port will be published
     * to <code>TFTP_SERVER_PORT</code>, and the TFTP server directory will be published to <code>TFTP_SERVER_DIR</code>.
     */
    private void publishTFTPInformation(String dir, String ipAddress, int port)
    {
        if (dir != null)
        {
            System.setProperty(TFTP_SERVER_DIR_ENV, dir);
        }

        if (ipAddress != null)
        {
            System.setProperty(TFTP_SERVER_IP_ENV, ipAddress);
        }
        
        String ipV6Address = tftpServer.getIpV6Address();
        if (ipV6Address != null)
        {
            System.setProperty(TFTP_SERVER_IP_V6_ENV, ipV6Address);
        }

        System.setProperty(TFTP_SERVER_PORT_ENV, Integer.toString(port));
    }
}
