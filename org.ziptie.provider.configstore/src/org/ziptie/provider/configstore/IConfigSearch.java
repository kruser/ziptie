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
 */
package org.ziptie.provider.configstore;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * IConfigSearch
 */
@WebService(name = "ConfigSearch", targetNamespace = "http://www.ziptie.org/server/configsearch")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IConfigSearch
{
    /**
     * Search all configs for matches against the provided Lucene expression.
     * 
     * @param expression a Lucene search expression
     * @return a list of ConfigSearchResult objects
     */
    @ZInvocationSecurity(perm = "org.ziptie.config.view")
    List<ConfigSearchResult> searchConfig(@WebParam(name = "expression") String expression);
}
