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

package org.ziptie.scripts.exception;

import java.io.Serializable;

/*
 * Created on Nov 19, 2003
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class UnsupportedFeatureException extends Exception
{
	static final long serialVersionUID = 6273724241312431500L;

    public UnsupportedFeatureException(String msg)
    {
        super(msg);
    }

    public UnsupportedFeatureException(String msg, boolean bLoggingEnabled)
    {
        //super(msg, bLoggingEnabled);
        super(msg);
    }

    public UnsupportedFeatureException(Throwable targetThrowable)
    {
        super(targetThrowable);
    }

    public UnsupportedFeatureException(Throwable targetThrowable, boolean bLoggingEnabled)
    {
        //super(targetThrowable, bLoggingEnabled);
        super(targetThrowable);
    }

    public UnsupportedFeatureException(String msg, Throwable targetThrowable)
    {
        super(msg, targetThrowable);
    }

    public UnsupportedFeatureException(String msg, Throwable targetThrowable, boolean bLoggingEnabled)
    {
        //super(msg, targetThrowable, bLoggingEnabled);
        super(msg, targetThrowable);
    }

    public UnsupportedFeatureException(
        String errorCode,
        String errorMsg,
        Serializable errorData,
        Throwable targetThrowable,
        boolean bLoggingEnabled)
    {
        // super(errorCode, errorMsg, errorData, targetThrowable, bLoggingEnabled);
        super(errorMsg);
    }
}
