package org.ziptie.server.birt;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.Dictionary;
import java.util.Enumeration;
import java.util.Locale;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;

import org.apache.log4j.Logger;
import org.eclipse.birt.report.engine.api.EngineConfig;
import org.eclipse.birt.report.engine.api.EngineConstants;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportRunnable;
import org.eclipse.birt.report.model.api.IResourceLocator;
import org.eclipse.birt.report.model.api.ModuleHandle;
import org.osgi.framework.Bundle;
import org.ziptie.provider.tools.BasePluginManager;
import org.ziptie.provider.tools.PluginDescriptor;
import org.ziptie.provider.tools.ZToolProperties;
import org.ziptie.server.birt.internal.BirtActivator;
import org.ziptie.zap.util.ResourceElf;

/**
 * ReportPluginManager
 */
public class ReportPluginManager extends BasePluginManager
{
    private static final Logger LOGGER = Logger.getLogger(ReportPluginManager.class);

    private static final String MENU_LABEL_PROP = "menu.label"; //$NON-NLS-1$
    private static final String REPORT_PLUGIN_TYPE = "report"; //$NON-NLS-1$

    /**
     * Default constructor.
     */
    public ReportPluginManager()
    {
        super();

        // Cause an initial scan of the bundles for the default locale
        getPluginDescriptorMap();

        setInitialized(true);
    }

    /**
     * @param reportTitle
     * @return
     */
    @SuppressWarnings({ "unchecked", "nls" })
    public IReportEngine getReportEngine(String reportTitle)
    {
        PluginDescriptor pluginDescriptor = getPluginDescriptor(reportTitle);
        if (pluginDescriptor == null)
        {
            LOGGER.error(String.format("Request for BIRT engine instance for report '%s' failed.", reportTitle));
            return null;
        }

        String level = System.getProperty("org.ziptie.birt.loglevel", "WARNING");
        Level logLevel = java.util.logging.Level.parse(level);

        final Bundle bundle = pluginDescriptor.getBundle();
        EngineConfig engineConfig = new EngineConfig();
        engineConfig.setTempDir(".");
        engineConfig.setLogConfig("tmp", logLevel);
        engineConfig.setResourceLocator(new IResourceLocator()
        {
            public URL findResource(ModuleHandle moduleHandle, String resourceName, int arg2)
            {
                Dictionary<?, ?> headers = bundle.getHeaders();
                String dir = (String) headers.get("ZReport-Directory"); //$NON-NLS-1$

                URL entry = bundle.getEntry(dir + "/" + resourceName);
                return entry;
            }
        });

        // Find a class in the bundle and use it to set the classloader for this BIRT engine instance
        Enumeration<?> classes = bundle.findEntries("/", "*.class", true);
        if (classes != null && classes.hasMoreElements())
        {
            try
            {
                URL classUrl = (URL) classes.nextElement();
                String className = classUrl.toExternalForm().replaceAll("bundleentry://[0-9]+/bin/", "").replaceAll("\\.class", "").replace('/', '.');
                Class clazz = bundle.loadClass(className);
                engineConfig.getAppContext().put(EngineConstants.APPCONTEXT_CLASSLOADER_KEY, clazz.getClassLoader());
            }
            catch (ClassNotFoundException e)
            {
                // fall thru
            }
        }

        return BirtActivator.getReportEngineFactory().createReportEngine(engineConfig);
    }

    /**
     * Get an IReportRunnable by it's title.
     *
     * @param reportTitle the title of the report to retrieve
     * @return an IReportRunnable
     */
    public IReportRunnable getReportByTitle(String reportTitle)
    {
        PluginDescriptor pluginDescriptor = getPluginDescriptor(reportTitle);
        if (pluginDescriptor == null)
        {
            return null;
        }

        final Bundle bundle = pluginDescriptor.getBundle();
        String reportPath = pluginDescriptor.getBundlePath().replace(".properties", ".rptdesign"); //$NON-NLS-1$ //$NON-NLS-2$
        URL url = bundle.getEntry(reportPath);

        IReportEngine reportEngine = BirtActivator.getReportEngineFactory().createReportEngine(new EngineConfig());

        try
        {
            IResourceLocator locator = new IResourceLocator()
            {
                public URL findResource(ModuleHandle moduleHandle, String resourceName, int arg2)
                {
                    URL entry = bundle.getEntry(resourceName);
                    return entry;
                }
            };

            InputStream is = url.openStream();
            IReportRunnable reportDesign = reportEngine.openReportDesign(reportPath, is, locator);
            is.close();

            return reportDesign;
        }
        catch (Exception e)
        {
            LOGGER.error(Messages.bind(Messages.ReportPluginManager_definitionNotFound, reportTitle), e);
            throw new RuntimeException(e);
        }
        finally
        {
            reportEngine.destroy();
        }
    }

    @Override
    protected void scanBundleForInstall(final Bundle bundle, Locale locale)
    {
        Dictionary<?, ?> headers = bundle.getHeaders();
        Object object = headers.get("ZReport-Directory"); //$NON-NLS-1$
        if (!(object instanceof String))
        {
            return;
        }

        String path = (String) object;
        Enumeration<?> enumeration = bundle.findEntries(path, "*.properties", true); //$NON-NLS-1$
        if (enumeration.hasMoreElements())
        {
            getPluginBundles().add(bundle);
        }

        while (enumeration != null && enumeration.hasMoreElements())
        {
            URL url = (URL) enumeration.nextElement();
            try
            {
                String reportPath = url.getPath();
                if (reportPath.indexOf('_') >= 0)
                {
                    // ignore property files with an "_", these are i18n property files.
                    // we only care about base properties.
                    continue;
                }

                PluginDescriptor descriptor = new PluginDescriptor(bundle, reportPath);
                Properties props = ResourceElf.loadLanguageProperties(bundle, reportPath, locale);
                descriptor.setPluginType(REPORT_PLUGIN_TYPE);
                descriptor.setProperties(new ZToolProperties(props));

                String title = props.getProperty(MENU_LABEL_PROP);
                if (title != null)
                {
                    descriptor.setToolName(title);
                }
                else
                {
                    LOGGER.warn(String.format("Report '%s' does not have a Title attribute -- cannot be loaded.", reportPath)); //$NON-NLS-1$
                    continue;
                }

                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                props.storeToXML(baos, ""); //$NON-NLS-1$
                descriptor.setPropertyText(baos.toString());

                if (descriptor.getToolName() != null)
                {
                    ConcurrentHashMap<String, PluginDescriptor> pluginDescriptorMap = getPluginDescriptorMap();
                    pluginDescriptorMap.put(descriptor.getToolName(), descriptor);
                    LOGGER.info(Messages.bind(Messages.ReportPluginManager_discoveredReport, descriptor.getToolName()));
                }
            }
            catch (Exception io)
            {
                LOGGER.warn(Messages.bind(Messages.ReportPluginManager_errorReadingReport, url), io);
                continue;
            }
        }

    }

    @Override
    protected String getPluginTypeDisplayName()
    {
        return Messages.ReportPluginManager_pluginTypeDisplayName;
    }
}
