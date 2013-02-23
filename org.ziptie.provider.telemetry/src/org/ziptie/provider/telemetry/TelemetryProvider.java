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
package org.ziptie.provider.telemetry;

import java.math.BigInteger;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

import org.hibernate.Hibernate;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.ScrollMode;
import org.hibernate.classic.Session;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.MACAddress;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.zap.jta.TransactionElf;

/**
 * TelemetryProvider
 */
public class TelemetryProvider implements ITelemetryProvider
{

    /** {@inheritDoc} */
    public SwitchPortResult findSwitchPort(String host)
    {
        SwitchPortResult result = new SwitchPortResult();
        MACAddress targetMacAddress = null;
        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        try
        {
            if (NetworkAddressElf.isValidMacAddress(host))
            {
                targetMacAddress = new MACAddress(host);
            }
            else
            {
                try
                {
                    IPAddress ipAddress = new IPAddress(InetAddress.getByName(host));
                    result.setHostIpAddress(ipAddress.getIPAddress());
                    DeviceArpTableEntry entry = null;
                    if (ipAddress.isVersion6())
                    {
                        entry = findNdpEntry(ipAddress);

                    }
                    else
                    {
                        entry = findArpEntry(ipAddress);
                    }
                    
                    if (entry != null)
                    {
                        result.setArpEntry(entry);
                        String mac = entry.getMacAddress();
                        targetMacAddress = new MACAddress(mac);
                    }
                    else
                    {
                        result.setError(SwitchPortResult.NO_ARP_ENTRY);
                        return result;
                    }
                }
                catch (UnknownHostException e)
                {
                    result.setError(SwitchPortResult.UNABLE_TO_RESOLVE_HOST);
                    return result;
                }
            }
            result.setMacEntry(findMacTableEntry(targetMacAddress));
            result.setHostMacAddress(targetMacAddress.getMACAddress());
            if (result.getMacEntry() == null)
            {
                result.setError(SwitchPortResult.NO_MAC_ENTRY);
            }
            return result;
        }
        finally
        {
            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }

    }

    /** {@inheritDoc} */
    @SuppressWarnings({ "unchecked", "nls" })
    public MacPageData getMacTable(MacPageData pageData, String ipAddress, String managedNetwork)
    {
        ZDeviceCore device = getDevice(ipAddress, managedNetwork);
        if (device == null)
        {
            pageData.setMacEntries(new MacTableEntry[0]);
            pageData.setTotal(0);
            return pageData;
        }

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        try
        {
            Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
            String fromClause = "FROM discovery_mac WHERE device_id = " + device.getDeviceId();
            SQLQuery query = session.createSQLQuery("SELECT mac_address, interface, vlan " + fromClause + " ORDER BY interface");
            query.addScalar("mac_address", Hibernate.LONG);
            query.addScalar("interface", Hibernate.STRING);
            query.addScalar("vlan", Hibernate.STRING);
            query.setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());
            query.scroll(ScrollMode.SCROLL_INSENSITIVE);
            List<Object[]> resultList = (List<Object[]>) query.list();
            if (resultList == null || resultList.isEmpty())
            {
                pageData.setMacEntries(new MacTableEntry[0]);
                pageData.setTotal(0);
                return pageData;
            }
            else
            {
                if (pageData.getOffset() == 0)
                {
                    // Set the total result size into the page data.
                    query = session.createSQLQuery("SELECT count(mac_address) " + fromClause);
                    pageData.setTotal(getCount(query));
                }

                List<MacTableEntry> macTable = new ArrayList<MacTableEntry>();
                for (Object[] resultEntry : resultList)
                {
                    MacTableEntry entry = new MacTableEntry();
                    entry.setMacAddress((Long) resultEntry[0]);
                    entry.setPort((String) resultEntry[1]);
                    entry.setVlan((String) resultEntry[2]);
                    macTable.add(entry);
                }
                pageData.setMacEntries(macTable.toArray(new MacTableEntry[0]));
                return pageData;
            }
        }
        finally
        {
            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
    }

    /** {@inheritDoc} */
    @SuppressWarnings({ "unchecked", "nls" })
    public ArpPageData getArpTable(ArpPageData pageData, String ipAddress, String managedNetwork)
    {
        ZDeviceCore device = getDevice(ipAddress, managedNetwork);
        if (device == null)
        {
            pageData.setArpEntries(new ArpTableEntry[0]);
            pageData.setTotal(0);
            return pageData;
        }

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        try
        {
            Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
            String fromClause = "FROM discovery_arp arp WHERE arp.device_id = " + device.getDeviceId();
            SQLQuery query = session.createSQLQuery("SELECT ip_address, mac_address, interface " + fromClause + " ORDER BY ip_address");
            query.addScalar("ip_address", Hibernate.STRING);
            query.addScalar("mac_address", Hibernate.LONG);
            query.addScalar("interface", Hibernate.STRING);
            query.setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());
            query.scroll(ScrollMode.SCROLL_INSENSITIVE);
            List<Object[]> resultList = (List<Object[]>) query.list();
            if (resultList == null || resultList.isEmpty())
            {
                pageData.setArpEntries(new ArpTableEntry[0]);
                pageData.setTotal(0);
                return pageData;
            }
            else
            {
                if (pageData.getOffset() == 0)
                {
                    // Set the total result size into the page data.
                    query = session.createSQLQuery("SELECT count(arp.ip_address) " + fromClause);
                    pageData.setTotal(getCount(query));
                }

                List<ArpTableEntry> arpTable = new ArrayList<ArpTableEntry>();
                for (Object[] resultEntry : resultList)
                {
                    ArpTableEntry entry = new ArpTableEntry();
                    entry.setIpAddress((String) resultEntry[0]);
                    entry.setMacAddress((Long) resultEntry[1]);
                    entry.setInterfaceName((String) resultEntry[2]);
                    arpTable.add(entry);
                }
                pageData.setArpEntries(arpTable.toArray(new ArpTableEntry[0]));
                return pageData;
            }
        }
        finally
        {
            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    @SuppressWarnings({ "unchecked", "nls" })
    public DeviceArpPageData getArpEntries(DeviceArpPageData pageData, String networkAddress, String sort, boolean descending)
    {
        StringBuilder selectClause = new StringBuilder(
                                                       "SELECT d.ip_address as device, d.network as managedNetwork, arp.device_id as device_id, arp.ip_address as ipAddress, arp.mac_address as macAddress, arp.interface as interfaceName");
        StringBuilder fromClause = new StringBuilder(" FROM discovery_arp arp LEFT JOIN device d on arp.device_id = d.device_id");
        if (networkAddress.indexOf('/') > 0)
        {
            Long[] hiLoRange = NetworkAddressElf.getHiLoRange(networkAddress);
            if (hiLoRange[0] == null)
            {
                if (NetworkAddressElf.isIPv6AddressOrMask(networkAddress))
                {
                    String[] ipAndCidr = networkAddress.split("/");
                    long[] hiLo = NetworkAddressElf.getHiLo(ipAndCidr[0]);
                    fromClause.append(String.format(" WHERE arp.ip_low BETWEEN %d AND %d AND arp.ip_high=%d", hiLoRange[2], hiLoRange[1], hiLo[0]));
                }
                else
                {
                    fromClause.append(String.format(" WHERE arp.ip_low BETWEEN %d AND %d", hiLoRange[2], hiLoRange[1]));
                }
            }
            else
            {
                fromClause.append(String.format(" WHERE arp.ip_high BETWEEN %d AND %d", hiLoRange[1], hiLoRange[0]));
            }
        }
        else
        {
            long[] hiLo = NetworkAddressElf.getHiLo(networkAddress);
            fromClause.append(String.format(" WHERE arp.ip_high=%d AND arp.ip_low=%d", hiLo[0], hiLo[1]));
        }

        selectClause.append(fromClause);
        if (sort != null)
        {
            selectClause.append(" ORDER BY ").append(sort);
            if (descending)
            {
                selectClause.append(" DESC");
            }
        }

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        try
        {
            Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
            SQLQuery query = session.createSQLQuery(selectClause.toString());
            query.addScalar("device", Hibernate.STRING);
            query.addScalar("managedNetwork", Hibernate.STRING);
            query.addScalar("device_id", Hibernate.INTEGER);
            query.addScalar("ipAddress", Hibernate.STRING);
            query.addScalar("macAddress", Hibernate.LONG);
            query.addScalar("interfaceName", Hibernate.STRING);

            query.setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());
            query.scroll(ScrollMode.SCROLL_INSENSITIVE);
            List<Object[]> resultList = (List<Object[]>) query.list();
            if (resultList == null || resultList.isEmpty())
            {
                pageData.setArpEntries(new DeviceArpTableEntry[0]);
                pageData.setTotal(0);
                return pageData;
            }
            else
            {
                if (pageData.getOffset() == 0)
                {
                    // Set the total result size into the page data.
                    query = session.createSQLQuery("SELECT count(arp.ip_address) " + fromClause.toString());
                    pageData.setTotal(getCount(query));
                }

                List<DeviceArpTableEntry> arpTable = new ArrayList<DeviceArpTableEntry>();
                for (Object[] resultEntry : resultList)
                {
                    DeviceArpTableEntry entry = new DeviceArpTableEntry();
                    entry.setDevice((String) resultEntry[0]);
                    entry.setManagedNetwork((String) resultEntry[1]);
                    entry.setDeviceId((Integer) resultEntry[2]);
                    entry.setIpAddress((String) resultEntry[3]);
                    entry.setMacAddress((Long) resultEntry[4]);
                    entry.setInterfaceName((String) resultEntry[5]);
                    arpTable.add(entry);
                }
                pageData.setArpEntries(arpTable.toArray(new DeviceArpTableEntry[0]));
                return pageData;
            }
        }
        finally
        {
            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
    }

    /** {@inheritDoc} */
    public List<Neighbor> getNeighbors(String ipAddress, String managedNetwork)
    {
        ZDeviceCore device = getDevice(ipAddress, managedNetwork);
        List<Neighbor> neighborList = new ArrayList<Neighbor>();
        if (device != null)
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            try
            {
                Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
                addRoutingNeighbors(neighborList, session, device);
                addDiscoveryProtocolNeighbors(neighborList, session, device);
            }
            finally
            {
                if (ownTransaction)
                {
                    TransactionElf.commit();
                }
            }
        }
        return neighborList;
    }

    /**
     * Retrieve neighbors from the routing table
     * @param neighborList the list of neighbors so far
     * @param session
     * @param device 
     */
    @SuppressWarnings({ "unchecked", "nls" })
    private void addRoutingNeighbors(List<Neighbor> neighborList, Session session, ZDeviceCore device)
    {
        SQLQuery query = session.createSQLQuery("SELECT protocol, remote_ip_address, router_id_ip_address, interface FROM discovery_routing WHERE device_id="
                + device.getDeviceId() + " ORDER by remote_ip_address");
        query.addScalar("protocol", Hibernate.STRING);
        query.addScalar("remote_ip_address", Hibernate.STRING);
        query.addScalar("router_id_ip_address", Hibernate.STRING);
        query.addScalar("interface", Hibernate.STRING);
        List<Object[]> resultList = (List<Object[]>) query.list();
        for (Object[] resultEntry : resultList)
        {
            Neighbor neighbor = new Neighbor();
            neighbor.setProtocol((String) resultEntry[0]);
            neighbor.setIpAddress((String) resultEntry[1]);
            neighbor.setOtherId(NetworkAddressElf.fromDatabaseString((String) resultEntry[2]));
            neighbor.setLocalInterface((String) resultEntry[3]);
            neighborList.add(neighbor);
        }
    }

    /**
     * Add discovery protocol neighbors
     * @param neighborList
     * @param session
     * @param device
     */
    @SuppressWarnings({ "unchecked", "nls" })
    private void addDiscoveryProtocolNeighbors(List<Neighbor> neighborList, Session session, ZDeviceCore device)
    {
        SQLQuery query = session.createSQLQuery("SELECT protocol, ip_address, local_interface, remote_interface, sys_name FROM discovery_xdp WHERE device_id="
                + device.getDeviceId() + " ORDER by ip_address");
        query.addScalar("protocol", Hibernate.STRING);
        query.addScalar("ip_address", Hibernate.STRING);
        query.addScalar("local_interface", Hibernate.STRING);
        query.addScalar("remote_interface", Hibernate.STRING);
        query.addScalar("sys_name", Hibernate.STRING);
        List<Object[]> resultList = (List<Object[]>) query.list();
        for (Object[] resultEntry : resultList)
        {
            Neighbor neighbor = new Neighbor();
            neighbor.setProtocol((String) resultEntry[0]);
            neighbor.setIpAddress((String) resultEntry[1]);
            neighbor.setLocalInterface((String) resultEntry[2]);
            neighbor.setRemoteInterface((String) resultEntry[3]);
            neighbor.setOtherId((String) resultEntry[4]);
            neighborList.add(neighbor);
        }
    }

    /**
     * Find the best matching MAC forwarding entry for the provided MAC address
     * @param targetMacAddress what to look for
     * @return
     */
    @SuppressWarnings({ "unchecked", "nls" })
    private DeviceMacTableEntry findMacTableEntry(MACAddress targetMacAddress)
    {
        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        try
        {
            Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
            String queryString = "SELECT d.ip_address as device, d.network as net, m.device_id as device_id, m.mac_address as mac, m.interface as interface, m.vlan as vlan FROM discovery_mac m LEFT JOIN device d on m.device_id = d.device_id where m.mac_address=" + targetMacAddress.getMacLong();
            SQLQuery query = session.createSQLQuery(queryString);
            query.addScalar("device", Hibernate.STRING);
            query.addScalar("net", Hibernate.STRING);
            query.addScalar("device_id", Hibernate.INTEGER);
            query.addScalar("mac", Hibernate.LONG);
            query.addScalar("interface", Hibernate.STRING);
            query.addScalar("vlan", Hibernate.STRING);
            List<Object[]> resultList = (List<Object[]>) query.list();
            List<DeviceMacTableEntry> possibleMatches = new ArrayList<DeviceMacTableEntry>();
            for (Object[] resultEntry : resultList)
            {
                DeviceMacTableEntry entry = new DeviceMacTableEntry();
                entry.setDevice((String) resultEntry[0]);
                entry.setManagedNetwork((String) resultEntry[1]);
                entry.setDeviceId((Integer) resultEntry[2]);
                entry.setMacAddress((Long) resultEntry[3]);
                entry.setPort((String) resultEntry[4]);
                entry.setVlan((String) resultEntry[5]);
                possibleMatches.add(entry);
            }

            int portMacCount = 0;
            DeviceMacTableEntry leader = null;
            for (DeviceMacTableEntry macEntry : possibleMatches)
            {
                int frequency = getMacFrequency(macEntry);
                if (leader == null || portMacCount > frequency)
                {
                    portMacCount = frequency;
                    leader = macEntry;
                }
            }
            return leader;
        }
        finally
        {
            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
    }

    /**
     * Tries to find the best MAC address for the IP Address provided.  This method looks at all 
     * ARP tables to determine the least used matching MAC address.
     * @param ipAddress find a mac mapped to this IP
     * @return the matching ARP entry
     */
    private DeviceArpTableEntry findArpEntry(IPAddress ipAddress)
    {
        DeviceArpPageData pageData = new DeviceArpPageData();
        pageData.setPageSize(500);
        List<DeviceArpTableEntry> arpEntries = new ArrayList<DeviceArpTableEntry>();
        do
        {
            pageData = getArpEntries(pageData, ipAddress.getIPAddress(), "ipAddress", false); //$NON-NLS-1$
            DeviceArpTableEntry[] entries = pageData.getArpEntries();
            for (int i = 0; i < entries.length; i++)
            {
                arpEntries.add(entries[i]);
            }
        }
        while (pageData.getTotal() >= pageData.getPageSize());

        int macUseCount = 0;
        DeviceArpTableEntry leader = null;

        for (DeviceArpTableEntry arpEntry : arpEntries)
        {
            int frequency = getArpFrequency(arpEntry);
            if (leader == null || macUseCount > frequency)
            {
                macUseCount = frequency;
                leader = arpEntry;
            }
        }
        return leader;
    }

    /**
     * Gives a count of how many times the MAC address on the provided 
     * {@link DeviceArpTableEntry} was seen on the device in the same entry.
     * @param arpEntry
     * @return
     */
    @SuppressWarnings("nls")
    private int getArpFrequency(DeviceArpTableEntry arpEntry)
    {
        String queryString = String.format("SELECT count(*) FROM discovery_arp WHERE device_id=%d AND mac_address=%d", arpEntry.getDeviceId(),
                                           arpEntry.getRawMac().getMacLong());
        Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
        SQLQuery query = session.createSQLQuery(queryString);
        return getCount(query);
    }

    /**
     * Gets the MAC address for the {@link IPAddress} provided using the discovery_xdp table.
     * This should be called when working with an IPv6 address as NDP neighbors can be in the X
     * @param ipAddress
     * @return
     */
    @SuppressWarnings({ "unchecked", "nls" })
    private DeviceArpTableEntry findNdpEntry(IPAddress ipAddress)
    {
        long[] hiLo = ipAddress.getHiLo();
        Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
        String queryString = "SELECT d.ip_address as device, d.network as net, x.device_id as device_id, x.ip_address as ip, x.mac_address as mac, x.local_interface as interface";
        String fromClause = String.format(" FROM discovery_xdp x LEFT JOIN device d on x.device_id = d.device_id WHERE x.ip_high=%d AND x.ip_low=%d AND x.protocol='NDP'", hiLo[0], hiLo[1]);
        
        SQLQuery query = session.createSQLQuery(queryString + fromClause);
        query.addScalar("device", Hibernate.STRING);
        query.addScalar("net", Hibernate.STRING);
        query.addScalar("device_id", Hibernate.INTEGER);
        query.addScalar("ip", Hibernate.STRING);
        query.addScalar("mac", Hibernate.LONG);
        query.addScalar("interface", Hibernate.STRING);
        
        List<Object[]> resultList = (List<Object[]>) query.list();
        // pick the first one, which there should only be one anyways
        for (Object[] resultEntry : resultList)
        {
            DeviceArpTableEntry entry = new DeviceArpTableEntry();
            entry.setDevice((String) resultEntry[0]);
            entry.setManagedNetwork((String) resultEntry[1]);
            entry.setDeviceId((Integer) resultEntry[2]);
            entry.setIpAddress((String) resultEntry[3]);
            entry.setMacAddress((Long) resultEntry[4]);
            entry.setInterfaceName((String) resultEntry[5]);
            return entry;
        }
        return null;
    }

    /**
     * Counts the number of MAC addresses on a certain device's interface.  If an 
     * interface only has one MAC address in the MAC forwarding table, then the chances 
     * are good that it is the interface that the end host is directly plugged into.
     * @param macEntry
     * @return
     */
    @SuppressWarnings("nls")
    private int getMacFrequency(DeviceMacTableEntry macEntry)
    {
        String queryString = String.format("SELECT count(*) FROM discovery_mac WHERE device_id=%d AND interface='%s'", macEntry.getDeviceId(),
                                           macEntry.getPort());
        Session session = TelemetryActivator.getSessionFactory().getCurrentSession();
        SQLQuery query = session.createSQLQuery(queryString);
        return getCount(query);
    }

    /**
     * Get a device by the IP
     * @param ip
     * @return
     */
    private ZDeviceCore getDevice(String ip, String managedNetwork)
    {
        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        try
        {
            return TelemetryActivator.getDeviceProvider().getDevice(ip, managedNetwork);
        }
        finally
        {
            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
    }
    
    private int getCount(Query query)
    {
        Object uniqueResult = query.uniqueResult();
        if (uniqueResult instanceof Integer)
        {
            return (Integer) uniqueResult;
        }
        else if (uniqueResult instanceof Long)
        {
            return ((Long) uniqueResult).intValue();
        }
        else
        {
            return ((BigInteger) uniqueResult).intValue();
        }
    }
}
