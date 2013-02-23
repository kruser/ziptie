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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim.http;

import simple.http.Request;
import simple.http.Response;
import simple.http.load.BasicService;
import simple.http.serve.Context;

/**
 * TODO lbayer: Add class description here
 */
public class HttpSimService extends BasicService
{
    /**
     * @param arg0
     */
    public HttpSimService(Context arg0)
    {
        super(arg0);
    }

    /* (non-Javadoc)
     * @see simple.http.serve.BasicResource#process(simple.http.Request, simple.http.Response)
     */
    protected void process(Request arg0, Response arg1) throws Exception
    {
        // TODO lbayer: Auto-generated method stub
    }
}
