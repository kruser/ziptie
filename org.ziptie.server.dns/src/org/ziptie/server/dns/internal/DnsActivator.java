package org.ziptie.server.dns.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.ziptie.server.dns.DnsService;
import org.ziptie.server.dns.IDnsService;

/**
 * DnsActivator
 */
public class DnsActivator implements BundleActivator
{
    private ServiceRegistration serviceRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        DnsService dnsService = new DnsService();

        serviceRegistration = context.registerService(IDnsService.class.getName(), dnsService, null);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        serviceRegistration.unregister();
    }
}
