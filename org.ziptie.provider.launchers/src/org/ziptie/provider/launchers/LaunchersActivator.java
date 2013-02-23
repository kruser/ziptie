package org.ziptie.provider.launchers;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;

public class LaunchersActivator implements BundleActivator
{
    private static final Logger LOGGER = Logger.getLogger(LaunchersActivator.class);
    
    private static ServiceTracker sessionTracker;
    private static LaunchersProvider launchersProvider;
    
    /**
     * {@inheritDoc}
     */
    public void start(BundleContext context) throws Exception
    {
        LOGGER.info("Launchers provider starting...");
        
        sessionTracker = new ServiceTracker(context, SessionFactory.class.getName(), null);
        sessionTracker.open();
        
        launchersProvider = new LaunchersProvider();
    }

    /**
     * {@inheritDoc}
     */
    public void stop(BundleContext context) throws Exception
    {
        // Close the Session service tracker and tear it down
        sessionTracker.close();
        sessionTracker = null;
        launchersProvider = null;
    }
    
    /**
     * Lookup the session factory service.
     * 
     * @return The session factory instance.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionTracker.getService();
    }
    
    /**
     * @return the telemetryProvider
     */
    public static LaunchersProvider getLaunchersProvider()
    {
        return launchersProvider;
    }
    
}
