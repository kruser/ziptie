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
package org.ziptie.server.job;

import org.ziptie.protocols.ProtocolNames;

/**
 */
public class AdapterException extends Exception
{
    private static final long serialVersionUID = -6535167191439611714L;

    private ErrorCode errorCode;

    /**
     * Create the exception.
     * @param errorCode The error code.
     * @param message The detailed message.
     */
    public AdapterException(ErrorCode errorCode, String message)
    {
        super(message);
        this.errorCode = errorCode;
    }

    /**
     * Get the error code for the exception.
     * @return The error code.
     */
    public ErrorCode getErrorCode()
    {
        return errorCode;
    }

    /**
     * The error code.
     */
    public enum ErrorCode
    {
        UNEXPECTED_RESPONSE,
        INVALID_CREDENTIALS,
        SSH_ERROR(ProtocolNames.SSH),
        TELNET_ERROR(ProtocolNames.Telnet),
        SNMP_ERROR(ProtocolNames.SNMP),
        FTP_ERROR(ProtocolNames.FTP),
        HTTP_ERROR(ProtocolNames.HTTP),
        SCP_ERROR(ProtocolNames.SCP),
        TFTP_ERROR(ProtocolNames.TFTP),
        TOO_MANY_USERS,
        PASSWORD_REQUIRED_BUT_NOT_SET,
        DEVICE_MEMORY_ERROR,
        NVRAM_CORRUPTION_ERROR,
        INSUFFICIENT_PRIVILEGE,
        PERL_ERROR,
        FAILURE;

        private boolean isProtocolError;
        private ProtocolNames protocol;

        private ErrorCode()
        {
        }

        private ErrorCode(ProtocolNames protocol)
        {
            this.protocol = protocol;
            isProtocolError = protocol != null;
        }

        /**
         * Gets whether this error code is for a protocol failure.
         * @return <code>true</code> if the code represents a protocol failure.
         */
        public boolean isProtocolError()
        {
            return isProtocolError;
        }

        /**
         * Gets the applicable protocol for this error.
         * @return The protocol this error is for, or <code>null</code>
         */
        public ProtocolNames getProtocol()
        {
            return protocol;
        }
    }
}
