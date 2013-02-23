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

import java.util.List;

import javax.jws.WebService;

import org.ziptie.provider.configstore.internal.ConfigStoreActivator;

/**
 * ConfigSearchDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.configstore.IConfigSearch", //$NON-NLS-1$
            serviceName = "ConfigSearchService", portName = "ConfigSearchPort")
public class ConfigSearchDelegate implements IConfigSearch
{
    /** {@inheritDoc} */
    public List<ConfigSearchResult> searchConfig(String expression)
    {
        return getConfigSearch().searchConfig(expression);
    }

    /**
     * This is an accessor to get the 'true' service.  If the bundle has been restarted,
     * this may return a different provider than previous invocations.  
     * 
     * @return the provider to which to delegate
     */
    private IConfigSearch getConfigSearch()
    {
        IConfigSearch configSearch = ConfigStoreActivator.getConfigSearch();
        if (configSearch == null)
        {
            throw new RuntimeException(Messages.ConfigSearchDelegate_serviceUnavailable);
        }

        return configSearch;
    }
}
