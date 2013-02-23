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
 * Contributor(s): kruse, Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.protocols;

import java.util.Set;

import org.ziptie.exception.PersistenceException;

/**
 * The {@link IProtocolPersister} interfaces defines the structure for methods to save protocol information that should be used to
 * determine how to connect to devices.
 * <p>
 * The {@link IProtocolPersister} is responsible for updating the ID field of each {@link ProtocolConfig} and underlying {@link Protocol}.
 * The ID field is considered to be a unique primary key.
 * 
 * @author rkruse
 * @author Dylan White (dylamite@ziptie.org)
 */
public interface IProtocolPersister
{
    /**
     * Retrieves the {@link ProtocolConfig} that is set as the default; returns a new {@link ProtocolConfig} if a default is not yet set.
     * The default protocol configuration is the last one checked if there is no device specific protocol configuration or any protocol
     * configuration that is mapped to the device that is trying to determine which protocol configuration to use.
     * 
     * @return The default protocol configuration.
     * @throws PersistenceException if the data store throws an error.
     */
    ProtocolConfig getDefaultProtocolConfig() throws PersistenceException;

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
     * @param protocolConfig A protocol configuration to set as the default.
     * @return The protocol configuration populated with its persisted ID.
     * @throws PersistenceException If there was an error setting the specified {@link ProtocolConfig} object
     * as the default protocol configuration within the data store.
     */
    ProtocolConfig saveDefaultProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException;

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
     * @param protocolConfig A non-default protocol config.
     * @return The protocol configuration populated with its persisted ID.
     * @throws PersistenceException if the data store throws an error.
     */
    ProtocolConfig saveProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException;

    /**
     * Retrieves a {@link Set} of all {@link ProtocolConfig} objects.  This does not include the {@link ProtocolConfig} object that
     * has been marked as the default.  To retrieve the default {@link ProtocolConfig} object, refer to the
     * {@link #getDefaultProtocolConfig()} method.
     * 
     * @return A {@link Set} of the protocol configurations.
     * @throws PersistenceException if the data store throws an error.
     */
    Set<ProtocolConfig> getAllProtocolConfigs() throws PersistenceException;

    /**
     * Deletes the specified {@link ProtocolConfig} object.
     * 
     * @param protocolConfig The protocol configuration to delete.
     * @throws PersistenceException If there was an error deleting the protocol configuration from the data store.
     */
    void deleteProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException;

    /**
     * Maps a device that is associated with the specified device ID to a {@link ProtocolSet} object that contains
     * all of the protocols associated with the device.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @param protocolSet The protocol set containing all of the protocols to associate with the device.
     * @throws PersistenceException if the data store has issues creating the device to credential set mapping.
     */
    void mapDeviceToProtocolSet(String deviceID, ProtocolSet protocolSet) throws PersistenceException;

    /**
     * Retrieves the {@link Protocol} object containing all of the protocols associated with the device that is represented by the
     * specified device ID.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @param returnStaleProtocols Flag to determine whether or not protocols that has been marked as stale should be returned.
     * @return The protocol set containing all the protocols associated with the device; null if there are no protocols mapped to the device.
     * @throws PersistenceException if the data store has issues retrieving the device to protocol mapping.
     */
    ProtocolSet getProtocolSetByDeviceID(String deviceID, boolean returnStaleProtocols) throws PersistenceException;

    /**
     * Clears out any mapping of a {@link Protocol} object to the device specified by the device ID.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @throws PersistenceException if the data store has issues removing the device to protocol mapping.
     */
    void clearDeviceToProtocolMapping(String deviceID) throws PersistenceException;

    /**
     * Clears out all of the mappings of a {@link Protocol} object to one or more devices.  All of these protocols
     * are assumed to be associated with the specified {@link ProtocolConfig} object.  This can be used to clear out any
     * saved protocols in the event that the {@link ProtocolConfig} object has been updated or removed.
     * 
     * @param protocolConfig The protocolConfig that has been removed or updated.
     * @throws PersistenceException if the data store has issues removing the device to protocol mappings.
     */
    void clearDeviceToProtocolMappings(ProtocolConfig protocolConfig) throws PersistenceException;

    /**
     * Marks the mapping of a device, that is associated with the specified device ID, to a {@link Protocol} object 
     * as being stale/old.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @throws PersistenceException if the data store has issues updating the device to protocol mapping as being stale.
     */
    void markDeviceToProtocolMappingAsStale(String deviceID) throws PersistenceException;

    /**
     * Marks all {@link Protocol} objects associated with the specified {@list ProtocolConfig} and their associated mappings a device to a
     * {@link Protocol} object as being stale/old.
     * 
     * @param protocolConfig The protocol configuration containing all of the protocols to mark as being stale/old.
     * @throws PersistenceException if the data store has issues updating the all of the associated device to protocol mappings
     * as being stale.
     */
    void markDeviceToProtocolMappingsAsStale(ProtocolConfig protocolConfig) throws PersistenceException;

    /**
     * Retrieves the value of a property that is mapped to a specified key.
     * 
     * @param key The key of the property.
     * @return The value of the property; null if that is no property mapped to the specified key.
     */
    String getProperty(String key);

    /**
     * Saves a property to the data store.
     * 
     * @param key The key of the property.
     * @param value The value of the property.
     * @throws PersistenceException if the data store has issues persisting the property.
     */
    void saveProperty(String key, String value) throws PersistenceException;
}
