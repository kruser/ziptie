/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/04 15:36:00 $
 * $Revision: 1.4 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/DiscoveryEventTest.java,v $e
 */

package org.ziptie.discovery;

import java.util.HashSet;
import java.util.Set;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.MACAddress;
import org.ziptie.discovery.RoutingNeighbor.RoutingProtocol;
import org.ziptie.discovery.XdpEntry.XdpTypes;
import org.ziptie.exception.NonContiguousSubnetMask;

/**
 * @author rkruse
 */
public class DiscoveryEventTest extends TestCase
{

    /**
     * @see junit.framework.TestCase#setUp()
     */
    protected void setUp() throws Exception
    {
        super.setUp();
    }

    /**
     * 
     *
     */
    public void testNewEvent()
    {
        DiscoveryEvent event1 = new DiscoveryEvent(new IPAddress("10.100.15.3"));
        assertEquals("10.100.15.3", event1.getAddress().getIPAddress());
    }

    /**
     * 
     *
     */
    public void testSysDetails() 
    {
        DiscoveryEvent event1 = new DiscoveryEvent(new IPAddress("10.100.15.3"));
        event1.setSysName("cisco2610");
        assertEquals("cisco2610", event1.getSysName());

        event1.setSysDescr("Cisco IOS blah blah blah");
        assertEquals("Cisco IOS blah blah blah", event1.getSysDescr());

        event1.setSysOID("1.2.3.4.5.6");
        assertEquals("1.2.3.4.5.6", event1.getSysOID());

        event1.setSysOIDString("C2610");
        assertEquals("C2610", event1.getSysOIDString());

        event1.setVendor("Nortel");
        assertEquals("Nortel", event1.getVendor());
    }
    
    /**
     * 
     *
     */
    public void testToString() 
    {
        DiscoveryEvent event1 = new DiscoveryEvent(new IPAddress("10.100.15.3"));
        assertTrue(event1.toString().contains("10.100.15.3"));
    }

    /**
     * 
     *
     */
    public void testInInventory()
    {
        DiscoveryEvent event = new DiscoveryEvent(new IPAddress("10.100.15.3"));
        assertFalse(event.isInInventory());
        event.setDeviceId(213);
        assertTrue(event.isInInventory());
    }
    
    /**
     * A network device should have a routing table if it is forwarding
     * @throws NonContiguousSubnetMask 
     * @throws IllegalArgumentException 
     *
     */
    public void testRoutingNeighbors() throws IllegalArgumentException, NonContiguousSubnetMask
    {
        DiscoveryEvent neighbors = new DiscoveryEvent(new IPAddress("10.100.4.8"));
        // Shouldn't allow duplicates like this
        neighbors.addRoutingNeighbor(new RoutingNeighbor(new IPAddress("10.100.1.4"), RoutingProtocol.EIGRP));
        neighbors.addRoutingNeighbor(new RoutingNeighbor(new IPAddress("10.100.1.4"), RoutingProtocol.EIGRP));
        
        assertEquals(1, neighbors.getRoutingNeighbors().size());
        assertEquals("10.100.4.8", neighbors.getAddress().getIPAddress());
        System.out.println(neighbors.toString());
    }
    
    public void testArpTable()
    {
        DiscoveryEvent neighbors = new DiscoveryEvent(new IPAddress("10.100.4.8"));
        neighbors.addArpEntry(new ArpEntry(new IPAddress("10.100.1.4"), new MACAddress("abc")));
        
        assertEquals(1, neighbors.getArpTable().size());
        for(ArpEntry entry : neighbors.getArpTable())
        {
            assertEquals("10.100.1.4", entry.getIpAddress().getIPAddress());
        }
        System.out.println(neighbors.toString());
    }
    
    public void testCdpNeighbors()
    {
        XdpEntry entry1 = new XdpEntry(XdpTypes.CDP);
        entry1.setIpAddress(new IPAddress("10.100.4.8"));
        
        DiscoveryEvent neighbors = new DiscoveryEvent(new IPAddress("10.100.4.8"));
        neighbors.addXdpNeighbor(entry1);
        assertEquals(1, neighbors.getXdpNeighbors().size());
        System.out.println(neighbors.toString());
    }
    
    public void testMacTable()
    {
        MacTableEntry entry = new MacTableEntry(new MACAddress("aabbccddeeff"));
        entry.setInterfaceName("eth0");
        DiscoveryEvent neighbors = new DiscoveryEvent(new IPAddress("10.100.15.4"));
        neighbors.addMacTableEntry(entry);
        assertEquals(1, neighbors.getMacTable().size());
        
        // set the whole thing
        Set<MacTableEntry> macTable = new HashSet<MacTableEntry>();
        macTable.add(entry);
        neighbors.setMacTable(macTable);
        assertEquals(1, neighbors.getMacTable().size());
        System.out.println(neighbors.toString());
    }
}