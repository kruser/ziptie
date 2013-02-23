package org.ziptie.provider.credentials;

import org.apache.log4j.Logger;
import org.ziptie.exception.PersistenceException;
import org.ziptie.provider.devices.IDeviceStoreObserver;
import org.ziptie.provider.devices.ZDeviceCore;

/**
 * Make changes to the stored credentials and protocols based on 
 * changes to the inventory.
 */
public class InventoryChangeListener implements IDeviceStoreObserver
{
    private static Logger LOGGER = Logger.getLogger(InventoryChangeListener.class);

    /**
     * {@inheritDoc}
     */
    public void deviceCreated(ZDeviceCore device)
    {
        // no-op
    }

    /**
     * {@inheritDoc}
     */
    public void deviceDeleted(ZDeviceCore device)
    {
        try
        {
            String deviceId = Integer.toString(device.getDeviceId());
            ZipTieCredentialsManager.getInstance().clearDeviceToCredentialSetMapping(deviceId);
            ZipTieProtocolManager.getInstance().clearDeviceToProtocolMapping(deviceId);
        }
        catch (PersistenceException e)
        {
            LOGGER.error(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void deviceTypeChanged(ZDeviceCore device)
    {
        try
        {
            String deviceId = Integer.toString(device.getDeviceId());
            ZipTieProtocolManager.getInstance().clearDeviceToProtocolMapping(deviceId);
        }
        catch (PersistenceException e)
        {
            LOGGER.error(e);
        }
    }
}
