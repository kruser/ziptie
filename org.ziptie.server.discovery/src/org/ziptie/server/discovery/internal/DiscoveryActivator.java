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

package org.ziptie.server.discovery.internal;

import org.apache.log4j.Logger;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.discovery.DiscoveryConfigProperties;
import org.ziptie.discovery.DiscoveryEngine;
import org.ziptie.net.adapters.IAdapterService;
import org.ziptie.provider.credentials.ICredentialsProvider;
import org.ziptie.provider.devices.DeviceProvider;
import org.ziptie.provider.devices.IDeviceProvider;
import org.ziptie.server.discovery.DiscoveryHandler;
import org.ziptie.server.discovery.DiscoveryInventoryCallback;

/**
 * DiscoveryActivator
 */
public class DiscoveryActivator implements BundleActivator
{
    private static final Logger LOGGER = Logger.getLogger(DiscoveryActivator.class);
    private static final String DISCOVERY_HANDLER_ID = "ADD_DEVICE_HANDLER";

    private static DiscoveryStatsMonitor statsMonitor;

    private static ServiceTracker deviceTracker;
    private static ServiceTracker credentialsTracker;
    private static ServiceTracker adapterTracker;

    private ServiceRegistration serviceRegistration;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        LOGGER.info(Messages.providerStarting);

        adapterTracker = new ServiceTracker(context, IAdapterService.class.getName(), null);
        adapterTracker.open();

        deviceTracker = new ServiceTracker(context, IDeviceProvider.class.getName(), null);
        deviceTracker.open();

        credentialsTracker = new ServiceTracker(context, ICredentialsProvider.class.getName(), null);
        credentialsTracker.open();

        DiscoveryEngine discoveryEngine = DiscoveryEngine.startup(new DiscoveryInventoryCallback(), new DiscoveryConfigProperties());
        discoveryEngine.registerEventHandler(DISCOVERY_HANDLER_ID, new DiscoveryHandler());

        serviceRegistration = context.registerService(DiscoveryEngine.class.getName(), discoveryEngine, null);

        statsMonitor = new DiscoveryStatsMonitor();

        LOGGER.info(Messages.providerStarted);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctx) throws Exception
    {
        serviceRegistration.unregister();

        deviceTracker.close();
        deviceTracker = null;

        credentialsTracker.close();
        credentialsTracker = null;

        adapterTracker.close();
        adapterTracker = null;

        LOGGER.info(Messages.providerStopped);
    }

    /**
     * Lookup the device provider service.
     * @return The device provider instance.
     */
    public static DeviceProvider getDeviceProvider()
    {
        return (DeviceProvider) deviceTracker.getService();
    }

    /**
     * Look up the credentials provider service.
     * @return The credentials provider service.
     */
    public static ICredentialsProvider getCredentialsProvider()
    {
        return (ICredentialsProvider) credentialsTracker.getService();
    }

    /**
     * Lookup the adapter service.
     * @return the adapter service.
     */
    public static IAdapterService getAdapterService()
    {
        return (IAdapterService) adapterTracker.getService();
    }

    /* package */static DiscoveryStatsMonitor getStatsMonitor()
    {
        return statsMonitor;
    }
}
