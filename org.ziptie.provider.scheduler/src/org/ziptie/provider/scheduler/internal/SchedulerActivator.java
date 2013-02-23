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
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 */

package org.ziptie.provider.scheduler.internal;

import java.io.File;
import java.io.FileInputStream;
import java.net.URI;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionDelta;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.IRegistryChangeEvent;
import org.eclipse.core.runtime.IRegistryChangeListener;
import org.eclipse.core.runtime.Platform;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.packageadmin.PackageAdmin;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.provider.scheduler.IScheduler;
import org.ziptie.provider.scheduler.JobType;
import org.ziptie.provider.scheduler.Scheduler;
import org.ziptie.provider.scheduler.SchedulerException;
import org.ziptie.zap.jta.TransactionElf;
import org.ziptie.zap.security.ISecurityService;

/**
 * Activator.
 */
public class SchedulerActivator implements BundleActivator, IRegistryChangeListener
{
    private static final String EXTENSION_NAMESPACE = "org.ziptie.provider.scheduler";
    private static final String EXTENSION_POINT_ID = EXTENSION_NAMESPACE + ".quartzJob";
    private static Logger USER_LOG = Logger.getLogger(SchedulerActivator.class);

    private static BundleContext context;
    private static Scheduler scheduler;
    private static ServiceTracker dsTracker;
    private static ServiceTracker sessionTracker;
    private static ServiceTracker securityTracker;
    private static boolean ramStore;

    private ServiceTracker bundleTracker;
    private IExtensionRegistry extensionRegistry;
    private ServiceRegistration serviceRegistration;

    /**
     * Default constructor.
     */
    public SchedulerActivator()
    {
        extensionRegistry = Platform.getExtensionRegistry();
        extensionRegistry.addRegistryChangeListener(this, EXTENSION_NAMESPACE);
    }

    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        USER_LOG.info("Scheduler starting...");

        try
        {
            context = ctx;

            sessionTracker = new ServiceTracker(context, SessionFactory.class.getName(), null);
            sessionTracker.open();

            dsTracker = new ServiceTracker(context, DataSource.class.getName(), null);
            dsTracker.open();

            securityTracker = new ServiceTracker(context, ISecurityService.class.getName(), null);
            securityTracker.open();

            Properties props = getSchedulerProperties();
            ramStore = props.getProperty("org.quartz.jobStore.class").indexOf("RAMJobStore") > -1;

            cleanupAbandonedJobs();

            createScheduler(props);

            USER_LOG.info("Scheduler started.");
        }
        catch (Exception e)
        {
            USER_LOG.fatal("Scheduler failed to start.", e);
            throw e;
        }
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        USER_LOG.info("Scheduler stopping...");
        extensionRegistry.removeRegistryChangeListener(this);

        if (bundleTracker != null)
        {
            bundleTracker.close();
            bundleTracker = null;
        }

        securityTracker.close();
        securityTracker = null;

        dsTracker.close();
        dsTracker = null;

        destroyScheduler();
        scheduler = null;

        sessionTracker.close();
        sessionTracker = null;

        USER_LOG.info("Scheduler stopped.");
    }

    /** {@inheritDoc} */
    public void registryChanged(IRegistryChangeEvent event)
    {
        IExtensionDelta[] extensionDeltas = event.getExtensionDeltas(EXTENSION_NAMESPACE);
        if (extensionDeltas.length > 0)
        {
            try
            {
                USER_LOG.info("Bundle change detected.  Restarting scheduler.");
                configureSchedulerJobTypes();
            }
            catch (SchedulerException se)
            {
                USER_LOG.fatal("Bundle change listener was unable to recreate scheduler service.", se);
            }
        }
    }

    private Properties getSchedulerProperties() throws Exception
    {
        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20");
        File configDir = new File(URI.create(configArea));
        File configFile = new File(configDir, String.format("/quartz/quartz.%s.properties", System.getProperty("database", "derby")));
        if (!configFile.exists())
        {
            configFile = new File(configDir, "/quartz/quartz.properties");
        }

        if (configFile.exists())
        {
            USER_LOG.debug("Quartz configuration file using " + configFile);
            Properties props = new Properties();
            props.load(new FileInputStream(configFile));
            return props;
        }
        else
        {
            USER_LOG.error("No quartz configuration file");
            throw new Exception("Missing Quartz Configuration");
        }
    }

    /**
     * Create, register, and start the scheduler.
     *
     * @throws SchedulerException thrown if there is an error starting the scheduler.
     */
    private void createScheduler(Properties props) throws SchedulerException
    {
        scheduler = new Scheduler(props);
        configureSchedulerJobTypes();
        scheduler.start();
        serviceRegistration = context.registerService(IScheduler.class.getName(), scheduler, null);
        USER_LOG.info("Scheduler service registered.");
    }

    /**
     * Shutdown and deregister the scheduler.
     *
     * @throws SchedulerException thrown if there is an error shutting down the scheduler
     */
    private void destroyScheduler() throws SchedulerException
    {
        scheduler.shutdown();
        serviceRegistration.unregister();
        USER_LOG.info("Scheduler service unregistered.");
    }

    /**
     * Use the extension point registry to discover job types and register them.
     */
    private void configureSchedulerJobTypes() throws SchedulerException
    {
        IConfigurationElement[] configElements = extensionRegistry.getConfigurationElementsFor(EXTENSION_POINT_ID);

        if (configElements.length == 0)
        {
            USER_LOG.warn("No jobs discovered by scheduler.");
        }

        Map<String, JobType> jobTypeCopy = new HashMap<String, JobType>(scheduler.getJobTypeMapping());

        for (IConfigurationElement element : configElements)
        {
            String name = element.getAttribute("name");
            String className = element.getAttribute("class");
            String cudPermission = element.getAttribute("cudPermission");
            String runPermission = element.getAttribute("runPermission");

            try
            {
                String targetBundle = element.getContributor().getName();
                Bundle bundle = getBundle(targetBundle);
                Class clazz = bundle.loadClass(className);

                JobType jobType = jobTypeCopy.get(name);
                if (jobType == null)
                {
                    USER_LOG.info(String.format("Discovered Job '%s'", name));
                    if (USER_LOG.isDebugEnabled())
                    {
                        USER_LOG.debug(String.format("  Job '%s' in bundle '%s'", name, targetBundle));
                    }
                    scheduler.registerJobType(name, clazz, cudPermission, runPermission);
                }
                else if (!jobType.getJobClass().equals(clazz))
                {
                    scheduler.unregisterJobType(name, jobType.getJobClass());
                    USER_LOG.info(String.format("Rediscovered Updated Job Type '%s' in bundle '%s'", name, targetBundle));
                    scheduler.registerJobType(name, clazz, cudPermission, runPermission);
                }
                // otherwise the job type mapping is already known by the scheduler

                // remove job types as we discover them, so that only unknown (removed)
                // job types are still hanging around at the end
                jobTypeCopy.remove(name);
            }
            catch (ClassNotFoundException cnfe)
            {
                USER_LOG.error(String.format("Scheduler bundle unable to load Job Type with class '%s'", className), cnfe);
            }
        }

        // remove any job types that weren't rediscovered.
        for (Map.Entry<String, JobType> me : jobTypeCopy.entrySet())
        {
            scheduler.unregisterJobType(me.getKey(), me.getValue().getJobClass());
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
    private Bundle getBundle(String symbolicName)
    {
        PackageAdmin packageAdmin = getBundleAdmin();
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

    /**
     * Get the PackageAdmin service for this OSGi instance.
     *
     * @return the PackageAdmin service instance for this OSGi instance.
     */
    private PackageAdmin getBundleAdmin()
    {
        if (bundleTracker == null)
        {
            if (context == null)
            {
                return null;
            }
            bundleTracker = new ServiceTracker(context, PackageAdmin.class.getName(), null);
            bundleTracker.open();
        }
        return (PackageAdmin) bundleTracker.getService();
    }

    /**
     * Set the status of any jobs that are marked as "still running" to canceled.  Of we're just
     * starting up, these jobs are NOT running anymore.  Of course, I don't know what this means
     * in a bundle restart scenario ... not sure what to do about that, as it's theoretically 
     * possible for a schedule to be running at the time we restart this bundle.  Ah well, an
     * obscure bug for another day.
     */
    private void cleanupAbandonedJobs()
    {
        if (!isRAMStore())
        {
            TransactionElf.beginOrJoinTransaction();

            try
            {
                Session session = getSessionFactory().getCurrentSession();
                Query query = session.createQuery("UPDATE ExecutionData e SET e.endTime=:et, e.canceled=true WHERE e.endTime=null");
                query.setTimestamp("et", Calendar.getInstance().getTime());
                int updated = query.executeUpdate();
                TransactionElf.commit();

                if (updated > 0)
                {
                    USER_LOG.info(String.format("Set status of %d abandonded jobs to cancelled.", updated));
                }
            }
            catch (Exception e)
            {
                USER_LOG.warn("Exception resetting status of abandoned jobs.", e);
            }
        }
    }

    /**
     * Lookup the data source service.
     * @return The data source instance.
     */
    public static DataSource getDataSource()
    {
        return (DataSource) dsTracker.getService();
    }

    /**
     * Lookup the hibernate session factory service.
     * @return The session factory instance.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionTracker.getService();
    }

    /**
     * Lookup the security service.
     * @return the security service instance.
     */
    public static ISecurityService getSecurityService()
    {
        return (ISecurityService) securityTracker.getService();
    }

    /**
     * Get the singleton scheduler.
     * @return The scheduler instance.
     */
    public static Scheduler getScheduler()
    {
        return scheduler;
    }

    /**
     * Method to check whether the scheduler is using a RAM Store.
     *
     * @return true if the scheduler using a RAM Store
     */
    public static boolean isRAMStore()
    {
        return ramStore;
    }
}
