/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: edg $
 *     $Date: 2008/08/14 15:27:07 $
 * $Revision: 1.12 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/XdpEntry.java,v $e
 */

package org.ziptie.discovery;

import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.MACAddress;

/**
 * An <code>XdpEntry</code> is a class that represents an entry in the cache
 * of a discovery protocol. <br>
 * <br>
 * Examples of discovery protocols are:
 * <li>CDP (Cisco Discovery Protocol)
 * <li>LLDP (Link Layer Discovery Protocol)
 * <li>FDP (Foundry Discovery Protocol)
 * <li>EDP (Extreme Discovery Protocol).
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
public class XdpEntry extends TelemetryObject
{
    /**
     * XdpTypes
     */
    public enum XdpTypes
    {
        CDP, LLDP, EDP, FDP, NDP
    }

    private XdpTypes type;
    private String sysDescr = "";
    private String sysName = "";
    private String sysOid = "";
    private String interfaceName = "";
    private String platform = "";
    private String localIfName = "";
    private IPAddress ipAddress;
    private MACAddress macAddress;

    /**
     * default constructor, only here to satisfy hibernate.
     */
    public XdpEntry()
    {
    }

    /**
     * Create a Discovery Protocol entry by specifying the source of the data.
     * 
     * @param type the type of discovery protocol
     */
    public XdpEntry(XdpTypes type)
    {
        this.type = type;
    }

    /**
     * Should be one of the static TYPE_* identifiers from this class. Examples
     * are "CDP", "LLDP".
     * 
     * @return the type
     */
    public String getType()
    {
        return type.name();
    }

    /**
     * Return the raw enumeration instead of the name per getType().
     *
     * @return the XdpTypes version of getType().
     */
    public XdpTypes getXdpType()
    {
        return type;
    }
    
    /**
     * Returns the {@link IPAddress} associated with the remote device.  If the neighbor was learned over layer-2
     * then this value will return an address with the value of '0.0.0.0'.
     * 
     * @return the ipAddress - can be null if the discovery protocol doesn't
     *         recognize this field.
     */
    public IPAddress getIpAddress()
    {
        return ipAddress;
    }

    /**
     * @param ipAddress the ipAddress to set
     */
    public void setIpAddress(IPAddress ipAddress)
    {
        this.ipAddress = ipAddress;
    }

    /**
     * A string usually coinciding with the SNMP sysDescr field.
     * 
     * @return the sysDescr - returns an empty string if this hasn't been set.
     */
    public String getSysDescr()
    {
        return sysDescr;
    }

    /**
     * A string usually coinciding with the SNMP sysDescr field.
     * 
     * @param sysDescr the sysDescr to set
     */
    public void setSysDescr(String sysDescr)
    {
        this.sysDescr = sysDescr;
    }

    /**
     * The dotted decimal OID of the remote system.
     * 
     * An emptry string if the value is not available.
     * 
     * @return the sysOid
     */
    public String getSysOid()
    {
        return sysOid;
    }

    /**
     * @param sysOid the sysOid to set
     */
    public void setSysOid(String sysOid)
    {
        this.sysOid = sysOid;
    }

    /**
     * This should be similar to the SNMP sysName field. In some discovery
     * protocols it is also the deviceID.
     * 
     * @return the sysName - returns an empty string if this hasn't been set.
     */
    public String getSysName()
    {
        return sysName;
    }

    /**
     * This should be similar to the SNMP sysName field. In some discovery
     * protocols it is also the deviceID.
     * 
     * @param sysName the sysName to set
     */
    public void setSysName(String sysName)
    {
        this.sysName = sysName;
    }

    /**
     * The interface name is the name of the remote port.<br>
     * <br>
     * 
     * For example, if there are two devices: <br>
     * RouterA.serial0 <--> RouterB.serial1 <br>
     * <br>
     * And this entry was read from <i>RouterA</i>, the entry would indicate
     * that <i>RouterB</i> was the neighbor and that interface <i>serial1</i>
     * was the remote port.
     * 
     * @return the interfaceName - returns an empty string if this hasn't been
     *         set.
     */
    public String getInterfaceName()
    {
        return interfaceName;
    }

    /**
     * @param interfaceName the interfaceName to set
     */
    public void setInterfaceName(String interfaceName)
    {
        this.interfaceName = interfaceName;
    }

    /**
     * Identifies the make and model of this target device. For CDP entries,
     * this value is usually the make and model, e.g. 'cisco WS-C3750-24P'
     * 
     * @return the platform - returns an empty string if this hasn't been set.
     */
    public String getPlatform()
    {
        return platform;
    }

    /**
     * @param platform the platform to set
     */
    public void setPlatform(String platform)
    {
        this.platform = platform;
    }

    /**
     * @return the localIfName
     */
    public String getLocalIfName()
    {
        return localIfName;
    }

    /**
     * @param localIfName the localIfName to set
     */
    public void setLocalIfName(String localIfName)
    {
        if (localIfName != null)
        {
            this.localIfName = localIfName;
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString()
    {
        return getType() + " entry: " + getSysName() + "(" + getIpAddress() + ") found on " + getLocalIfName()
                + " via interface " + getInterfaceName();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((ipAddress == null) ? 0 : ipAddress.hashCode());
        return result;
    }

    /**
     * {@inheritDoc}
     */
    // CHECKSTYLE:OFF - suppresessed for Cyclomatic Complexity
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
        final XdpEntry other = (XdpEntry) obj;
        if (interfaceName == null)
        {
            if (other.interfaceName != null)
            {
                return false;
            }
        }
        else if (!interfaceName.equals(other.interfaceName))
        {
            return false;
        }
        if (ipAddress == null)
        {
            if (other.ipAddress != null)
            {
                return false;
            }
        }
        else if (!ipAddress.equals(other.ipAddress))
        {
            return false;
        }
        if (!type.equals(other.type))
        {
            return false;
        }
        return true;
    }
    // CHECKSTYLE:ON

    /**
     * @return the macAddress
     */
    public MACAddress getMacAddress()
    {
        return macAddress;
    }

    /**
     * @param macAddress the macAddress to set
     */
    public void setMacAddress(MACAddress macAddress)
    {
        this.macAddress = macAddress;
    }
}
