package org.ziptie.server.core;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;
import org.osgi.service.packageadmin.PackageAdmin;
import org.ziptie.server.core.internal.CoreActivator;

/**
 * AbstractExtensionNotifier
 */
public class AbstractExtensionNotifier
{
    private static final Logger LOGGER = Logger.getLogger(AbstractExtensionNotifier.class);

    private static final int THREAD_KEEP_ALIVE = 10;
    private static final int QUEUE_CAPACITY = 1000000;

    private Lock extensionLoadLock;
    private Class<?>[] observerExtensions;

    private ThreadPoolExecutor executor;
    private String extensionPoint;

    /**
     * Default constructor.
     */
    public AbstractExtensionNotifier(String extensionPoint, String threadName)
    {
        this.extensionPoint = extensionPoint;
        extensionLoadLock = new ReentrantLock();
        NotifierThreadFactory threadFactory = new NotifierThreadFactory(threadName);
        executor = new ThreadPoolExecutor(5, 5, THREAD_KEEP_ALIVE, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>(QUEUE_CAPACITY), threadFactory);
    }

    // ----------------------------------------------------------------------
    //                     P R O T E C T E D   M E T H O D S
    // ----------------------------------------------------------------------

    /**
     * @return
     */
    protected Executor getExecutor()
    {
        return executor;
    }

    /**
     * 
     */
    protected final List<?> createObserverExtensions()
    {
        extensionLoadLock.lock();
        try
        {
            if (observerExtensions == null)
            {
                IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();
                IConfigurationElement[] configElements = extensionRegistry.getConfigurationElementsFor(extensionPoint);

                observerExtensions = new Class[configElements.length];
                if (configElements.length == 0)
                {
                    LOGGER.warn(String.format("No %s extensions discovered.", extensionPoint)); //$NON-NLS-1$
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
                            observerExtensions[i++] = clazz;
                        }
                        catch (ClassNotFoundException cnfe)
                        {
                            LOGGER.error(String.format("ConfigStore bundle unable to load extension class '%s'", className), cnfe); //$NON-NLS-1$
                        }
                    }
                }
            }
        }
        finally
        {
            extensionLoadLock.unlock();
        }

        ArrayList<Object> extensionList = new ArrayList<Object>();
        for (Class<?> clazz : observerExtensions)
        {
            try
            {
                extensionList.add(clazz.newInstance());
            }
            catch (Exception e)
            {
                LOGGER.warn(String.format("Unable to create Revision Observer extension %s", clazz.getName())); //$NON-NLS-1$
            }
        }

        return extensionList;
    }

    // ----------------------------------------------------------------------
    //                     P R I V A T E   M E T H O D S
    // ----------------------------------------------------------------------


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
        PackageAdmin packageAdmin = CoreActivator.getPackageAdmin();
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

    // ----------------------------------------------------------------------
    //                       I N N E R   C L A S S E S
    // ----------------------------------------------------------------------

    /**
     * NotifierThreadFactory
     */
    private final class NotifierThreadFactory implements ThreadFactory
    {
        private String threadName;

        public NotifierThreadFactory(String threadName)
        {
            this.threadName = threadName;
        }

        public Thread newThread(Runnable r)
        {
            Thread t = new Thread(r);
            t.setDaemon(true);
            t.setName(threadName);
            return t;
        }
    }
}
