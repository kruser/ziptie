package org.ziptie.provider.devices;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.addressing.NetworkAddressElf;

/**
 * ZDeviceStatus
 */
@Entity(name = "ZDeviceStatus")
@Table(name  = "device")
public class ZDeviceStatus
{
    @Id
    @Column(name = "device_id", updatable = false)
    private int deviceId;

    @Column(name = "inode", updatable = false)
    private int inode;

    @Column(name = "ip_address", updatable = false)
    private String ipAddress;

    @Column(name = "network", updatable = false)
    private String managedNetwork;

    @Column(name = "hostname")
    private String hostname;

    @Column(name = "vendor_hw")
    private String hardwareVendor;

    @Column(name = "hw_version")
    private String hwVersion;

    @Column(name = "canonical_hw_version")
    private String canonicalHwVersion;

    @Column(name = "model")
    private String model;

    @Column(name = "vendor_sw")
    private String softwareVendor;

    @Column(name = "os_version")
    private String osVersion;

    @Column(name = "canonical_os_version")
    private String canonicalOsVersion;

    @Column(name = "asset_identity")
    private String assetIdentity;

    @Column(name = "backup_status")
    private String backupStatus;

    @Column(name = "backup_message")
    private String backupStatusMessage;

    @Column(name = "last_backup")
    private Date lastBackupAttempt;

    @Column(name = "last_telemetry")
    private Date lastTelemetry;

    @Column(name = "device_type")
    private String deviceType;

    /**
     * Default constructor.
     */
    public ZDeviceStatus()
    {
        // default constructor
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
     * @param canonicalOsVersion The canonical OS version.
     */
    public void setCanonicalOsVersion(String canonicalOsVersion)
    {
        this.canonicalOsVersion = canonicalOsVersion;
    }

    // ----------------------------------------------------------------------
    //                         External (SOAP) Attributes
    // ----------------------------------------------------------------------


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
     * Set the hostname of the device.
     *
     * @param hostname the hostname of the device
     */
    public void setHostname(String hostname)
    {
        this.hostname = hostname;
    }

    /**
     * Get the hostname of the device.
     *
     * @return the hostname
     */
    public String getHostname()
    {
        return hostname;
    }

    /**
     * @return the hwVersion
     */
    public String getHwVersion()
    {
        return hwVersion;
    }

    /**
     * @param hwVersion the hwVersion to set
     */
    public void setHwVersion(String hwVersion)
    {
        this.hwVersion = hwVersion;
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
     * @param backupStatusMessage The backup status message or <code>null</code>
     */
    public void setBackupStatusMessage(String backupStatusMessage)
    {
        this.backupStatusMessage = backupStatusMessage;
    }

    /**
     * @return the backup status message or <code>null</code>
     */
    public String getBackupStatusMessage()
    {
        return backupStatusMessage;
    }

    /**
     * @param lastBackupAttempt The time that the last backup was attempted, or <code>null</code> for never.
     */
    public void setLastBackupAttempt(Date lastBackupAttempt)
    {
        this.lastBackupAttempt = lastBackupAttempt;
    }

    /**
     * @return The time that the last backup was attempted, or <code>null</code> for never.
     */
    public Date getLastBackupAttempt()
    {
        return lastBackupAttempt;
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
