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

import org.ziptie.exception.NonContiguousSubnetMask;

/**
 * Subnet
 */
public class Subnet implements NetworkAddress, Comparable, Serializable
{
    private static final int IPV4_BITS = 32;
    private static final long serialVersionUID = 4773154758194276537L;
    private BigInteger iteratingIp;
    private short netmaskBits;
    private IPAddress networkAddress;
    private IPAddress originalAddress;
    private boolean exclude;

    /**
     *
     */
    public Subnet()
    {
        netmaskBits = 0;
        originalAddress = new IPAddress();
        networkAddress = new IPAddress();
    }

    /**
     * @param network
     * @param maskBits
     * @param exclude
     */
    public Subnet(IPAddress network, short maskBits, boolean exclude)
    {
        netmaskBits = maskBits;
        originalAddress = network;
        networkAddress = originalAddress.mask(maskBits);
        setExclude(exclude);
    }

    /**
     * @param network
     * @param maskBits
     */
    public Subnet(IPAddress network, short maskBits)
    {
        this(network, maskBits, false);
    }

    /**
     * This method is only for building IPv4 subnets
     * 
     * @param network
     * @param subnetMask
     * @throws NonContiguousSubnetMask
     * @deprecated This is deprecated as it only makes sense for an IPv4 subnet. Use {@link #Subnet(IPAddress, short)} instead
     */
    public Subnet(IPAddress network, IPAddress subnetMask) throws NonContiguousSubnetMask
    {
        this(network, subnetMask, false);
    }

    /**
     * @param network
     * @param subnetMask
     * @param exclude
     * @throws NonContiguousSubnetMask
     * @deprecated This is deprecated as it only makes sense for an IPv4 subnet. Use {@link #Subnet(IPAddress, short, boolean)} instead
     */
    public Subnet(IPAddress network, IPAddress subnetMask, boolean exclude) throws NonContiguousSubnetMask
    {
        if (network.isVersion6())
        {
            throw new IllegalArgumentException("This method is not valid for IPv6 subnets.");
        }
        netmaskBits = maskToBits(subnetMask);
        originalAddress = network;
        networkAddress = originalAddress.mask(netmaskBits);
        setExclude(exclude);
    }

    /**
     * @return
     */
    public IPAddress getNetworkAddress()
    {
        return networkAddress;
    }

    /**
     * @param networkAddress
     */
    public void setNetworkAddress(IPAddress networkAddress)
    {
        this.networkAddress = networkAddress;
    }

    /**
     * @param inVar
     */
    public void setExclude(boolean inVar)
    {
        this.exclude = inVar;
    }

    public boolean getExclude()
    {
        return exclude;
    }

    /**
     * @return
     */
    public short getNetmaskBits()
    {
        return netmaskBits;
    }

    /**
     * @param numOfBits
     */
    public void setNetmaskBits(short numOfBits)
    {
        this.netmaskBits = numOfBits;
        this.networkAddress = originalAddress.mask(netmaskBits);
    }

    /**
     * Only valid for IPv4 subnet definitions.  This method converts the bit mask into an IPv4 address.
     * 
     * IPv6 subnet definitions should only use the method for {@link #getNetmaskBits()}
     * @return the subnet mask as an IP Address.  If this is an IPv6 subnet this returns null.
     */
    public IPAddress getNetmask()
    {
        if (networkAddress.isVersion6())
        {
            return null;
        }
        else
        {
            // get the correct number of bits set
            int intMask = (int) Math.round(Math.pow(2.0, (netmaskBits)) - 1);
            // shift bits set to high order position
            intMask <<= (IPV4_BITS - netmaskBits);
            IPAddress rtnAddress = new IPAddress(intMask);

            return rtnAddress;
        }
    }

    /**
     * @param netmask
     * @throws NonContiguousSubnetMask
     */
    public void setNetmask(IPAddress netmask) throws NonContiguousSubnetMask
    {
        this.netmaskBits = maskToBits(netmask);
    }

    /**
     * Returns the broadcast IP address
     * @return the broadcast 
     */
    public IPAddress getBroadcastAddress()
    {
        return new IPAddress(networkAddress.getIpLow() | (~getNetmask().getIpLow()));
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return networkAddress + "/" + netmaskBits;
    }

    protected short maskToBits(IPAddress subnetMask) throws NonContiguousSubnetMask
    {
        long intAddress = subnetMask.getIpLow();
        long mask = 1;
        short counter = 0;
        boolean foundOnes = false;

        for (int i = 0; i < IPV4_BITS; i++)
        {
            if ((intAddress & mask) != 0)
            {
                counter++;
                foundOnes = true;
            }
            else if (foundOnes)
            {
                throw new NonContiguousSubnetMask("Invalid Subnet Mask, it must not contain embedded zeros");
            }
            mask <<= 1;
        }

        return counter;
    }

    // these two for the NetworkAddress interface
    /** {@inheritDoc} */
    public String getFirstValue()
    {
        return networkAddress.toString();
    }

    /** {@inheritDoc} */
    public String getSecondValue()
    {
        return "" + netmaskBits;
    }

    /** {@inheritDoc} */
    public boolean contains(IPAddress testAddress)
    {
        return networkAddress.equals(testAddress.mask(netmaskBits));
    }

    /** {@inheritDoc} */
    public int compareTo(Object obj)
    {
        Subnet subnet = (Subnet) obj;
        int rtnValue = networkAddress.compareTo(subnet.getNetworkAddress());
        if (rtnValue == 0)
        {
            short otherMaskBits = subnet.getNetmaskBits();
            if (netmaskBits < otherMaskBits)
            {
                rtnValue = -1;
            }
            else if (netmaskBits > otherMaskBits)
            {
                rtnValue = 1;
            }
        }
        return rtnValue;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        boolean rtnValue = false;
        if (obj instanceof Subnet)
        {
            Subnet otherSubnet = (Subnet) obj;
            rtnValue = (hashCode() == otherSubnet.hashCode());
        }
        return rtnValue;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return (int) (networkAddress.getIpLow() ^ (networkAddress.getIpLow() >>> 32)) | netmaskBits;
    }

    /** {@inheritDoc} */
    @Override
    public Subnet clone() throws CloneNotSupportedException
    {
        Subnet clone = (Subnet) super.clone();

        clone.setNetworkAddress(getNetworkAddress().clone());
        clone.originalAddress = originalAddress.clone();

        return clone;
    }

    /** {@inheritDoc} */
    public Iterator<IPAddress> iterator()
    {
        iteratingIp = new BigInteger(getNetworkAddress().getInetAddress().getAddress());
        return this;
    }

    /** {@inheritDoc} */
    public boolean hasNext()
    {
        return this.contains(NetworkAddressElf.bigIntToIP(iteratingIp, (networkAddress.isVersion6() ? 6 : 4)));
    }

    /** {@inheritDoc} */
    public IPAddress next()
    {
        IPAddress toReturn = NetworkAddressElf.bigIntToIP(iteratingIp, (networkAddress.isVersion6() ? 6 : 4));
        iteratingIp = iteratingIp.add(BigInteger.ONE);
        return toReturn;
    }

    /** {@inheritDoc} */
    public void remove()
    {
        throw new UnsupportedOperationException();
    }

    /**
     * Handles reading back a Subnet that used to have m_<variable>.
     *
     * @param ois
     * @throws IOException
     * @throws ClassNotFoundException
     */
    private void readObject(java.io.ObjectInputStream ois) throws IOException, ClassNotFoundException
    {
        GetField fields = ois.readFields();
        ObjectStreamClass osc = fields.getObjectStreamClass();

        if (osc.getField("exclude") != null)
        {
            // New version class no magic necessary
            netmaskBits = fields.get("netmaskBits", (short) 0);
            networkAddress = (IPAddress) fields.get("networkAddress", new IPAddress());
            originalAddress = (IPAddress) fields.get("originalAddress", new IPAddress());
            exclude = fields.get("exclude", Boolean.FALSE.booleanValue());
        }
        else
        {
            // this is an old version of the class
            netmaskBits = fields.get("m_netmaskBits", (short) 0);
            networkAddress = (IPAddress) fields.get("m_networkAddress", new IPAddress());
            originalAddress = (IPAddress) fields.get("originalAddress", new IPAddress());
            exclude = fields.get("m_exclude", Boolean.FALSE.booleanValue());
        }
    }
}
