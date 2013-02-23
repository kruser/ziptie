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

package org.ziptie.provider.netman;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * This class is used to create Managed Networks.  Every device resides in 
 * one and only one Managed Network (possibly 'N' Managed Networks in the future).
 */
// MULTIPLESTRINGS:OFF
@WebService(name = "Networks", targetNamespace = "http://www.ziptie.org/server/networks")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface INetworksProvider
{
    /**
     * Create a new Managed Network within the system.
     *
     * @param networkName the name to give the new Managed Network.  Must be unique among Managed Networks.
     */
    @ZInvocationSecurity(perm = "org.ziptie.networks.administer")
    void defineManagedNetwork(@WebParam(name = "networkName") String networkName);

    /**
     * Set which Managed Network is considered the default.
     *
     * @param networkName the name of the Managed Network to set as the default
     */
    @ZInvocationSecurity(perm = "org.ziptie.networks.administer")
    void setDefaultManagedNetwork(@WebParam(name = "networkName") String networkName);

    /**
     * Get the Managed Network that has been flagged as the default Managed Network.
     *
     * @return the default Managed Network
     */
    ManagedNetwork getDefaultManagedNetwork();

    /**
     * Get the Managed Network identifed by name.
     *
     * @param networkName the name of the Managed Network to get
     * @return a ManagedNetwork instance
     */
    ManagedNetwork getManagedNetwork(@WebParam(name = "networkName") String networkName);

    /**
     * Get the names of the Managed Networks that have been defined.
     *
     * @return a possibly empty array of unique Strings identifying the managed networks that have
     *    been defined within the system
     */
    List<String> getManagedNetworkNames();

    /**
     * Delete a Managed Network identified by the name.
     *
     * @param networkName the name of the Managed Network to delete
     */
    @ZInvocationSecurity(perm = "org.ziptie.networks.administer")
    void deleteManagedNetwork(@WebParam(name = "networkName") String networkName);

    /**
     * Update a Managed Network's information using the contents of the supplied ManagedNetwork
     * instance.  This instance must encapsulate information about a Managed Network that actually
     * exists, otherwise an exception is thrown.
     *
     * @param managedNetwork a ManagedNetwork instance to use to update a Managed Network definition
     */
    @ZInvocationSecurity(perm = "org.ziptie.networks.administer")
    void updateManagedNetwork(@WebParam(name = "managedNetwork") ManagedNetwork managedNetwork);
}
