package org.ziptie.server.restore.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.provider.configstore.IConfigStore;
import org.ziptie.provider.scheduler.IScheduler;
import org.ziptie.server.dispatcher.OperationManager;

/**
 * The {@link RestoreActivator} class provides the mechanism for starting and stopping the functionality of the
 * org.ziptie.server.restore bundle.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public class RestoreActivator implements BundleActivator
{
    private static ServiceTracker configStoreTracker;
    private static ServiceTracker operationManagerTracker;
    private static ServiceTracker schedulerTracker;

    /**
     * {@inheritDoc}
     */
    public void start(BundleContext context) throws Exception
    {
        operationManagerTracker = new ServiceTracker(context, OperationManager.class.getName(), null);
        operationManagerTracker.open();

        configStoreTracker = new ServiceTracker(context, IConfigStore.class.getName(), null);
        configStoreTracker.open();

        schedulerTracker = new ServiceTracker(context, IScheduler.class.getName(), null);
        schedulerTracker.open();
    }

    /**
     * {@inheritDoc}
     */
    public void stop(BundleContext context) throws Exception
    {
        schedulerTracker.close();
        schedulerTracker = null;

        configStoreTracker.close();
        configStoreTracker = null;

        operationManagerTracker.close();
        operationManagerTracker = null;
    }

    /**
     * Get the Operation Manager for device operations.
     *
     * @return the Operation Manager
     */
    public static OperationManager getOperationManager()
    {
        return (OperationManager) operationManagerTracker.getService();
    }

    /**
     * Look up the config store service.
     * 
     * @return The config store service.
     */
    public static IConfigStore getConfigStoreService()
    {
        return (IConfigStore) configStoreTracker.getService();
    }

    /**
     * Look up the scheduler service.
     * 
     * @return The scheduler service.
     */
    public static IScheduler getSchedulerService()
    {
        return (IScheduler) schedulerTracker.getService();
    }
}
