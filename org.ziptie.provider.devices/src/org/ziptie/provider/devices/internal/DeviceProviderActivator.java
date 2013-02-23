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

package org.ziptie.provider.devices.internal;

import javax.transaction.UserTransaction;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.net.adapters.IAdapterService;
import org.ziptie.net.snmp.TrapSender;
import org.ziptie.provider.devices.DeviceProvider;
import org.ziptie.provider.devices.DeviceTagProvider;
import org.ziptie.provider.devices.IDeviceProvider;
import org.ziptie.provider.devices.IDeviceTagProvider;
import org.ziptie.provider.devices.ISimpleDeviceSearch;
import org.ziptie.provider.devices.SimpleDeviceSearch;
import org.ziptie.provider.netman.INetworksProvider;

/**
 * Lifecycle class for the devices provider bundle.  This class tracks services for easy access.
 */
public class DeviceProviderActivator implements BundleActivator
{
    private static final Logger LOGGER = Logger.getLogger(DeviceProviderActivator.class);

    private static ServiceTracker sessionTracker;
    private static ServiceTracker transactionTracker;
    private static ServiceTracker networksTracker;
    private static ServiceTracker trapTracker;
    private static ServiceTracker adapterTracker;

    private static DeviceProvider provider;
    private static DeviceTagProvider tagProvider;
    private static SimpleDeviceSearch search;

    private ServiceRegistration serviceRegistration;
    private ServiceRegistration searchServiceRegistration;
    private ServiceRegistration tagRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        LOGGER.info("Device Provider starting...");

        try
        {
            sessionTracker = new ServiceTracker(context, SessionFactory.class.getName(), null);
            sessionTracker.open();

            transactionTracker = new ServiceTracker(context, UserTransaction.class.getName(), null);
            transactionTracker.open();

            networksTracker = new ServiceTracker(context, INetworksProvider.class.getName(), null);
            networksTracker.open();

            trapTracker = new ServiceTracker(context, TrapSender.class.getName(), null);
            trapTracker.open();

            adapterTracker = new ServiceTracker(context, IAdapterService.class.getName(), null);
            adapterTracker.open();

            provider = new DeviceProvider();
            serviceRegistration = context.registerService(IDeviceProvider.class.getName(), provider, null);

            search = new SimpleDeviceSearch();
            searchServiceRegistration = context.registerService(ISimpleDeviceSearch.class.getName(), search, null);

            tagProvider = new DeviceTagProvider();
            tagRegistration = context.registerService(IDeviceTagProvider.class.getName(), tagProvider, null);

            LOGGER.info("Device Provider started.");
        }
        catch (Exception e)
        {
            LOGGER.fatal("Device Provider failed to start.", e);
            throw e;
        }
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        provider = null;
        tagProvider = null;
        search = null;

        tagRegistration.unregister();
        searchServiceRegistration.unregister();
        serviceRegistration.unregister();

        networksTracker.close();
        networksTracker = null;

        trapTracker.close();
        trapTracker = null;

        transactionTracker.close();
        transactionTracker = null;

        sessionTracker.close();
        sessionTracker = null;

        adapterTracker.close();
        adapterTracker = null;

        LOGGER.info("Device Provider stopped.");
    }

    /**
     * Get the singleton search provider.
     * @return the search instance.
     */
    public static SimpleDeviceSearch getSearch()
    {
        return search;
    }

    /**
     * Get the singleton device provider.
     * @return The device provider instance.
     */
    public static DeviceProvider getDeviceProvider()
    {
        return provider;
    }

    /**
     * Get the singleton tag provider.
     * @return The device tag provider instance.
     */
    public static IDeviceTagProvider getTagProvider()
    {
        return tagProvider;
    }

    /**
     * Lookup the session factory service.
     * @return The session factory instance.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionTracker.getService();
    }

    /**
     * Lookup the networks provider service.
     * @return The networks provider instance.
     */
    public static INetworksProvider getNetworksProvider()
    {
        return (INetworksProvider) networksTracker.getService();
    }

    /**
     * Get a reference to the adapter service.
     *
     * @return the adapter service
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
