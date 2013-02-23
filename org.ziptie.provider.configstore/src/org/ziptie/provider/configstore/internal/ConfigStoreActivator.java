package org.ziptie.provider.configstore.internal;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.LinkedList;
import java.util.List;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.eclipse.osgi.framework.internal.core.BundleURLConnection;
import org.hibernate.SessionFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.service.packageadmin.PackageAdmin;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.net.snmp.TrapSender;
import org.ziptie.provider.configstore.ConfigSearch;
import org.ziptie.provider.configstore.ConfigStore;
import org.ziptie.provider.configstore.IConfigSearch;
import org.ziptie.provider.configstore.IConfigStore;
import org.ziptie.provider.configstore.Messages;
import org.ziptie.provider.configstore.RevisionNotifier;
import org.ziptie.provider.devices.IDeviceProvider;

/**
 * Activator
 */
@SuppressWarnings("restriction")
public class ConfigStoreActivator implements BundleActivator
{
    private static final Logger LOGGER = Logger.getLogger(ConfigStoreActivator.class);

    private static final String LINUX = "linux"; //$NON-NLS-1$
    private static final String WINDOWS = "windows"; //$NON-NLS-1$
    private static final String MACOSX = "macosx"; //$NON-NLS-1$
    private static final String SOLARIS = "solaris"; //$NON-NLS-1$

    private static ConfigStore configStore;
    private static ConfigSearch configSearch;
    private static RevisionNotifier revisionNotifier;
    private static ServiceTracker devicesTracker;
    private static ServiceTracker bundleTracker;
    private static ServiceTracker trapTracker;
    private static ServiceTracker dsTracker;
    private static ServiceTracker sessionTracker;
    private static BundleContext context;

    private static String xdiffPath;

    private ServiceRegistration storeRegistration;
    private ServiceRegistration searchRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        LOGGER.info(Messages.ConfigStoreActivator_starting);

        try
        {
            context = ctx;

            configStore = new ConfigStore();
            storeRegistration = context.registerService(IConfigStore.class.getName(), configStore, null);

            configSearch = new ConfigSearch();
            searchRegistration = context.registerService(IConfigSearch.class.getName(), configSearch, null);

            sessionTracker = new ServiceTracker(context, SessionFactory.class.getName(), null);
            sessionTracker.open();

            revisionNotifier = new RevisionNotifier();

            devicesTracker = new ServiceTracker(context, IDeviceProvider.class.getName(), null);
            devicesTracker.open();

            bundleTracker = new ServiceTracker(ctx, PackageAdmin.class.getName(), null);
            bundleTracker.open();

            trapTracker = new ServiceTracker(ctx, TrapSender.class.getName(), null);
            trapTracker.open();

            dsTracker = new ServiceTracker(context, DataSource.class.getName(), null);
            dsTracker.open();

            LOGGER.info(Messages.ConfigStoreActivator_registered);
        }
        catch (Exception e)
        {
            LOGGER.fatal(Messages.ConfigStoreActivator_serviceFailed, e);
            throw e;
        }
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        storeRegistration.unregister();
        searchRegistration.unregister();

        configStore = null;
        configSearch = null;
        revisionNotifier = null;
        bundleTracker.close();
        devicesTracker.close();
        trapTracker.close();
        dsTracker.close();
        sessionTracker.close();

        LOGGER.info(Messages.ConfigStoreActivator_stopped);
    }

    /**
     * Get the configuration store.
     *
     * @return the configuration store
     */
    public static IConfigStore getConfigStore()
    {
        return configStore;
    }

    /**
     * Get the configuration search provider.
     *
     * @return the configuration search provider
     */
    public static IConfigSearch getConfigSearch()
    {
        return configSearch;
    }

    /**
     * Get a reference to the Device Provider service.
     *
     * @return a reference to an IDeviceProvider
     */
    public static IDeviceProvider getDeviceProvider()
    {
        return (IDeviceProvider) devicesTracker.getService();
    }

    /**
     * Get a reference to the Revision Notifier service.
     *
     * @return the Revision Notifier
     */
    public static RevisionNotifier getRevisionNotifier()
    {
        return revisionNotifier;
    }

    /**
     * Lookup the session factory service.
     * @return The session factory instance.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionTracker.getService();
    }

    /**
     * Get a DataSource instance.
     *
     * @return a DataSource
     */
    public static synchronized DataSource getDataSource()
    {
        return (DataSource) dsTracker.getService();
    }

    /**
     * Get the path of the xdiff binary for this OS.
     *
     * @return the path to xdiff
     */
    @SuppressWarnings("nls")
    public static synchronized String getXdiffPath()
    {
        if (xdiffPath == null)
        {
            URL entry = context.getBundle().getEntry("/bin/" + getOS());
            if (entry != null)
            {
                try
                {
                    URLConnection connection = entry.openConnection();
                    if (connection instanceof BundleURLConnection)
                    {
                        URL fileURL = ((BundleURLConnection) connection).getFileURL();
                        String escapedURL = fileURL.toExternalForm().replace(" ", "%20");
                        URI uri = URI.create(escapedURL);
                        xdiffPath = new File(uri).getAbsolutePath() + File.separator + "xdiff";

                        // This code sets the executable bit on the plink file in both Linux and Mac OS X
                        //
                        if (!getOS().contains(WINDOWS))
                        {
                            List<String> cmds = new LinkedList<String>();
                            cmds.add("sh");
                            cmds.add("-c");
                            cmds.add("chmod +x " + xdiffPath.replace(" ", "\\ "));

                            ProcessBuilder pb = new ProcessBuilder(cmds);
                            Process process = pb.start();
                            process.waitFor();
                            if (process.exitValue() != 0)
                            {
                                LOGGER.warn("Non-zero return code setting xdiff executable permission.");
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    LOGGER.fatal("Cannot construct path for xdiff -- revision repository is now inaccessible."); //$NON-NLS-1$
                }
            }
        }

        return xdiffPath;
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
        PackageAdmin packageAdmin = (PackageAdmin) bundleTracker.getService();
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
     * Get the TrapSender from the tracker.
     *
     * @return the TrapSender service.
     */
    public static TrapSender getTrapSender()
    {
        return (TrapSender) trapTracker.getService();
    }

    @SuppressWarnings("nls")
    private static String getOS()
    {
        String os = System.getProperty("os.name");
        if ("Mac OS X".equals(os))
        {
            os = MACOSX;
        }
        // Normalize any version of Windows into "windows"
        else if (os.contains("indows"))
        {
            os = WINDOWS;
        }
        // Normalize any version of Linux into "linux"
        else if (os.contains("inux"))
        {
            os = LINUX;
        }
        // Normalize any version of Solaris into "solaris"
        else if (os.equalsIgnoreCase("sunos") || os.contains("olari"))
        {
            os = SOLARIS;
        }
        return os;
    }
}
