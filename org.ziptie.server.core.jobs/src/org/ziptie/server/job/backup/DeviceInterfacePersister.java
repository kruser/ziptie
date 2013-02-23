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
 */
package org.ziptie.server.job.backup;

import java.util.ArrayList;
import java.util.List;

import javax.xml.stream.events.Characters;
import javax.xml.stream.events.EndElement;
import javax.xml.stream.events.XMLEvent;

import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.ziptie.addressing.IPAddress;
import org.ziptie.provider.devices.InterfaceIpAddress;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.server.job.internal.CoreJobsActivator;

/**
 * DeviceInterfacePersister
 * 
 * Pulls interface IP addresses from the backup artifact (ZED) and persists
 * them to the DB where they can be used for search.
 * 
 * Note that this only saves an IP address to the database if the interface
 * is administratively up and if the <code>device</code> object's primary IP
 * address can be found configured on an interface (not NAT'd).
 */
public class DeviceInterfacePersister implements IBackupPersister
{
    private static Logger LOGGER = Logger.getLogger(DeviceInterfacePersister.class);

    private static final int BATCH_SIZE = 100;
    private static List<String> pathsOfInterest;

    private ZDeviceLite device;
    private List<InterfaceIpAddress> interfaceIps;
    private List<InterfaceIpAddress> currentInterfaceIps;
    private boolean adminUp;
    private StringBuilder charData;

    static
    {
        pathsOfInterest = new ArrayList<String>();
        pathsOfInterest.add("/ZiptieElementDocument/interfaces/interface"); //$NON-NLS-1$
        pathsOfInterest.add("/ZiptieElementDocument/interfaces/interface/name"); //$NON-NLS-1$
        pathsOfInterest.add("/ZiptieElementDocument/interfaces/interface/adminStatus"); //$NON-NLS-1$
        pathsOfInterest.add("/ZiptieElementDocument/interfaces/interface/interfaceIp/ipConfiguration/ipAddress"); //$NON-NLS-1$
    }

    /**
     * Default constructor
     */
    public DeviceInterfacePersister()
    {
        interfaceIps = new ArrayList<InterfaceIpAddress>();
        currentInterfaceIps = new ArrayList<InterfaceIpAddress>();
        charData = new StringBuilder();
    }

    /** {@inheritDoc} */
    public void characterData(XMLEvent xmlEvent)
    {
        Characters characters = xmlEvent.asCharacters();
        if (characters.isIgnorableWhiteSpace())
        {
            return;
        }
        charData.append(characters.getData());
    }

    /** {@inheritDoc} */
    public void cleanup()
    {
    }

    /** {@inheritDoc} */
    public void endDocument(XMLEvent xmlEvent)
    {
        boolean sameIpSpace = !nattedIp();

        SessionFactory factory = CoreJobsActivator.getSessionFactory();
        Session session = factory.getCurrentSession();

        String hql = "DELETE " + InterfaceIpAddress.class.getName() + " WHERE device_id = " + device.getDeviceId();
        session.createQuery(hql).executeUpdate();

        // Prepare for batching ... see http://www.hibernate.org/hib_docs/reference/en/html/batch.html
        session.flush();
        session.clear();

        int batchCount = 0;
        for (InterfaceIpAddress intIp : interfaceIps)
        {
            intIp.setSameIpSpace(sameIpSpace);
            session.save(intIp);
            if (batchCount++ % BATCH_SIZE == 0)
            {
                session.flush();
                session.clear();
            }
        }
    }

    /**
     * Analyze the interface IP addresses and the device's administrative IP address.
     * Return true if the device's IP address is not found on an interface configuration.
     * @return
     */
    private boolean nattedIp()
    {
        IPAddress deviceAdminIp = new IPAddress(device.getIpAddress());
        for (InterfaceIpAddress intIp : interfaceIps)
        {
            IPAddress thisOne = new IPAddress(intIp.getIpAddress());
            if (thisOne.equals(deviceAdminIp))
            {
                return false;
            }
        }
        return true;
    }

    /** {@inheritDoc} */
    public void endElement(XMLEvent xmlEvent)
    {
        EndElement element = xmlEvent.asEndElement();
        String localPart = element.getName().getLocalPart();
        if (localPart.equals("adminStatus"))
        {
            adminUp = (getElementText().equalsIgnoreCase("up"));
        }
        else if (localPart.equals("ipAddress"))
        {
            if (adminUp)
            {
                try
                {
                    InterfaceIpAddress intIp = new InterfaceIpAddress(getElementText(), device);
                    currentInterfaceIps.add(intIp);
                }
                catch (Exception e)
                {
                    LOGGER.warn("Invalid IP address " + getElementText());
                }
            }
        }
        else if (localPart.equals("name"))
        {
            String name = getElementText();
            for (InterfaceIpAddress intIp : currentInterfaceIps)
            {
                intIp.setInterfaceName(name);
                interfaceIps.add(intIp);
            }
            currentInterfaceIps.clear();
        }
        else if (localPart.equals("interface"))
        {
            adminUp = false;
        }
        charData.setLength(0);
    }

    /** {@inheritDoc} */
    public List<String> getPathsOfInterest()
    {
        return pathsOfInterest;
    }

    /** {@inheritDoc} */
    public void setDevice(ZDeviceCore device)
    {
        ZDeviceLite deviceLite = new ZDeviceLite();
        deviceLite.setAdapterId(device.getAdapterId());
        deviceLite.setHostname(device.getHostname());
        deviceLite.setIpAddress(device.getIpAddress());
        deviceLite.setManagedNetwork(device.getManagedNetwork());
        deviceLite.setDeviceId(device.getDeviceId());
        deviceLite.setInode(device.getInode());
        this.device = deviceLite;
    }

    /** {@inheritDoc} */
    public void startDocument(XMLEvent xmlEvent)
    {
    }

    /** {@inheritDoc} */
    public void startElement(XMLEvent xmlEvent)
    {
    }

    /**
     * Trims the char data
     * @return
     */
    private String getElementText()
    {
        return charData.toString().trim();
    }

}
