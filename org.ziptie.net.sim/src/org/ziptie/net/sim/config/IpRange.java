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
 * Representation of an IP range.
 * <p> ie: 10.10.1.1 through 10.10.1.3 (this would include those two IPs plus 10.10.1.2) 
 */
public class IpRange extends AbstractIpMapping
{
    private IpAddressMapping start, end;

    private int hashValue;

    public IpRange()
    {
    }

    public IpRange(IpAddressMapping start, IpAddressMapping end)
    {
        if (start.getIntValue() >= end.getIntValue())
        {
            throw new IllegalArgumentException("Bad ip range: " + start + "-" + end);
        }

        this.start = start;
        this.end = end;
    }

    public boolean contains(IpAddressMapping ip)
    {
        return ip.getIntValue() >= start.getIntValue() && ip.getIntValue() <= end.getIntValue();
    }

    public Iterator iterator()
    {
        return new RangeIterator();
    }

    /**
     * @return Returns the start.
     */
    public IpAddressMapping getStart()
    {
        return start;
    }

    /**
     * @return Returns the end.
     */
    public IpAddressMapping getEnd()
    {
        return end;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public boolean equals(Object obj)
    {
        try
        {
            IpRange other = (IpRange) obj;
            return other.end.equals(end) && other.start.equals(start);
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
        return "{" + start + " - " + end + ")";
    }

    private class RangeIterator implements Iterator
    {
        private int next;

        public RangeIterator()
        {
            next = start.getIntValue();
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
            return next <= end.getIntValue();
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
