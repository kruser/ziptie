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
package org.ziptie.discovery;

import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.exception.PersistenceException;
import org.ziptie.net.common.NILProperties;

/**
 * DiscoveryConfigProperties uses {@link NILProperties} for 
 * some user changeable properties.
 */
public class DiscoveryConfigProperties implements IDiscoveryConfigPersister
{

    /** {@inheritDoc} */
    public DiscoveryConfig loadDiscoveryConfig()
    {
        NILProperties properties = NILProperties.getInstance();
        DiscoveryConfig discoveryConfig = new DiscoveryConfig();
        discoveryConfig.setBoundaryNetworks(parseAddressSet(properties.getString("nil.discovery.boundaries")));
        discoveryConfig.setExclusions(parseAddressSet(properties.getString("nil.discovery.exclusions")));
        discoveryConfig.setDiscoverNeighbors(properties.getBoolean("nil.discovery.discoverNeighbors"));
        discoveryConfig.setPollARP(properties.getBoolean("nil.discovery.walkArp"));
        discoveryConfig.setPollCDP(properties.getBoolean("nil.discovery.walkDiscoveryProtocolNeighbors"));
        discoveryConfig.setPollRoutingNeighbors(properties.getBoolean("nil.discovery.walkRoutingNeighbors"));
        discoveryConfig.setClearCacheDelayMinutes(properties.getInt("nil.discovery.clearCacheDelayMinutes"));
        discoveryConfig.setMaxMaskPingSweep(properties.getInt("nil.discovery.maxMaskPingSweep"));
        discoveryConfig.setMaxMaskPingSweepIpv6(properties.getInt("nil.discovery.maxMaskPingSweepIpv6"));
        discoveryConfig.setPingSize(properties.getInt("nil.discovery.pingSize"));
        discoveryConfig.setPingCount(properties.getInt("nil.discovery.pingCount"));
        discoveryConfig.setPingTimeout(properties.getInt("nil.discovery.pingTimeout"));
        discoveryConfig.setMasterThreads(properties.getInt("nil.discovery.masterThreads"));
        return discoveryConfig;
    }

    /** {@inheritDoc} */
    public void saveDiscoveryConfig(DiscoveryConfig discoveryConfig) throws PersistenceException
    {
        // no-op - we're not saving back to the properties
    }

    /**
     * Takes a comma separated list of addresses and returns an addressSet object. 
     * @param addressString a CSV list of addresses
     * @return the AddressSet
     */
    private AddressSet parseAddressSet(String addressString)
    {
        AddressSet addressSet = new AddressSet();
        if (addressString.length() > 0)
        {
            String[] strings = addressString.split(",");
            for (int i = 0; i < strings.length; i++)
            {
                addressSet.add(NetworkAddressElf.parseAddress(strings[i]));
            }
        }
        return addressSet;
    }

}
