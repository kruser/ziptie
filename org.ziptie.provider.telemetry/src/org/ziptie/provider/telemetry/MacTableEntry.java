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

import org.ziptie.addressing.MACAddress;

/**
 * MacTableEntry
 */
@Entity(name = "MacTableEntry")
public class MacTableEntry
{
    private MACAddress macAddress;
    private String port = "";
    private String vlan = "";
    /**
     * @return the macAddress
     */
    public String getMacAddress()
    {
        return macAddress.getMACAddress();
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
    /**
     * @return the port
     */
    public String getPort()
    {
        return port;
    }
    /**
     * @param port the port to set
     */
    public void setPort(String port)
    {
        this.port = port;
    }
    /**
     * @return the vlan
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
}
