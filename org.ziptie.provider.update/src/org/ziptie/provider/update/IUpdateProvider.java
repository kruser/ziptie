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
 * Contributor(s):
 */
package org.ziptie.provider.update;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

/**
 * Provides update functions for a server.
 */
@WebService(name = "Update", targetNamespace = "http://www.ziptie.org/server/update")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IUpdateProvider
{
    /**
     * Gets an XML summary of the install.
     * @return The XML.
     */
    String getSummaryXml();

    /**
     * Requests the server to download a crate.
     * @param crateId The crate ID
     * @param version The crate version.
     * @param forgeHost The forge server host.  Defaults to "forge.ziptie.org".
     * @return <code>true</code> if the download was successful, <code>false</code> otherwise.
     */
    boolean download(@WebParam(name = "crateId") String crateId,
                  @WebParam(name = "version") String version,
                  @WebParam(name = "forgeHost") String forgeHost);
}
