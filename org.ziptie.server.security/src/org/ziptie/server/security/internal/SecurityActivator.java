package org.ziptie.server.security.internal;

import org.hibernate.SessionFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.osgi.framework.ServiceRegistration;
import org.ziptie.server.security.ISecurityServiceEx;
import org.ziptie.server.security.SecurityService;
import org.ziptie.zap.security.ISecurityService;
import org.ziptie.zap.web.IWebService;

/**
 * The activator class controls the plug-in life cycle
 */
public class SecurityActivator implements BundleActivator
{
    private static SecurityActivator theOneTrueActivator;
    private static BundleContext context;
    private String bootstrapVersion;
    private SecurityService service;
    private ServiceRegistration registration;

    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        theOneTrueActivator = this;

        context = ctx;
        service = new SecurityService();
        registration = context.registerService(ISecurityService.class.getName(), service, null);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        theOneTrueActivator = null;

        service = null;
        registration.unregister();
    }

    /**
     * Get the version of the bootstrap bundle.
     *
     * @return the bootstrap version
     */
    public static synchronized String getBootstrapVersion()
    {
        if (theOneTrueActivator.bootstrapVersion == null)
        {
            Bundle[] bundles = context.getBundles();
            for (Bundle bundle : bundles)
            {
                if (bundle.getSymbolicName().contains("bootstrap")) //$NON-NLS-1$
                {
                    theOneTrueActivator.bootstrapVersion = (String) bundle.getHeaders().get("Bundle-Version"); //$NON-NLS-1$
                    break;
                }
            }
        }

        return theOneTrueActivator.bootstrapVersion;
    }

    /**
     * Get the ISecurityService impl. reference.
     *
     * @return the ISecurityService
     */
    public static ISecurityServiceEx getSecurityService()
    {
        return theOneTrueActivator.service;
    }

    /**
     * Get the IWebService implementation.
     *
     * @return the IWebService implementation
     */
    public static IWebService getWebService()
    {
        ServiceReference serviceReference = context.getServiceReference(IWebService.class.getName());
        return (IWebService) context.getService(serviceReference);
    }

    /**
     * Get the Hibernate session factory.
     *
     * @return the SessionFactory
     */
    public static SessionFactory getSessionFactory()
    {
        ServiceReference serviceReference = context.getServiceReference(SessionFactory.class.getName());
        return (SessionFactory) context.getService(serviceReference);
    }
}
