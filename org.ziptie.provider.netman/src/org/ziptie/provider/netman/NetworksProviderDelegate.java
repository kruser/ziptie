package org.ziptie.provider.netman;

import java.util.List;

import javax.jws.WebService;

import org.ziptie.provider.netman.internal.NetworksActivator;
import org.ziptie.server.security.SecurityHandler;

/**
 * NetworksProviderDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.netman.INetworksProvider",
            serviceName = "NetworksService", portName = "NetworksPort")
public class NetworksProviderDelegate implements INetworksProvider
{
    /** {@inheritDoc} */
    public void defineManagedNetwork(String name)
    {
        getProvider().defineManagedNetwork(name);
    }

    /** {@inheritDoc} */
    public void deleteManagedNetwork(String name)
    {
        getProvider().deleteManagedNetwork(name);
    }

    /** {@inheritDoc} */
    public ManagedNetwork getDefaultManagedNetwork()
    {
        return getProvider().getDefaultManagedNetwork();
    }

    /** {@inheritDoc} */
    public ManagedNetwork getManagedNetwork(String name)
    {
        return getProvider().getManagedNetwork(name);
    }

    /** {@inheritDoc} */
    public List<String> getManagedNetworkNames()
    {
        return getProvider().getManagedNetworkNames();
    }

    /** {@inheritDoc} */
    public void setDefaultManagedNetwork(String name)
    {
        getProvider().setDefaultManagedNetwork(name);
    }

    /** {@inheritDoc} */
    public void updateManagedNetwork(ManagedNetwork managedNetwork)
    {
        getProvider().updateManagedNetwork(managedNetwork);
    }

    private INetworksProvider getProvider()
    {
        INetworksProvider provider = NetworksActivator.getNetworksProvider();
        if (provider == null)
        {
            throw new RuntimeException(Messages.serviceUnavailable);
        }

        return (INetworksProvider) SecurityHandler.newProxy(provider);
    }
}
