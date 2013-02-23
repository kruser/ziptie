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
 * Portions created by AlterPoint are Copyright (C) 2006, 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s): Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.server.job.backup;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.net.client.ConnectionPath;
import org.ziptie.net.client.Credential;
import org.ziptie.net.client.Credentials;
import org.ziptie.net.client.FileServer;
import org.ziptie.net.client.FileServers;
import org.ziptie.net.client.Protocol;
import org.ziptie.net.client.Protocols;
import org.ziptie.net.utils.FileServerInfo;
import org.ziptie.protocols.ProtocolNames;
import org.ziptie.protocols.ProtocolSet;

/**
 * The <code>ConnectionPathElf</code> class provides a number of helper functions for converting host/IP information and
 * internal ZipTie <code>Protocol</code>, and <code>Credential</code> objects into a SOAP-compatible
 * <code>ConnectionPath</code> object that can be used by web services to describe all of the information needed to connect
 * to a device.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public final class ConnectionPathElf
{
    // Specifies the environment variable names for FTP server information
    public static final String FTP_SERVER_IP_ENV = "FTP_SERVER_IP"; //$NON-NLS-1$
    public static final String FTP_SERVER_IP_V6_ENV = "FTP_SERVER_IP_V6";; //$NON-NLS-1$
    public static final String FTP_SERVER_PORT_ENV = "FTP_SERVER_PORT"; //$NON-NLS-1$
    public static final String FTP_SERVER_DIR_ENV = "FTP_SERVER_DIR"; //$NON-NLS-1$

    // Specifies the environment variable names for TFTP server information
    public static final String TFTP_SERVER_IP_ENV = "TFTP_SERVER_IP"; //$NON-NLS-1$
    public static final String TFTP_SERVER_IP_V6_ENV = "TFTP_SERVER_IP_V6";; //$NON-NLS-1$
    public static final String TFTP_SERVER_PORT_ENV = "TFTP_SERVER_PORT"; //$NON-NLS-1$
    public static final String TFTP_SERVER_DIR_ENV = "TFTP_SERVER_DIR"; //$NON-NLS-1$

    // Specifies the name of various server properties
    public static final String SERVER_ROOT_DIR = "serverRootDir"; //$NON-NLS-1$
    public static final String SERVER_PORT = "serverPort"; //$NON-NLS-1$
    public static final String SERVER_IP = "serverIp"; //$NON-NLS-1$

    /**
     * Private default constructor for the <code>ConnectionPathElf</code> class in order to hide it from being used.
     */
    private ConnectionPathElf()
    {
        // Does nothing
    }

    /**
     * Generates a SOAP-compatible <code>ConnectionPath</code> object from the specified host/IP string,
     * <code>Protocol</code>, and <code>Credential</code> objects.  All of the parameters must be valid and specified, or else
     * a valid SOAP-compatible <code>ConnectionPath</code> object will not be generated.
     * 
     * @param host The host/IP address of the device to connect to.
     * @param ziptieProtocolSet The internal ZipTie <code>ProtocolSet</code> object to use against the device specified by the IP
     * address.  All of the <code>Protocol</code> objects specified in the <code>ProtocolSet</code> will be converted into
     * SOAP-compatible equivalents.
     * @param ziptieCredentialSet The internal ZipTie <code>CredentialSet</code> object to use against the device specified by the IP
     * address.  All of the <code>Credential</code> objects specified in the <code>CredentialSet</code> will be converted into
     * SOAP-compatible equivalents.
     * 
     * @return A valid SOAP-compatible <code>ConnectionPath</code> object if all of the parameters specified were valid; otherwise;
     * a valid SOAP-compatible <code>ConnectionPath</code> object will not be generated and <code>null</code> will be returned.
     */
    // CHECKSTYLE:OFF - suppress cyclomatic complexity warning
    public static ConnectionPath generateSoapConnectionPath(String host, ProtocolSet ziptieProtocolSet, CredentialSet ziptieCredentialSet)
    {
        // CHECKSTYLE:ON

        // Only attempt to generate a SOAP-compatible connection path object if the host, protocol set, and credential set
        // specified are all valid
        if (host == null || ziptieProtocolSet == null || ziptieCredentialSet == null)
        {
            return null;
        }

        // Determine whether or not the host we are trying to connect to is a IPv4 or IPv6 compatible device
        boolean useIPv6 = (NetworkAddressElf.isValidIpAddress(host) && NetworkAddressElf.isIPv6AddressOrMask(host)) ? true : false;

        // Create a new SOAP-compatible connection path object
        ConnectionPath connectionPath = new ConnectionPath();

        // Set the host on the connection path
        connectionPath.setHost(host);

        // Convert the internal ZipTie protocol set object into an array of SOAP-compatible protocol objects
        Protocol[] soapProtocols = ProtocolElf.convertProtocolsToSoapProtocols(ziptieProtocolSet);
        Protocols protos = new Protocols();
        Collections.addAll(protos.getProtocol(), soapProtocols);
        connectionPath.setProtocols(protos);

        // Convert the internal ZipTie credential set object into an array of SOAP-compatible credential objects
        Credential[] soapCredentials = CredentialElf.convertCredentialsToSoapCredentials(ziptieCredentialSet);
        Credentials creds = new Credentials();
        Collections.addAll(creds.getCredential(), soapCredentials);
        connectionPath.setCredentials(creds);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //
        // Special case: Add on ZipTie TFTP and FTP server information if the protocol is either TFTP or FTP
        // TODO dwhite: See if there is a more elegant way to do this.
        //
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // Create a list to store all the file server metadata found
        List<FileServer> listOfFileServers = new ArrayList<FileServer>();

        for (Protocol soapProtocol : soapProtocols)
        {
            // Add TFTP server info
            if (soapProtocol.getName().equalsIgnoreCase("TFTP")) //$NON-NLS-1$
            {
                FileServerInfo tftpFileServerInfo = getTftpFileServerInfo(useIPv6);
                FileServer tftpFileServer = new FileServer();
                tftpFileServer.setProtocol(tftpFileServerInfo.getProtocolName());
                tftpFileServer.setRootDir(tftpFileServerInfo.getRootDir());
                tftpFileServer.setIp(tftpFileServerInfo.getIp());
                tftpFileServer.setPort(tftpFileServerInfo.getPort());

                // Add TFTP server info to the list of file server information
                listOfFileServers.add(tftpFileServer);
            }

            // Add FTP server info
            else if (soapProtocol.getName().equalsIgnoreCase("FTP")) //$NON-NLS-1$
            {
                FileServerInfo ftpFileServerInfo = getFtpFileServerInfo(useIPv6);
                FileServer ftpFileServer = new FileServer();
                ftpFileServer.setProtocol(ftpFileServerInfo.getProtocolName());
                ftpFileServer.setRootDir(ftpFileServerInfo.getRootDir());
                ftpFileServer.setIp(ftpFileServerInfo.getIp());
                ftpFileServer.setPort(ftpFileServerInfo.getPort());

                // Add FTP server info to the list of file server information
                listOfFileServers.add(ftpFileServer);
            }

            FileServers fileServers = new FileServers();
            fileServers.getFileServer().addAll(listOfFileServers);

            // Add file server information to the connection path
            connectionPath.setFileServers(fileServers);
        }

        // Return the generated ConnectionPath object
        return connectionPath;
    }

    /**
     * Get the details of the TFTP server
     * 
     * @param useIPv6 Whether or not to retrieve the possible IPv6 address of the machine running
     * the TFTP server as opposed to the IPv4 address.
     * @return the details of the TFTP server
     */
    public static FileServerInfo getTftpFileServerInfo(boolean useIPv6)
    {
        // TODO: rkruse - this should be handled via an extension point, not system properties
        FileServerInfo tftpFileServer = new FileServerInfo();
        tftpFileServer.setProtocolName(ProtocolNames.TFTP.name());

        // Add the TFTP server's root/home directory as a property
        String serverRootDir = System.getProperty(TFTP_SERVER_DIR_ENV);
        if (serverRootDir != null)
        {
            tftpFileServer.setRootDir(serverRootDir);
        }

        // Add the TFTP server's IP address as a property
        String serverIPv4 = System.getProperty(TFTP_SERVER_IP_ENV);
        String serverIPv6 = System.getProperty(TFTP_SERVER_IP_V6_ENV);

        // Attempt to use IPv6 communication
        if (useIPv6)
        {
            // If the IPv6 address is available, use it
            if (serverIPv6 != null)
            {
                tftpFileServer.setIp(serverIPv6);
            }
            // Otherwise, default to the IPv4 address
            else if (serverIPv4 != null)
            {
                tftpFileServer.setIp(serverIPv4);
            }
        }
        else
        {
            // Only attempt to use the IPv4 address
            if (serverIPv4 != null)
            {
                tftpFileServer.setIp(serverIPv4);
            }
        }

        // Add the TFTP server's port as a property
        String serverPort = System.getProperty(TFTP_SERVER_PORT_ENV);
        if (serverPort != null)
        {
            tftpFileServer.setPort(Integer.parseInt(serverPort));
        }
        return tftpFileServer;
    }

    /**
     * Get the FTP server data
     * 
     * @param useIPv6 Whether or not to retrieve the possible IPv6 address of the machine running
     * the FTP server as opposed to the IPv4 address.
     * @return the details of the FTP server
     */
    public static FileServerInfo getFtpFileServerInfo(boolean useIPv6)
    {
        // TODO: rkruse - this should be handled via an extension point, not system properties
        FileServerInfo ftpFileServer = new FileServerInfo();
        ftpFileServer.setProtocolName(ProtocolNames.FTP.name());

        // Add the FTP server's root/home directory as a property
        String serverRootDir = System.getProperty(FTP_SERVER_DIR_ENV);
        if (serverRootDir != null)
        {
            ftpFileServer.setRootDir(serverRootDir);
        }

        // Add the FTP server's IP address as a property
        String serverIPv4 = System.getProperty(FTP_SERVER_IP_ENV);
        String serverIPv6 = System.getProperty(FTP_SERVER_IP_V6_ENV);

        // Attempt to use IPv6 communication
        if (useIPv6)
        {
            // If the IPv6 address is available, use it
            if (serverIPv6 != null)
            {
                ftpFileServer.setIp(serverIPv6);
            }
            // Otherwise, default to the IPv4 address
            else if (serverIPv4 != null)
            {
                ftpFileServer.setIp(serverIPv4);
            }
        }
        else
        {
            // Only attempt to use the IPv4 address
            if (serverIPv4 != null)
            {
                ftpFileServer.setIp(serverIPv4);
            }
        }

        // Add the FTP server's port as a property
        String serverPort = System.getProperty(FTP_SERVER_PORT_ENV);
        if (serverPort != null)
        {
            ftpFileServer.setPort(Integer.parseInt(serverPort));
        }
        return ftpFileServer;
    }
}
