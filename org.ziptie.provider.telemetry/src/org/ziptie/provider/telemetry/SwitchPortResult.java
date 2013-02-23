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

/**
 * SwitchPortResult
 */
@Entity(name = "SwitchPortResult")
public class SwitchPortResult
{
    public static final int NO_ERROR = 0;
    public static final int UNABLE_TO_RESOLVE_HOST = 1;
    public static final int NO_ARP_ENTRY = 2;
    public static final int NO_MAC_ENTRY = 3;
    
    private String hostIpAddress;
    private String hostMacAddress;
    private DeviceArpTableEntry arpEntry;
    private DeviceMacTableEntry macEntry;
    private int error = NO_ERROR;

    /**
     * @return the hostIpAddress
     */
    public String getHostIpAddress()
    {
        return hostIpAddress;
    }

    /**
     * @param hostIpAddress the hostIpAddress to set
     */
    public void setHostIpAddress(String hostIpAddress)
    {
        this.hostIpAddress = hostIpAddress;
    }

    /**
     * @return the hostMacAddress
     */
    public String getHostMacAddress()
    {
        return hostMacAddress;
    }

    /**
     * @param hostMacAddress the hostMacAddress to set
     */
    public void setHostMacAddress(String hostMacAddress)
    {
        this.hostMacAddress = hostMacAddress;
    }

    /**
     * @return the arpEntry
     */
    public DeviceArpTableEntry getArpEntry()
    {
        return arpEntry;
    }

    /**
     * @param arpEntry the arpEntry to set
     */
    public void setArpEntry(DeviceArpTableEntry arpEntry)
    {
        this.arpEntry = arpEntry;
    }

    /**
     * @return the macEntry
     */
    public DeviceMacTableEntry getMacEntry()
    {
        return macEntry;
    }

    /**
     * @param macEntry the macEntry to set
     */
    public void setMacEntry(DeviceMacTableEntry macEntry)
    {
        this.macEntry = macEntry;
    }

    /**
     * An error code.
     * <ul>0 - no error</ul>
     * <ul>1 - unable resolve host</ul>
     * <ul>2 - unable to find IP in an ARP/NDP table</ul>
     * <ul>3 - unable to find the MAC address in a forwarding table</ul>
     * 
     * @return the error
     */
    public int getError()
    {
        return error;
    }

    /**
     * @param error the error to set
     */
    public void setError(int error)
    {
        this.error = error;
    }

}
