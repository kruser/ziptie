package org.ziptie.provider.devices;

/**
 * IDeviceStoreObserver
 */
public interface IDeviceStoreObserver
{
    /**
     * Called by the Device Provider when a device is created.
     *
     * @param device the created device
     */
    void deviceCreated(ZDeviceCore device);

    /**
     * Called by the Device Provider when a device is deleted.
     *
     * @param device the deleted device
     */
    void deviceDeleted(ZDeviceCore device);

    /**
     * Called by the Device Provider when a device type (adapter) is changed.
     * 
     * @param device the changed device
     */
    void deviceTypeChanged(ZDeviceCore device);
}
