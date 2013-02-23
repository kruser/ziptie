package org.ziptie.provider.devices;

import org.apache.log4j.Logger;

/**
 * SimpleDeviceSearch
 */
public class SimpleDeviceSearch implements ISimpleDeviceSearch
{
    private static final Logger LOGGER = Logger.getLogger(SimpleDeviceSearch.class);

    /** {@inheritDoc} */
    public PageData search(String scheme, String query, PageData pageData, String sortColumn, boolean descending)
    {
        IDeviceResolutionScheme resolver = DeviceResolutionElf.getResolutionScheme(scheme);

        if (LOGGER.isDebugEnabled())
        {
            LOGGER.debug(String.format("Device search with scheme '%s' and query:\n%s", scheme, query)); //$NON-NLS-1$
        }

        return resolver.resolve(scheme, query, pageData, sortColumn, descending);
    }
}
