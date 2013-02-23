/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint. Portions created by
 * AlterPoint are Copyright (C) 2006, AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.utils;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.Semaphore;

import org.ziptie.addressing.IPAddress;

/**
 * Provides very simple access to opening TCP ports on remote hosts. This
 * instance keeps a {@link Semaphore} of allowed outbound scans since Windows
 * operating systems will throttle outbound TCP connections if there are 10
 * failures within a second.
 * 
 * @author rkruse
 */
public final class PortScan
{
    private static final int TIMEOUT = 2000;
    private static final int WINDOWS_SEMAPHORES = 8;
    private static final int NORMAL_SEMAPHORES = 100;
    private static PortScan instance;
    private static PrivateMutex privateMutex = new PrivateMutex();

    private Semaphore semaphore;

    /**
     * Private constructor
     */
    private PortScan()
    {
        init();
    }

    /**
     * Retrieves the singleton instance of the <code>PortScan</code>.
     * 
     * @return
     */
    public static PortScan getInstance()
    {
        synchronized (privateMutex)
        {
            if (instance == null)
            {
                instance = new PortScan();
            }
            return instance;
        }
    }

    /**
     * Serially scans the given ports, one after the next.
     * 
     * @param host
     * @param ports
     * @return a list of ports that responded to the connection
     */
    public List<Integer> scan(IPAddress host, Collection<Integer> ports)
    {
        InetAddress address = host.getInetAddress();
        List<Integer> results = new ArrayList<Integer>();
        for (Integer port : ports)
        {
            if (isPortOpen(address, port))
            {
                results.add(port);
            }
        }
        return results;
    }

    /**
     * Check a single port
     * @param host the host to check
     * @param port the port number to check
     * @return true if the TCP port is open, false otherwise
     */
    public boolean isPortOpen(IPAddress host, int port)
    {
        return isPortOpen(host.getInetAddress(), port);
    }

    /**
     * Setup the semaphores
     */
    private void init()
    {
        int semaphoreCount = NORMAL_SEMAPHORES;
        if (System.getProperty("os.name").contains("Windows"))
        {
            semaphoreCount = WINDOWS_SEMAPHORES;
        }
        semaphore = new Semaphore(semaphoreCount);
    }

    /**
     * Used when synchronizing the static call to #getInstance.
     * 
     * @author rkruse
     */
    private static class PrivateMutex
    {
    }

    /**
     * Check a single port
     * 
     * @param address
     * @param portToScan
     * @return
     */
    private boolean isPortOpen(InetAddress address, Integer portToScan)
    {
        boolean portOpen = false;
        Socket socket = null;
        try
        {
            semaphore.acquire();
            InetSocketAddress endpoint = new InetSocketAddress(address, portToScan);
            socket = new Socket();
            socket.setSoTimeout(TIMEOUT);
            socket.connect(endpoint, TIMEOUT);
            portOpen = true;
        }
        catch (java.io.IOException e)
        {
            portOpen = false;
        }
        catch (InterruptedException e)
        {
            portOpen = false;
        }
        finally
        {
            semaphore.release();
            try
            {
                if (socket != null)
                {
                    socket.close();
                }
            }
            catch (java.io.IOException e)
            {
                e.printStackTrace();
            }
        }
        return portOpen;
    }
}
