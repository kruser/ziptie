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

package org.ziptie.credentials;

/**
 * An exception to describe when a <code>CredentialSet</code> doesn't have the
 * credential name that it is being asked for.
 * 
 * @author rkruse
 */
public class CredentialNotSetException extends Exception
{
    private static final long serialVersionUID = -5960057329335996412L;

    /**
     * 
     * @param errorMessage the error message
     */
    public CredentialNotSetException(String errorMessage)
    {
        super(errorMessage);
    }

    /**
     * 
     * @param t the cause
     */
    public CredentialNotSetException(Throwable t)
    {
        super(t);
    }

    /**
     * 
     * @param errorMessage the error message
     * @param t the cause
     */
    public CredentialNotSetException(String errorMessage, Throwable t)
    {
        super(errorMessage, t);
    }
}
