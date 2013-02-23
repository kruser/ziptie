package org.ziptie.provider.devices;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.addressing.NetworkAddressElf;

/**
 * ZDeviceLite
 *
 */
@Entity(name = "ZDeviceLite")
@Table(name = "device")
public class ZDeviceLite
{
    @Id
    @Column(name = "device_id", updatable = false)
    private int deviceId;

    @Column(name = "inode", updatable = false)
    @XmlTransient
    private int inode;

    @Column(name = "ip_address", updatable = false)
    private String ipAddress;

    @Column(name = "ip_high", updatable = false)
    private long ipHigh;

    @Column(name = "ip_low", updatable = false)
    private long ipLow;

    @Column(name = "hostname", updatable = false)
    private String hostname;

    @Column(name = "network", updatable = false)
    private String managedNetwork;

    @Column(name = "adapter_id", updatable = false)
    private String adapterId;

    @Column(name = "device_type", updatable = false)
    private String deviceType;

    @Column(name = "vendor_hw", updatable = false)
    private String hardwareVendor;

    @Column(name = "canonical_hw_version", updatable = false)
    private String canonicalHwVersion;

    @Column(name = "model", updatable = false)
    private String model;

    @Column(name = "vendor_sw", updatable = false)
    private String softwareVendor;

    @Column(name = "canonical_os_version", updatable = false)
    private String canonicalOsVersion;

    @Column(name = "os_version", updatable = false)
    private String osVersion;

    @Column(name = "asset_identity", updatable = false)
    private String assetIdentity;

    @Column(name = "backup_status", updatable = false)
    private String backupStatus;

    @Column(name = "last_telemetry", updatable = false)
    private Date lastTelemetry;

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

    /**
     * @return the cannonicalHwVersion
     */
    @XmlTransient
    public String getCanonicalHwVersion()
    {
        return canonicalHwVersion;
    }

    /**
     * @param canonicalHwVersion the cannonicalHwVersion to set
     */
    public void setCanonicalHwVersion(String canonicalHwVersion)
    {
        this.canonicalHwVersion = canonicalHwVersion;
    }

    /**
     * @return the cannonicalOsVersion
     */
    @XmlTransient
    public String getCanonicalOsVersion()
    {
        return canonicalOsVersion;
    }

    /**
     * @param canonicalOsVersion the cannonicalOsVersion to set
     */
    public void setCanonicalOsVersion(String canonicalOsVersion)
    {
        this.canonicalOsVersion = canonicalOsVersion;
    }

    // ----------------------------------------------------------------------
    //                         External (SOAP) Attributes
    // ----------------------------------------------------------------------

    /**
     * @return the adapterId
     */
    public String getAdapterId()
    {
        return adapterId;
    }

    /**
     * @param adapterId the adapterId to set
     */
    public void setAdapterId(String adapterId)
    {
        this.adapterId = adapterId;
    }

    /**
     * @return the assetIdentity
     */
    public String getAssetIdentity()
    {
        return assetIdentity;
    }

    /**
     * @param assetIdentity the assetIdentity to set
     */
    public void setAssetIdentity(String assetIdentity)
    {
        this.assetIdentity = assetIdentity;
    }

    /**
     * @return the backupStatus
     */
    public String getBackupStatus()
    {
        return backupStatus;
    }

    /**
     * @param backupStatus the backupStatus to set
     */
    public void setBackupStatus(String backupStatus)
    {
        this.backupStatus = backupStatus;
    }

    /**
     * @return the hardwareVendor
     */
    public String getHardwareVendor()
    {
        return hardwareVendor;
    }

    /**
     * @param hardwareVendor the hardwareVendor to set
     */
    public void setHardwareVendor(String hardwareVendor)
    {
        this.hardwareVendor = hardwareVendor;
    }

    /**
     * @return the hostname
     */
    public String getHostname()
    {
        return hostname;
    }

    /**
     * @param hostname the hostname to set
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
     * @param ipAddress the ipAddress to set
     */
    public void setIpAddress(String ipAddress)
    {
        this.ipAddress = NetworkAddressElf.toDatabaseString(ipAddress);

        long[] hilo = NetworkAddressElf.getHiLo(ipAddress);
        setIpHigh(hilo[0]);
        setIpLow(hilo[1]);
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
     * @return the model
     */
    public String getModel()
    {
        return model;
    }

    /**
     * @param model the model to set
     */
    public void setModel(String model)
    {
        this.model = model;
    }

    /**
     * @return the osVersion
     */
    public String getOsVersion()
    {
        return osVersion;
    }

    /**
     * @param osVersion the osVersion to set
     */
    public void setOsVersion(String osVersion)
    {
        this.osVersion = osVersion;
    }

    /**
     * @return the softwareVendor
     */
    public String getSoftwareVendor()
    {
        return softwareVendor;
    }

    /**
     * @param softwareVendor the softwareVendor to set
     */
    public void setSoftwareVendor(String softwareVendor)
    {
        this.softwareVendor = softwareVendor;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return getIpAddress() + "@" + getManagedNetwork(); //$NON-NLS-1$
    }

    /**
     * @return the deviceType
     */
    public String getDeviceType()
    {
        return deviceType;
    }

    /**
     * @param deviceType the deviceType to set
     */
    public void setDeviceType(String deviceType)
    {
        this.deviceType = deviceType;
    }

    /**
     * @return the lastTelemetry
     */
    public Date getLastTelemetry()
    {
        return lastTelemetry;
    }

    /**
     * @param lastTelemetry the lastTelemetry to set
     */
    public void setLastTelemetry(Date lastTelemetry)
    {
        this.lastTelemetry = lastTelemetry;
    }
}
