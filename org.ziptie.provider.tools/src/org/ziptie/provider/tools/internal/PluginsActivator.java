/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 */
package org.ziptie.provider.tools.internal;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.hibernate.SessionFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.BundleEvent;
import org.osgi.framework.ServiceRegistration;
import org.osgi.framework.SynchronousBundleListener;
import org.osgi.service.packageadmin.PackageAdmin;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.perl.PerlPoolManager;
import org.ziptie.provider.devices.IDeviceProvider;
import org.ziptie.provider.scheduler.IScheduler;
import org.ziptie.provider.scheduler.Scheduler;
import org.ziptie.provider.tools.IPluginManager;
import org.ziptie.provider.tools.IPluginProvider;
import org.ziptie.provider.tools.PluginProvider;
import org.ziptie.server.dispatcher.OperationManager;
import org.ziptie.server.security.ISecurityServiceEx;
import org.ziptie.zap.security.ISecurityService;
import org.ziptie.zap.web.IWebService;

/**
 * ToolsActivator
 */
public class PluginsActivator implements BundleActivator, SynchronousBundleListener
{
    private static final Logger LOGGER = Logger.getLogger(PluginsActivator.class);

    private static final String EXTENSION_POINT_ID = "org.ziptie.provider.plugins"; //$NON-NLS-1$

    private static PluginProvider pluginsProvider;
    private static BundleContext context;

    private static ServiceTracker packageTracker;
    private static ServiceTracker schedulerTracker;
    private static ServiceTracker opManTracker;
    private static ServiceTracker deviceTracker;
    private static ServiceTracker securityTracker;
    private static ServiceTracker sessionFactoryTracker;
    private static ServiceTracker perlTracker;
    private static ServiceTracker webTracker;

    private static List<IPluginManager> pluginManagers;

    private ServiceRegistration registration;


    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        pluginsProvider = new PluginProvider();

        registration = ctx.registerService(IPluginProvider.class.getName(), pluginsProvider, null);

        context = ctx;
        pluginManagers = new ArrayList<IPluginManager>();

        perlTracker = new ServiceTracker(ctx, PerlPoolManager.class.getName(), null);
        perlTracker.open();

        packageTracker = new ServiceTracker(ctx, PackageAdmin.class.getName(), null);
        packageTracker.open();

        opManTracker = new ServiceTracker(ctx, OperationManager.class.getName(), null);
        opManTracker.open();

        deviceTracker = new ServiceTracker(ctx, IDeviceProvider.class.getName(), null);
        deviceTracker.open();

        securityTracker = new ServiceTracker(ctx, ISecurityService.class.getName(), null);
        securityTracker.open();

        sessionFactoryTracker = new ServiceTracker(context, SessionFactory.class.getName(), null);
        sessionFactoryTracker.open();

        schedulerTracker = new ServiceTracker(context, IScheduler.class.getName(), null);
        schedulerTracker.open();

        webTracker = new ServiceTracker(context, IWebService.class.getName(), null);
        webTracker.open();

        context.addBundleListener(this);

        bindExtensions();
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        registration.unregister();
        registration = null;

        context = null;

        packageTracker.close();
        schedulerTracker.close();
        opManTracker.close();
        deviceTracker.close();
        securityTracker.close();
        webTracker.close();
        sessionFactoryTracker.close();
        sessionFactoryTracker = null;
        perlTracker.close();
    }

    /**
     * Get a reference to the scheduler.
     *
     * @return a reference to the scheduler
     */
    public static Scheduler getScheduler()
    {
        return (Scheduler) schedulerTracker.getService();
    }

    /**
     * Get the Operation Manager for device operations.
     *
     * @return the Operation Manager
     */
    public static OperationManager getOperationManager()
    {
        return (OperationManager) opManTracker.getService();
    }

    /**
     * Get the Device Provider.
     *
     * @return the Device Provider
     */
    public static IDeviceProvider getDeviceProvider()
    {
        return (IDeviceProvider) deviceTracker.getService();
    }

    /**
     * Get the Security Service.
     *
     * @return the Security Service
     */
    public static ISecurityServiceEx getSecurityService()
    {
        return (ISecurityServiceEx) securityTracker.getService();
    }

    /**
     * Lookup the hibernate session factory instance.
     *
     * @return The singleton session factory.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionFactoryTracker.getService();
    }

    /**
     * Lookup the Perl server pool instance.
     * @return The singleton perl pool.
     */
    public static PerlPoolManager getPerlPoolManager()
    {
        return (PerlPoolManager) perlTracker.getService();
    }

    /**
     * Get the Tools Provider.
     * 
     * @return the Tools Provider
     */
    public static IPluginProvider getToolsProvider()
    {
        return pluginsProvider;
    }

    /**
     * @param className the classname of the plugin manager to get a reference to
     * @return the appropriate plugin manager
     */
    public static IPluginManager getPluginManager(String className)
    {
        return (IPluginManager) context.getService(context.getServiceReference(className));
    }

    /**
     * Get the WebService.
     *
     * @return the IWebService
     */
    public static IWebService getWebService()
    {
        return (IWebService) webTracker.getService();
    }

    /**
     * @return the bundle context
     */
    public static BundleContext getContext()
    {
        return context;
    }

    /**
     * @return the list of plugin managers
     */
    public static List<IPluginManager> getPluginManagers()
    {
        return pluginManagers;
    }

    /** {@inheritDoc} */
    public void bundleChanged(BundleEvent event)
    {
        //        if (event.getType() == BundleEvent.INSTALLED)
        //        {
        //            scriptToolManager.scanBundleForInstall(event.getBundle());
        //        }
        //        else if (event.getType() == BundleEvent.UNINSTALLED)
        //        {
        //            scriptToolManager.scanBundleForUninstall(event.getBundle());
        //        }
        //        else if (event.getType() == BundleEvent.UPDATED)
        //        {
        //            scriptToolManager.scanBundleForUninstall(event.getBundle());
        //            scriptToolManager.scanBundleForInstall(event.getBundle());
        //        }
    }

    private void bindExtensions()
    {
        IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();
        IConfigurationElement[] configElements = extensionRegistry.getConfigurationElementsFor(EXTENSION_POINT_ID);

        Class<?>[] classes = new Class[configElements.length];
        if (configElements.length == 0)
        {
            LOGGER.warn(String.format("No %s extensions discovered.", EXTENSION_POINT_ID)); //$NON-NLS-1$
        }
        else
        {
            int i = 0;
            for (IConfigurationElement element : configElements)
            {
                String className = element.getAttribute("class"); //$NON-NLS-1$
                try
                {
                    String targetBundle = element.getContributor().getName();
                    Bundle bundle = getBundle(targetBundle);
                    Class<?> clazz = bundle.loadClass(className);
                    classes[i++] = clazz;

                    IPluginManager newInstance = (IPluginManager) clazz.newInstance();
                    pluginManagers.add(newInstance);
                    context.registerService(className, newInstance, null);
                }
                catch (Exception cnfe)
                {
                    LOGGER.error(String.format("ConfigStore bundle unable to load extension class '%s'", className), cnfe); //$NON-NLS-1$
                }
            }
        }
    }

    /**
     * Returns the resolved bundle with the specified symbolic name that has the
     * highest version.  If no resolved bundles are installed that have the 
     * specified symbolic name then null is returned.
     * <p>
     * @param symbolicName the symbolic name of the bundle to be returned.
     * @return the bundle that has the specified symbolic name with the 
     * highest version, or <tt>null</tt> if no bundle is found.
     */
    public static Bundle getBundle(String symbolicName)
    {
        PackageAdmin packageAdmin = getPackageAdmin();
        if (packageAdmin == null)
        {
            return null;
        }

        Bundle[] bundles = packageAdmin.getBundles(symbolicName, null);
        if (bundles == null)
        {
            return null;
        }

        //Return the first bundle that is not installed or uninstalled
        for (int i = 0; i < bundles.length; i++)
        {
            if ((bundles[i].getState() & (Bundle.INSTALLED | Bundle.UNINSTALLED)) == 0)
            {
                return bundles[i];
            }
        }
        return null;
    }

    private static PackageAdmin getPackageAdmin()
    {
        return (PackageAdmin) packageTracker.getService();
    }
}
