package org.ziptie.provider.devices.internal;

import org.ziptie.provider.devices.DeviceResolutionElf;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;

/**
 * SimpleSearchResolutionScheme
 *
 * This resolution scheme utilizes the SimpleSearch service to resolve
 * devices.  The input data is a comma separated list consisting of
 * the following format:
 * 
 *    method,arg1,arg2,arg3
 * 
 * Where 'method' is the literal name of a method from the ISimpleDeviceSearch
 * interface, and the arguments are the first N parameters of that method up to
 * but not including the PageData parameter.  For example:
 * 
 *   searchByMakeModel,Cisco,262*
 *
 * (note that wildcards and any standard search parameters are supported).
 */
public class SimpleSearchResolutionScheme implements IDeviceResolutionScheme
{
    /** {@inheritDoc} */
    public PageData resolve(String scheme, String data, PageData page, String sortColumn, boolean descending)
    {
        String[] split = data.split(",", 2); //$NON-NLS-1$

        String newData = split.length > 1 ? split[1] : ""; //$NON-NLS-1$
        String newScheme;
        String method = split[0];
        if ("searchByAddress".equals(method)) //$NON-NLS-1$
        {
            newScheme = "ipAddress"; //$NON-NLS-1$
        }
        else if ("searchByHostname".equals(method)) //$NON-NLS-1$
        {
            newScheme = "hostname"; //$NON-NLS-1$
        }
        else if ("searchByMakeModel".equals(method)) //$NON-NLS-1$
        {
            newScheme = "makeModel"; //$NON-NLS-1$
        }
        else if ("searchByOsVersion".equals(method)) //$NON-NLS-1$
        {
            newScheme = "osVersion"; //$NON-NLS-1$
        }
        else if ("searchByTag".equals(method)) //$NON-NLS-1$
        {
            newScheme = "tag"; //$NON-NLS-1$
        }
        else
        {
            throw new IllegalArgumentException("Unknown resolution type: " + method); //$NON-NLS-1$
        }

        return DeviceResolutionElf.getResolutionScheme(newScheme).resolve(newScheme, newData, page, sortColumn, descending);
    }
}
