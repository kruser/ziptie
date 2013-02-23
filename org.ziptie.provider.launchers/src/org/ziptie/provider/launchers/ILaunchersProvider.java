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
package org.ziptie.provider.launchers;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * ILauncherProvider
 */
@WebService(name = "Launchers", targetNamespace = "http://www.ziptie.org/server/launchers")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface ILaunchersProvider
{
    /**
     * Get all configured launchers.
     * @return a list of the {@link Launcher} objects
     */
    List<Launcher> getLaunchers();
    
    /**
     * Delete a launcher with the given name
     * @param name the name of the launcher
     */
    @ZInvocationSecurity(perm = "org.ziptie.launchers.administer")
    void deleteLauncher(@WebParam(name = "name") String name); 
    
    /**
     * Add a launcher.  If the launcher already exists under the given name then it is 
     * simply updated
     * @param name the display name - needs to be unique
     * @param url the URL 
     */
    @ZInvocationSecurity(perm = "org.ziptie.launchers.administer")
    void addOrUpdateLauncher(@WebParam(name = "name") String name, @WebParam(name = "url") String url); 
}
