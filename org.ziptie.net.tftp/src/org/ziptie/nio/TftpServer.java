package org.ziptie.nio;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.util.Properties;

import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.ziptie.nio.common.Log4jLogger;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServerImpl;

public class TftpServer
{

    /**
     * @param args
     * @throws IOException 
     * @throws FileNotFoundException 
     * @throws InterruptedException 
     */
    public static void main(String[] args) throws FileNotFoundException, IOException, InterruptedException
    {
        TftpServer server = new TftpServer();
        server.setupLog4j();
        server.startTftpd();
        Thread.sleep(100000000);
    }
    
    private void setupLog4j()
    {
        Logger root = Logger.getRootLogger();
        root.addAppender(new ConsoleAppender(new PatternLayout("%d{ISO8601} %-5p: %X{metadata} %m%n"), ConsoleAppender.SYSTEM_ERR));
        root.setLevel(Level.DEBUG);
    }

    private void startTftpd() throws FileNotFoundException, IOException
    {
        File conf = new File("c:\\Dev\\ziptie\\HEAD\\conf");
        File scratch = new File("c:\\Dev\\ziptie\\HEAD\\conf\\scratch");
        URI configRoot = conf.toURI();
        URI scratchURI = scratch.toURI();

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
                System.out.println("TFTP root directory, '" + tftpRootDir.getAbsolutePath() + "' doesn't exist....creating.");
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

        // Create a basic TFTP server and start it
        TftpServerImpl tftpServer = new TftpServerImpl(tftpProps, tftpLogger);
        tftpServer.start();

        System.out.println("TFTP server started");
    }

}
