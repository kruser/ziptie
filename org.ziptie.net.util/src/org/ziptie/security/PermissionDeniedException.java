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



package org.ziptie.security;

/**
 * An <code>PermissionDeniedException</code> should be thrown when an attempt is made to access a resource for which
 * the the caller does not have the proper permissions.
 * <p>
 * <p>
 * 
 * @author rkruse
 */
public class PermissionDeniedException extends Exception
{
    private static final long serialVersionUID = -2276625246236734375L;

    /**
     * Constructs an <code>PermissionDeniedException</code> with a specified message.
     * 
     * @param message - The message to attach to the constructed <code>PermissionDeniedException</code>.
     */
    public PermissionDeniedException(String message)
    {
        super(message);
    }

    /**
     * Constructs an <code>PermissionDeniedException</code> with a specified message and a <code>Throwable</code>
     * cause.
     * 
     * @param message - The message to attach to the constructed <code>PermissionDeniedException</code>.
     * @param cause - The <code>Throwable</code> cause of the constructed <code>PermissionDeniedException</code>.
     */
    public PermissionDeniedException(String message, Throwable cause)
    {
        super(message, cause);
    }

    /**
     * Constructs an <code>PermissionDeniedException</code> from a <code>Throwable</code> cause.
     * 
     * @param cause - The <code>Throwable</code> cause of the constructed <code>PermissionDeniedException</code>.
     */
    public PermissionDeniedException(Throwable cause)
    {
        super(cause);
    }
}
