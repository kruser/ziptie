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
 * Portions created by AlterPoint are Copyright (C) 2008,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.server.discovery;

import java.util.LinkedList;
import java.util.List;

import org.apache.log4j.Logger;
import org.quartz.InterruptableJob;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.UnableToInterruptJobException;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.NetworkAddress;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.discovery.DiscoveryEngine;
import org.ziptie.provider.devices.DeviceResolutionElf;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.security.PermissionDeniedException;

/**
 * Schedulable discovery job. 
 */
public class DiscoveryJob implements InterruptableJob
{
    /** {@inheritDoc} */
    public void interrupt() throws UnableToInterruptJobException
    {
        try
        {
            DiscoveryEngine.getInstance().clearAllActivity();
        }
        catch (PermissionDeniedException e)
        {
            throw new UnableToInterruptJobException(e);
        }
    }

    /** {@inheritDoc} */
    public void execute(JobExecutionContext context) throws JobExecutionException
    {
        JobDataMap data = context.getMergedJobDataMap();
        boolean crawlNeighbors = Boolean.parseBoolean(data.get("crawl").toString()); //$NON-NLS-1$
        boolean includeInventory = Boolean.parseBoolean(data.getString("includeInventory")); //$NON-NLS-1$

        List<NetworkAddress> addressSet = new LinkedList<NetworkAddress>();

        String addresses = data.getString("addresses"); //$NON-NLS-1$
        if (addresses != null)
        {
            for (String address : addresses.split(",")) //$NON-NLS-1$
            {
                try
                {
                    NetworkAddress aset = NetworkAddressElf.parseAddress(address);
                    if (aset != null)
                    {
                        addressSet.add(aset);
                    }
                }
                catch (Exception e)
                {
                    Logger.getLogger(getClass()).debug(e.getMessage(), e);
                }
            }
        }
        else if (includeInventory)
        {
            List<ZDeviceLite> devices = DeviceResolutionElf.resolveDevices("managedNetwork", "Default"); //$NON-NLS-1$ //$NON-NLS-2$
            for (ZDeviceLite deviceLite : devices)
            {
                addressSet.add(new IPAddress(deviceLite.getIpAddress()));
            }
        }

        try
        {
            DiscoveryEngine engine = DiscoveryEngine.getInstance();
            engine.clearDiscoveryCache();
            engine.pingAndDiscover(addressSet, includeInventory, true, crawlNeighbors);

            // sleep until done.
            while (engine.isActive())
            {
                Thread.sleep(1024);
            }
        }
        catch (InterruptedException e)
        {
            throw new JobExecutionException(e);
        }
        catch (PermissionDeniedException e)
        {
            throw new JobExecutionException(e);
        }
    }
}
