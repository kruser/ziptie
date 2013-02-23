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
 * Copyright the ZipTie Project (www.ziptie.org)
 */

package org.ziptie.provider.devices;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.Restrictions;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.provider.devices.DeviceNotifier.DeviceNotification;
import org.ziptie.provider.devices.internal.DeviceProviderActivator;
import org.ziptie.provider.netman.ManagedNetwork;

/**
 * DeviceProvider
 */
public class DeviceProvider implements IDeviceProvider
{
    private static final Logger LOGGER = Logger.getLogger(DeviceProvider.class);

    private static final String IP_ADDRESS = "ipAddress"; //$NON-NLS-1$
    private static final String NETWORK = "managedNetwork"; //$NON-NLS-1$
    private static final String DEVICE_ID = "deviceId"; //$NON-NLS-1$

    private static final int BATCH_SIZE = 500;

    private DeviceNotifier deviceNotifier;

    /**
     * Default constructor.
     */
    public DeviceProvider()
    {
        deviceNotifier = new DeviceNotifier();
    }

    // -----------------------------------------------------------------------
    //                     IDeviceProvider (SOAP) Methods
    // -----------------------------------------------------------------------

    /** {@inheritDoc} */
    public void deleteDevice(String ipAddress, String managedNetwork)
    {
        ZDeviceCore device = getDevice(ipAddress, managedNetwork);
        if (device == null)
        {
            return;
        }

        LOGGER.debug("Deleting device " + device); //$NON-NLS-1$

        Session currentSession = DeviceProviderActivator.getSessionFactory().getCurrentSession();
        currentSession.delete(device);

        deviceNotifier.notifyDeviceObservers(device, DeviceNotification.DELETE);
    }

    /** {@inheritDoc} */
    public ZDeviceCore getDevice(String ipAddress, String managedNetwork)
    {
        String network = resolveManagedNetwork(managedNetwork);

        // IPAddress address = (IPAddress) NetworkAddressElf.parseAddress(ipAddress);
        String ipv6 = NetworkAddressElf.toDatabaseString(ipAddress);

        SessionFactory sessionFactory = DeviceProviderActivator.getSessionFactory();
        Session currentSession = sessionFactory.getCurrentSession();

        return (ZDeviceCore) currentSession.createCriteria(ZDeviceCore.class).add(Restrictions.eq(IP_ADDRESS, ipv6)).add(Restrictions.eq(NETWORK, network))
                                           .uniqueResult();
    }

    /** {@inheritDoc} */
    public ZDeviceCore getDeviceByInterfaceIp(String ipAddress, String managedNetwork)
    {
        String network = resolveManagedNetwork(managedNetwork);
        String databaseIp = NetworkAddressElf.toDatabaseString(ipAddress);

        StringBuilder queryString = new StringBuilder("SELECT DISTINCT d.device_id ");
        queryString.append("FROM device d LEFT OUTER JOIN device_interface_ips i on d.device_id=i.device_id");
        queryString.append(String.format(" WHERE (d.ip_address='%s' OR i.ip_address='%s')", databaseIp, databaseIp));
        queryString.append(String.format(" AND d.network='%s'", network));

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();
        Query query = session.createSQLQuery(queryString.toString());
        List<?> deviceIds = query.list();
        if (deviceIds == null || deviceIds.isEmpty())
        {
            return null;
        }
        else
        {
            return (ZDeviceCore) session.createCriteria(ZDeviceCore.class).add(Restrictions.eq(DEVICE_ID, deviceIds.get(0))).uniqueResult();
        }
    }

    /** {@inheritDoc} */
    public ZDeviceStatus getDeviceStatus(String ipAddress, String managedNetwork)
    {
        String network = resolveManagedNetwork(managedNetwork);

        String ipv6 = NetworkAddressElf.toDatabaseString(ipAddress);

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        return (ZDeviceStatus) session.createCriteria(ZDeviceStatus.class).add(Restrictions.eq(IP_ADDRESS, ipv6)).add(Restrictions.eq(NETWORK, network))
                                      .uniqueResult();
    }

    /**
     * Retrieves a device from ZipTie that is associated with the specified device ID.
     * 
     * @param deviceID The ID of the device to retrieve.
     * @return A {@link ZDeviceCore} object or <code>null</code> if the device was not found.
     */
    public ZDeviceCore getDevice(int deviceID)
    {
        Session currentSession = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        return (ZDeviceCore) currentSession.createCriteria(ZDeviceCore.class).add(Restrictions.eq(DEVICE_ID, deviceID)).uniqueResult();
    }

    /** {@inheritDoc} */
    public List<ZDeviceLite> getDeviceLites(String[] devices)
    {
        LinkedList<ZDeviceLite> result = new LinkedList<ZDeviceLite>();

        String defaultNetwork = DeviceProviderActivator.getNetworksProvider().getDefaultManagedNetwork().getName();

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        // TODO lbayer: don't do one SELECT per device.  Cross cut on managed network using an IN query or something clever.

        for (String string : devices)
        {
            String[] ipAndNetwork = string.split("@"); //$NON-NLS-1$
            String ip = ipAndNetwork[0];
            if (NetworkAddressElf.isValidAddress(ip))
            {
                String network = (ipAndNetwork.length < 2) ? defaultNetwork : ipAndNetwork[1];

                ZDeviceLite lite = (ZDeviceLite) session.createCriteria(ZDeviceLite.class).add(Restrictions.eq(NETWORK, network))
                                                        .add(Restrictions.eq(IP_ADDRESS, NetworkAddressElf.toDatabaseString(ip))).uniqueResult();

                result.add(lite);
            }
        }

        return result;
    }

    /** {@inheritDoc} */
    public void updateDevice(String ipAddress, String managedNetwork, ZDeviceCore device)
    {
        ZDeviceCore dbDevice = getDevice(ipAddress, managedNetwork);
        if (dbDevice == null)
        {
            return;
        }

        if (DeviceProviderActivator.getAdapterService().getAdapterMetadata(device.getAdapterId()) != null)
        {
            if (!dbDevice.getAdapterId().equals(device.getAdapterId()))
            {
                dbDevice.setAdapterId(device.getAdapterId());
                deviceNotifier.notifyDeviceObservers(dbDevice, DeviceNotification.CHANGE_DEVICE_TYPE);
            }
        }

        // When setting the host name, we should accept any host name that is given.  There are situations
        // where the hostname retrieved by DNS lookup gives us a string that does not validate.
        dbDevice.setHostname(device.getHostname());
        //if (NetworkAddressElf.isValidHostname(device.getHostname()))
        //{
        //    dbDevice.setHostname(device.getHostname());
        //}

        if (NetworkAddressElf.isValidAddress(device.getIpAddress()))
        {
            dbDevice.setIpAddress(NetworkAddressElf.toDatabaseString(device.getIpAddress()));
        }

        if (DeviceProviderActivator.getNetworksProvider().getManagedNetwork(device.getManagedNetwork()) != null)
        {
            dbDevice.setManagedNetwork(device.getManagedNetwork());
        }

        SessionFactory sessionFactory = DeviceProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();
        session.merge(dbDevice);
    }

    /** {@inheritDoc} */
    public void createDevice(String ipAddress, String managedNetwork, String adapterId)
    {
        ZDeviceCore device = new ZDeviceCore();
        device.setIpAddress(ipAddress);
        device.setManagedNetwork(managedNetwork);
        device.setAdapterId(adapterId);

        createDevice(device);
    }

    /** {@inheritDoc} */
    public List<ZDeviceCore> createDeviceBatched(List<ZDeviceCore> devices)
    {
        ArrayList<ZDeviceCore> failedDevices = new ArrayList<ZDeviceCore>();

        SessionFactory sessionFactory = DeviceProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        int batch = 0;
        for (ZDeviceCore device : devices)
        {
            try
            {
                createDevice(device);
            }
            catch (RuntimeException e)
            {
                failedDevices.add(device);
                continue;
            }

            if (++batch % BATCH_SIZE == 0)
            {
                session.flush();
                session.clear();
                LOGGER.info(Messages.bind(Messages.DeviceProvider_addedBatchDevices, BATCH_SIZE));
            }
        }

        return failedDevices;
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<String> getAllHardwareVendors()
    {
        SessionFactory sessionFactory = DeviceProviderActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        Query query = session.createQuery("SELECT DISTINCT d.hardwareVendor FROM ZDeviceLite d"); //$NON-NLS-1$
        List<?> list = query.list();

        return (List<String>) list;
    }

    private String resolveManagedNetwork(String managedNetwork)
    {
        ManagedNetwork network = DeviceProviderActivator.getNetworksProvider().getManagedNetwork(managedNetwork);
        if (network == null)
        {
            network = DeviceProviderActivator.getNetworksProvider().getDefaultManagedNetwork();
        }
        return network.getName();
    }

    /**
     * Internal create device method using a ZDeviceCore.
     *
     * @param device a ZDeviceCore object
     */
    public void createDevice(ZDeviceCore device)
    {
        String adapterId = device.getAdapterId();
        String network = resolveManagedNetwork(device.getManagedNetwork());

        if (DeviceProviderActivator.getAdapterService().getAdapterMetadata(adapterId) == null)
        {
            throw new RuntimeException(Messages.bind(Messages.DeviceProvider_invalidAdapterId, adapterId));
        }

        device.setManagedNetwork(network);

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        session.save(device);

        deviceNotifier.notifyDeviceObservers(device, DeviceNotification.CREATE);

        if (LOGGER.isDebugEnabled())
        {
            LOGGER.debug(String.format(Messages.bind(Messages.createdDevice, device.getIpAddress(), network)));
        }
    }
}
