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



package org.ziptie.exception;

/**
 * Thrown when an unexpected error is encountered in the application.
 */
public class ApplicationException extends Exception
{
    static final long serialVersionUID = -2564083004232437365L;

    /**
     * Constructs a new <code>ApplicationException</code> with the specified detail message.
     * 
     * @param message the detail message (which is saved for later retrieval by the {@link #getMessage()} method).
     */
    public ApplicationException(String message)
    {
        super(message);
    }

    /**
     * Constructs a new <code>ApplicationException</code> with the specified cause and a detail
     * message of <tt>(cause==null ? null : cause.toString())</tt> (which
     * typically contains the class and detail message of <tt>cause</tt>).
     *
     * @param cause the cause (which is saved for later retrieval by the {@link #getCause()} method).  
     *              (A <tt>null</tt> value is permitted, and indicates that the cause is nonexistent or unknown.)
     */
	public ApplicationException(Throwable cause)
	{
		super(cause);
	}

    /**
     * Constructs a new <code>ApplicationException</code> with the specified detail message and cause.
     * <p>
     * Note that the detail message associated with <code>cause</code> is <i>not</i> 
     * automatically incorporated in this exception's detail message.
     *
     * @param message the detail message (which is saved for later retrieval by the {@link #getMessage()} method).
     * @param cause the cause (which is saved for later retrieval by the {@link #getCause()} method).  
     *              (A <tt>null</tt> value is permitted, and indicates that the cause is nonexistent or unknown.)
     */
	public ApplicationException(String message, Throwable cause)
	{
		super(message, cause);
	}
}
