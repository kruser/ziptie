package org.ziptie.server.core.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.service.packageadmin.PackageAdmin;
import org.osgi.util.tracker.ServiceTracker;

public class CoreActivator implements BundleActivator
{
    private static ServiceTracker bundleTracker;

    public void start(BundleContext context) throws Exception
    {
        bundleTracker = new ServiceTracker(context, PackageAdmin.class.getName(), null);
        bundleTracker.open();
    }

    public void stop(BundleContext context) throws Exception
    {
        bundleTracker.close();
    }

    public static PackageAdmin getPackageAdmin()
    {
        return (PackageAdmin) bundleTracker.getService();
    }
}
