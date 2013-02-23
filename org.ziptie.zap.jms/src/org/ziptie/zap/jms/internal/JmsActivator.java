package org.ziptie.zap.jms.internal;

import java.io.File;
import java.net.URI;

import org.apache.activemq.broker.BrokerFactory;
import org.apache.activemq.broker.BrokerService;
import org.apache.log4j.Logger;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;

/**
 * JmsActivator
 */
public class JmsActivator implements BundleActivator
{
    private static final String ACTIVEMQ_XML = "activemq.xml"; //$NON-NLS-1$
    private static final Logger LOGGER = Logger.getLogger(JmsActivator.class);

    private ServiceRegistration registerService;
    private BrokerService broker;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        LOGGER.info("Starting JMS service..."); //$NON-NLS-1$

        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        File activemqConfigDir = new File(URI.create(configArea + "activemq")); //$NON-NLS-1$
        if (!activemqConfigDir.isDirectory())
        {
            LOGGER.fatal(String.format("configureActiveMQ: %s directory not found", activemqConfigDir)); //$NON-NLS-1$
        }

        File configFile = new File(activemqConfigDir, ACTIVEMQ_XML);
        if (!configFile.exists())
        {
            LOGGER.fatal(String.format("configureActiveMQ: %s config file not found", configFile)); //$NON-NLS-1$
            return;
        }

        String uri = configFile.toURI().toASCIIString().replace("file:", "xbean:"); //$NON-NLS-1$ //$NON-NLS-2$
        broker = BrokerFactory.createBroker(uri);
        broker.setDeleteAllMessagesOnStartup(true);
        broker.start();
        registerService = context.registerService(broker.getClass().getName(), broker, null);

        // configure the broker
//        broker.setBrokerName(BROKER_NAME);
//        broker.setUseShutdownHook(true);
//        broker.addConnector("tcp://localhost:61616");

        LOGGER.info("JMS started."); //$NON-NLS-1$
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        if (registerService != null)
        {
            broker.stop();
            registerService.unregister();
        }
    }
}
