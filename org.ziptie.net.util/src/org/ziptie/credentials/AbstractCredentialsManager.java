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

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.IPAddress;
import org.ziptie.exception.PersistenceException;
import org.ziptie.security.ISecurityCheck;
import org.ziptie.security.PermissionDeniedException;

/**
 * The {@link AbstractCredentialsManager} class provides various functionality for handling credentials.  This includes the retrieval, persistence,
 * and deletion of credential related objects, associating credentials with devices, and maintaining the priorities of
 * credential objects in relation to each other.
 * 
 * @author rkruse
 * @author Dylan White (dylamite@ziptie.org)
 */
public abstract class AbstractCredentialsManager
{
    private static final int DEFAULT_MAX_CREDENTIALS = 3;
    private static final String MAX_CREDS = "MAX_CREDS";
    private static Object saveMutex = new Object();

    private ICredentialsPersister persister;
    private ISecurityCheck securityCheck;

    /**
     * Retrieves the implementation of the {@link ICredentialsPersister} interface that will be used to persists credential related objects.
     * 
     * @return The implementation of the {@link ICredentialsPersister} interface being used.
     */
    public ICredentialsPersister getPersister()
    {
        return persister;
    }

    /**
     * Sets the implementation of the {@link ICredentialsPersister} interface that will be used to persists credential related objects.
     * 
     * @param persister The implementation of the {@link ICredentialsPersister} interface that to be used.
     */
    public void setPersister(ICredentialsPersister persister)
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
     * @throws PersistenceException If there was an error setting the specified {@link CredentialConfig} object
     * as the default credential configuration within the data store.
     */
    public void saveDefaultCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException
    {
        CredentialConfig originalDefault = persister.getDefaultCredentialConfig();
        if (originalDefault != null && (originalDefault.getId() != credentialConfig.getId()))
        {
            for (CredentialSet cs : originalDefault.getCredentialSets())
            {
                persister.clearDeviceToCredentialSetMappings(cs);
            }
        }
        else
        {
            markCredentialsStale(credentialConfig);
        }
        persister.saveDefaultCredentialConfig(credentialConfig);
    }

    /**
     * Deletes the specified {@link CredentialConfig} object.  Beyond deleting the credential configuration, all the mappings of devices to
     * credential sets and credentials stored within the specified credential configuration will be deleted as well.
     * 
     * @param credentialConfig The credential configuration to delete.
     * @throws PermissionDeniedException If the user doesn't have permission to delete the credential configuration.
     * @throws PersistenceException If there was an error deleting the credential configuration from the data store.
     */
    public void deleteCredentialConfig(CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkWritePrivileges();
        for (CredentialSet cs : credentialConfig.getCredentialSets())
        {
            persister.clearDeviceToCredentialSetMappings(cs);
        }
        persister.deleteCredentialConfig(credentialConfig);
    }

    /**
     * Returns an ordered {@link List} of {@link CredentialSet} objects that are associated with a specified IP address.
     * The list may only have a size of 1 if there has been a previously reporting working set of credentials.
     * 
     * @param ipAddress The IP address to check for.
     * @return The matching {@link CredentialSet} objects.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public List<CredentialSet> getCredentialSetsByIpAddress(IPAddress ipAddress) throws PermissionDeniedException, PersistenceException
    {
        // Get the maximum number of credential sets to try
        int maxSize = getMaxCredentialTries();

        // Create an empty list to store all of the credential sets that match
        List<CredentialSet> matchingCredentialSets = new ArrayList<CredentialSet>();

        // Add all of the credential sets that match the specified IP address to the list of matching credential sets
        addAllCredentialSetsByAddress(ipAddress, matchingCredentialSets, maxSize);
        addAllDefaultCredentialSets(matchingCredentialSets, maxSize);

        return matchingCredentialSets;
    }

    /**
     * Retrieves a {@link List} of all {@link CredentialConfig} objects.  This does not include the {@link CredentialConfig} object that
     * has been marked as the default.  To retrieve the default {@link CredentialConfig} object, refer to the
     * {@link #getDefaultCredentialConfig()} method.
     * 
     * @return A {@link List} of the credential configurations.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public List<CredentialConfig> getAllCredentialConfigs() throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkReadPrivileges();
        return new LinkedList<CredentialConfig>(persister.getAllCredentialConfigs());
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
        return getPersister().getCredentialSetByDeviceID(deviceID, returnStaleCredentials);
    }

    /**
     * Retrieves the {@link CredentialConfig} that is set as the default; returns a new {@link CredentialConfig} if a default is not yet set.
     * The default credential configuration is the last one checked if there is no device specific credential configuration or any credential
     * configuration that is mapped to the device that is trying to determine which credential configuration to use.
     * 
     * @return The default credential configuration.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public CredentialConfig getDefaultCredentialConfig() throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkReadPrivileges();
        return persister.getDefaultCredentialConfig();
    }

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
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    public void saveCredentialConfig(CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkWritePrivileges();
        if (credentialConfig.getId() >= 0)
        {
            markCredentialsStale(credentialConfig);
        }
        else
        {
            markDefaultGroupStale();
        }

        persister.saveCredentialConfig(credentialConfig);
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
        getPersister().clearDeviceToCredentialSetMapping(deviceID);
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
    public abstract void mapDeviceToCredentialSet(String deviceID, CredentialSet credentialSet) throws PermissionDeniedException, PersistenceException;

    /**
     * Marks the device-to-credential set mapping associated with the specified device ID as stale.
     * The process (usually the backing up of a device) that is used to determine the proper working credentials should call
     * {@link #getCredentialSets(IPAddress, boolean)} with true for retrieving only non-stale credentials.
     * 
     * @param deviceID The ID of the device to create a mapping for.
     * @throws PersistenceException if an error occurred within the data store when persisting the device-to-credential set mapping.
     */
    public void markDeviceToCredentialSetMappingAsStale(String deviceID) throws PersistenceException
    {
        getPersister().markDeviceToCredentialSetMappingAsStale(deviceID);
    }

    /**
     * Retrieves the maximum number for how many {@link CredentialSet} objects can be mapped to a device.  This allows for only trying
     * a certain number of logins before giving up.
     * 
     * @return The maximum number of credential tries allowed.
     */
    public int getMaxCredentialTries()
    {
        String value = persister.getProperty(MAX_CREDS);
        if (value != null)
        {
            return Integer.parseInt(value);
        }
        return DEFAULT_MAX_CREDENTIALS;
    }

    /**
     * Sets the maximum number for how many {@link CredentialSet} objects can be mapped to a device.  This allows for only trying
     * a certain number of logins before giving up.
     * @param maxCredentialTries The maximum number of credential tries to be allowed.
     * @throws PersistenceException if the data store had an error occur while persisting the property.
     */
    public void setMaxCredentialTries(int maxCredentialTries) throws PersistenceException
    {
        persister.saveProperty(MAX_CREDS, Integer.toString(maxCredentialTries));
    }

    /**
     * Removes all {@link CredentialSet} objects that don't have a device directly mapped to them.
     * 
     * @throws PersistenceException if there was an error in data store while purging all of the unmapped credential sets.
     * @throws PermissionDeniedException if the user does not have permission to purge unmapped credentials.
     */
    public void purgeUnmappedCredentials() throws PersistenceException, PermissionDeniedException
    {
        synchronized (saveMutex)
        {
            securityCheck.checkWritePrivileges();
            persister.purgeUnmappedCredentialSets();
        }
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
    public abstract List<CredentialSet> calculateCredentialSets(String deviceID, boolean returnStaleCredentials) throws PersistenceException,
            PermissionDeniedException;

    /**
     * Marks all of the credentials sets associated with the default credential configuration as stale.
     * 
     * @throws PersistenceException if an error occurred in the data store.
     * @throws PermissionDeniedException if the user is not allowed to retrieve the default credential configuration.
     */
    private void markDefaultGroupStale() throws PersistenceException, PermissionDeniedException
    {
        for (CredentialSet credSet : getDefaultCredentialConfig().getCredentialSets())
        {
            persister.markDeviceToCredentialSetMappingsAsStale(credSet);
        }
    }

    /**
     * Marks all of the credentials sets associated with the specified credential configuration as stale.
     * 
     * @param credentialConfig The credential configuration to parse and mark as stale.
     * @throws PersistenceException if an error occured in the data store.
     */
    private void markCredentialsStale(CredentialConfig credentialConfig) throws PersistenceException
    {
        for (CredentialSet credSet : credentialConfig.getCredentialSets())
        {
            persister.markDeviceToCredentialSetMappingsAsStale(credSet);
        }
    }

    /**
     * Traverses the default {@link CredentialConfig} object and adds each of its {@link CredentialSet} objects to the specified
     * {@link List} of credential sets.  The number of credential sets that are added to this list can not be greater than the specified
     * maximum size. 
     * 
     * @param matchingCredentialSets The {@link List} to store any found credential set within.
     * @param maxSize The maximum number of credential sets allowed to be stored within the list of credential sets.
     * @throws PersistenceException if an error occurred within the data store when retrieving the default credential configuration.
     */
    private void addAllDefaultCredentialSets(List<CredentialSet> matchingCredentialSets, int maxSize) throws PersistenceException
    {
        // Assuming the the matching credential sets list does not already contain the maximum number of credential sets,
        // traverse the default credential config and add each of its credential sets to our list until we are either done
        // or have reached the maximum limit.
        if (matchingCredentialSets.size() < maxSize)
        {
            CredentialConfig defaultCC = persister.getDefaultCredentialConfig();
            for (CredentialSet cSet : defaultCC.getCredentialSets())
            {
                if (matchingCredentialSets.size() < maxSize)
                {
                    matchingCredentialSets.add(cSet);
                }
            }
        }
    }

    /**
     * Traverses every single {@link CredentialConfig} object and checks to see if {@link AddressSet} object associated with it contains the
     * specified IP address.  If so, each of the {@link CredentialSet} objects associated with the credential configuration is added to the specified
     * {@link List} of credential sets.  The number of credential sets that are added to this list can not be greater than the specified
     * maximum size. 
     * 
     * @param ipAddress The IP address that must be supported by the address set of a credential configuration.
     * @param matchingCredentialSets The {@link List} to store any found credential set within.
     * @param maxSize The maximum number of credential sets allowed to be stored within the list of credential sets.
     * @throws PersistenceException if an error occurred within the data store when retrieving the default credential configuration.
     * @throws PermissionDeniedException if the user is not allowed to retrieve all of the credential configurations.
     */
    private void addAllCredentialSetsByAddress(IPAddress ipAddress, List<CredentialSet> matchingCredentialSets, int maxSize) throws PersistenceException,
            PermissionDeniedException
    {
        if (matchingCredentialSets.size() < maxSize)
        {
            List<CredentialConfig> all = getAllCredentialConfigs();
            for (CredentialConfig currConfig : all)
            {
                if (matchingCredentialSets.size() < maxSize)
                {
                    AddressSet addressSet = currConfig.getAddressSet();
                    if (addressSet.contains(ipAddress))
                    {
                        for (CredentialSet cSet : currConfig.getCredentialSets())
                        {
                            matchingCredentialSets.add(cSet);
                        }
                    }
                }
            }
        }
    }

    /**
     * Updates a single credential and purges any unused credentials
     * @param ipAddress the IP of the device to update
     * @param managedNetwork the managed network that the device lives in 
     * @param credentialKey the name of the credential, e.g. 'enablePassword'
     * @param credentialValue the value of the credential
     * @throws PersistenceException if an error occurred within the data store when retrieving the default credential configuration.
     * @throws PermissionDeniedException if the user is not allowed to retrieve all of the credential configurations.
     */
    public abstract void updateSingleCredential(String ipAddress, String managedNetwork, String credentialKey, String credentialValue)
        throws PersistenceException, PermissionDeniedException;

    /**
     * Updates a single credential, but only if it finds the dependent credential value in the device's credential set.
     * Use this method to update a password for a given username. 
     * 
     * @param ipAddress the IP of the device to update
     * @param managedNetwork the managed network that the device lives in 
     * @param credentialKey the name of the credential, e.g. 'enablePassword'
     * @param credentialValue the value of the credential
     * @param dependentCredentialKey the name of the cred to check first. e.g. 'username'
     * @param dependentCredentialValue the value of the cred to check first.
     * @throws PersistenceException if an error occurred within the data store when retrieving the default credential configuration.
     * @throws PermissionDeniedException if the user is not allowed to retrieve all of the credential configurations.
     */
    public abstract void updateDependentCredential(String ipAddress, String managedNetwork, String credentialKey, String credentialValue,
                                                   String dependentCredentialKey, String dependentCredentialValue) throws PersistenceException,
            PermissionDeniedException;

}
