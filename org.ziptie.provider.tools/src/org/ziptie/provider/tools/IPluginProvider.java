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
package org.ziptie.provider.tools;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * Interface for command list execution results.
 */
@WebService(name = "Plugins", targetNamespace = "http://www.ziptie.org/server/plugins")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IPluginProvider
{
    /**
     * Get a list of all available plugins.  The return value is a list of
     * <code>PluginDescriptor</code> objects which encapsulate the
     * text of the properties definitions.
     *
     * @return a list of <code>PluginDescriptor</code> objects
     */
    List<PluginDescriptor> getPluginDescriptors();

    /**
     * @param executionId The ID of the command list job execution.
     * @return the PluginExecRecord for the specified execution
     */
    @ZInvocationSecurity(perm = "org.ziptie.job.plugin.runPermission")
    PluginExecRecord getExecutionRecord(@WebParam(name = "executionId") int executionId);

    /**
     * Gets the details for the given execution.
     *
     * @param executionId The ID of the command list job execution.
     * @return The command/response details.
     */
    @ZInvocationSecurity(perm = "org.ziptie.job.plugin.runPermission")
    List<ToolRunDetails> getExecutionDetails(@WebParam(name = "executionId") int executionId);

    /**
     * Get the children of the directory for the relative tools file store path.
     *
     * @param path a relative path in the file store
     * @return a list of files and sub-directories, with sub-directories ending in "/"
     */
    @ZInvocationSecurity(perm = "org.ziptie.job.plugin.runPermission")
    List<String> getFileStoreEntries(@WebParam(name = "path") String path);
}
