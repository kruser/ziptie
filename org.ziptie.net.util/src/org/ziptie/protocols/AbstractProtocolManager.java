/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint. Portions created by
 * AlterPoint are Copyright (C) 2006, AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.protocols;

import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;
import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.IPAddress;
import org.ziptie.exception.PersistenceException;
import org.ziptie.protocols.utils.ProtocolConfigElf;
import org.ziptie.security.ISecurityCheck;
import org.ziptie.security.PermissionDeniedException;

/**
 * The {@link AbstractProtocolManager} class provides various functionality for handling protocols.  This includes the retrieval, persistence,
 * and deletion of protocol related objects, associating protocols with devices, and maintaining the priorities of
 * protocol objects in relation to each other.
 * 
 * @author rkruse
 * @author Dylan White (dylamite@ziptie.org)
 */
public abstract class AbstractProtocolManager
{
    private static final boolean DEFAULT_TCP_SCAN = true;
    private static final String TCP_SCAN_TAG = "TCP_SCAN";
    private static Logger LOGGER = Logger.getLogger(AbstractProtocolManager.class);

    private IProtocolPersister persister;
    private ISecurityCheck securityCheck;

    /**
     * Retrieves the implementation of the {@link IProtocolPersister} interface that will be used to persists protocol related objects.
     * 
     * @return The implementation of the {@link IProtocolPersister} interface being used.
     */
    public IProtocolPersister getPersister()
    {
        return persister;
    }

    /**
     * Sets the implementation of the {@link IProtocolPersister} interface that will be used to persists protocol related objects.
     * 
     * @param persister The implementation of the {@link IProtocolPersister} interface that to be used.
     */
    public void setPersister(IProtocolPersister persister)
    {
        this.persister = persister;
    }

    /**
     * Retrieves the implementation of the {@link ISecurityCheck} interface that will be used to see if certain actions are allowed.
     * 
     * @return The implementation of the {@link ISecurityCheck} interface being used.
     */
    public ISecurityCheck getSecurityCheck()
    {
        return securityCheck;
    }

    /**
     * Sets the implementation of the {@link ISecurityCheck} interface that will be used to see if certain actions are allowed.
     * 
     * @param securityCheck The implementation of the {@link ISecurityCheck} interface that to be used.
     */
    public void setSecurityCheck(ISecurityCheck securityCheck)
    {
        this.securityCheck = securityCheck;
    }

    /**
     * Retrieves the {@link ProtocolConfig} that is set as the default; returns a new {@link ProtocolConfig} if a default is not yet set.
     * The default protocol configuration is the last one checked if there is no device specific protocol configuration or any protocol
     * configuration that is mapped to the device that is trying to determine which protocol configuration to use.
     * 
     * @return The default protocol configuration.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public ProtocolConfig getDefaultProtocolConfig() throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkReadPrivileges();
        return persister.getDefaultProtocolConfig();
    }

    /**
     * Saves the specified {@link ProtocolConfig} object as the default protocol configuration.  The default protocol configuration is the last
     * one checked if there is no device specific protocol configuration or any protocol configuration that is mapped to the device that is trying
     * to determine which protocol configuration to use.
     * <p>
     * To save a non-default {@link ProtocolConfig} object, use the {@link #saveProtocolConfig(ProtocolConfig)} method.
     * <p>
     * If the {@link ProtocolConfig} specified is a new default protocol configuration, then all saved mappings between devices and the
     * previous default protocol configuration will be wiped clean.
     * <p>
     * If the {@link ProtocolConfig} specified is the existing default protocol configuration, it will just be updated and the saved mappings
     * between devices will be marked as stale.
     * 
     * @param protocolConfig A protocol configuration to save as the default.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public void saveDefaultProtocolConfig(ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkWritePrivileges();
        ProtocolConfig originalDefault = persister.getDefaultProtocolConfig();
        if (originalDefault != null && (originalDefault.getId() != protocolConfig.getId()))
        {
            persister.clearDeviceToProtocolMappings(originalDefault);
        }
        else if (protocolConfig.getId() >= 0)
        {
            persister.markDeviceToProtocolMappingsAsStale(protocolConfig);
        }
        persister.saveDefaultProtocolConfig(protocolConfig);
    }

    /**
     * Saves the specified non-default {@link ProtocolConfig} object.  To save a {@link ProtocolConfig} object as the default, use the
     * {@link #saveDefaultProtocolConfig(ProtocolConfig)} method.
     * <p>
     * If the {@link ProtocolConfig} specified is a new protocol configuration (meaning it hasn't been saved before), then all saved mappings
     * between devices and the default protocol configuration will be wiped clean.  This allows for this new protocol configuration to be given
     * a chance when trying to determine the proper protocols to use.
     * <p>
     * If the {@link ProtocolConfig} specified is an existing protocol configuration (meaning it has been saved before), it will just be updated
     * and the saved mappings between devices will be marked as stale.
     * 
     * @param protocolConfig The {@link ProtocolConfig} object to save.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public void saveProtocolConfig(ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkWritePrivileges();

        // If the ProtocolConfig has been changed (resaved) then we mark the
        // protocols as stale
        if (protocolConfig.getId() >= 0)
        {
            persister.markDeviceToProtocolMappingsAsStale(protocolConfig);
        }
        else
        {
            persister.markDeviceToProtocolMappingsAsStale(getDefaultProtocolConfig());
        }

        persister.saveProtocolConfig(protocolConfig);
    }

    /**
     * Deletes the specified {@link ProtocolConfig} object.  Beyond deleting the protocol configuration, all the mappings of devices to
     * protocol sets and protocols stored within the specified protocol configuration will be deleted as well.
     * 
     * @param protocolConfig The protocol configuration to delete.
     * @throws PermissionDeniedException If the user doesn't have permission to delete the protocol configuration.
     * @throws PersistenceException If there was an error deleting the protocol configuration from the data store.
     */
    public void deleteProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException, PermissionDeniedException
    {
        securityCheck.checkWritePrivileges();
        persister.clearDeviceToProtocolMappings(protocolConfig);
        persister.deleteProtocolConfig(protocolConfig);
    }

    /**
     * Returns a new {@link ProtocolConfig} object with all its protocols enabled but in the default order
     * of preference. This can be useful for a UI to create a screen of all the protocol sets.
     * 
     * @return A new protocol configuration in its default state.
     */
    public ProtocolConfig getNewFullProtocolConfig()
    {
        return ProtocolConfigElf.getNewConfig();
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
    public abstract List<ProtocolSet> calculateSupportedProtocolSets(List<ProtocolSet> protocolSetsFromAdapter, String deviceID, boolean includeStaleProtocols)
            throws PersistenceException, NoEnabledProtocolsException;

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
        try
        {
            // The are no protocols mapped to the device, them map the specified protocol set to it
            if (getPersister().getProtocolSetByDeviceID(deviceID, false) == null)
            {
                getPersister().mapDeviceToProtocolSet(deviceID, protocolSet);
            }
        }
        catch (PersistenceException pe)
        {
            /*
             * Normal activity if a protocol config has been deleted during the
             * backup
             */
            LOGGER.debug("The original protocols defined for the device ID " + deviceID + " have been removed from the datastore.  "
                    + "Unable to map device to protocols");
        }
    }

    /**
     * Retrieves a {@link List} of all {@link ProtocolConfig} objects.  This does not include the {@link ProtocolConfig} object that
     * has been marked as the default.  To retrieve the default {@link ProtocolConfig} object, refer to the
     * {@link #getDefaultProtocolConfig()} method.
     * 
     * @return A {@link List} of the protocol configurations.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public List<ProtocolConfig> getAllProtocolConfigs() throws PersistenceException, PermissionDeniedException
    {
        securityCheck.checkReadPrivileges();
        return new LinkedList<ProtocolConfig>(persister.getAllProtocolConfigs());
    }

    /**
     * Clears out any mapping of a {@link Protocol} object to the device specified by the device ID.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @throws PersistenceException if the data store has issues removing the device to protocol mapping.
     */
    public void clearDeviceToProtocolMapping(String deviceID) throws PersistenceException
    {
        persister.clearDeviceToProtocolMapping(deviceID);
    }

    /**
     * Clears out all of the mappings of a {@link Protocol} object to one or more devices.  All of these protocols
     * are assumed to be associated with the specified {@link ProtocolConfig} object.  This can be used to clear out any
     * saved protocols in the event that the {@link ProtocolConfig} object has been updated or removed.
     * 
     * @param protocolConfig The protocolConfig that has been removed or updated.
     * @throws PersistenceException if the data store has issues removing the device to protocol mappings.
     */
    public void clearDeviceToProtocolMappings(ProtocolConfig protocolConfig) throws PersistenceException
    {
        persister.clearDeviceToProtocolMappings(protocolConfig);
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
        persister.markDeviceToProtocolMappingAsStale(deviceID);
    }

    /**
     * Marks all {@link Protocol} objects associated with the specified {@list ProtocolConfig} and their associated mappings a device to a
     * {@link Protocol} object as being stale/old.
     * 
     * @param protocolConfig The protocol configuration containing all of the protocols to mark as being stale/old.
     * @throws PersistenceException if the data store has issues updating the all of the associated device to protocol mappings
     * as being stale.
     */
    public void markDeviceToProtocolMappingsAsStale(ProtocolConfig protocolConfig) throws PersistenceException
    {
        persister.markDeviceToProtocolMappingsAsStale(protocolConfig);
    }

    /**
     * Determines whether or not a TCP port should be opened for TCP-based protocols before deciding if it is a supported protocol
     * for a device.
     * 
     * @return Whether or not a TCP port should be opened for TCP-based protocols before deciding if it is a supported protocol
     * for a device.
     */
    public boolean isDoTCPScan()
    {
        String value = persister.getProperty(TCP_SCAN_TAG);
        if (value != null)
        {
            return Boolean.parseBoolean(value);
        }
        return DEFAULT_TCP_SCAN;
    }

    /**
     * Sets whether or not a TCP port should be opened for TCP-based protocols before deciding if it is a supported protocol
     * for a device.
     * 
     * @param doTCPScan Boolean flag determining whether or not a TCP port should be opened for TCP-based protocols before deciding
     * if it is a supported protocol for a device.
     * @throws PersistenceException if an error occurred while saving the TCP scan property to the data store.
     */
    public void setDoTCPScan(boolean doTCPScan) throws PersistenceException
    {
        persister.saveProperty(TCP_SCAN_TAG, Boolean.toString(doTCPScan));
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
        return persister.getProtocolSetByDeviceID(deviceID, returnStaleProtocols);
    }

    /**
     * Retrieves the {@link ProtocolConfig} object that is associated with a specified IP address; if there is no protocol configuration associated
     * with the specified IP address, then the default protocol configuration will be returned for use.
     * <p>
     * Note that this method only returns the protocol information as configured by the user of the API.  It will not return any previously
     * resolved parameters such as protocol versions or SSH ciphers.  To obtain previously resolved values, use the
     * {@link #calculateSupportedProtocolSets(List, String)} method.
     * 
     * @param ipAddress The IP address to check for.
     * @return The matching protocol configuration; the default protocol configuration if no match was found.
     * @throws PersistenceException if the data store throws an error.
     */
    public ProtocolConfig getProtocolConfigByIpAddress(IPAddress ipAddress) throws PersistenceException
    {
        Set<ProtocolConfig> allProtocolConfigs = persister.getAllProtocolConfigs();
        for (ProtocolConfig config : allProtocolConfigs)
        {
            AddressSet addressSet = config.getAddressSet();
            if (addressSet.contains(ipAddress))
            {
                return config;
            }
        }
        return persister.getDefaultProtocolConfig();
    }
}
