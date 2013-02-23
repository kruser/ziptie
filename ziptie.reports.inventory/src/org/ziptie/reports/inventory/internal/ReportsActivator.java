package org.ziptie.reports.inventory.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.provider.configstore.IConfigStore;

/**
 * ReportsActivator
 */
public class ReportsActivator implements BundleActivator
{
    private static ServiceTracker configStoreTracker;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        configStoreTracker = new ServiceTracker(context, IConfigStore.class.getName(), null);
        configStoreTracker.open();
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
    }

    /**
     * Get a reference to the configuration store.
     *
     * @return a reference to an IConfigStore
     */
    public static IConfigStore getConfigStore()
    {
        return (IConfigStore) configStoreTracker.getService();
    }
}
