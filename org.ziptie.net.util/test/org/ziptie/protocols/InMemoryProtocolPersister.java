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
 * 
 * Contributor(s):
 */

package org.ziptie.protocols;

import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TreeSet;

import org.ziptie.exception.PersistenceException;

/**
 * Saves protocol info in Java structures rather than to a DB. Use with unit
 * tests.
 * 
 * @author rkruse
 */
public class InMemoryProtocolPersister implements IProtocolPersister
{

    private Set<ProtocolConfig> protocolConfigs;
    private ProtocolConfig defaultProtocolConfig;
    private Map<String, ProtocolSetStatus> workingProtocols;
    private long idCounter = 1;
    private Properties globalProperties;

    /**
     * Default constructor.
     */
    public InMemoryProtocolPersister()
    {
        protocolConfigs = new TreeSet<ProtocolConfig>();
        workingProtocols = new HashMap<String, ProtocolSetStatus>();
        globalProperties = new Properties();
    }

    /**
     * {@inheritDoc}
     */
    public void deleteProtocolConfig(ProtocolConfig protocolConfig)
    {
        protocolConfigs.remove(protocolConfig);
    }

    /**
     * {@inheritDoc}
     */
    public Set<ProtocolConfig> getAllProtocolConfigs()
    {
        return protocolConfigs;
    }

    /**
     * {@inheritDoc}
     */
    public ProtocolConfig getDefaultProtocolConfig()
    {
        return defaultProtocolConfig;
    }

    /**
     * {@inheritDoc}
     */
    public ProtocolConfig saveDefaultProtocolConfig(ProtocolConfig protocolConfig)
    {
        addIdsIfNeeded(protocolConfig);
        this.defaultProtocolConfig = protocolConfig;
        return protocolConfig;
    }

    /**
     * {@inheritDoc}
     */
    public ProtocolConfig saveProtocolConfig(ProtocolConfig config)
    {
        addIdsIfNeeded(config);
        protocolConfigs.remove(config);
        protocolConfigs.add(config);

        return config;
    }

    /**
     * {@inheritDoc}
     */
    public String getProperty(String key)
    {
        return globalProperties.getProperty(key);
    }

    /**
     * {@inheritDoc}
     */
    public void saveProperty(String key, String value)
    {
        globalProperties.setProperty(key, value);
    }

    /**
     * {@inheritDoc}
     */
    public void clearDeviceToProtocolMapping(String deviceID) throws PersistenceException
    {
        ProtocolSetStatus psStatus = workingProtocols.get(deviceID);
        if (psStatus != null)
        {
            psStatus.setStale(true);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void clearDeviceToProtocolMappings(ProtocolConfig protocolConfig) throws PersistenceException
    {
        Set<String> keys = workingProtocols.keySet();
        for (String key : keys)
        {
            ProtocolSetStatus protocolSetStatus = workingProtocols.get(key);
            if (protocolSetStatus.getProtocolSet().getProtocolConfigId() == protocolConfig.getId())
            {
                workingProtocols.remove(key);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public ProtocolSet getProtocolSetByDeviceID(String deviceID, boolean returnStaleProtocols) throws PersistenceException
    {
        ProtocolSetStatus psStatus = workingProtocols.get(deviceID);
        if (psStatus == null || (!returnStaleProtocols && psStatus.isStale()))
        {
            return null;
        }
        else
        {
            return psStatus.getProtocolSet();
        }
    }

    /**
     * {@inheritDoc}
     */
    public void mapDeviceToProtocolSet(String deviceID, ProtocolSet protocolSet) throws PersistenceException
    {
        clearDeviceToProtocolMapping(deviceID);
        workingProtocols.put(deviceID, new ProtocolSetStatus(protocolSet, false));
    }

    /**
     * {@inheritDoc}
     */
    public void markDeviceToProtocolMappingAsStale(String deviceID) throws PersistenceException
    {
        ProtocolSetStatus protocolSetStatus = workingProtocols.get(deviceID);
        protocolSetStatus.setStale(true);
    }

    /**
     * {@inheritDoc}
     */
    public void markDeviceToProtocolMappingsAsStale(ProtocolConfig protocolConfig) throws PersistenceException
    {
        Set<String> keys = workingProtocols.keySet();
        for (String key : keys)
        {
            ProtocolSetStatus protocolSetStatus = workingProtocols.get(key);
            if (protocolSetStatus.getProtocolSet().getProtocolConfigId() == protocolConfig.getId())
            {
                protocolSetStatus.setStale(true);
            }
        }
    }

    /**
     * Used by this persister to track 'stale' status of a protocolSet
     * 
     * @author rkruse
     */
    private static class ProtocolSetStatus
    {
        private ProtocolSet protocolSet;
        private boolean stale;

        /**
         * 
         * @param protocolSet
         * @param stale
         */
        public ProtocolSetStatus(ProtocolSet protocolSet, boolean stale)
        {
            this.protocolSet = protocolSet;
            this.stale = stale;
        }

        /**
         * @return the protocolSet
         */
        public ProtocolSet getProtocolSet()
        {
            return protocolSet;
        }

        /**
         * @param protocolSet the protocolSet to set
         */
        public void setProtocolSet(ProtocolSet protocolSet)
        {
            this.protocolSet = protocolSet;
        }

        /**
         * @return the stale
         */
        public boolean isStale()
        {
            return stale;
        }

        /**
         * @param stale the stale to set
         */
        public void setStale(boolean stale)
        {
            this.stale = stale;
        }
    }

    /**
     * Sets a unique ID to the protocolConfig and the underlying protocols
     * 
     * @param config
     */
    private void addIdsIfNeeded(ProtocolConfig config)
    {
        if (config.getId() == ProtocolConfig.UNSAVED_ID)
        {
            config.setId(getNewID());
        }

        for (Protocol protocol : config.getProtocols())
        {
            if (protocol.getId() == Protocol.UNSAVED_ID)
            {
                protocol.setId(getNewID());
            }
        }
    }

    private long getNewID()
    {
        idCounter++;
        return idCounter;
    }
}
