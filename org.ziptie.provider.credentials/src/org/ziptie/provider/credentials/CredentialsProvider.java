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
 * Copyright the ZipTie Project (www.ziptie.org)
 */

package org.ziptie.provider.credentials;

import java.util.List;

import org.ziptie.addressing.IPAddress;
import org.ziptie.credentials.AbstractCredentialsManager;
import org.ziptie.credentials.CredentialConfig;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.exception.PersistenceException;
import org.ziptie.net.utils.PortScan;
import org.ziptie.protocols.AbstractProtocolManager;
import org.ziptie.protocols.NoEnabledProtocolsException;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolConfig;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.credentials.internal.CredentialsProviderActivator;
import org.ziptie.security.PermissionDeniedException;

/**
 * The {@link CredentialsProvider} class implements the {@link ICredentialsProvider} interface in order to perform the various functionality to be made
 * available in order to create, update, and delete credential and protocol information that is used through-out ZipTie.  This class makes heavy use
 * of the {@link AbstractCredentialsManager} and {@link AbstractProtocolManager} classes to provide the necessary support and functionality.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public class CredentialsProvider implements ICredentialsProvider
{
    /** {@inheritDoc} */
    public void deleteCredentialConfig(CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException
    {
        CredentialsProviderActivator.getCredentialsManager().deleteCredentialConfig(credentialConfig);
    }

    /** {@inheritDoc} */
    public void deleteProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException, PermissionDeniedException
    {
        CredentialsProviderActivator.getProtocolManager().deleteProtocolConfig(protocolConfig);
    }

    /** {@inheritDoc} */
    public List<CredentialConfig> getAllCredentialConfigs() throws PermissionDeniedException, PersistenceException
    {
        return CredentialsProviderActivator.getCredentialsManager().getAllCredentialConfigs();
    }

    /** {@inheritDoc} */
    public List<ProtocolConfig> getAllProtocolConfigs() throws PersistenceException, PermissionDeniedException
    {
        return CredentialsProviderActivator.getProtocolManager().getAllProtocolConfigs();
    }

    /** {@inheritDoc} */
    public List<CredentialSet> getCredentialSetsByIpAddress(String ipAddress) throws PermissionDeniedException, PersistenceException
    {
        IPAddress ipAddrObj = new IPAddress(ipAddress);
        return CredentialsProviderActivator.getCredentialsManager().getCredentialSetsByIpAddress(ipAddrObj);
    }

    /** {@inheritDoc} */
    public CredentialConfig getDefaultCredentialConfig() throws PermissionDeniedException, PersistenceException
    {
        return CredentialsProviderActivator.getCredentialsManager().getDefaultCredentialConfig();
    }

    /** {@inheritDoc} */
    public ProtocolConfig getDefaultProtocolConfig() throws PermissionDeniedException, PersistenceException
    {
        return CredentialsProviderActivator.getProtocolManager().getDefaultProtocolConfig();
    }

    /** {@inheritDoc} */
    public ProtocolConfig getNewFullProtocolConfig()
    {
        return CredentialsProviderActivator.getProtocolManager().getNewFullProtocolConfig();
    }

    /** {@inheritDoc} */
    public ProtocolConfig getProtocolConfigByIpAddress(String ipAddress) throws PersistenceException
    {
        IPAddress ipAddrObj = new IPAddress(ipAddress);
        return CredentialsProviderActivator.getProtocolManager().getProtocolConfigByIpAddress(ipAddrObj);
    }

    /** {@inheritDoc} */
    public void saveCredentialConfig(CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException
    {
        CredentialsProviderActivator.getCredentialsManager().saveCredentialConfig(credentialConfig);
    }

    /** {@inheritDoc} */
    public void saveDefaultCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException
    {
        CredentialsProviderActivator.getCredentialsManager().saveDefaultCredentialConfig(credentialConfig);
    }

    /** {@inheritDoc} */
    public void saveDefaultProtocolConfig(ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException
    {
        CredentialsProviderActivator.getProtocolManager().saveDefaultProtocolConfig(protocolConfig);
    }

    /** {@inheritDoc} */
    public void saveProtocolConfig(ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException
    {
        CredentialsProviderActivator.getProtocolManager().saveProtocolConfig(protocolConfig);
    }

    /**
     * Maps a device, associated with the specified device ID, to a {@link CredentialSet} object.  This is important if it has been determined
     * that the credentials specified in the {@link CredentialSet} have been used successfully with the device associated with the specified
     * device ID.
     * <p>
     * If the {@link CredentialSet} being passed in is a previously unsaved, it will be saved first under {@link CredentialConfig} object
     * that is associated with the specified IP, and then a separate mapping will take place to map the {@link CredentialSet} to the specified
     * device ID directly.
     * <p>
     * If there is already an identical {@link CredentialSet} inside of the matching {@link CredentialConfig}, then it won't save a new one; instead
     * the existing saved set will be used when mapping to the specified IP address.
     * @param credentialSet The credential set containing all of the credentials that were used successfully.
     * @param deviceID The ID of the device to map to.
     * 
     * @throws PermissionDeniedException only if the specified credential set doesn't already exist and the user doesn't have the appropriate
     * credentials permission.
     * @throws PersistenceException if the data store can't save the mapping.
     */
    public void mapDeviceToCredentialSet(String deviceID, CredentialSet credentialSet) throws PermissionDeniedException, PersistenceException
    {
        CredentialsProviderActivator.getCredentialsManager().mapDeviceToCredentialSet(deviceID, credentialSet);
    }

    /**
     * Maps a device that is associated with the specified device ID to a {@link ProtocolSet} object that contains
     * all of the protocols associated with the device.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @param protocolSet The protocol set containing all of the protocols to associate with the device.
     * @throws PersistenceException if the data store has issues creating the device to credential set mapping.
     */
    public void mapDeviceToProtocolSet(String deviceID, ProtocolSet protocolSet) throws PersistenceException
    {
        CredentialsProviderActivator.getProtocolManager().mapDeviceToProtocolSet(deviceID, protocolSet);
    }

    /**
     * Removes all {@link CredentialSet} objects that don't have a device directly mapped to them.
     * 
     * @throws PersistenceException if there was an error in data store while purging all of the unmapped credential sets.
     * @throws PermissionDeniedException if the user does not have permission to purge unmapped credentials.
     */
    public void purgeUnmappedCredentials() throws PermissionDeniedException
    {

        try
        {
            CredentialsProviderActivator.getCredentialsManager().purgeUnmappedCredentials();
        }
        catch (PersistenceException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * Retrieves the {@link CredentialSet} object associated with the device that is represented by the specified device ID.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @param returnStaleCredentials Flag to determine whether or not a credential set that has been marked as stale should be returned.
     * @return The credential set associated with the device; null if that is no credential set mapped to the device.
     * @throws PersistenceException if the data store has issues retrieving the device to credential set mapping.
     */
    public CredentialSet getCredentialSetByDeviceID(String deviceID, boolean returnStaleCredentials) throws PersistenceException
    {
        return CredentialsProviderActivator.getCredentialsManager().getCredentialSetByDeviceID(deviceID, returnStaleCredentials);
    }

    /**
     * Retrieves the {@link Protocol} object containing all of the protocols associated with the device that is represented by the
     * specified device ID.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @param returnStaleProtocols Flag to determine whether or not protocols that has been marked as stale should be returned.
     * @return The protocol set containing all the protocols associated with the device; null if there are no protocols mapped to the device.
     * @throws PersistenceException if the data store has issues retrieving the device to protocol mapping.
     */
    public ProtocolSet getProtocolSetByDeviceID(String deviceID, boolean returnStaleProtocols) throws PersistenceException
    {
        return CredentialsProviderActivator.getProtocolManager().getProtocolSetByDeviceID(deviceID, returnStaleProtocols);
    }

    /**
     * Calculates which of the specified {@link ProtocolSet} objects are actually supported for use against a device associated with the specified
     * device ID.  This is achieved by checking if the ports for all the protocols from a protocol set are open and ready for use on the device
     * specified by the ID.  This method is most commonly used when checking to see which of the protocol sets that have been specified
     * on a device adapter is the preferred set.  If a single protocol set have already been mapped for use with the device associated with the
     * specified ID, then this method will not check any open ports and will return a {@link List} containing the single protocol set.
     * 
     * @param protocolSetsFromAdapter A {@link List} of {@link ProtocolSet} objects that test to see if they are supported for use with the
     * device that is associated with the specified device ID.
     * @param deviceID The ID of the device to use when testing to see which protocol sets are supported.
     * @param includeStaleProtocols Flag to determine whether or not to include protocols that have been marked stale.
     * @return A {@link List} of all {@link ProtocolSet} objects that have been determined to be supported against the device associated with the
     * specified device ID.
     * @throws PersistenceException if the data store throws an error.
     * @throws NoEnabledProtocolsException if there are no protocols enable on the device.
     */
    public List<ProtocolSet> calculateSupportedProtocolSets(List<ProtocolSet> protocolSetsFromAdapter, String deviceID, boolean includeStaleProtocols)
            throws PersistenceException, NoEnabledProtocolsException
    {
        return CredentialsProviderActivator.getProtocolManager().calculateSupportedProtocolSets(protocolSetsFromAdapter, deviceID, includeStaleProtocols);
    }

    public ProtocolSet getAllEnabledProtocols(String ipAddress, String deviceId) throws PersistenceException
    {
        IPAddress ip = new IPAddress(ipAddress);
        AbstractProtocolManager protocolManager = CredentialsProviderActivator.getProtocolManager();
        ProtocolSet protocolSet = new ProtocolSet();
        ProtocolSet protocolSetByDeviceID = null;
        ProtocolConfig protocolConfig = protocolManager.getProtocolConfigByIpAddress(ip);
        if (deviceId != null)
        {
            protocolSetByDeviceID = protocolManager.getProtocolSetByDeviceID(deviceId, true);
        }

        for (Protocol protocol : protocolConfig.getProtocols())
        {
            if (protocol.isEnabled())
            {
                if (protocolSetByDeviceID != null)
                {
                    for (Protocol inner : protocolSetByDeviceID.getProtocols())
                    {
                        if (inner.getName().equals(protocol.getName()))
                        {
                            protocol.setValidatedOnDevice(true);
                            break;
                        }
                    }
                    protocolSet.addProtocol(protocol);
                }
                else
                {
                    if (protocolManager.isDoTCPScan() && protocol.isTCP())
                    {
                        if (PortScan.getInstance().isPortOpen(ip, protocol.getPort()))
                        {
                            protocolSet.addProtocol(protocol);
                        }
                    }
                    else
                    {
                        protocolSet.addProtocol(protocol);
                    }
                }
            }
        }
        return protocolSet;
    }

    /**
     * Calculates the list of {@link CredentialSet} objects that can be used with the device associated with the specified
     * device ID.  This is done by checking to see if there is a current credential set mapped to the device and that the
     * credential set is not stale.  If this is the case, the mapped credential set will be returned; otherwise, all of the
     * credential sets associated with the IP of the device will be retrieved and can be used.
     * 
     * @param deviceID The ID of the device that will be using the calculated credentials.
     * @param returnStaleCredentials Whether or not stale credentials should be allowed to be included in the credential sets
     * found.
     * @return A list of found credential sets to use with the device associated with the specified device ID.
     * @throws PersistenceException if there is an error retrieving a previous device to credential set mapping from the data store
     * @throws PermissionDeniedException if there is an error retrieving the information.
     */
    public List<CredentialSet> calculateCredentialSets(String deviceID, boolean returnStaleCredentials) throws PersistenceException, PermissionDeniedException
    {
        return CredentialsProviderActivator.getCredentialsManager().calculateCredentialSets(deviceID, returnStaleCredentials);
    }

    /**
     * Clears out the saved device-to-credential set mapping for a device associated with the specified device ID.
     * A user of the manager should clear these out if the corresponding device has been removed from
     * the inventory.
     * 
     * @param deviceID The ID of the device to clear credentials for.
     * @throws PersistenceException if an error occurred within the data store when clearing the device-to-credential set mapping.
     */
    public void clearDeviceToCredentialSetMapping(String deviceID) throws PersistenceException
    {
        CredentialsProviderActivator.getCredentialsManager().clearDeviceToCredentialSetMapping(deviceID);
    }

    /**
     * Marks the mapping of a device, that is associated with the specified device ID, to a {@link Protocol} object 
     * as being stale/old.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @throws PersistenceException if the data store has issues updating the device to protocol mapping as being stale.
     */
    public void markDeviceToProtocolMappingAsStale(String deviceID) throws PersistenceException
    {
        CredentialsProviderActivator.getProtocolManager().markDeviceToProtocolMappingAsStale(deviceID);
    }

    /**
     * Marks the mapping of a device with a credential set as stale so that future operations can choose to use it
     * or not based on its staleness.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @throws PersistenceException if the data store has issues updating the device to protocol mapping as being stale.
     */
    public void markDeviceToCredentialMappingAsStale(String deviceID) throws PersistenceException
    {
        CredentialsProviderActivator.getCredentialsManager().markDeviceToCredentialSetMappingAsStale(deviceID);
    }

    /**
     * {@inheritDoc}
     */
    public void updateSingleCredential(String ipAddress, String managedNetwork, String credentialKey, String credentialValue) throws PersistenceException,
            PermissionDeniedException
    {
        CredentialsProviderActivator.getCredentialsManager().updateSingleCredential(ipAddress, managedNetwork, credentialKey, credentialValue);
    }

    /** {@inheritDoc} */
    public void updateDependentCredential(String ipAddress, String managedNetwork, String credentialKey, String credentialValue, String dependentCredentialKey,
                                          String dependentCredentialValue) throws PersistenceException, PermissionDeniedException
    {
        CredentialsProviderActivator.getCredentialsManager().updateDependentCredential(ipAddress, managedNetwork, credentialKey, credentialValue,
                                                                                       dependentCredentialKey, dependentCredentialValue);
    }

}
