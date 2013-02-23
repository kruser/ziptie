/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2008,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.adaptertool;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

import org.apache.ftpserver.FtpConfigImpl;
import org.apache.ftpserver.config.PropertiesConfiguration;
import org.apache.ftpserver.ftplet.UserManager;
import org.apache.ftpserver.interfaces.IFtpConfig;
import org.apache.ftpserver.usermanager.BaseUser;
import org.ziptie.net.ftp.Server;
import org.ziptie.net.utils.FileServerInfo;
import org.ziptie.nio.common.Log4jLogger;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServerImpl;

/**
 * Manages the TFTP and FTP servers.
 */
public final class FileServerElf
{
    private static Log4jLogger tftpLogger;
    private static TftpServerImpl tftpServer;

    private FileServerElf()
    {
    }

    /**
     * 
     * @return the unstarted TFTP server instance
     * @throws IOException if there was an error reading the config
     */
    public static TftpServerImpl getTftpServer() throws IOException
    {
        tftpLogger = new Log4jLogger("TFTPServer"); //$NON-NLS-1$

        Properties props = new Properties();
        props.load(new FileInputStream("conf/tftp.properties")); //$NON-NLS-1$

        File tftpRootDir;
        String dir = props.getProperty(TftpServerImpl.ROOT_DIRECTORY);
        if (dir != null)
        {
            tftpRootDir = new File(dir);
        }
        else
        {
            tftpRootDir = new File("ftroot"); //$NON-NLS-1$
            if (!tftpRootDir.exists())
            {
                tftpRootDir.mkdirs();
            }

            // Make sure to set the TFTP root dir as a property
            props.setProperty(TftpServerImpl.ROOT_DIRECTORY, tftpRootDir.getAbsolutePath());
        }

        // If the TFTP scratch directory does not exist within the configuration root directory, then create it
        if (!tftpRootDir.exists() || !tftpRootDir.isDirectory())
        {
            tftpRootDir.mkdir();
        }

        return new TftpServerImpl(props, tftpLogger);
    }

    /**
     * Starts the FTP server.
     * 
     * @param useIPv6 Whether or not to retrieve the possible IPv6 address of the machine running
     * the FTP server as opposed to the IPv4 address.
     * @return The file server description.
     * @throws Exception on error
     */
    public static FileServerInfo startFtpd(boolean useIPv6) throws Exception
    {
        IFtpConfig config = getFtpServerConfig();

        Server.start(config);

        return getFtpServerInfo(useIPv6);
    }

    /**
     * Start the TFTP server.
     * @param useIPv6 Whether or not to retrieve the possible IPv6 address of the machine running
     * the TFTP server as opposed to the IPv4 address.
     * @return The file server description.
     * @throws IOException If the TFTP properties are unable to load.
     */
    public static FileServerInfo startTftpd(boolean useIPv6) throws IOException
    {
        tftpServer = getTftpServer();
        tftpServer.start();

        return getTftpServerInfo(tftpServer, useIPv6);
    }

    /**
     * Get the file server info for the FTP server.
     * 
     * @param useIPv6 Whether or not to retrieve the possible IPv6 address of the machine running
     * the FTP server as opposed to the IPv4 address.
     * @return The FTP {@link FileServerInfo}
     */
    public static FileServerInfo getFtpServerInfo(boolean useIPv6)
    {
        return new FileServerInfo("FTP", useIPv6 ? Server.getIpV6Address() : Server.getIpAddress(), Server.getPort(), "ftroot"); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * 
     * @param server the TFTP server implementation
     * @param useIPv6 Whether or not to retrieve the possible IPv6 address of the machine running
     * the TFTP server as opposed to the IPv4 address.
     * @return the FileServerInfo
     */
    public static FileServerInfo getTftpServerInfo(TftpServerImpl server, boolean useIPv6)
    {
        return new FileServerInfo("TFTP", useIPv6 ? server.getIpV6Address() : server.getIpAddress(), server.getPort(), server.getDirectory()); //$NON-NLS-1$
    }

    private static IFtpConfig getFtpServerConfig() throws Exception
    {
        Properties ftpProps = new Properties();
        ftpProps.setProperty("config.user-manager.prop-file", "conf/ftp-users.gen-config"); //$NON-NLS-1$//$NON-NLS-2$
        ftpProps.setProperty("config.ip-restrictor.file", "conf/ftp-ip.gen-config"); //$NON-NLS-1$//$NON-NLS-2$
        ftpProps.load(new FileInputStream(new File("conf/ftpd.properties"))); //$NON-NLS-1$

        // Create a FTP configuration from the properties and start the FTP server
        IFtpConfig ftpConfig = new FtpConfigImpl(new PropertiesConfiguration(ftpProps));

        UserManager man = ftpConfig.getUserManager();
        for (Object next : man.getAllUserNames())
        {
            String username = (String) next;
            BaseUser usr = (BaseUser) man.getUserByName(username);
            usr.setHomeDirectory("ftroot/" + username); //$NON-NLS-1$
            man.save(usr);
        }

        return ftpConfig;
    }

    /**
     * Shutdown the TFTP and FTP servers if they are running.
     *
     */
    public static void shutDownServers()
    {
        if (tftpServer != null)
        {
            tftpServer.stop();
            tftpServer = null;
        }

        Server.stop();
    }
}
