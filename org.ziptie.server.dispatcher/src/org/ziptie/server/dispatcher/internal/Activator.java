package org.ziptie.server.dispatcher.internal;

import java.io.File;
import java.io.FileInputStream;
import java.net.URI;
import java.util.Properties;

import org.apache.log4j.Logger;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.ziptie.server.dispatcher.OperationManager;

/**
 * Activator
 */
public class Activator implements BundleActivator
{
    private static final Logger DEV_LOG = Logger.getLogger(Activator.class);

    private static BundleContext context;
    private OperationManager operationManager;
    private ServiceRegistration serviceRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        context = ctx;

        operationManager = new OperationManager();
        serviceRegistration = context.registerService(OperationManager.class.getName(), operationManager, null);

        Properties props = new Properties();
        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$
        configArea += (configArea != null ? "/dispatcher/dispatcher.properties" : "osgi-config/dispatcher/dispatcher.properties"); //$NON-NLS-1$
        File file = new File(URI.create(configArea));
        if (file.exists())
        {
            FileInputStream fis = new FileInputStream(file);
            props.load(fis);
        }

        if (props.getProperty("maxThreadCount") != null)
        {
            operationManager.setMaxThreadCount(Integer.valueOf(props.getProperty("maxThreadCount")));
        }

        DEV_LOG.info("Operation Dispatcher started.");
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        if (operationManager != null)
        {
            serviceRegistration.unregister();
            operationManager.shutdown();
        }
        DEV_LOG.info("Operation Dispatcher shutdown.");
    }
}
