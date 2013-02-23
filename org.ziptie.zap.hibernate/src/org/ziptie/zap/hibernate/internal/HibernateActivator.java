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

package org.ziptie.zap.hibernate.internal;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionDelta;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.IRegistryChangeEvent;
import org.eclipse.core.runtime.IRegistryChangeListener;
import org.eclipse.core.runtime.Platform;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.AnnotationConfiguration;
import org.hibernate.cfg.Configuration;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.zap.util.BundleFinderHelper;

/**
 * Activator.
 */
public class HibernateActivator implements BundleActivator, IRegistryChangeListener
{
    private static final String ATTR_NAME = "name";
    private static Logger LOGGER = Logger.getLogger(HibernateActivator.class);
    private static final String EXTENSION_NAMESPACE = "org.ziptie.zap.hibernate";
    private static final String EXTENSION_POINT_ID = "PersistenceUnit";
    private static final String META_INF = "/META-INF/"; //$NON-NLS-1$

    private static Map<String, Integer> tracingBundles;

    private static BundleContext context;
    private BundleFinderHelper bundleFinder;
    private IExtensionRegistry extensionRegistry;
    private ServiceTracker bundleTracker;
    private Map<String, ServiceRegistration> cfgRegistrations;
    private Map<String, ServiceRegistration> sfRegistrations;

    /**
     * Default constructor.
     */
    public HibernateActivator()
    {
        cfgRegistrations = new HashMap<String, ServiceRegistration>();
        sfRegistrations = new HashMap<String, ServiceRegistration>();
    }

    /**
     * {@inheritDoc}
     */
    public void start(BundleContext bundleContext) throws Exception
    {
        LOGGER.info("Hibernate starting...");
        context = bundleContext;
        bundleFinder = new BundleFinderHelper(bundleContext);

        CustomConnectionProvider.init(context);
        ZTransactionManagerLookup.init(context);
        ZTransactionFactory.init(context);

        try
        {
            tracingBundles = new HashMap<String, Integer>();

            extensionRegistry = Platform.getExtensionRegistry();
            extensionRegistry.addRegistryChangeListener(this, EXTENSION_NAMESPACE);

            configureHibernate();

            LOGGER.info("Hibernate started.");
        }
        catch (Exception e)
        {
            LOGGER.fatal("Hibernate failed to start.", e);
            throw e;
        }
    }

    /**
     * {@inheritDoc}
     */
    public void stop(BundleContext bundleContext) throws Exception
    {
        extensionRegistry.removeRegistryChangeListener(this);

        if (bundleTracker != null)
        {
            bundleTracker.close();
            bundleTracker = null;
        }

        for (ServiceRegistration sr : cfgRegistrations.values())
        {
            sr.unregister();
        }
        cfgRegistrations.clear();

        for (ServiceRegistration sr : sfRegistrations.values())
        {
            sr.unregister();
        }
        sfRegistrations.clear();

        LOGGER.info("Hibernate stopped.");
    }

    /** {@inheritDoc} */
    public void registryChanged(IRegistryChangeEvent event)
    {
        IExtensionDelta[] extensionDeltas = event.getExtensionDeltas(EXTENSION_NAMESPACE, EXTENSION_POINT_ID);

        if (extensionDeltas.length > 0)
        {
            configureHibernate();
        }
    }

    /**
     * Configure the HibernateBundle bundle.
     *
     * @throws HibernateBundleException thrown if there is an error starting the bundle.
     */
    private void configureHibernate()
    {
        // acquire the OSGi service.ranking of all currently registered DataSource
        // services.  we will reuse these rankings when registering associated
        // SessionManager services.
        Map<String, Integer> dsRankings = getDataSourceRankings(context);

        // get the list of all hibernated classes
        Map<String, List<Object>> unitNameToClassList = findHibernateArtifacts();

        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        File hibernateConfigDir = new File(URI.create(configArea + "hibernate"));
        if (!hibernateConfigDir.isDirectory())
        {
            LOGGER.fatal("configureHibernate: " + hibernateConfigDir + " directory not found");
        }

        // score the Hibernate configuration files; either by the one specified
        // "database" System property, or by number if there is no "database".
        String database = System.getProperty("database"); //$NON-NLS-1$
        if (database == null)
        {
            for (int i = 1; i <= 10; i++)
            {
                File configFile = new File(hibernateConfigDir, String.format("hibernate.cfg.%d.xml", i));
                if (!configFile.exists())
                {
                    return;
                }

                configureHibernate(configFile, dsRankings, unitNameToClassList);
            }
        }
        else
        {
            File configFile = new File(hibernateConfigDir, String.format("hibernate.cfg.%s.xml", database));
            if (!configFile.exists())
            {
                LOGGER.fatal("configurateHibernate: " + configFile + " not found");
            }

            configureHibernate(configFile, dsRankings, unitNameToClassList);
        }

        for (Map.Entry<String, List<Object>> me : unitNameToClassList.entrySet())
        {
            LOGGER.error("persistence-unit " + me.getKey() + " not found; " + me.getValue().size()
                    + " hibernated classes have no home");
        }
    }

    private Map<String, Integer> getDataSourceRankings(BundleContext bundleContext)
    {
        Map<String, Integer> rankings = new HashMap<String, Integer>();

        try
        {

            ServiceReference[] refs = bundleContext.getServiceReferences(DataSource.class.getName(), null);
            for (ServiceReference ref : refs)
            {
                String servicePID = (String) ref.getProperty("service.pid");
                Integer serviceRanking = (Integer) ref.getProperty("service.ranking");

                if (servicePID != null && serviceRanking != null)
                {
                    rankings.put(servicePID, serviceRanking);
                }
            }
        }
        catch (Exception ex)
        {
            LOGGER.warn("unable to acquire all data source service rankings", ex);
        }

        return rankings;
    }

    private void configureHibernate(File configFile, Map<String, Integer> dsRankings,
                                    Map<String, List<Object>> unitNameToClassList)
    {
        Dictionary<String, Object> props = new Hashtable<String, Object>();

        AnnotationConfiguration configuration = new AnnotationConfiguration();
        configuration.configure(configFile);
        String dsUniqueName = configuration.getProperty("datasource.uniqueName");
        if (dsUniqueName == null)
        {
            dsUniqueName = "ziptie-ds";
        }

        List<Object> artifacts = unitNameToClassList.remove(dsUniqueName);
        if (artifacts == null || artifacts.size() == 0)
        {
            LOGGER.warn("configured hibernate source " + dsUniqueName + " contains no annotated classes");
            return;
        }

        String dialect = configuration.getProperty("hibernate.dialect");
        dialect = dialect.substring(dialect.lastIndexOf('.') + 1);
        for (Object artifact : artifacts)
        {
            try
            {
                if (artifact instanceof Class)
                {
                    configuration.addAnnotatedClass((Class) artifact);
                }
                else if (artifact instanceof OverridableResource)
                {
                    URL url = ((OverridableResource) artifact).getResource(dialect);
                    configuration.addURL(url);
                }
                else
                {
                    LOGGER.warn("unknown hibernate artifact type: " + artifact);
                }
            }
            catch (Exception ex)
            {
                LOGGER.error("problem with Hibernate artifact " + artifact, ex);
            }
        }

        props.put("service.pid", dsUniqueName);

        int ranking = 1;
        Integer matchingDSRanking = dsRankings.get(dsUniqueName);
        if (matchingDSRanking != null)
        {
            ranking = matchingDSRanking;
        }
        props.put("service.ranking", ranking);

        // register the sessionfactory as an OSGi service
        SessionFactory sessionFactory = configuration.buildSessionFactory();
        sfRegistrations.put(dsUniqueName,
                            context.registerService(SessionFactory.class.getName(), sessionFactory, props));

        // register the configuration itself as an OSGi service
        cfgRegistrations
                        .put(dsUniqueName, context.registerService(Configuration.class.getName(), configuration, props));
    }

    /**
     * Find the lists of all hibernated classes through the plugin registry
     *
     * @return a Map of persistence-unit-name to a list of class names in that unit
     */
    private Map<String, List<Object>> findHibernateArtifacts()
    {
        Map<String, List<Object>> unitToArtifacts = new HashMap<String, List<Object>>();

        IConfigurationElement[] configElements = extensionRegistry.getConfigurationElementsFor(EXTENSION_NAMESPACE
                + "." + EXTENSION_POINT_ID);
        for (IConfigurationElement element : configElements)
        {
            String bundleName = element.getContributor().getName();
            Bundle targetBundle = bundleFinder.findBySymbolicName(bundleName);
            String persistenceUnitName = element.getAttribute(ATTR_NAME);

            List<Object> listOfArtifacts = unitToArtifacts.get(persistenceUnitName);
            if (listOfArtifacts == null)
            {
                listOfArtifacts = new ArrayList<Object>();
                unitToArtifacts.put(persistenceUnitName, listOfArtifacts);
            }

            IConfigurationElement[] classList = element.getChildren("class");
            for (IConfigurationElement oneClass : classList)
            {
                String className = oneClass.getAttribute(ATTR_NAME);
                try
                {
                    Class clazz = targetBundle.loadClass(className);
                    LOGGER.debug(String.format("Hibernate class %s in bundle %s", className,
                                               targetBundle.getSymbolicName()));
                    listOfArtifacts.add(clazz);
                }
                catch (ClassNotFoundException ex)
                {
                    LOGGER.error(String.format("bundle %s can't load class %s", bundleName, className, ex));
                }
            }

            IConfigurationElement[] resourceList = element.getChildren("resource");
            for (IConfigurationElement oneResource : resourceList)
            {
                String resourceName = oneResource.getAttribute(ATTR_NAME);
                URL url = targetBundle.getEntry(resourceName);
                if (url == null)
                {
                    LOGGER.error(String.format("Hibernate resource %s in bundle %s does not exist", resourceName, targetBundle.getSymbolicName()));
                }
                else
                {
                    LOGGER.info(String.format("Hibernate resource %s in bundle %s", resourceName, targetBundle.getSymbolicName()));
                }

                OverridableResource or = new OverridableResource(url);
                IConfigurationElement[] overrides = oneResource.getChildren("override");
                for (IConfigurationElement override : overrides)
                {
                    String dialect = override.getAttribute("dialect");
                    String overrideName = override.getAttribute("name");
                    URL ourl = targetBundle.getEntry(overrideName);
                    LOGGER.info(String.format("Hibernate dialect %s resource %s in bundle %s", dialect, override,
                                              targetBundle.getSymbolicName()));
                    or.addOverride(dialect, ourl);
                }

                listOfArtifacts.add(or);
            }
        }

        return unitToArtifacts;
    }
}
