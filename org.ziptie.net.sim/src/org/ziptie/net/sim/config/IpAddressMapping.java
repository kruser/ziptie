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

import org.ziptie.net.sim.util.Util;

/**
 * Definition of an IP address.
 */
public class IpAddressMapping extends AbstractIpMapping
{
    private String ip;
    private int intValue;

    public IpAddressMapping(int value)
    {
        intValue = value;
        ip = Util.deintify(value);
    }

    public IpAddressMapping(String ip)
    {
        this.ip = ip;
        intValue = Util.intify(ip);
    }

    public boolean contains(IpAddressMapping ip)
    {
        return equals(ip);
    }

    public Iterator iterator()
    {
        return new IpIterator();
    }

    public int getIntValue()
    {
        return intValue;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    public int hashCode()
    {
        return intValue;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public boolean equals(Object obj)
    {
        try
        {
            IpAddressMapping other = (IpAddressMapping) obj;

            return other.intValue == intValue;
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    public String toString()
    {
        return ip;
    }

    private class IpIterator implements Iterator
    {
        private boolean notDone = true;

        public boolean hasNext()
        {
            return notDone;
        }

        public Object next()
        {
            notDone = false;
            return IpAddressMapping.this;
        }

        public void remove()
        {
            throw new UnsupportedOperationException();
        }
    }
}
