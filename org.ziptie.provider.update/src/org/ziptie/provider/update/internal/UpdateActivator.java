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
 * 
 * Contributor(s):
 */
package org.ziptie.provider.update.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.crates.InstallLocation;
import org.ziptie.provider.update.IUpdateProvider;

/**
 * Life-cycle class for the update bundle.
 */
public class UpdateActivator implements BundleActivator
{
    private static ServiceTracker tracker;
    private static BundleContext context;
    private static UpdateProvider provider;

    private ServiceRegistration registration;

    /** {@inheritDoc} */
    public void start(BundleContext ctxt)
    {
        context = ctxt;
        tracker = new ServiceTracker(ctxt, InstallLocation.class.getName(), null);
        tracker.open();

        provider = new UpdateProvider();

        registration = ctxt.registerService(IUpdateProvider.class.getName(), provider, null);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctxt)
    {
        tracker.close();
        tracker = null;

        registration.unregister();
        registration = null;
    }

    /**
     * Get the install location.
     * @return the install location.
     */
    public static InstallLocation getInstallLocation()
    {
        return (InstallLocation) tracker.getService();
    }

    /**
     * Gets this bundle's context.
     * @return The context.
     */
    public static BundleContext getContext()
    {
        return context;
    }

    /**
     * Get the singleton update provider.
     * @return the provider
     */
    static UpdateProvider getUpdateProvider()
    {
        return provider;
    }
}
