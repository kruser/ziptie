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
package org.ziptie.provider.devices;


/**
 * Implementors provide a means to get a set of devices for some arbitrary data.
 * Scheme's can be registered using the "org.ziptie.provider.devices.deviceResolutionScheme" extension point.
 */
public interface IDeviceResolutionScheme
{
    String WILDCARD = "*"; //$NON-NLS-1$
    String ATTR_ADAPTER_ID = "adapterId"; //$NON-NLS-1$
    String ATTR_CANONICAL_OS_VERSION = "canonicalOsVersion"; //$NON-NLS-1$
    String ATTR_DEVICE_ID = "deviceId"; //$NON-NLS-1$
    String ATTR_HOSTNAME = "hostname"; //$NON-NLS-1$
    String ATTR_MODEL = "model"; //$NON-NLS-1$
    String ATTR_IP_ADDRESS = "ipAddress"; //$NON-NLS-1$
    String ATTR_IP_LOW = "ipLow"; //$NON-NLS-1$
    String ATTR_IP_HIGH = "ipHigh"; //$NON-NLS-1$
    String ATTR_NETWORK = "managedNetwork"; //$NON-NLS-1$

    /**
     * Resolves the given data into a page of devices.
     * @param page The page to retrieve.
     * @param scheme The resolution scheme of the request
     * @param data The resolution data to resolve.
     * @param sortColumn The column to sort by, or <code>null</code>
     * @param descending <code>true</code> for descending ordered sort, <code>false</code> for ascending.
     * @return The page of devices.
     */
    PageData resolve(String scheme, String data, PageData page, String sortColumn, boolean descending);
}
