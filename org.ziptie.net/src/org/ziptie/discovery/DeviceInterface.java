/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/07/09 19:22:48 $
 * $Revision: 1.1 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/DeviceInterface.java,v $e
 */

package org.ziptie.discovery;

import java.util.ArrayList;
import java.util.List;

import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.Subnet;

/**
 * Holds data from the public SNMP interface tables.<br>
 * <br>
 * This class is also comparable with the following rules<br>
 * <li> softwareLoopback(24) interfaces come before all others
 * <li> the ifIndex is used to order all other interface types
 * 
 * @author rkruse
 */
public class DeviceInterface implements Comparable<DeviceInterface>
{
    private static final String SOFTWARE_LOOPBACK = "softwareLoopback";

    private String ifType = "";
    private String ifOperStatus = "";
    private String name = "";
    private long inOctets;
    private List<IPAddress> ipAddresses;
    private List<Subnet> subnets;

    /**
     *  
     *
     */
    public DeviceInterface()
    {
        ipAddresses = new ArrayList<IPAddress>();
        subnets = new ArrayList<Subnet>();
    }

    /**
     * The <code>SnmpIPInterface</code> will order interfaces in the order
     * they are added.
     * 
     * @param address the IP address of this interface
     */
    public void addIPAddress(IPAddress address)
    {
        this.ipAddresses.add(address);
    }

    /**
     * returns a <code>List</code> of <code>IPAddress</code> objects in the
     * order in which they were added
     * 
     * @return a List of IPs on this interface
     */
    public List<IPAddress> getIPAddresses()
    {
        return ipAddresses;
    }

    /**
     * Add a <code>Subnet</code> that is represented by an IP and mask on this
     * interface
     * 
     * @param subnet the subnet
     */
    public void addSubnet(Subnet subnet)
    {
        subnets.add(subnet);
    }

    /**
     * Get the subnets as represented by the IP and mask combinations configured
     * on this interface
     * 
     * @return all subnets
     */
    public List<Subnet> getSubnets()
    {
        return subnets;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(DeviceInterface other)
    {
        if (this.getIfType().equals(SOFTWARE_LOOPBACK))
        {
            if (!other.getIfType().equals(SOFTWARE_LOOPBACK))
            {
                // THIS object is a loopback, but the other one isn't
                return -1;
            }
        }
        else if (other.getIfType().equals(SOFTWARE_LOOPBACK))
        {
            // The other object is a loopback but THIS isn't
            return +1;
        }

        // If we haven't returned yet we should compare the ifIndex numbers
        return this.getName().compareTo(other.getName());
    }

    /**
     * If the status == 1 then return true
     * 
     * @return true if the interface is up, false otherwise
     */
    public boolean isInterfaceUp()
    {
        return ifOperStatus.matches("[uU][pP]");
    }

    /**
     * The name of the interface
     * 
     * @return the name
     */
    public String getName()
    {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * This value is a rolling counter, it represents the number of bytes input on this interface.  
     * Differences in the inOctets value can signify an interface that is in use.
     * @return the inOctets
     */
    public long getInOctets()
    {
        return inOctets;
    }

    /**
     * This value is a rolling counter, it represents the number of bytes input on this interface.  
     * Differences in the inOctets value can signify an interface that is in use.
     * @param inOctets the inOctets to set
     */
    public void setInOctets(long inOctets)
    {
        this.inOctets = inOctets;
    }

    /**
     * @return the ifType
     */
    public String getIfType()
    {
        return ifType;
    }

    /**
     * @param ifType the ifType to set
     */
    public void setIfType(String ifType)
    {
        this.ifType = ifType;
    }

    /**
     * @return the ifOperStatus
     */
    public String getIfOperStatus()
    {
        return ifOperStatus;
    }

    /**
     * @param ifOperStatus the ifOperStatus to set
     */
    public void setIfOperStatus(String ifOperStatus)
    {
        this.ifOperStatus = ifOperStatus;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((ifType == null) ? 0 : ifType.hashCode());
        result = prime * result + ((name == null) ? 0 : name.hashCode());
        return result;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (this == obj)
        {
            return true;
        }
        if (obj == null)
        {
            return false;
        }
        if (getClass() != obj.getClass())
        {
            return false;
        }
        final DeviceInterface other = (DeviceInterface) obj;
        if (ifType == null)
        {
            if (other.ifType != null)
            {
                return false;
            }
        }
        else if (!ifType.equals(other.ifType))
        {
            return false;
        }
        if (name == null)
        {
            if (other.name != null)
            {
                return false;
            }
        }
        else if (!name.equals(other.name))
        {
            return false;
        }
        return true;
    }
}
