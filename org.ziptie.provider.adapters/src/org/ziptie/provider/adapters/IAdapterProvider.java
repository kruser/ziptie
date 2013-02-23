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

package org.ziptie.provider.adapters;

import java.util.List;

import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.credentials.CredentialKey;

/**
 * IAdapterProvider
 */
@WebService(name = "Adapters", targetNamespace = "http://www.ziptie.org/server/adapters")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IAdapterProvider
{
    /**
     * Gets the set of adapters currently installed in the system.
     * @return The available adapters.
     */
    List<AdapterLite> getAvailableAdapters();

    /**
     * Get the available credential keys.
     * @return A list of credential keys.
     */
    List<CredentialKey> getCredentialKeys();
}
