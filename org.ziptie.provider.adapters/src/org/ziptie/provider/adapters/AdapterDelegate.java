package org.ziptie.provider.adapters;

import java.util.List;

import javax.jws.WebService;

import org.ziptie.credentials.CredentialKey;
import org.ziptie.provider.adapters.internal.AdapterProviderActivator;

/**
 * AdapterDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.adapters.IAdapterProvider",
            serviceName = "AdaptersService", portName = "AdaptersPort")
public class AdapterDelegate implements IAdapterProvider
{

    /** {@inheritDoc} */
    public List<AdapterLite> getAvailableAdapters()
    {
        return getProvider().getAvailableAdapters();
    }

    /** {@inheritDoc} */
    public List<CredentialKey> getCredentialKeys()
    {
        return getProvider().getCredentialKeys();
    }

    private IAdapterProvider getProvider()
    {
        IAdapterProvider provider = AdapterProviderActivator.getAdapterProvider();
        if (provider == null)
        {
            throw new RuntimeException("Adapter provider service is currently unavailable");
        }

        return provider;
    }
}
