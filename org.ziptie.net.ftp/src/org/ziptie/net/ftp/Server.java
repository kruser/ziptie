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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.ftp;

import java.io.File;
import java.io.FileInputStream;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.URI;
import java.net.UnknownHostException;
import java.util.Collection;

import org.apache.ftpserver.FtpConfigImpl;
import org.apache.ftpserver.config.PropertiesConfiguration;
import org.apache.ftpserver.ftplet.FtpException;
import org.apache.ftpserver.ftplet.UserManager;
import org.apache.ftpserver.interfaces.IFtpConfig;
import org.apache.log4j.Logger;

/**
 * Server is an FTP server.
 */
public final class Server
{
    private static final String WINDOWS_STRING = "indows"; //$NON-NLS-1$

    private static FtpServerWrapper server;

    private Server()
    {
        // hide constructor
    }

    /**
     * Start the FTP server.
     * @param config The configuration to use.
     */
    @SuppressWarnings("unchecked")
    public static void start(IFtpConfig config)
    {
        try
        {
            if (server == null || server.getFtpConfig() == null)
            {
                server = new FtpServerWrapper(config);
            }

            Logger.getLogger(Server.class).info("Start FTP server, bind to port " + server.getFtpConfig().getServerPort());

            server.start();

            for (String username : (Collection<String>) server.getFtpConfig().getUserManager().getAllUserNames())
            {
                File homeDir = new File(server.getFtpConfig().getUserManager().getUserByName(username).getHomeDirectory());
                if (!homeDir.exists())
                {
                    homeDir.mkdirs();
                }
            }
        }
        catch (RuntimeException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Start the FTP server.
     * @param configURI a file URI for the configuration properties file
     */
    public static void start(URI configURI)
    {
        if (null == server || null == server.getFtpConfig())
        {
            try
            {
                start(new FtpConfigImpl(new PropertiesConfiguration(new FileInputStream(new File(configURI)))));
            }
            catch (RuntimeException e)
            {
                throw e;
            }
            catch (Exception e)
            {
                throw new RuntimeException(e);
            }
        }
    }

    /**
     * Stop the FTP server.
     */
    public static void stop()
    {
        if (server != null && !server.isStopped())
        {
            server.stop();
        }
    }

    /**
     * @return the home directory of the anonymous user
     */
    public static String getAdminUserHomeDirectory()
    {
        try
        {
            UserManager userManager = server.getFtpConfig().getUserManager();
            String adminName = userManager.getAdminName();
            return userManager.getUserByName(adminName).getHomeDirectory();
        }
        catch (FtpException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * @return the port that the server is bound to
     */
    public static int getPort()
    {
        return server.getFtpConfig().getServerPort();
    }

    /**
     * Retrieves the IP address for the FTP server.
     * 
     * @return The IP address for the FTP server.
     */
    public static String getIpAddress()
    {
        InetAddress serverAddress = server.getFtpConfig().getServerAddress();
        String ipAddress = "";

        if (serverAddress != null)
        {
            ipAddress = serverAddress.getHostAddress();
        }
        else
        {
            InetAddress activeLocalAddress = server.getFtpConfig().getDataConnectionConfig().getActiveLocalAddress();

            if (activeLocalAddress != null)
            {
                ipAddress = activeLocalAddress.getHostAddress();
            }
        }

        return ipAddress;
    }

    /**
     * Attempts to retrieve the IPv6 address for the FTP server.  If an IP address is specified in the
     * configuration file for the FTP server, that will take precedence above all else.  Otherwise, we
     * will test to see if the FTP server is running locally and if so, we will attempt to get the IPv6
     * address for the local machine.
     * 
     * @return The IPv6 address of the local machine running the FTP server or an IPv4/IPv6 address specified
     * in the FTP server configuration file.
     */
    public static String getIpV6Address()
    {
        InetAddress serverAddress = server.getFtpConfig().getServerAddress();
        String determinedIpAddress = "";

        if (serverAddress != null)
        {
            determinedIpAddress = serverAddress.getHostAddress();
        }
        else
        {
            try
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
                String osName = System.getProperty("os.name"); //$NON-NLS-1$

                if (osName.contains(WINDOWS_STRING))
                {
                    return getIpAddress();
                }

                // Get all of the IP addresses associated with the canonical host name of the local machine
                InetAddress localHost = server.getFtpConfig().getDataConnectionConfig().getActiveLocalAddress();
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
            catch (UnknownHostException e)
            {
                throw new RuntimeException(e);
            }
        }

        return determinedIpAddress;
    }
}
