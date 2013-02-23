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
 * Contributor(s): Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.net.adapters;

/**
 * The <code>AdapterServiceException</code> class provides a container for an exception that might occur during
 * the use of the <code>AdapterService</code> class.  It is to be thrown inside classes that are used by the 
 * <code>AdapterService</code> class.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public class AdapterServiceException extends Exception
{
    /**
     * Serial version UID for possible serialization purposes.
     */
    private static final long serialVersionUID = -1953070328344873663L;

    /**
     * Constructs a new <code>AdapterServiceException</code> with the specified message.
     * 
     * @param errorMessage The message saved for later retrieval with getMessage().
     */
    public AdapterServiceException(String errorMessage)
    {
        super(errorMessage);
    }

    /**
     * Constructs a new <code>AdapterServiceException</code> with the specified <code>Throwable</code> object
     * as the cause.
     * 
     * @param cause The <code>Throwable</code> object that is the cause of this <code>AdapterServiceException</code>.
     */
    public AdapterServiceException(Throwable cause)
    {
        super(cause);
    }

    /**
     * Constructs a new <code>AdapterServiceException</code> with the specified detailed error message and a 
     * <code>Throwable</code> object as the cause.
     * 
     * @param errorMessage The message saved for later retrieval with getMessage().
     * @param cause The <code>Throwable</code> object that is the cause of this <code>AdapterServiceException</code>.
     */
    public AdapterServiceException(String errorMessage, Throwable cause)
    {
        super(errorMessage, cause);
    }
}
