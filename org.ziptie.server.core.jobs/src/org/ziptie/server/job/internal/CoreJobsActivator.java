/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 */

package org.ziptie.server.job.internal;

import org.hibernate.SessionFactory;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.service.packageadmin.PackageAdmin;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.net.adapters.IAdapterService;
import org.ziptie.net.snmp.TrapSender;
import org.ziptie.provider.credentials.CredentialsProvider;
import org.ziptie.provider.credentials.ICredentialsProvider;
import org.ziptie.provider.devices.IDeviceProvider;
import org.ziptie.server.dispatcher.OperationManager;
import org.ziptie.server.dns.IDnsService;

/**
 * CoreJobsActivator
 */
public class CoreJobsActivator implements BundleActivator
{
    private static ServiceTracker bundleTracker;
    private static ServiceTracker dnsTracker;
    private static ServiceTracker opManTracker;
    private static ServiceTracker deviceTracker;
    private static ServiceTracker sessionTracker;
    private static ServiceTracker credentialsTracker;
    private static ServiceTracker adapterTracker;
    private static ServiceTracker trapTracker;

    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        bundleTracker = new ServiceTracker(ctx, PackageAdmin.class.getName(), null);
        bundleTracker.open();

        opManTracker = new ServiceTracker(ctx, OperationManager.class.getName(), null);
        opManTracker.open();

        deviceTracker = new ServiceTracker(ctx, IDeviceProvider.class.getName(), null);
        deviceTracker.open();

        sessionTracker = new ServiceTracker(ctx, SessionFactory.class.getName(), null);
        sessionTracker.open();

        credentialsTracker = new ServiceTracker(ctx, ICredentialsProvider.class.getName(), null);
        credentialsTracker.open();

        dnsTracker = new ServiceTracker(ctx, IDnsService.class.getName(), null);
        dnsTracker.open();

        adapterTracker = new ServiceTracker(ctx, IAdapterService.class.getName(), null);
        adapterTracker.open();

        trapTracker = new ServiceTracker(ctx, TrapSender.class.getName(), null);
        trapTracker.open();
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        bundleTracker.close();
        bundleTracker = null;

        opManTracker.close();
        opManTracker = null;

        deviceTracker.close();
        deviceTracker = null;

        credentialsTracker.close();
        credentialsTracker = null;

        adapterTracker.close();
        adapterTracker = null;

        trapTracker.close();
        trapTracker = null;
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
     * Lookup the operation manager service.
     * @return the operation manager instance
     */
    public static OperationManager getOperationManager()
    {
        return (OperationManager) opManTracker.getService();
    }

    /**
     * Lookup the device provider service.
     * @return The device provider instance.
     */
    public static IDeviceProvider getDeviceProvider()
    {
        return (IDeviceProvider) deviceTracker.getService();
    }

    /**
     * Lookup the session factory service
     * @return The session factory instance.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionTracker.getService();
    }

    /**
     * Look up the credentials provider service.
     * @return The credentials provider service.
     */
    public static CredentialsProvider getCredentialsProvider()
    {
        return (CredentialsProvider) credentialsTracker.getService();
    }

    /**
     * Lookup the DNS service.
     *
     * @return the DNS service
     */
    public static IDnsService getDnsService()
    {
        return (IDnsService) dnsTracker.getService();
    }

    /**
     * Lookup the adapter service.
     * @return the adapter service.
     */
    public static IAdapterService getAdapterService()
    {
        return (IAdapterService) adapterTracker.getService();
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
}
