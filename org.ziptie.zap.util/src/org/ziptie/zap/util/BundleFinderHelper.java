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


package org.ziptie.zap.util;

import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.service.packageadmin.PackageAdmin;
import org.osgi.util.tracker.ServiceTracker;


/**
 * A simple helper class for looking up Bundles by their symbolic names.
 * 
 * @author egrossenbacher
 */
public class BundleFinderHelper
{
    private ServiceTracker packageAdminTracker;

    /**
     * Create a new BundleFinderElf that begins tracking the package admin.
     * Use 'close' to shut this thing down.
     * 
     * @param context a BundleContext for use in tracking the package admin.
     */
    public BundleFinderHelper(BundleContext context)
    {
        packageAdminTracker = new ServiceTracker(context, PackageAdmin.class.getName(), null);
        packageAdminTracker.open();
    }

    /**
     * Close this object, releasing any resources.
     */
    public void close()
    {
        packageAdminTracker.close();
        packageAdminTracker = null;
    }

    /**
     * Returns the resolved bundle with the specified symbolic name that has the
     * highest version.  If no resolved bundles are installed that have the 
     * specified symbolic name then null is returned.
     * <p>
     * @param symbolicName the symbolic name of the bundle to be returned.
     * @return the bundle that has the specified symbolic name with the 
     * highest version, or <tt>null</tt> if no bundle is found.
     */
    public Bundle findBySymbolicName(String symbolicName)
    {
        PackageAdmin packageAdmin = (PackageAdmin) packageAdminTracker.getService();
        if (packageAdmin == null)
        {
            return null;
        }

        Bundle[] bundles = packageAdmin.getBundles(symbolicName, null);
        if (bundles == null)
        {
            return null;
        }

        //Return the first bundle that is not installed or uninstalled
        for (int i = 0; i < bundles.length; i++)
        {
            if ((bundles[i].getState() & (Bundle.INSTALLED | Bundle.UNINSTALLED)) == 0)
            {
                return bundles[i];
            }
        }
        return null;
    }

}
