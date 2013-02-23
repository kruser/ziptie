package org.ziptie.zap.metro.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

/**
 * MetroActivator
 */
public class MetroActivator implements BundleActivator
{
    private static BundleContext context;

    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        context = ctx;
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        context = null;
    }

    public static BundleContext getBundleContext()
    {
        return context;
    }
}
