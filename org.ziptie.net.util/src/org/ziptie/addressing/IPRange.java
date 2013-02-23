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
 * Contributor(s):
 */

package org.ziptie.addressing;

import java.io.IOException;
import java.io.ObjectStreamClass;
import java.io.Serializable;
import java.io.ObjectInputStream.GetField;
import java.math.BigInteger;
import java.util.Iterator;

/**
 * IPRange
 */
public class IPRange implements NetworkAddress, Comparable, Serializable
{
    static final long serialVersionUID = -270021144363575511L;

    private IPAddress rangeStart;
    private IPAddress rangeEnd;
    private IPAddress currentIP;

    /**
     * @param start starting IP Address
     * @param end ending IP Address
     */
    public IPRange(String start, String end)
    {
        IPAddress ips = new IPAddress(start);
        IPAddress ipe = new IPAddress(end);
        if (ips.isVersion6() != ipe.isVersion6())
        {
            throw new IllegalArgumentException("The start and end IP addresses are not of the same type.");
        }

        testRange(ips, ipe);

        setRangeStart(ips);
        setRangeEnd(ipe);
        setCurrentIP(ips);
    }

    /**
     * @param start starting IP Address
     * @param end ending IP Address
     */
    public IPRange(IPAddress start, IPAddress end)
    {
        testRange(start, end);
        setRangeStart(start);
        setRangeEnd(end);
        setCurrentIP(start);
    }

    /**
     * {@inheritDoc}
     */
    public String toString()
    {
        return rangeStart.toString() + "-" + rangeEnd.toString();
    }

    /**
     * @param rangeStart the start of the range
     */
    public void setRangeStart(IPAddress rangeStart)
    {
        this.rangeStart = rangeStart;
    }

    /**
     * @return the start of the range
     */
    public IPAddress getRangeStart()
    {
        return rangeStart;
    }

    /**
     * @param rangeEnd set the end of the range
     */
    public void setRangeEnd(IPAddress rangeEnd)
    {
        this.rangeEnd = rangeEnd;
    }

    /**
     * @return the IP Address that is the end of this range
     */
    public IPAddress getRangeEnd()
    {
        return rangeEnd;
    }

    /**
     * Used while iterating
     * @param newIp the current IP Address to set
     */
    public void setCurrentIP(IPAddress newIp)
    {
        this.currentIP = new IPAddress(newIp.toString());
    }

    /** {@inheritDoc} */
    public String getFirstValue()
    {
        return rangeStart.toString();
    }

    /** {@inheritDoc} */
    public String getSecondValue()
    {
        return rangeEnd.toString();
    }

    /** {@inheritDoc} */
    public boolean getExclude()
    {
        return false;
    }

    /** {@inheritDoc} */
    public boolean contains(IPAddress address)
    {
        boolean gteqStart = (address.compareTo(rangeStart) >= 0);
        boolean lteqEnd = (address.compareTo(rangeEnd) <= 0);

        return gteqStart && lteqEnd;
    }

    /** {@inheritDoc} */
    public int compareTo(Object obj)
    {
        return compareTo((IPRange) obj);
    }

    protected int compareTo(IPRange otherRange)
    {
        int comparison = rangeStart.compareTo(otherRange.rangeStart);
        if (comparison == 0)
        {
            comparison = rangeEnd.compareTo(otherRange.rangeEnd);
        }
        return comparison;
    }

    /** {@inheritDoc} */
    public boolean hasNext()
    {
        BigInteger current = new BigInteger(currentIP.getInetAddress().getAddress());
        BigInteger end = new BigInteger(rangeEnd.getInetAddress().getAddress());
        return (current.compareTo(end) <= 0);
    }

    /** {@inheritDoc} */
    public IPAddress next()
    {
        if (currentIP.isVersion6())
        {
            BigInteger current = new BigInteger(currentIP.getInetAddress().getAddress());
            BigInteger end = new BigInteger(rangeEnd.getInetAddress().getAddress());
            if (current.compareTo(end) <= 0)
            {
                IPAddress oldCurrent = currentIP;
                currentIP = NetworkAddressElf.bigIntToIP(current.add(BigInteger.ONE), 6);
                return oldCurrent;
            }
            else
            {
                return currentIP;
            }
        }
        else
        {
            long current = currentIP.getIpLow();
            long end = rangeEnd.getIpLow();
            if (current <= end)
            {
                IPAddress oldCurrent = currentIP;
                currentIP = new IPAddress(current + 1);
                return oldCurrent;
            }
            else
            {
                return currentIP;
            }
        }
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        boolean isEqual = false;
        if (obj instanceof IPRange)
        {
            IPRange otherIPRange = (IPRange) obj;
            isEqual = otherIPRange.rangeStart.equals(rangeStart) && otherIPRange.rangeEnd.equals(rangeEnd);
        }
        return isEqual;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return rangeStart.hashCode() | (rangeEnd.hashCode());
    }

    /** {@inheritDoc} */
    @Override
    public IPRange clone() throws CloneNotSupportedException
    {
        IPRange clone = (IPRange) super.clone();

        clone.currentIP = null;
        clone.setRangeStart(getRangeStart().clone());
        clone.setRangeEnd(getRangeEnd().clone());

        return clone;
    }

    /** {@inheritDoc} */
    public Iterator<IPAddress> iterator()
    {
        setCurrentIP(getRangeStart());
        return this;
    }

    /** {@inheritDoc} */
    public void remove()
    {
        throw new UnsupportedOperationException();
    }

    private void testRange(IPAddress start, IPAddress end)
    {
        if (start.compareTo(end) > 0)
        {
            throw new IllegalArgumentException("IP Address " + start + " is not less than IP Address " + end);
        }

    }

    /**
     * Handles reading back an IPRange that used to have m_<variable>.
     *
     * @param ois
     * @throws IOException
     * @throws ClassNotFoundException
     */
    private void readObject(java.io.ObjectInputStream ois) throws IOException, ClassNotFoundException
    {
        GetField fields = ois.readFields();
        ObjectStreamClass osc = fields.getObjectStreamClass();

        if (osc.getField("rangeStart") != null)
        {
            // New version class no magic necessary
            rangeStart = (IPAddress) fields.get("rangeStart", null);
            rangeEnd = (IPAddress) fields.get("rangeEnd", null);
            currentIP = (IPAddress) fields.get("currentIP", null);
        }
        else
        {
            // this is an old version of the class
            rangeStart = (IPAddress) fields.get("m_rangeStart", null);
            rangeEnd = (IPAddress) fields.get("m_rangeEnd", null);
            currentIP = (IPAddress) fields.get("m_currentIP", null);
        }
    }
}
