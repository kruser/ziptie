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
package org.ziptie.crates;

/**
 * Thrown from errors with a crate location.
 */
public class CrateException extends Exception
{
    private static final long serialVersionUID = -837194662510692595L;

    /**
     * Create the exception
     * @param message the message
     * @param cause the cause
     */
    public CrateException(String message, Throwable cause)
    {
        super(message, cause);
    }

    /**
     * Create the exception
     * @param message the message
     */
    public CrateException(String message)
    {
        super(message);
    }
}
