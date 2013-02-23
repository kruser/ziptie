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

import org.ziptie.provider.configstore.internal.ConfigStoreActivator;
import org.ziptie.provider.devices.ZDeviceCore;

/**
 * ConfigIndexerRevisionObserver
 */
public class ConfigIndexerRevisionObserver implements IRevisionObserver
{
    private ConfigSearch configSearch;

    /**
     * Default constructor.
     */
    public ConfigIndexerRevisionObserver()
    {
        configSearch = (ConfigSearch) ConfigStoreActivator.getConfigSearch();
    }

    /** {@inheritDoc} */
    public void revisionChange(ZDeviceCore device, List<ConfigHolder> configs)
    {
        for (ConfigHolder holder : configs)
        {
            if (holder.getFullName().contains(ConfigBackupPersister.ZIPTIE_ELEMENT_DOCUMENT) || holder.getType() == null)
            {
                continue;
            }

            if (holder.getType().equals("M")) //$NON-NLS-1$
            {
                configSearch.updateIndex(device, holder);
            }
            else if (holder.getType().equals("A")) //$NON-NLS-1$
            {
                configSearch.addToIndex(device, holder);
            }
            else if (holder.getType().equals("D")) //$NON-NLS-1$
            {
                configSearch.deleteFromIndex(device, holder);
            }
        }
    }
}
