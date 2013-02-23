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

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Date;
import java.util.Set;

import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.MACAddress;
import org.ziptie.discovery.ArpEntry;
import org.ziptie.discovery.DiscoveryEvent;
import org.ziptie.discovery.IDiscoveryEventHandler;
import org.ziptie.discovery.MacTableEntry;
import org.ziptie.discovery.RoutingNeighbor;
import org.ziptie.discovery.XdpEntry;
import org.ziptie.provider.devices.ZDeviceStatus;
import org.ziptie.zap.jta.TransactionElf;

/**
 * The purpose of this implementation is to persist the neighbor data
 * that is learned via the discovery process. 
 */
public class DiscoveryEventHandler implements IDiscoveryEventHandler
{
    private static Logger LOGGER = Logger.getLogger(DiscoveryEventHandler.class);
    
    private static String ARP_TABLE = "discovery_arp";
    private static String MAC_TABLE = "discovery_mac";
    private static String XDP_TABLE = "discovery_xdp";
    private static String ROUTING_TABLE = "discovery_routing";
    private static String DEVICE_ID = "device_id";

    /** {@inheritDoc} */
    public void handleEvent(DiscoveryEvent discoveryEvent)
    {
        if (discoveryEvent.isInInventory())
        {
            try
            {
                TransactionElf.beginOrJoinTransaction();
                deleteOldRecords(discoveryEvent);
                saveArpTable(discoveryEvent.getArpTable(), discoveryEvent.getDeviceId());
                saveXdpTable(discoveryEvent.getXdpNeighbors(), discoveryEvent.getDeviceId());
                saveRoutingNeighbors(discoveryEvent.getRoutingNeighbors(), discoveryEvent.getDeviceId());
                saveMacTable(discoveryEvent.getMacTable(), discoveryEvent.getDeviceId());
                updateDeviceStatus(discoveryEvent.getDeviceId());
                LOGGER.info("Neighbor data updated for " + discoveryEvent.getAddress());
            }
            catch (Exception e)
            {
                LOGGER.error("Error saving neighbors from discovery.", e);
                TransactionElf.rollback();
            }
            finally
            {
                TransactionElf.commit();
            }
        }
    }

    /**
     * Update the timestamp on the device
     * @param deviceId
     */
    private void updateDeviceStatus(int deviceId)
    {
        SessionFactory factory = TelemetryActivator.getSessionFactory();
        Session session = factory.getCurrentSession();

        ZDeviceStatus deviceStatus = (ZDeviceStatus) session.get(ZDeviceStatus.class, deviceId);
        if (deviceStatus != null)
        {
            deviceStatus.setLastTelemetry(new Date());
            session.saveOrUpdate(deviceStatus);
        }
        
    }

    private void saveMacTable(Set<MacTableEntry> macTable, int deviceId) throws SQLException
    {
        if (macTable.size() > 0)
        {
            Connection connection = TelemetryActivator.getDataSource().getConnection();
            PreparedStatement stmt = null;

            try
            {
                stmt = connection.prepareStatement("INSERT INTO " + MAC_TABLE + "(device_id, mac_address, interface, vlan) values(?, ?, ?, ?)");//$NON-NLS-1$
                for (MacTableEntry entry : macTable)
                {
                    stmt.setInt(1, deviceId);
                    stmt.setLong(2, entry.getMacAddress().getMacLong());
                    stmt.setString(3, entry.getInterfaceName());
                    stmt.setString(4, entry.getVlan());
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
            finally
            {
                if (stmt != null)
                {
                    stmt.close();
                }
                connection.close();
            }
        }
    }

    private void saveRoutingNeighbors(Set<RoutingNeighbor> routingNeighbors, int deviceId) throws SQLException
    {
        if (routingNeighbors.size() > 0)
        {
            Connection connection = TelemetryActivator.getDataSource().getConnection();
            PreparedStatement stmt = null;

            try
            {
                stmt = connection
                                 .prepareStatement("INSERT INTO " + ROUTING_TABLE + "(device_id, protocol, remote_ip_address, remote_ip_low, remote_ip_high, router_id_ip_address, router_id_ip_low, router_id_ip_high, interface) values(?, ?, ?, ?, ?, ?, ?, ?, ?)");//$NON-NLS-1$
                for (RoutingNeighbor entry : routingNeighbors)
                {
                    stmt.setInt(1, deviceId);
                    stmt.setString(2, entry.getRoutingProtocol().name());
                    stmt.setString(3, entry.getIpAddress().toDatabaseString());
                    stmt.setLong(4, entry.getIpAddress().getIpLow());
                    stmt.setLong(5, entry.getIpAddress().getIpHigh());
                    stmt.setString(6, entry.getRouterId().toDatabaseString());
                    stmt.setLong(7, entry.getRouterId().getIpLow());
                    stmt.setLong(8, entry.getRouterId().getIpHigh());
                    stmt.setString(9, entry.getIfName());
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
            finally
            {
                if (stmt != null)
                {
                    stmt.close();
                }
                connection.close();
            }
        }
    }

    private void saveXdpTable(Set<XdpEntry> xdpNeighbors, int deviceId) throws SQLException
    {
        if (xdpNeighbors.size() > 0)
        {
            Connection connection = TelemetryActivator.getDataSource().getConnection();
            PreparedStatement stmt = null;

            try
            {
                stmt = connection
                                 .prepareStatement("INSERT INTO " + XDP_TABLE + "(device_id, protocol, ip_address, ip_low, ip_high, mac_address, local_interface, remote_interface, platform, sys_name) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");//$NON-NLS-1$
                for (XdpEntry entry : xdpNeighbors)
                {
                    IPAddress ip = entry.getIpAddress();
                    MACAddress mac = entry.getMacAddress();
                    stmt.setInt(1, deviceId);
                    stmt.setString(2, entry.getType());
                    if (ip != null)
                    {
                        stmt.setString(3, ip.toDatabaseString());
                        stmt.setLong(4, ip.getIpLow());
                        stmt.setLong(5, ip.getIpHigh());
                    }
                    else
                    {
                        stmt.setNull(3, Types.VARCHAR);
                        stmt.setNull(4, Types.BIGINT);
                        stmt.setNull(5, Types.BIGINT);
                    }
                    if (mac != null)
                    {
                        stmt.setLong(6, mac.getMacLong());
                    }
                    else
                    {
                        stmt.setNull(6, Types.BIGINT);
                    }
                    stmt.setString(7, entry.getLocalIfName());
                    stmt.setString(8, entry.getInterfaceName());
                    stmt.setString(9, entry.getPlatform());
                    stmt.setString(10, entry.getSysName());
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
            finally
            {
                if (stmt != null)
                {
                    stmt.close();
                }
                connection.close();
            }
        }
    }

    private void saveArpTable(Set<ArpEntry> arpTable, int deviceId) throws SQLException
    {
        if (arpTable.size() > 0)
        {
            Connection connection = TelemetryActivator.getDataSource().getConnection();
            PreparedStatement stmt = null;

            try
            {
                stmt = connection.prepareStatement("INSERT INTO " + ARP_TABLE + "(device_id, ip_address, ip_low, ip_high, mac_address, interface) values(?, ?, ?, ?, ?, ?)");//$NON-NLS-1$
                for (ArpEntry entry : arpTable)
                {
                    stmt.setInt(1, deviceId);
                    stmt.setString(2, entry.getIpAddress().toDatabaseString());
                    stmt.setLong(3, entry.getIpAddress().getIpLow());
                    stmt.setLong(4, entry.getIpAddress().getIpHigh());
                    stmt.setLong(5, entry.getMacAddress().getMacLong());
                    stmt.setString(6, entry.getInterfaceName());
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }
            finally
            {
                if (stmt != null)
                {
                    stmt.close();
                }
                connection.close();
            }
        }
    }

    private void deleteOldRecords(DiscoveryEvent discoveryEvent)
    {
        SessionFactory sessionFactory = TelemetryActivator.getSessionFactory();
        Session session = sessionFactory.getCurrentSession();

        session.createSQLQuery("DELETE FROM " + ARP_TABLE + " WHERE " + DEVICE_ID + " = " + discoveryEvent.getDeviceId()).executeUpdate();
        session.createSQLQuery("DELETE FROM " + XDP_TABLE + " WHERE " + DEVICE_ID + " = " + discoveryEvent.getDeviceId()).executeUpdate();
        session.createSQLQuery("DELETE FROM " + MAC_TABLE + " WHERE " + DEVICE_ID + " = " + discoveryEvent.getDeviceId()).executeUpdate();
        session.createSQLQuery("DELETE FROM " + ROUTING_TABLE + " WHERE " + DEVICE_ID + " = " + discoveryEvent.getDeviceId()).executeUpdate();
    }

}
