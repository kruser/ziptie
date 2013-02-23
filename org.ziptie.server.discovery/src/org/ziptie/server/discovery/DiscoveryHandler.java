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
 */

package org.ziptie.server.discovery;

import org.apache.log4j.Logger;
import org.ziptie.addressing.IPAddress;
import org.ziptie.discovery.ArpEntry;
import org.ziptie.discovery.DiscoveryEvent;
import org.ziptie.discovery.IDiscoveryEventHandler;
import org.ziptie.discovery.MacTableEntry;
import org.ziptie.discovery.RoutingNeighbor;
import org.ziptie.discovery.XdpEntry;
import org.ziptie.net.adapters.AdapterService;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.server.discovery.internal.DiscoveryActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * DiscoveryHandler
 */
public class DiscoveryHandler implements IDiscoveryEventHandler
{
    private static final Logger LOGGER = Logger.getLogger(DiscoveryHandler.class);

    /**
     * Package local constructor.
     */
    public DiscoveryHandler()
    {
    }

    /** {@inheritDoc} */
    public void handleEvent(DiscoveryEvent event)
    {
        if (event.isInInventory())
        {
            return; // don't bother doing anything
        }

        TransactionElf.beginOrJoinTransaction();
        try
        {
            IPAddress ipAddress = event.getAddress();

            synchronized (this)
            {
                // Check to see if we already have this device in the inventory
                ZDeviceCore device = DiscoveryActivator.getDeviceProvider().getDevice(ipAddress.toString(), null);
                if (device != null)
                {
                    return;
                }
                if (event.getAdapterId() == null)
                {
                    event.setAdapterId(DiscoveryActivator.getAdapterService().getAdapterId(event));
                }

                device = new ZDeviceCore();
                device.setIpAddress(ipAddress.toString());
                device.setAdapterId(event.getAdapterId());
                device.setHostname(event.getSysName());
                if (event.getAdapterId() != null)
                {
                    DiscoveryActivator.getDeviceProvider().createDevice(device);
                }
                else if (event.isGoodEvent())
                {
                    LOGGER.debug(Messages.bind(Messages.unsupportedAdapter0, ipAddress.toString()));
                    device.setAdapterId(AdapterService.GENERIC_ADAPTER_ID);
                    DiscoveryActivator.getDeviceProvider().createDevice(device);
                }

                event.setDeviceId(device.getDeviceId());
                pushDownNewDeviceId(event, device.getDeviceId());
                LOGGER.info("A new device was discovered at " + ipAddress);
            }
        }
        finally
        {
            TransactionElf.commit();
        }
    }

    /**
     * Set the deviceId on all the children.  This should only be called in the event that there is a brand new deviceId.
     * @param event the discoveryEvent
     * @param deviceId the deviceId
     */
    private void pushDownNewDeviceId(DiscoveryEvent event, int deviceId)
    {
        for (ArpEntry entry : event.getArpTable())
        {
            entry.setDeviceId(deviceId);
        }
        for (MacTableEntry entry : event.getMacTable())
        {
            entry.setDeviceId(deviceId);
        }
        for (RoutingNeighbor entry : event.getRoutingNeighbors())
        {
            entry.setDeviceId(deviceId);
        }
        for (XdpEntry entry : event.getXdpNeighbors())
        {
            entry.setDeviceId(deviceId);
        }
    }

}
