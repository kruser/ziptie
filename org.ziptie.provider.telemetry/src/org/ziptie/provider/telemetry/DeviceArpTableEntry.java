package org.ziptie.provider.telemetry;
import javax.persistence.Entity;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.addressing.NetworkAddressElf;


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

/**
 * DeviceArpTableEntry
 * 
 * Contains the device and managedNetwork that the ARP entry was found on.
 */
@Entity(name = "DeviceArpTableEntry")
public class DeviceArpTableEntry extends ArpTableEntry
{
    private String device;
    private int deviceId;
    private String managedNetwork;
    /**
     * @return the device
     */
    public String getDevice()
    {
        return NetworkAddressElf.fromDatabaseString(device);
    }
    /**
     * @param device the device to set
     */
    public void setDevice(String device)
    {
        this.device = device;
    }
    /**
     * @return the managedNetwork
     */
    public String getManagedNetwork()
    {
        return managedNetwork;
    }
    /**
     * @param managedNetwork the managedNetwork to set
     */
    public void setManagedNetwork(String managedNetwork)
    {
        this.managedNetwork = managedNetwork;
    }
    /**
     * @return the deviceId
     */
    @XmlTransient
    public int getDeviceId()
    {
        return deviceId;
    }
    /**
     * @param deviceId the deviceId to set
     */
    public void setDeviceId(int deviceId)
    {
        this.deviceId = deviceId;
    }

}
