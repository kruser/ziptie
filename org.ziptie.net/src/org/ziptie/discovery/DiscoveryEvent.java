/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/22 20:33:33 $
 * $Revision: 1.8 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/DiscoveryEvent.java,v $e
 */

package org.ziptie.discovery;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.ziptie.addressing.IPAddress;

/**
 * A <code>DiscoveryEvent</code> simply contains information from the device
 * that ran through the <code>DiscoveryEngine</code>. This event should be
 * passed by the creator to an <code>IDiscoveryEventHandler</code> for
 * processing.
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
public class DiscoveryEvent
{
    private boolean goodEvent;
    private boolean extendUsingNeighbors = true;
    private IPAddress address;
    private String sysName = "";
    private String sysOID = "";
    private String sysOIDString = "";
    private String sysDescr = "";
    private String vendor = "";
    private List<DeviceInterface> interfaces;

    private int deviceId = -1;
    private String adapterId;
    private Set<RoutingNeighbor> routingNeighbors;
    private Set<XdpEntry> discoveryProtocolEntries;
    private Set<MacTableEntry> macTable;
    private Set<ArpEntry> arpTable;

    /**
     * Default constructor.
     */
    public DiscoveryEvent()
    {
        this(null);
    }

    /**
     * Constructor.
     *
     * @param address an IP address
     */
    public DiscoveryEvent(IPAddress address)
    {
        this.address = address;
        this.interfaces = new ArrayList<DeviceInterface>();
        this.routingNeighbors = new HashSet<RoutingNeighbor>();
        this.discoveryProtocolEntries = new HashSet<XdpEntry>();
        this.arpTable = new HashSet<ArpEntry>();
        this.macTable = new HashSet<MacTableEntry>();
    }

    /**
     * @return the address
     */
    public IPAddress getAddress()
    {
        return address;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        StringBuilder event = new StringBuilder();
        event.append(address + " (" + sysName + ") | " + sysOID);
        return event.toString();
    }

    /**
     * This is most like the sysName attribute retrieved via SNMP
     * 
     * @param sysName the system name to set
     */
    public void setSysName(String sysName)
    {
        this.sysName = sysName;
    }

    /**
     * This is most like the sysName attribute retrieved via SNMP
     * 
     * @return the system name
     */
    public String getSysName()
    {
        return sysName;
    }

    /**
     * This is most likely the sysDescription as retrieved via SNMP. If SNMP was
     * unavailable this could also be populated with data from a CLI, e.g. "show
     * version" information on an IOS device.
     * 
     * @return the sysDescr
     */
    public String getSysDescr()
    {
        return sysDescr;
    }

    /**
     * This is most likely the sysDescription as retrieved via SNMP. If SNMP was
     * unavailable this could also be populated with data from a CLI, e.g. "show
     * version" information on an IOS device.
     * 
     * @param sysDescr the sysDescr to set
     */
    public void setSysDescr(String sysDescr)
    {
        this.sysDescr = sysDescr;
    }

    /**
     * This is the raw OID value of the device. e.g. 1.3.1.1.1.1.1
     * 
     * @return the sysOID
     */
    public String getSysOID()
    {
        return sysOID;
    }

    /**
     * This is the raw OID value of the device. e.g. 1.3.1.1.1.1.1
     * 
     * @param sysOID the sysOID to set
     */
    public void setSysOID(String sysOID)
    {
        this.sysOID = sysOID;
    }

    /**
     * This value should be the resolved value according to some MIB. This would
     * indicate a device's model name/number usually.
     * 
     * @return the sysOIDString
     */
    public String getSysOIDString()
    {
        return sysOIDString;
    }

    /**
     * This value should be the resolved value according to some MIB. This would
     * indicate a device's model name/number usually.
     * 
     * @param sysOIDString the sysOIDString to set
     */
    public void setSysOIDString(String sysOIDString)
    {
        this.sysOIDString = sysOIDString;
    }

    /**
     * The name of the vendor. e.g. 'Foundry'.
     * 
     * @return the vendor
     */
    public String getVendor()
    {
        return vendor;
    }

    /**
     * The name of the vendor. e.g. 'Foundry'.
     * 
     * @param vendor the vendor to set
     */
    public void setVendor(String vendor)
    {
        this.vendor = vendor;
    }

    /**
     * @param address the address to set
     */
    public void setAddress(IPAddress address)
    {
        this.address = address;
    }

    /**
     * The {@link DiscoveryEngine} asks if an IP is in the inventory. This
     * boolean indicates the result of that query as a helper to anybody who is
     * using this event so they don't have to ask themselves.
     * 
     * @return the inInventory
     */
    public boolean isInInventory()
    {
        return (deviceId >= 0);
    }

    /**
     * Contains interface information that was learned through SNMP.
     * 
     * @param interfaces the interfaces
     */
    public void setInterfaces(List<DeviceInterface> interfaces)
    {
        this.interfaces = interfaces;
    }

    /**
     * @return the interfaces
     */
    public List<DeviceInterface> getInterfaces()
    {
        return interfaces;
    }

    /**
     * If the <code>DiscoveryConfig</code> allows crawling of the network,
     * this value will be consulted to determine if this specific discovery
     * should extend or not.
     * 
     * @return the extendUsingNeighbors
     */
    public boolean isExtendUsingNeighbors()
    {
        return extendUsingNeighbors;
    }

    /**
     * If the <code>DiscoveryConfig</code> allows crawling of the network,
     * this value will be consulted to determine if this specific discovery
     * should extend or not.
     * 
     * @param extendUsingNeighbors the extendUsingNeighbors to set
     */
    public void setExtendUsingNeighbors(boolean extendUsingNeighbors)
    {
        this.extendUsingNeighbors = extendUsingNeighbors;
    }

    /**
     * Returns 'true' if this event contains relavent data about the host.  If false, most likely you'll just get an empty {@link DiscoveryEvent}.
     * @return the goodEvent
     */
    public boolean isGoodEvent()
    {
        return goodEvent;
    }

    /**
     * @param goodEvent the goodEvent to set
     */
    public void setGoodEvent(boolean goodEvent)
    {
        this.goodEvent = goodEvent;
    }

    /**
     * @return the deviceId
     */
    public int getDeviceId()
    {
        return deviceId;
    }

    /**
     * @param deviceId the deviceId to set
     */
    public void setDeviceId(int deviceId)
    {
        this.deviceId = deviceId;
    }

    /**
     * Returns a collection of all the {@link RoutingNeighbor} objects.
     * 
     * @return the routingNeighbors
     */
    public Set<RoutingNeighbor> getRoutingNeighbors()
    {
        return routingNeighbors;
    }

    /**
     * Set the entire route neighbors table
     * 
     * @param routingNeighbors the routingNeighbors to set
     */
    public void setRoutingNeighbors(Set<RoutingNeighbor> routingNeighbors)
    {
        this.routingNeighbors = routingNeighbors;
    }

    /**
     * Add a single {@link RoutingNeighbor}
     * 
     * @param neighbor the routing neighbor
     */
    public void addRoutingNeighbor(RoutingNeighbor neighbor)
    {
        routingNeighbors.add(neighbor);
    }

    /**
     * Adds an entry to the arp table
     * 
     * @param entry the ARP entry
     */
    public void addArpEntry(ArpEntry entry)
    {
        arpTable.add(entry);
    }

    /**
     * Sets the entire ARP table
     * 
     * @param arpTable the collection of ARP entries
     */
    public void setArpTable(Set<ArpEntry> arpTable)
    {
        this.arpTable = arpTable;
    }

    /**
     * Get the entire ARP table
     * 
     * @return the collection of ARP entriest
     */
    public Set<ArpEntry> getArpTable()
    {
        return arpTable;
    }

    /**
     * Add a CDP neighbor
     * 
     * @param xdpEntry the neighbor entry
     */
    public void addXdpNeighbor(XdpEntry xdpEntry)
    {
        discoveryProtocolEntries.add(xdpEntry);
    }

    /**
     * Returns the CDP neighbor data
     * 
     * @return the collection of neighbor entries
     */
    public Set<XdpEntry> getXdpNeighbors()
    {
        return discoveryProtocolEntries;
    }

    /**
     * Set the entire CDP neighbors table
     * 
     * @param xdpNeighbors the collection of neighbor entriese
     */
    public void setXdpNeighbors(Set<XdpEntry> xdpNeighbors)
    {
        this.discoveryProtocolEntries = xdpNeighbors;
    }

    /**
     * The MAC table is comprised of a series of {@link MacTableEntry} objects
     * that show the MAC-to-port mapping of a switch.
     * 
     * @return the macTable
     */
    public Set<MacTableEntry> getMacTable()
    {
        return macTable;
    }

    /**
     * @param macTable the macTable to set
     */
    public void setMacTable(Set<MacTableEntry> macTable)
    {
        this.macTable = macTable;
    }

    /**
     * 
     * @param macTableEntry the mac table entry
     */
    public void addMacTableEntry(MacTableEntry macTableEntry)
    {
        this.macTable.add(macTableEntry);
    }

    /**
     * @return the adapterId
     */
    public String getAdapterId()
    {
        return adapterId;
    }

    /**
     * @param adapterId the adapterId to set
     */
    public void setAdapterId(String adapterId)
    {
        this.adapterId = adapterId;
    }

}
