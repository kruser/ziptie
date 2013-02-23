package org.ziptie.provider.devices;

import javax.jws.WebService;

import org.ziptie.provider.devices.internal.DeviceProviderActivator;

/**
 * SimpleDeviceSearchDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.devices.ISimpleDeviceSearch", //$NON-NLS-1$
serviceName = "DeviceSearchService", portName = "DeviceSearchPort")
public class SimpleDeviceSearchDelegate implements ISimpleDeviceSearch
{
    private static final PageData EMPTY_PAGEDATA;

    static
    {
        EMPTY_PAGEDATA = new PageData();
    }

    /** {@inheritDoc} */
    public PageData search(String scheme, String query, PageData pageData, String sortColumn, boolean descending)
    {
        if (scheme == null || query == null || pageData == null)
        {
            return EMPTY_PAGEDATA;
        }
        return getProvider().search(scheme, query, pageData, sortColumn, descending);
    }

    /**
     * This is an accessor to get the 'true' scheduler as a service.  If the bundle
     * has been restarted, this may return a different Scheduler than previous
     * invocations.  But they should be backed by the same job store, so it would
     * be transparent to the client.
     * 
     * @return the Scheduler to which to delegate
     */
    private ISimpleDeviceSearch getProvider()
    {
        ISimpleDeviceSearch provider = DeviceProviderActivator.getSearch();
        if (provider == null)
        {
            throw new RuntimeException(Messages.SimpleDeviceSearchDelegate_searchProviderUnavailable);
        }

        return provider;
    }
}
