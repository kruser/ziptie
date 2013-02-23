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
 * Copyright the ZipTie Project (www.ziptie.org)
 */

package org.ziptie.provider.devices;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.TableGenerator;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.addressing.NetworkAddressElf;

/**
 * ZDeviceCore
 */
@Entity(name = "ZDeviceCore")
@Table(name = "device")
public class ZDeviceCore
{
    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value", pkColumnValue = "Device_seq", initialValue = 1, allocationSize = 100)
    @Column(name = "device_id")
    private int deviceId;
    // CHECKSTYLE:ON

    @Column(name = "inode")
    private int inode;

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "ip_high")
    private long ipHigh;

    @Column(name = "ip_low")
    private long ipLow;

    @Column(name = "hostname")
    private String hostname;

    @Column(name = "network")
    private String managedNetwork;

    @Column(name = "adapter_id")
    private String adapterId;

    /**
     * Default constructor.
     */
    public ZDeviceCore()
    {
        deviceId = -1;
    }

    // ----------------------------------------------------------------------
    //                     Internal (non-SOAP) Attributes
    // ----------------------------------------------------------------------

    /**
     * Get the persistent ID of the device.
     *
     * @return the deviceId the persistent ID of the device
     */
    @XmlTransient
    public int getDeviceId()
    {
        return deviceId;
    }

    /**
     * Set the persistent ID of the device.
     *
     * @param id the internal ID of the device
     */
    public void setDeviceId(int id)
    {
        deviceId = id;
    }

    /**
     * Get the inode of the device in the Directory.
     *
     * @return the inode of the device
     */
    @XmlTransient
    public int getInode()
    {
        return inode;
    }

    /**
     * Set the inode of the device in the Directory.
     *
     * @param inode the of the device
     */
    public void setInode(int inode)
    {
        this.inode = inode;
    }

    /**
     * @return the ipHigh
     */
    @XmlTransient
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
    @XmlTransient
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

    // ----------------------------------------------------------------------
    //                         External (SOAP) Attributes
    // ----------------------------------------------------------------------

    /**
     * Get the hostname of the device.  This can actually be either an
     * IP address or a DNS-referenceable hostname, depending on how you
     * manage your network.
     *
     * @return the hostname or IP address of the device
     */
    public String getHostname()
    {
        return hostname;
    }

    /**
     * Set the hostname of the device.
     *
     * @param hostname the hostname or IP address of the device
     */
    public void setHostname(String hostname)
    {
        this.hostname = hostname;
    }

    /**
     * Get the IPv4 or IPv6 IP address of the device.
     *
     * @return the IP address of the device
     */
    public String getIpAddress()
    {
        return NetworkAddressElf.fromDatabaseString(ipAddress);
    }

    /**
     * Set the IPv4 or IPv6 address of the device.
     *
     * @param ipAddress the IP address of the device
     */
    public void setIpAddress(String ipAddress)
    {
        this.ipAddress = NetworkAddressElf.toDatabaseString(ipAddress);

        long[] hilo = NetworkAddressElf.getHiLo(ipAddress);
        setIpHigh(hilo[0]);
        setIpLow(hilo[1]);
    }

    /**
     * Get the name of the Managed Network that this device
     * resides in.
     *
     * @return the Managed Network name for this device
     */
    public String getManagedNetwork()
    {
        return managedNetwork;
    }

    /**
     * Set the name of the Managed Network that this device
     * resides in.
     *
     * @param managedNetwork the name of the Managed Network
     */
    public void setManagedNetwork(String managedNetwork)
    {
        this.managedNetwork = managedNetwork;
    }

    /**
     * Get the ID of the adapter associated with this device.
     *
     * @return the ID of the adapter associated with this device
     */
    public String getAdapterId()
    {
        return adapterId;
    }

    /**
     * Set the ID of the adapter associated with this device.
     *
     * @param adapterId the ID of the adapter associated with this device
     */
    public void setAdapterId(String adapterId)
    {
        this.adapterId = adapterId;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null)
        {
            return false;
        }

        try
        {
            return ((ZDeviceCore) obj).getDeviceId() == getDeviceId();
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return getDeviceId();
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return getIpAddress() + "@" + getManagedNetwork(); //$NON-NLS-1$
    }
}
