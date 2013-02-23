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
 * Used by <code>IPAddress</code> when an address is created that doesn't follow IPv4 standards and/or doesn't match
 * the possible filter strings.
 * 
 * @author rkruse
 */
public class ValueFormatFault extends Exception
{
    private static final long serialVersionUID = 7561834444035136720L;

    /**
     * 
     * @param strMessage
     */
    public ValueFormatFault(String strMessage)
    {
        super(strMessage);
    }

    /**
     * 
     * @param strMessage
     * @param t
     */
    public ValueFormatFault(String strMessage, Throwable t)
    {
        super(strMessage, t);
    }
}
