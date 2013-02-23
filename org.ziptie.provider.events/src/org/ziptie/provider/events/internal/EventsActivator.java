package org.ziptie.provider.events.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.provider.events.EventProvider;
import org.ziptie.provider.events.IEventProvider;
import org.ziptie.server.security.ISecurityServiceEx;
import org.ziptie.zap.security.ISecurityService;

/**
 * EventsActivator
 */
public class EventsActivator implements BundleActivator
{
    private ServiceRegistration epRegistration;
    private static ServiceTracker eventTracker;
    private static ServiceTracker securityTracker;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        securityTracker = new ServiceTracker(context, ISecurityService.class.getName(), null);
        securityTracker.open();

        EventProvider ep = new EventProvider();

        epRegistration = context.registerService(IEventProvider.class.getName(), ep, null);
        
        eventTracker = new ServiceTracker(context, IEventProvider.class.getName(), null);
        eventTracker.open();
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        epRegistration.unregister();
        eventTracker.close();
        securityTracker.close();
    }

    /**
     * Get the IEventProvider.
     *
     * @return the IEventProvider
     */
    public static IEventProvider getEventProvider()
    {
        return (IEventProvider) eventTracker.getService();
    }

    public static ISecurityServiceEx getSecurityService()
    {
        return (ISecurityServiceEx) securityTracker.getService();
    }
}
