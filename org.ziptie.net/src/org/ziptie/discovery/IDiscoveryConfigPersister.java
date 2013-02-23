/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/07/21 20:38:56 $
 * $Revision: 1.3 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/IDiscoveryConfigPersister.java,v $e
 */

package org.ziptie.discovery;

import org.ziptie.exception.PersistenceException;

/**
 * This can be provided to the {@link DiscoveryEngine} startup if you want to persist the {@link DiscoveryConfig}.<br>
 * <br>
 * The <code>DiscoveryEngine</code> will cache the <code>DiscoveryConfig</code> and only call load and save when
 * necessary. So there is no need to make an implementation of this Interface high performing.
 * 
 * @author rkruse
 */
public interface IDiscoveryConfigPersister
{
    /**
     * Load up the {@link DiscoveryConfig} from the data store.
     * 
     * @return a discovery configuration
     */
    DiscoveryConfig loadDiscoveryConfig();

    /**
     * Save the details of the {@link DiscoveryConfig}
     * @param discoveryConfig the discovery configuration to save
     * 
     * @throws PersistenceException then if there is an error persisting the configuration
     */
    void saveDiscoveryConfig(DiscoveryConfig discoveryConfig) throws PersistenceException;
}
