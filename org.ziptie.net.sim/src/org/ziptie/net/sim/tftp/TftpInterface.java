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

package org.ziptie.net.sim.tftp;

import java.io.IOException;
import java.io.InputStream;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;

import org.apache.commons.net.DefaultDatagramSocketFactory;
import org.apache.commons.net.tftp.TFTPClient;
import org.ziptie.net.sim.util.IpAddress;

/**
 * API for the TFTP Client
 */
public class TftpInterface
{
    private static final int TIMEOUT = 30000; // 30 second timeout

    private static TftpInterface instance;

    public static synchronized TftpInterface getInstance()
    {
        if (instance == null)
        {
            instance = new TftpInterface();
        }
        return instance;
    }

    private TftpInterface()
    {
    }

    public void sendFile(IpAddress localIp, IpAddress remoteIp, String filename, InputStream file) throws UnknownHostException, IOException
    {
        TFTPClient client = null;
        try
        {
            client = new TFTPClient();
            client.setDatagramSocketFactory(new SocketFactory(localIp.getRealAddress()));
            client.open();
            client.sendFile(filename, TFTPClient.BINARY_MODE, file, remoteIp.getIp());
        }
        finally
        {
            try
            {
                client.close();
            }
            catch (NullPointerException e)
            {
            }
        }
    }

    /**
     * A DatagramSocket factory which creates sockets which bind on a specified local interface
     */
    private class SocketFactory extends DefaultDatagramSocketFactory
    {
        private InetAddress localAddr;

        /**
         * @param localIp The local interface to bind on
         */
        public SocketFactory(InetAddress localIp)
        {
            localAddr = localIp;
        }

        public DatagramSocket createDatagramSocket(int port) throws SocketException
        {
            return createDatagramSocket(port, localAddr);
        }

        public DatagramSocket createDatagramSocket() throws SocketException
        {
            return createDatagramSocket(0);
        }

        /* (non-Javadoc)
         * @see org.apache.commons.net.DefaultDatagramSocketFactory#createDatagramSocket(int, java.net.InetAddress)
         */
        public DatagramSocket createDatagramSocket(int port, InetAddress laddr) throws SocketException
        {
            DatagramSocket sock = super.createDatagramSocket(port, laddr);
            sock.setSoTimeout(TIMEOUT);
            return sock;
        }
    }
}
