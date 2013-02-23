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
package org.ziptie.adapters.ws;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

/**
 * The {@link INilSettingsProvider} defines an interface for providing the ability to modify the settings for the
 * Network Interface Layer (NIL).
 * 
 * @author Leo Bayer (lbayer@ziptie.org)
 * @author Dylan White (dylamite@ziptie.org)
 */
@WebService(name = "NilSettings", targetNamespace = "http://www.ziptie.org/server/nilsettings")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface INilSettingsProvider
{
    /**
     * Enables or disables the recording of adapter operations.
     * 
     * @param enable <code>true</code> to enable, <code>false</code> to disable
     */
    void enableRecordingAdapterOperations(@WebParam(name = "enable")
    boolean enable);

    /**
     * Determines whether or not recording of adapter operations is enabled.
     * 
     * @return <code>true</code> if enabled, <code>false</code> if disabled.
     */
    boolean isRecordingAdapterOperationsEnabled();

    /**
     * Sets the level of logging for adapter operations.
     * <p>
     * Any logging level less than or equal to zero (0) means that both <code>DEBUG</code> and <code>FATAL</code> messages will be logged.
     * <p>
     * Any logging level greater than 0 will disable <code>DEBUG</code> logging so that only <code>FATAL</code> messages are logged.
     * 
     * @param level the log level.
     */
    void setAdapterLoggingLevel(@WebParam(name = "level")
    int level);

    /**
     * Retrieves the logging level for adapter operations.
     * 
     * @return The logging level for adapter operations.
     */
    int getAdapterLoggingLevel();

    /**
     * Enables or disables logging adapter operations to a file.
     * 
     * @param enable <code>true</code> to enable, <code>false</code> to disable.
     */
    void enableLoggingAdapterOperationsToFile(@WebParam(name = "enable")
    boolean enable);

    /**
     * Determines whether or not logging of adapter operations to a file is enabled.
     * 
     * @return <code>true</code> if enabled, <code>false</code> if disabled.
     */
    boolean isLoggingAdapterOperationsToFileEnabled();

    /**
     * Retrieves the settings for the file server associated with the specified protocol.  If there is
     * no file server associated with the specified protocol, then <code>null</code> is returned.
     * 
     * @param protocolName The name of the protocol that the file server uses.  For example: "tftp" or "ftp".
     * The value of the protocol name is case-insensitive.
     * @return The {@link FileServerInfo} object containing all of the information about the file server.
     */
    FileServerInfo getFileServerInfo(@WebParam(name = "protocolName")
    String protocolName);

    /**
     * Retrieves the settings for the file server associated with the specified protocol.  If there is
     * no file server associated with the specified protocol, then <code>null</code> is returned.
     * 
     * @param protocolName The name of the protocol that the file server uses.  For example: "tftp" or "ftp".
     * The value of the protocol name is case-insensitive.
     * @param useIPv6 Determines whether or not an IPv4 or IPv6 address should be resolved for the file server in question.
     * @return The {@link FileServerInfo} object containing all of the information about the file server.
     */
    FileServerInfo getFileServerInfoForIPv6(@WebParam(name = "protocolName")
    String protocolName, @WebParam(name = "useIPv6")
    boolean useIPv6);
}
