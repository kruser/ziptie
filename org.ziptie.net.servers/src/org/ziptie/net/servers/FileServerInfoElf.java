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
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s): Leo Bayer (lbayer@ziptie.org), Dylan White (dylamite@ziptie.org)
 */
package org.ziptie.net.servers;

import org.ziptie.net.ftp.Server;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServerImpl;

/**
 * The {@link FileServerInfoElf} class provides easy access to the IP, port, and root directory information
 * for the TFTP and FTP servers controlled by ZipTie.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public final class FileServerInfoElf
{
    /**
     * Private default constructor for disabling any explicit creation of a {@link FileServerInfoElf} instance.
     */
    private FileServerInfoElf()
    {
        // Do nothing.
    }

    /**
     * Retrieves the IP address used to access the ZipTie TFTP server.
     * 
     * @return A string representation of the IP address of the ZipTie TFTP server.
     */
    public static String getTFTPServerIpAddress()
    {
        TftpServerImpl tftpServer = NetServerActivator.getTftpServer();
        return tftpServer != null ? tftpServer.getIpAddress() : null;
    }

    /**
     * Retrieves the IPv6 address used to access the ZipTie TFTP server.
     * This will only retrieve a valid IPv6 address is the TFTP server is running on the same
     * machine as the ZipTie server and the IPv6 protocol is enabled.
     * 
     * @return A string representation of the IPv6 address of the ZipTie TFTP server.
     */
    public static String getTFTPServerIpV6Address()
    {
        TftpServerImpl tftpServer = NetServerActivator.getTftpServer();
        return tftpServer != null ? tftpServer.getIpV6Address() : null;
    }

    /**
     * Retrieves the port that the ZipTie TFTP server is bound to.
     * 
     * @return The port that the ZipTie TFTP server is bound to.
     */
    public static int getTFTPServerPort()
    {
        TftpServerImpl tftpServer = NetServerActivator.getTftpServer();
        return tftpServer != null ? tftpServer.getPort() : 0;
    }

    /**
     * Retrieves the root directory of the ZipTie TFTP server.
     * 
     * @return The root directory of the ZipTie TFTP server.
     */
    public static String getTFTPServerRootDir()
    {
        TftpServerImpl tftpServer = NetServerActivator.getTftpServer();
        return tftpServer != null ? tftpServer.getDirectory() : null;
    }

    /**
     * Retrieves the IP address used to access the ZipTie FTP server.
     * 
     * @return A string representation of the IP address of the ZipTie FTP server.
     */
    public static String getFTPServerIpAddress()
    {
        return Server.getIpAddress();
    }

    /**
     * Retrieves the IP address used to access the ZipTie FTP server.
     * This will only retrieve a valid IPv6 address is the FTP server is running on the same
     * machine as the ZipTie server and the IPv6 protocol is enabled.
     * 
     * @return A string representation of the IPv6 address of the ZipTie FTP server.
     */
    public static String getFTPServerIpV6Address()
    {
        return Server.getIpV6Address();
    }

    /**
     * Retrieves the port that the ZipTie FTP server is bound to.
     * 
     * @return The port that the ZipTie FTP server is bound to.
     */
    public static int getFTPServerPort()
    {
        return Server.getPort();
    }

    /**
     * Retrieves the root directory of the ZipTie FTP server.
     * 
     * @return The root directory of the ZipTie FTP server.
     */
    public static String getFTPServerRootDir()
    {
        return Server.getAdminUserHomeDirectory();
    }

    /**
     * Get the username of the FTP server.
     * @return the username
     */
    public static String getFTPUsername()
    {
        return null;
    }

    /**
     * Get the password of the FTP server.
     * @return the password
     */
    public static String getFTPPassword()
    {
        return null;
    }
}
