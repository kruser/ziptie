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
 * Portions created by AlterPoint are Copyright (C) 2008,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.perl;

/**
 * Represents errors from the perl server.
 */
public class PerlException extends Exception
{
    private static final long serialVersionUID = -6669589410445831013L;

    /**
     * Create the exception with a message and a cause
     * @param message the detail message
     * @param cause The caused by exception.
     */
    public PerlException(String message, Throwable cause)
    {
        super(message, cause);
    }

    /**
     * Create the exception with a message.
     * @param message the detail message.
     */
    public PerlException(String message)
    {
        super(message);
    }
}
