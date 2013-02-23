package org.ziptie.provider.configstore;

import org.ziptie.provider.configstore.internal.ConfigStoreActivator;
import org.ziptie.provider.devices.IDeviceStoreObserver;
import org.ziptie.provider.devices.ZDeviceCore;

/**
 * DeviceDeletionObserver
 */
public class DeviceStoreObserver implements IDeviceStoreObserver
{
    /** {@inheritDoc} */
    public void deviceTypeChanged(ZDeviceCore device)
    {
        // no-op
    }

    /** {@inheritDoc} */
    public void deviceCreated(ZDeviceCore device)
    {
        // no-op
    }

    /** {@inheritDoc} */
    public void deviceDeleted(ZDeviceCore device)
    {
        RuntimeException re = null;
        try
        {
            ConfigStore configStore = (ConfigStore) ConfigStoreActivator.getConfigStore();
            configStore.deleteRevisionHistory(device);
        }
        catch (RuntimeException e)
        {
            // Store the exception, but continue on with deleting the device from the full
            // text search index.
            re = e;
        }

        ConfigSearch configSearch = (ConfigSearch) ConfigStoreActivator.getConfigSearch();
        configSearch.deleteFromIndex(device);

        // If the first phase had an exception, re-throw it
        if (re != null)
        {
            throw re;
        }
    }
}
