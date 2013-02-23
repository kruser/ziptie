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
 */
package org.ziptie.provider.telemetry;

import javax.persistence.Entity;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.addressing.MACAddress;
import org.ziptie.addressing.NetworkAddressElf;

/**
 * ArpTableEntry
 */
@Entity(name = "ArpTableEntry")
public class ArpTableEntry
{
    private String ipAddress = "";
    private String interfaceName = "";
    private MACAddress macAddress;

    /**
     * @return the ipAddress
     */
    public String getIpAddress()
    {
        return NetworkAddressElf.fromDatabaseString(ipAddress);
    }

    /**
     * @param ipAddress the ipAddress to set
     */
    public void setIpAddress(String ipAddress)
    {
        this.ipAddress = ipAddress;
    }

    /**
     * @return the macAddress
     */
    public String getMacAddress()
    {
        return macAddress.getMACAddress();
    }
    
    /**
     * Get the MACAddress object
     * @return the mac
     */
    @XmlTransient
    public MACAddress getRawMac()
    {
       return macAddress; 
    }

    /**
     * @return the interfaceName
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
     * @param macAddress the macAddress to set
     */
    public void setMacAddress(long macAddress)
    {
        this.macAddress = new MACAddress(macAddress);
    }
    
    /**
     * @param macAddress
     */
    public void setMacAddress(String macAddress)
    {
        this.macAddress = new MACAddress(macAddress);
    }

}
