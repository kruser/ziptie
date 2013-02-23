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

package org.ziptie.net.sim.config;

import java.util.Iterator;

/**
 * An IP Mask definition.
 * <p>A bitwise masking of ip addresses.
 */
public class IpSubnet extends AbstractIpMapping
{
    private IpAddressMapping ip;
    private IpAddressMapping mask;
    private int hashValue;

    public IpSubnet(IpAddressMapping ip, IpAddressMapping mask)
    {
        this.ip = ip;
        this.mask = mask;

        this.hashValue = (ip.toString() + mask.toString()).hashCode();
    }

    public IpSubnet(String strMask)
    {
        String[] strs = strMask.split("\\/");
        if (strs.length != 2)
        {
            throw new IllegalArgumentException("Invalid ip mask string: " + strMask);
        }

        this.ip = new IpAddressMapping(strs[0]);
        this.mask = new IpAddressMapping(strs[1]);

        this.hashValue = (ip.toString() + mask.toString()).hashCode();
    }

    public boolean contains(IpAddressMapping otherIp)
    {
        return (otherIp.getIntValue() & mask.getIntValue()) == ip.getIntValue();
    }

    public Iterator iterator()
    {
        return new SubnetIterator();
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public boolean equals(Object obj)
    {
        try
        {
            IpSubnet other = (IpSubnet) obj;
            return other.ip.equals(ip) && other.mask.equals(mask);
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    public int hashCode()
    {
        return hashValue;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    public String toString()
    {
        return ip.toString() + "/" + mask.toString();
    }

    /**
     * An iterator which iterates over the entire subnet.
     * <p>This skips all IPs which look like x.x.x.0
     */
    private class SubnetIterator implements Iterator
    {
        private int next;

        public SubnetIterator()
        {
            next = ip.getIntValue();
            if (isLastOctetZero(next))
            {
                next++;
            }
        }

        /* (non-Javadoc)
         * @see java.util.Iterator#hasNext()
         */
        public boolean hasNext()
        {
            return (next & mask.getIntValue()) == ip.getIntValue();
        }

        /* (non-Javadoc)
         * @see java.util.Iterator#next()
         */
        public Object next()
        {
            IpAddressMapping nip = new IpAddressMapping(next++);
            if (isLastOctetZero(next))
            {
                next++;
            }
            return nip;
        }

        public void remove()
        {
            throw new UnsupportedOperationException();
        }

        private boolean isLastOctetZero(int value)
        {
            return (value & 0xFF) == 0;
        }
    }
}
