package org.ziptie.log4j.internal;

import java.io.File;
import java.net.URI;

import org.apache.log4j.PropertyConfigurator;
import org.apache.log4j.xml.DOMConfigurator;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

/**
 * Log4jActivator
 */
public class Log4jActivator implements BundleActivator
{
    private static final String LOG4J_PROPERTIES = "log4j/log4j.properties"; //$NON-NLS-1$
    private static final String LOG4J_XML = "log4j/log4j.xml";
    private static final int THIRTY_SECONDS = 30000;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$
        if (configArea == null)
        {
            throw new RuntimeException("Unable to activate: osgi.configuration.area property is not defined.");
        }

        File file = new File(URI.create(configArea + LOG4J_PROPERTIES));
        if (file.exists())
        {
            String log4j = file.getAbsolutePath();
            PropertyConfigurator.configureAndWatch(log4j, THIRTY_SECONDS);
        }
        else
        {
            file = new File(URI.create(configArea + LOG4J_XML));
            DOMConfigurator.configureAndWatch(file.getAbsolutePath(), THIRTY_SECONDS);
        }
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
    }
}
