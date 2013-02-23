package org.ziptie.provider.security.internal;

import org.hibernate.SessionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.osgi.framework.ServiceRegistration;
import org.ziptie.provider.security.ISecurityProvider;
import org.ziptie.provider.security.SecurityProvider;
import org.ziptie.server.security.ISecurityServiceEx;
import org.ziptie.zap.security.ISecurityService;

public class SecurityProviderActivator implements BundleActivator
{

    private static SecurityProviderActivator theOneTrueActivator;
    private static BundleContext context;
    private ISecurityProvider securityProvider;
    private ServiceRegistration providerRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        SecurityProviderActivator.context = context;

        theOneTrueActivator = this;

        securityProvider = new SecurityProvider();
        providerRegistration = context.registerService(ISecurityProvider.class.getName(), securityProvider, null);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        providerRegistration.unregister();
    }

    /**
     * Get the ISecurityProvider implementation.
     * 
     * @return the ISecurityProvider implementation
     */
    public static ISecurityProvider getSecurityProvider()
    {
        return theOneTrueActivator.securityProvider;
    }

    /**
     * Get the SessionFactory.
     *
     * @return the SessionFactory
     */
    public static SessionFactory getSessionFactory()
    {
        ServiceReference serviceReference = context.getServiceReference(SessionFactory.class.getName());
        return (SessionFactory) context.getService(serviceReference);
    }

    /**
     * Get the security service.
     *
     * @return the ISecurityServiceEx implementation
     */
    public static ISecurityServiceEx getSecurityService()
    {
        ServiceReference serviceReference = context.getServiceReference(ISecurityService.class.getName());
        return (ISecurityServiceEx) context.getService(serviceReference);        
    }
}
