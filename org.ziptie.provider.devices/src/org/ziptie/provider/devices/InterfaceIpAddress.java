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
package org.ziptie.provider.devices;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.TableGenerator;

import org.ziptie.addressing.NetworkAddressElf;

/**
 * Class to map IP addresses found on device interfaces to a real device.
 * 
 * The addresses saved from this object are intended to be used to enhance
 * searching by IP address.
 */
@Entity
@Table(name = "device_interface_ips")
public class InterfaceIpAddress
{
    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "ip_high")
    private long ipHigh;

    @Column(name = "ip_low")
    private long ipLow;

    @Column(name = "same_ip_space")
    private boolean sameIpSpace = true;

    @ManyToOne
    @JoinColumn(name = "device_id", nullable = false)
    private ZDeviceLite device;

    @Column(name = "interface")
    private String interfaceName;

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value", pkColumnValue = "interface_ip_seq", initialValue = 1, allocationSize = 10)
    private long id = -1;
    // CHECKSTYLE:ON

    /**
     * Default constructor, required for hibernate.
     */
    public InterfaceIpAddress()
    {
    }

    /**
     * @param ipAddress an IP address that was found on an interface
     * @param device the device
     */
    public InterfaceIpAddress(String ipAddress, ZDeviceLite device)
    {
        this.device = device;
        this.ipAddress = NetworkAddressElf.toDatabaseString(ipAddress);
        long[] hilo = NetworkAddressElf.getHiLo(ipAddress);
        setIpHigh(hilo[0]);
        setIpLow(hilo[1]);
    }

    /**
     * @return the device
     */
    public ZDeviceLite getDevice()
    {
        return device;
    }

    /**
     * @param device the device to set
     */
    public void setDevice(ZDeviceLite device)
    {
        this.device = device;
    }

    /**
     * @return the id
     */
    public long getId()
    {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(long id)
    {
        this.id = id;
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
     * @return the ipAddress
     */
    public String getIpAddress()
    {
        return ipAddress;
    }

    /**
     * @param ipAddress the ipAddress to set
     */
    public void setIpAddress(String ipAddress)
    {
        this.ipAddress = ipAddress;
    }

    /**
     * @return the ipHigh
     */
    public long getIpHigh()
    {
        return ipHigh;
    }

    /**
     * @param ipHigh the ipHigh to set
     */
    public void setIpHigh(long ipHigh)
    {
        this.ipHigh = ipHigh;
    }

    /**
     * @return the ipLow
     */
    public long getIpLow()
    {
        return ipLow;
    }

    /**
     * @param ipLow the ipLow to set
     */
    public void setIpLow(long ipLow)
    {
        this.ipLow = ipLow;
    }

    /**
     * @return the sameIpSpace
     */
    public boolean isSameIpSpace()
    {
        return sameIpSpace;
    }

    /**
     * @param sameIpSpace the sameIpSpace to set
     */
    public void setSameIpSpace(boolean sameIpSpace)
    {
        this.sameIpSpace = sameIpSpace;
    }

}
