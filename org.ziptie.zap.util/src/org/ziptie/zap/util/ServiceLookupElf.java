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

import org.osgi.framework.BundleContext;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;
import org.ziptie.zap.util.internal.Activator;

/**
 * A Helper class for easily looking up a service.  This is intended to
 * potentially supplant the use of per-Bundle Activators that collect
 * dependent services with service trackers.
 * 
 * @author egrossenbacher
 */
public final class ServiceLookupElf
{
    private ServiceLookupElf()
    {
        // never make one of these
    }

    /**
     * Look up an OSGi service object and return it.  The ServiceReference is
     * automatically released by this method before it returns, so its possible
     * that the returned Service object may subsequently become invalid.  This
     * should only happen if the service bundle unloads, which is not a use case
     * that we are particularly concerned about.
     * 
     * @param <T> the service interface that we are retrieving
     * @param clazz the service interface class
     * @return the service interface object
     */
    @SuppressWarnings("unchecked")
    public static <T> T getService(Class<T> clazz)
    {
        BundleContext context = Activator.getBundleContext();
        ServiceReference ref = context.getServiceReference(clazz.getName());
        T service = (T) context.getService(ref);
        context.ungetService(ref);

        return service;
    }

    /**
     * Look up an OSGi service object and return it.  The ServiceReference is
     * automatically released by this method before it returns, so its possible
     * that the returned Service object may subsequently become invalid.  This
     * should only happen if the service bundle unloads, which is not a use case
     * that we are particularly concerned about.
     * 
     * This method will automatically include an AND'ed objectClass=[clazz.getName()] clause
     * into the OSGi server filter it generates.
     * 
     * @param <T> the service interface that we are retrieving
     * @param clazz the service interface class
     * @param filter an OSGi service filter string.  note the objectClass=[clazz.getName()] will
     * automatically be included here...
     * @throws InvalidSyntaxException if the filter isn't a valid OSGi service filter
     * @return the service interface object
     */

    @SuppressWarnings("unchecked")
    public static <T> T getService(Class<T> clazz, String filter) throws InvalidSyntaxException
    {
        String augmentFilter = "(&(objectClass=" + clazz.getName() + ")" + filter + ")";

        BundleContext context = Activator.getBundleContext();
        ServiceReference[] refs = context.getServiceReferences(clazz.getName(), augmentFilter);
        T service = null;
        if (refs.length > 0)
        {
            service = (T) context.getService(refs[0]);
            context.ungetService(refs[0]);
        }

        return service;
    }

}
