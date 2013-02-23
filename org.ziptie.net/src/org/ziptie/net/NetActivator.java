package org.ziptie.net;

import java.io.File;
import java.net.URI;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.ziptie.net.common.NILProperties;
import org.ziptie.net.snmp.TrapSender;

/**
 * Activator for the org.ziptie.net bundle.
 */
public class NetActivator implements BundleActivator
{
    private TrapSender trapSender;
    private ServiceRegistration trapSenderRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        setupNilProperties(context);
        trapSender = TrapSender.getInstance();
        trapSenderRegistration = context.registerService(TrapSender.class.getName(), trapSender, null);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        NILProperties.reset();
        trapSender.shutdown();
        trapSender = null;
        trapSenderRegistration.unregister();
    }

    /**
     * Setup the NILProperties prop handler
     *  
     * @param context
     */
    private void setupNilProperties(BundleContext context)
    {
        String configArea = context.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$
        configArea += (configArea != null ? "/network/" + NILProperties.NIL_PROPERTIES : "osgi-config/network/" + NILProperties.NIL_PROPERTIES); //$NON-NLS-1$
        File file = new File(URI.create(configArea));
        NILProperties.setup(file);
    }
}
