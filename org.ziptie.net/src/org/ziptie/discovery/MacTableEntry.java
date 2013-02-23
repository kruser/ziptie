/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/07 18:26:15 $
 * $Revision: 1.8 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/MacTableEntry.java,v $e
 */

package org.ziptie.discovery;

import org.ziptie.addressing.MACAddress;

/**
 * Maps port details to a {@link MACAddress}.
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
public class MacTableEntry extends TelemetryObject
{
    private MACAddress macAddress;
    private String interfaceName = "";
    private String vlan = "";

    /**
     * default constructor, only here to satisfy hibernate.
     */
    public MacTableEntry()
    {
    }

    /**
     * A MAC table entry must have an associated {@link MACAddress}, so this
     * will be the only constructor.
     * 
     * @param address the mac for this entry
     */
    public MacTableEntry(MACAddress address)
    {
        this.macAddress = address;
    }

    /**
     * @return the macAddress
     */
    public MACAddress getMacAddress()
    {
        return macAddress;
    }

    /**
     * The name of the VLAN that this entry was found on.
     * 
     * @return the vlan or an empty string if the vlan was unavailable
     */
    public String getVlan()
    {
        return vlan;
    }

    /**
     * @param vlan the vlan to set
     */
    public void setVlan(String vlan)
    {
        this.vlan = vlan;
    }


    /**
     * The textual representation of the interface on which this MAC entry was
     * found. This most likely comes from the SNMP ifDescr table.
     * 
     * @return the interfaceName
     */
    public String getInterfaceName()
    {
        return interfaceName;
    }

    /**
     * The textual representation of the interface on which this MAC entry was
     * found. This most likely comes from the SNMP ifDescr table.
     * 
     * @param interfaceName the interfaceName to set
     */
    public void setInterfaceName(String interfaceName)
    {
        if (interfaceName != null)
        {
            this.interfaceName = interfaceName;
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((interfaceName == null) ? 0 : interfaceName.hashCode());
        result = prime * result + ((macAddress == null) ? 0 : macAddress.hashCode());
        result = prime * result + ((vlan == null) ? 0 : vlan.hashCode());
        return result;
    }

    /** {@inheritDoc} */
    // CHECKSTYLE:OFF - suppress Cyclomatic Complexity check
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
        final MacTableEntry other = (MacTableEntry) obj;
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
        if (macAddress == null)
        {
            if (other.macAddress != null)
            {
                return false;
            }
        }
        else if (!macAddress.equals(other.macAddress))
        {
            return false;
        }
        if (vlan == null)
        {
            if (other.vlan != null)
            {
                return false;
            }
        }
        else if (!vlan.equals(other.vlan))
        {
            return false;
        }
        return true;
    }
    // CHECKSTYLE:ON

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return macAddress.getMACAddress() + "\t" + interfaceName + "\tVlan(" + vlan + ")";
    }

}
