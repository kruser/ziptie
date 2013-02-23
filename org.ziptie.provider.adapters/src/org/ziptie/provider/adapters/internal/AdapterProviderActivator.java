package org.ziptie.provider.adapters.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.net.adapters.IAdapterService;
import org.ziptie.provider.adapters.AdapterProvider;
import org.ziptie.provider.adapters.IAdapterProvider;

/**
 * AdapterProviderActivator
 */
public class AdapterProviderActivator implements BundleActivator
{
    private static AdapterProvider adapters;
    private static ServiceTracker adapterTracker;

    private ServiceRegistration registration;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        adapterTracker = new ServiceTracker(context, IAdapterService.class.getName(), null);
        adapterTracker.open();

        adapters = new AdapterProvider();
        registration = context.registerService(IAdapterProvider.class.getName(), adapters, null);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        registration.unregister();

        adapters = null;

        adapterTracker.close();
        adapterTracker = null;
    }

    /**
     * Get the adapter provider singleton.
     * @return The adapter provider instance.
     */
    public static IAdapterProvider getAdapterProvider()
    {
        return adapters;
    }

    /**
     * Lookup the adapter service.
     * @return the adapter service.
     */
    public static IAdapterService getAdapterService()
    {
        return (IAdapterService) adapterTracker.getService();
    }
}
