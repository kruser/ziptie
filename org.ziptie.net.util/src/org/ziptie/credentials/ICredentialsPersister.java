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
 * Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.credentials;

import java.util.Collection;

import org.ziptie.exception.PersistenceException;

/**
 * The {@link ICredentialsPersister} classes defines an interface that specifies the desired functionality that needs to be
 * fulfilled for properly persisting credential-related information and retrieving it.
 * 
 * @author rkruse
 * @author Dylan White (dylamite@ziptie.org)
 */
public interface ICredentialsPersister
{
    /**
     * Saves the specified {@link CredentialConfig} object as the default credential configuration.  The default credential configuration is the last
     * one checked if there is no device specific credential configuration or any credential configuration that is mapped to the device that is trying
     * to determine which credential configuration to use.
     * <p>
     * To save a non-default {@link CredentialConfig} object, use the {@link #saveCredentialConfig(CredentialConfig)} method.
     * <p>
     * If the {@link CredentialConfig} specified is a new default credential configuration, then all saved mappings between devices and the
     * previous default credential configuration will be wiped clean.
     * <p>
     * If the {@link CredentialConfig} specified is the existing default credential configuration, it will just be updated and the saved mappings
     * between devices will be marked as stale.
     * 
     * @param credentialConfig A credential configuration to set as the default.
     * @return The credential configuration populated with its persisted ID.
     * @throws PersistenceException If there was an error setting the specified {@link CredentialConfig} object
     * as the default credential configuration within the data store.
     */
    CredentialConfig saveDefaultCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException;

    /**
     * Retrieves a {@link Collection} of all {@link CredentialConfig} objects.  This does not include the {@link CredentialConfig} object that
     * has been marked as the default.  To retrieve the default {@link CredentialConfig} object, refer to the
     * {@link #getDefaultCredentialConfig()} method.
     * 
     * @return A {@link Collection} of the credential configurations.
     * @throws PersistenceException if the data store throws an error.
     */
    Collection<CredentialConfig> getAllCredentialConfigs() throws PersistenceException;

    /**
     * Retrieves the {@link CredentialConfig} that is set as the default; returns a new {@link CredentialConfig} if a default is not yet set.
     * The default credential configuration is the last one checked if there is no device specific credential configuration or any credential
     * configuration that is mapped to the device that is trying to determine which credential configuration to use.
     * 
     * @return The default credential configuration.
     * @throws PersistenceException if the data store throws an error.
     */
    CredentialConfig getDefaultCredentialConfig() throws PersistenceException;

    /**
     * Saves the specified non-default {@link CredentialConfig} object.  To save a {@link CredentialConfig} object as the default, use the
     * {@link #saveDefaultCredentialConfig(CredentialConfig)} method.
     * <p>
     * If the {@link CredentialConfig} specified is a new credential configuration (meaning it hasn't been saved before), then all saved mappings
     * between devices and the default credential configuration will be wiped clean.  This allows for this new credential configuration to be given
     * a chance when trying to determine the proper credentials to use.
     * <p>
     * If the {@link CredentialConfig} specified is an existing credential configuration (meaning it has been saved before), it will just be updated
     * and the saved mappings between devices will be marked as stale.
     * 
     * @param credentialConfig A non-default credential config.
     * @return The credential configuration populated with its persisted ID.
     * @throws PersistenceException if the data store throws an error.
     */
    CredentialConfig saveCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException;

    /**
     * Maps a device that is associated with the specified device ID to a {@link CredentialSet} object.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @param credentialSet The credential set to associate with the device.
     * @throws PersistenceException if the data store has issues creating the device to credential set mapping.
     */
    void mapDeviceToCredentialSetMapping(String deviceID, CredentialSet credentialSet) throws PersistenceException;

    /**
     * Retrieves the {@link CredentialSet} object associated with the device that is represented by the specified device ID.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @param returnStaleCredential Flag to determine whether or not a credential set that has been marked as stale should be returned.
     * @return The credential set associated with the device; null if there is no credential set mapped to the device.
     * @throws PersistenceException if the data store has issues retrieving the device to credential set mapping.
     */
    CredentialSet getCredentialSetByDeviceID(String deviceID, boolean returnStaleCredential) throws PersistenceException;

    /**
     * Clears out any mapping of a {@link CredentialSet} object to the device specified by the device ID.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @throws PersistenceException if the data store has issues removing the device to credential set mapping.
     */
    void clearDeviceToCredentialSetMapping(String deviceID) throws PersistenceException;

    /**
     * Clears out all of the mappings of a {@link CredentialSet} object to one or more devices.
     * This can be used to clear out any saved credentials in the event that the {@link CredentialSet} object has been
     * updated or removed.
     * 
     * @param credentialSet The credential set that has been removed or updated.
     * @throws PersistenceException if the data store has issues removing the device to credential set mappings.
     */
    void clearDeviceToCredentialSetMappings(CredentialSet credentialSet) throws PersistenceException;

    /**
     * Deletes the specified {@link CredentialConfig} object.
     * 
     * @param credentialConfig The credential configuration to delete.
     * @throws PersistenceException If there was an error deleting the credential configuration from the data store.
     */
    void deleteCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException;

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

    /**
     * Marks the mapping of a device, that is associated with the specified device ID, to a {@link CredentialSet} object 
     * as being stale/old.
     * 
     * @param deviceID The ID of a device that exists within the ZipTie inventory.
     * @throws PersistenceException if the data store has issues updating the device to credential set mapping as being stale.
     */
    void markDeviceToCredentialSetMappingAsStale(String deviceID) throws PersistenceException;

    /**
     * Marks all of the mappings a device to a {@link CredentialSet} object as being stale/old.
     * 
     * @param credentialSet The previously saved credential set that may be mapped to by one or more devices.
     * @throws PersistenceException if the data store has issues updating the all of the associated device to credential set mappings
     * as being stale.
     */
    void markDeviceToCredentialSetMappingsAsStale(CredentialSet credentialSet) throws PersistenceException;

    /**
     * Removes all {@link CredentialSet} objects that don't have a device directly mapped to them.
     * 
     * @throws PersistenceException if there was an error in data store while purging all of the unmapped credential sets.
     */
    void purgeUnmappedCredentialSets() throws PersistenceException;
}
