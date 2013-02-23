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
 * Copyright the ZipTie Project (www.ziptie.org)
 */

package org.ziptie.provider.netman.internal;

import javax.transaction.UserTransaction;

import org.hibernate.SessionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.provider.netman.INetworksProvider;
import org.ziptie.provider.netman.NetworksProvider;

/**
 * NetworksActivator
 */
public class NetworksActivator implements BundleActivator
{
    private static INetworksProvider service;
    private static ServiceTracker xactionTracker;
    private static ServiceTracker sessionTracker;

    private ServiceRegistration registration;

    /** {@inheritDoc} */
    public void start(BundleContext ctx) throws Exception
    {
        service = new NetworksProvider(ctx);
        registration = ctx.registerService(INetworksProvider.class.getName(), service, null);

        xactionTracker = new ServiceTracker(ctx, UserTransaction.class.getName(), null);
        xactionTracker.open();

        sessionTracker = new ServiceTracker(ctx, SessionFactory.class.getName(), null);
        sessionTracker.open();
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        registration.unregister();
        xactionTracker.close();
        sessionTracker.close();
    }

    /**
     * Get the bundle context.
     *
     * @return the BundleContext
     */
    public static INetworksProvider getNetworksProvider()
    {
        return service;
    }

    /**
     * Get the UserTransaction.
     *
     * @return the UserTransaction
     */
    public static UserTransaction getTransaction()
    {
        return (UserTransaction) xactionTracker.getService();
    }

    /**
     * Get the Hibernate SessionFactory.
     *
     * @return the SessionFactory
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionTracker.getService();
    }
}
