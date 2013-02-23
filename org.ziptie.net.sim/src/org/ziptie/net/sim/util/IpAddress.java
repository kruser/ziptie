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

package org.ziptie.net.sim.util;

import java.net.InetAddress;

/**
 * Abstracts IP Addresses
 * <p> The 'RealAddress' is what we use to actually communicate to the host.
 * <p> The ip is the ip name we use during communication.
 */
public class IpAddress
{
    private String ip;
    private InetAddress real;

    public IpAddress(InetAddress addr)
    {
        real = addr;
        ip = addr.getHostAddress();
    }

    public IpAddress(InetAddress real, String ip)
    {
        this.ip = ip;
        this.real = real;
    }

    public String getIp()
    {
        return ip;
    }

    public InetAddress getRealAddress()
    {
        return real;
    }

    public int getIntValue()
    {
        return Util.intify(ip);
    }

    public String toString()
    {
        return ip;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    public int hashCode()
    {
        return real.hashCode();
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public boolean equals(Object obj)
    {
        try
        {
            IpAddress other = (IpAddress) obj;
            return ip.equals(other.ip) && real.equals(other.real);
        }
        catch (ClassCastException e)
        {
            return false;
        }
    }

    /**
     * Gets a usable IpAddress given an InetAddress and a displayIp address.
     * If <code>addr</code> is a loopback address it will be replaced with the result of {@link Util#getLocalHost()}.
     * @param addr The address which should be used in network operations.
     * @param displayIp The address to use for configuration and display or <code>null</code> if <code>addr</code> should be used as is.
     * @return A new IpAddress
     */
    public static IpAddress getIpAddress(InetAddress addr, String displayIp)
    {
        byte[] bytes = addr.getAddress();

        if (bytes[0] == 127)
        {
            /*
             * If either address is a loopback address we need to bind on "localhost" to properly tftp back to the server.
             * Thus, we use getLocaHost() for the InetAddress
             */
            addr = Util.getLocalHost();
        }

        return displayIp == null ? new IpAddress(addr) : new IpAddress(addr, displayIp);
    }
}
