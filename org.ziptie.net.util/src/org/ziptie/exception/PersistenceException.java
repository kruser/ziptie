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
 * Used when there is a problem saving data to some type of data store, i.e. a
 * database, filesystem, etc.
 * 
 * @author rkruse
 */
public class PersistenceException extends Exception
{
    private static final long serialVersionUID = -7206940976390449448L;

    public PersistenceException(String errorMessage)
    {
        super(errorMessage);
    }

    public PersistenceException(Throwable t)
    {
        super(t);
    }

    public PersistenceException(String errorMessage, Throwable t)
    {
        super(errorMessage, t);
    }
}
