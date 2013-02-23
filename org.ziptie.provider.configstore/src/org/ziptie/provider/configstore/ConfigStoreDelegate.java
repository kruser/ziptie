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
 */
package org.ziptie.provider.configstore;

import java.util.Date;
import java.util.List;

import javax.jws.WebService;

import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.provider.configstore.internal.ConfigStoreActivator;

/**
 * This is a delegate class that is instantiated by the Metro service for
 * invocations coming from SOAP clients.  It delegates to a ConfigStore
 * whose lifecycle is managed by the Activator for this bundle.  The
 * decoupling of the lifecycle was necessary because we want OSGi to
 * manage the lifecycle, not Axis; so Axis is not allowed to instantiate
 * a real ConfigStore.
 * 
 * Both this class and the ConfigStore to which it delegates both implement
 * the IConfigStore interface, helping to enforce the one-to-one delegation
 * mapping between their exposed public methods.
 */
@WebService(endpointInterface = "org.ziptie.provider.configstore.IConfigStore", //$NON-NLS-1$
serviceName = "ConfigStoreService", portName = "ConfigStorePort")
public class ConfigStoreDelegate implements IConfigStore
{
    private static ServiceTracker configStoreTracker;

    /**
     * Initialize the static state of this delegate.
     *
     * @param ctx the BundleContext object for this bundle
     */
    public static void init(BundleContext ctx)
    {
        if (configStoreTracker != null)
        {
            configStoreTracker.close();
        }

        configStoreTracker = new ServiceTracker(ctx, IConfigStore.class.getName(), null);
        configStoreTracker.open();
    }

    /** {@inheritDoc} */
    public List<RevisionInfo> retrieveCurrentRevisionInfo(String ipAddress, String managedNetwork)
    {
        if (NetworkAddressElf.isValidAddress(ipAddress))
        {
            return getConfigStore().retrieveCurrentRevisionInfo(ipAddress, managedNetwork);
        }

        return null;
    }

    /** {@inheritDoc} */
    public List<ChangeLog> retrieveChangeLog(String ipAddress, String managedNetwork)
    {
        if (NetworkAddressElf.isValidAddress(ipAddress))
        {
            return getConfigStore().retrieveChangeLog(ipAddress, managedNetwork);
        }

        return null;
    }

    /** {@inheritDoc} */
    public Revision retrieveRevision(String ipAddress, String managedNetwork, String configPath, Date timestamp)
    {
        if (NetworkAddressElf.isValidAddress(ipAddress))
        {
            return getConfigStore().retrieveRevision(ipAddress, managedNetwork, configPath, timestamp);
        }

        return null;
    }

    /** {@inheritDoc} */
    public String retrieveRevisionUnifiedDiff(String ipAddress, String managedNetwork, String configPath, Date timestamp1, Date timestamp2)
    {
        if (NetworkAddressElf.isValidAddress(ipAddress))
        {
            return getConfigStore().retrieveRevisionUnifiedDiff(ipAddress, managedNetwork, configPath, timestamp1, timestamp2);
        }

        return null;
    }

    /**
     * This is an accessor to get the 'true' service.  If the bundle has been restarted,
     * this may return a different provider than previous invocations.  
     * 
     * @return the provider to which to delegate
     */
    private IConfigStore getConfigStore()
    {
        IConfigStore configStore = ConfigStoreActivator.getConfigStore();
        if (configStore == null)
        {
            throw new RuntimeException(Messages.ConfigStoreDelegate_serviceUnavailable);
        }

        return configStore;
    }
}
