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

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.credentials.CredentialConfig;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.exception.PersistenceException;
import org.ziptie.protocols.ProtocolConfig;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.security.PermissionDeniedException;
import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * The {@link ICredentialsProvider} class specifies an interface describing the various functionality to be made
 * available in order to create, update, and delete credential and protocol information that is used through-out ZipTie.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
// MULTIPLESTRINGS:OFF
@WebService(name = "Credentials", targetNamespace = "http://www.ziptie.org/server/credentials")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface ICredentialsProvider
{
    /**
     * Retrieves a {@link List} of all {@link CredentialConfig} objects.  This does not include the {@link CredentialConfig} object that
     * has been marked as the default.  To retrieve the default {@link CredentialConfig} object, refer to the
     * {@link #getDefaultCredentialConfig()} method.
     * 
     * @return A {@link List} of the credential configurations.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public List<CredentialConfig> getAllCredentialConfigs() throws PermissionDeniedException, PersistenceException;

    /**
     * Retrieves the {@link CredentialConfig} that is set as the default; returns a new {@link CredentialConfig} if a default is not yet set.
     * The default credential configuration is the last one checked if there is no device specific credential configuration or any credential
     * configuration that is mapped to the device that is trying to determine which credential configuration to use.
     * 
     * @return The default credential configuration.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public CredentialConfig getDefaultCredentialConfig() throws PermissionDeniedException, PersistenceException;

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
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void saveCredentialConfig(@WebParam(name = "credentialConfig")
    CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException;

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
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void saveDefaultCredentialConfig(@WebParam(name = "credentialConfig")
    CredentialConfig credentialConfig) throws PersistenceException;

    /**
     * Deletes the specified {@link CredentialConfig} object.  Beyond deleting the credential configuration, all the mappings of devices to
     * credential sets and credentials stored within the specified credential configuration will be deleted as well.
     * 
     * @param credentialConfig The credential configuration to delete.
     * @throws PermissionDeniedException If the user doesn't have permission to delete the credential configuration.
     * @throws PersistenceException If there was an error deleting the credential configuration from the data store.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void deleteCredentialConfig(@WebParam(name = "credentialConfig")
    CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException;

    /**
     * Returns an ordered {@link List} of {@link CredentialSet} objects that are associated with a specified IP address.
     * The list may only have a size of 1 if there has been a previously reporting working set of credentials.
     * 
     * @param ipAddress The IP address to check for.
     * @return The matching {@link CredentialSet} objects.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public List<CredentialSet> getCredentialSetsByIpAddress(@WebParam(name = "ipAddress")
    String ipAddress) throws PermissionDeniedException, PersistenceException;

    /**
     * Retrieves a {@link List} of all {@link ProtocolConfig} objects.  This does not include the {@link ProtocolConfig} object that
     * has been marked as the default.  To retrieve the default {@link ProtocolConfig} object, refer to the
     * {@link #getDefaultProtocolConfig()} method.
     * 
     * @return A {@link List} of the protocol configurations.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public List<ProtocolConfig> getAllProtocolConfigs() throws PersistenceException, PermissionDeniedException;

    /**
     * Returns a new {@link ProtocolConfig} object with all its protocols enabled but in the default order
     * of preference. This can be useful for a UI to create a screen of all the protocol sets.
     * 
     * @return A new protocol configuration in its default state.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public ProtocolConfig getNewFullProtocolConfig();

    /**
     * Retrieves the {@link ProtocolConfig} that is set as the default; returns a new {@link ProtocolConfig} if a default is not yet set.
     * The default protocol configuration is the last one checked if there is no device specific protocol configuration or any protocol
     * configuration that is mapped to the device that is trying to determine which protocol configuration to use.
     * 
     * @return The default protocol configuration.
     * @throws PermissionDeniedException if the user doesn't have permission.
     * @throws PersistenceException if the data store throws an error.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public ProtocolConfig getDefaultProtocolConfig() throws PermissionDeniedException, PersistenceException;

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
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void saveProtocolConfig(@WebParam(name = "protocolConfig")
    ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException;

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
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void saveDefaultProtocolConfig(@WebParam(name = "protocolConfig")
    ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException;

    /**
     * Deletes the specified {@link ProtocolConfig} object.  Beyond deleting the protocol configuration, all the mappings of devices to
     * protocol sets and protocols stored within the specified protocol configuration will be deleted as well.
     * 
     * @param protocolConfig The protocol configuration to delete.
     * @throws PermissionDeniedException If the user doesn't have permission to delete the protocol configuration.
     * @throws PersistenceException If there was an error deleting the protocol configuration from the data store.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void deleteProtocolConfig(@WebParam(name = "protocolConfig")
    ProtocolConfig protocolConfig) throws PersistenceException, PermissionDeniedException;

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
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public ProtocolConfig getProtocolConfigByIpAddress(@WebParam(name = "ipAddress")
    String ipAddress) throws PersistenceException;
    
    /**
     * Intelligently updates your already existing credential definitions with a new value.  If there already exists a matching
     * credential then this method has no effect.
     * 
     * This method will not change the <code>AddressSet</code> objects defined within <code>CredentialSet</code> objects.  Instead
     * it will just update the behind-the-scenes stickiness of a credential to a device.
     * 
     * @param ipAddress the IP address of the device
     * @param managedNetwork the name of the managed network that the device lives in
     * @param credentialKey the key name of the credential to be updated.  e.g. 'enablePassword'
     * @param credentialValue the new value of the credential to be updated.
     * @throws PersistenceException
     * @throws PermissionDeniedException
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void updateSingleCredential(@WebParam(name = "ipAddress") String ipAddress, @WebParam(name = "managedNetwork") String managedNetwork, @WebParam(name = "credentialKey") String credentialKey, @WebParam(name = "credentialValue") String credentialValue) throws PersistenceException, PermissionDeniedException;
    
    /**
     * Similar to the {@link #updateSingleCredential(String, String, String, String)} method except that it will
     * only update this credential if the credential set being used by the device also contains the dependent credential.
     * 
     * This method is useful for changing passwords but only updating the server credentials if a particular username is
     * being used with that password.
     * 
     * @param ipAddress the IP address of the device
     * @param managedNetwork the name of the managed network that the device lives in
     * @param credentialKey the key name of the credential to be updated.  e.g. 'password'
     * @param credentialValue the new value of the credential to be updated.
     * @param dependentCredentialKey the key name of the other credential to check first.  e.g. 'username'
     * @param dependentCredentialValue the value that the dependent credential must have before considering changing the other credential value
     * @throws PersistenceException
     * @throws PermissionDeniedException
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void updateDependentCredential(@WebParam(name = "ipAddress") String ipAddress, @WebParam(name = "managedNetwork") String managedNetwork, @WebParam(name = "credentialKey") String credentialKey, @WebParam(name = "credentialValue") String credentialValue, @WebParam(name = "dependentCredentialKey") String dependentCredentialKey, @WebParam(name = "dependentCredentialValue") String dependentCredentialValue ) throws PersistenceException, PermissionDeniedException;
    
    /**
     * Deletes all <code>CredentialSet</code> objects that aren't being used by a device.
     * 
     * @throws PermissionDeniedException if the user doesn't have permission to perform this action.
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public void purgeUnmappedCredentials() throws PermissionDeniedException;
    
    /**
     * Returns all enabled Protocols for the given ipAddress.
     * @param ipAddress the ipAddress of a the device
     * @param deviceId if set, then the returned protocols will include hints for if each protocol was validated on the device during the default operation (backup).  Can be null.
     * @return a ProtocolSet
     * @throws PersistenceException if there are issues retrieving the data
     */
    @ZInvocationSecurity(perm = "org.ziptie.credentials.administer")
    public ProtocolSet getAllEnabledProtocols(String ipAddress, String deviceId) throws PersistenceException;
}
