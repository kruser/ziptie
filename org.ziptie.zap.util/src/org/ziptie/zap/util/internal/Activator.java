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

package org.ziptie.zap.util.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

/**
 * Track the bundle context, for use by the ServiceLookupElf.
 * 
 * @author egrossenbacher
 */
public class Activator implements BundleActivator
{
    private static BundleContext context;

    /**{@inheritDoc}*/
    public void start(BundleContext bc) throws Exception
    {
        Activator.context = bc;
    }

    /**{@inheritDoc}*/
    public void stop(BundleContext bc) throws Exception
    {
        Activator.context = null;
    }

    /**
     * @return get the BundleContext for this bundle
     */
    public static BundleContext getBundleContext()
    {
        return context;
    }
}
