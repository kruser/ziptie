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

package org.ziptie.provider.credentials.internal;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.credentials.AbstractCredentialsManager;
import org.ziptie.protocols.AbstractProtocolManager;
import org.ziptie.provider.credentials.CredentialsProvider;
import org.ziptie.provider.credentials.DatabaseCredentialsPersister;
import org.ziptie.provider.credentials.DatabaseProtocolPersister;
import org.ziptie.provider.credentials.ICredentialsProvider;
import org.ziptie.provider.credentials.ZipTieCredentialsManager;
import org.ziptie.provider.credentials.ZipTieProtocolManager;
import org.ziptie.provider.devices.DeviceProvider;
import org.ziptie.provider.devices.IDeviceProvider;
import org.ziptie.provider.netman.INetworksProvider;

public class CredentialsProviderActivator implements BundleActivator
{
    private static final Logger LOGGER = Logger.getLogger(CredentialsProviderActivator.class);

    private static CredentialsProvider credentialsProvider;

    private static ServiceTracker sessionTracker;
    private static ServiceTracker dataSourceTracker;
    private static ServiceTracker networksTracker;
    private static ServiceTracker deviceTracker;

    private static AbstractCredentialsManager credentialsManager;
    private static AbstractProtocolManager protocolManager;

    private ServiceRegistration credentialsRegistration;

    public void start(BundleContext context) throws Exception
    {
        // Log that the Credentials service/provider is attempting to start
        LOGGER.info(Messages.providerStarting);

        // Begin or join a transaction so that any calls to use a transaction will end up
        // using the transaction established/joined here.  This will make for less commit calls
        // in the code that is called here.
        // boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

        try
        {
            // Grab a reference to the SessionFactory service and open a tracker on it
            sessionTracker = new ServiceTracker(context, SessionFactory.class.getName(), null);
            sessionTracker.open();

            // Grab a reference to the DataSource service and open a tracker on it
            dataSourceTracker = new ServiceTracker(context, DataSource.class.getName(), null);
            dataSourceTracker.open();

            // Grab a reference to the Networks service and open a tracker on it
            networksTracker = new ServiceTracker(context, INetworksProvider.class.getName(), null);
            networksTracker.open();
            
            // Grab a reference to the Device service and open a tracker on it
            deviceTracker = new ServiceTracker(context, IDeviceProvider.class.getName(), null);
            deviceTracker.open();

            // Grab an instance of our CredentialsProvider class.  This provides all the access to performing any operation
            // for the Credentials service.
            credentialsProvider = new CredentialsProvider();

            // Register the Credentials service so the rest of the world can know about it
            credentialsRegistration = context.registerService(ICredentialsProvider.class.getName(), credentialsProvider, null);

            // Startup the CredentialsManager
            ZipTieCredentialsManager.startup(DatabaseCredentialsPersister.getInstance());
            credentialsManager = ZipTieCredentialsManager.getInstance();

            // Startup the ProtocolManager
            ZipTieProtocolManager.startup(DatabaseProtocolPersister.getInstance());
            protocolManager = ZipTieProtocolManager.getInstance();
        }
        finally
        {
//            if (ownTransaction)
//            {
//                TransactionElf.commit();
//            }
        }

        // Log that the Credentials service/provider has started
        LOGGER.info(Messages.providerStarted);
    }

    public void stop(BundleContext context) throws Exception
    {
        // Un-register the Credentials service so no one knows about it
        credentialsRegistration.unregister();

        // Clear out our reference to the instance of the Credential provider
        credentialsProvider = null;

        // Close the DataSource service tracker and tear it down
        dataSourceTracker.close();
        dataSourceTracker = null;

        // Close the Networks service tracker and tear it down
        networksTracker.close();
        networksTracker = null;
        
        // Close the Device service tracker and tear it down
        deviceTracker.close();
        deviceTracker = null;

        // Close the Session service tracker and tear it down
        sessionTracker.close();
        sessionTracker = null;

        // Log that the Credentials service/provider has stopped
        LOGGER.info(Messages.providerStopped);
    }

    /**
     * Get the <code>CredentialsProvider</code> "singleton" instance managed by this bundle.
     *
     * @return A <code>CredentialsProvider</code> instance.
     */
    public static CredentialsProvider getCredentialsProvider()
    {
        return credentialsProvider;
    }

    public static AbstractCredentialsManager getCredentialsManager()
    {
        return credentialsManager;
    }

    public static AbstractProtocolManager getProtocolManager()
    {
        return protocolManager;
    }

    /**
     * Lookup the session factory service.
     * 
     * @return The session factory instance.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionTracker.getService();
    }

    /**
     * Lookup the data source service.
     * 
     * @return The data source instance.
     */
    public static DataSource getDataSource()
    {
        return (DataSource) dataSourceTracker.getService();
    }

    /**
     * Lookup the networks provider service.
     * 
     * @return The networks provider instance.
     */
    public static INetworksProvider getNetworksProvider()
    {
        return (INetworksProvider) networksTracker.getService();
    }
    
    /**
     * Lookup the device provider service.
     * 
     * @return The device provider instance.
     */
    public static DeviceProvider getDeviceProvider()
    {
        return (DeviceProvider) deviceTracker.getService();
    }
}
