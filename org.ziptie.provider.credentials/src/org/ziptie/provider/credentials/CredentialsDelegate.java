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

import javax.jws.WebService;

import org.ziptie.credentials.CredentialConfig;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.exception.PersistenceException;
import org.ziptie.protocols.ProtocolConfig;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.credentials.internal.CredentialsProviderActivator;
import org.ziptie.security.PermissionDeniedException;
import org.ziptie.server.security.SecurityHandler;

@WebService(endpointInterface = "org.ziptie.provider.credentials.ICredentialsProvider", serviceName = "CredentialsService", portName = "CredentialsPort")
/**
 * The {@link CredentialsDelegate} class implements the {@link ICredentialsProvider} interface in order to act as a delegate to perform the various
 * functionality to be made available in order to create, update, and delete credential and protocol information that is used through-out ZipTie.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public class CredentialsDelegate implements ICredentialsProvider
{
    /** {@inheritDoc} */
    public void deleteCredentialConfig(CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException
    {
        getProvider().deleteCredentialConfig(credentialConfig);
    }

    /** {@inheritDoc} */
    public void deleteProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException, PermissionDeniedException
    {
        getProvider().deleteProtocolConfig(protocolConfig);
    }

    /** {@inheritDoc} */
    public List<CredentialConfig> getAllCredentialConfigs() throws PermissionDeniedException, PersistenceException
    {
        return getProvider().getAllCredentialConfigs();
    }

    /** {@inheritDoc} */
    public List<ProtocolConfig> getAllProtocolConfigs() throws PersistenceException, PermissionDeniedException
    {
        return getProvider().getAllProtocolConfigs();
    }

    /** {@inheritDoc} */
    public List<CredentialSet> getCredentialSetsByIpAddress(String ipAddress) throws PermissionDeniedException, PersistenceException
    {
        return getProvider().getCredentialSetsByIpAddress(ipAddress);
    }

    /** {@inheritDoc} */
    public CredentialConfig getDefaultCredentialConfig() throws PermissionDeniedException, PersistenceException
    {
        return getProvider().getDefaultCredentialConfig();
    }

    /** {@inheritDoc} */
    public ProtocolConfig getDefaultProtocolConfig() throws PermissionDeniedException, PersistenceException
    {
        return getProvider().getDefaultProtocolConfig();
    }

    /** {@inheritDoc} */
    public ProtocolConfig getNewFullProtocolConfig()
    {
        return getProvider().getNewFullProtocolConfig();
    }

    /** {@inheritDoc} */
    public ProtocolConfig getProtocolConfigByIpAddress(String ipAddress) throws PersistenceException
    {
        return getProvider().getProtocolConfigByIpAddress(ipAddress);
    }

    /** {@inheritDoc} */
    public void saveCredentialConfig(CredentialConfig credentialConfig) throws PermissionDeniedException, PersistenceException
    {
        getProvider().saveCredentialConfig(credentialConfig);
    }

    /** {@inheritDoc} */
    public void saveDefaultCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException
    {
        getProvider().saveDefaultCredentialConfig(credentialConfig);
    }

    /** {@inheritDoc} */
    public void saveDefaultProtocolConfig(ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException
    {
        getProvider().saveDefaultProtocolConfig(protocolConfig);
    }

    /** {@inheritDoc} */
    public void saveProtocolConfig(ProtocolConfig protocolConfig) throws PermissionDeniedException, PersistenceException
    {
        getProvider().saveProtocolConfig(protocolConfig);
    }
    

    /** {@inheritDoc} */
    public void updateSingleCredential(String ipAddress, String managedNetwork, String credentialKey, String credentialValue) throws PersistenceException, PermissionDeniedException
    {
        getProvider().updateSingleCredential(ipAddress, managedNetwork, credentialKey, credentialValue);
    }
    
    /** {@inheritDoc} */
    public void purgeUnmappedCredentials() throws PermissionDeniedException
    {
        getProvider().purgeUnmappedCredentials();
    }

    /** {@inheritDoc} */
    public void updateDependentCredential(String ipAddress, String managedNetwork, String credentialKey, String credentialValue, String dependentCredentialKey,
                                          String dependentCredentialValue) throws PersistenceException, PermissionDeniedException
    {
        getProvider().updateDependentCredential(ipAddress, managedNetwork, credentialKey, credentialValue, dependentCredentialKey, dependentCredentialValue);
    }
    
    /** {@inheritDoc} */
    public ProtocolSet getAllEnabledProtocols(String ipAddress, String deviceId) throws PersistenceException
    {
        return getProvider().getAllEnabledProtocols(ipAddress, deviceId);
    }
    
    /**
     * Retrieves the Credential provider.
     * 
     * @return The Credential provider.
     */
    private ICredentialsProvider getProvider()
    {
        ICredentialsProvider provider = CredentialsProviderActivator.getCredentialsProvider();
        if (provider == null)
        {
            throw new RuntimeException(Messages.credentialsServiceNotAvailable);
        }

        return (ICredentialsProvider) SecurityHandler.newProxy(provider);
    }
}
