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
package org.ziptie.discovery;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.net.URL;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;

/**
 * DiscoveryEventParserTest
 */
public class DiscoveryEventParserTest extends TestCase
{

    /**
     * General test to transform the XML DiscoveryEvent to a DiscoveryEvent object and then verify the results
     * @throws FileNotFoundException 
     */
    public void testTransform() throws FileNotFoundException
    {
        URL resource = DiscoveryEventParserTest.class.getResource("discoveryEvent.xml");
        FileInputStream fis = new FileInputStream(resource.getFile());
        
        DiscoveryEventParser parser = new DiscoveryEventParser(fis);
        DiscoveryEvent event = parser.parseEvent();
        
        assertNotNull(event);
        assertEquals("10.100.20.210", event.getAddress().getIPAddress());
        assertEquals(".1.3.6.1.4.1.9.1.282", event.getSysOID());
        assertEquals("AUS-6506.krissy.org", event.getSysName());
        assertTrue(event.getSysDescr().contains("Cisco Internetwork Operating System Software"));
        
        // validate the interfaces
        assertEquals(102, event.getInterfaces().size());
        DeviceInterface deviceInterface = event.getInterfaces().get(5);
        IPAddress address = deviceInterface.getIPAddresses().get(0);
        assertEquals("10.100.20.93", address.getIPAddress());
        
        // validate the routing neighbors
        assertEquals(13, event.getRoutingNeighbors().size());
        
        // validate the CDP neighbors
        assertEquals(1, event.getXdpNeighbors().size());
        for(XdpEntry cdp : event.getXdpNeighbors())
        {
            // there is only one in here
            assertEquals("10.100.4.200", cdp.getIpAddress().getIPAddress());
            assertEquals("FastEthernet0/5", cdp.getInterfaceName());
            assertEquals("Ethernet0/0", cdp.getLocalIfName());
        }
        
        // validate the ARP table
        assertEquals(134, event.getArpTable().size());
        
        // validate the MAC table
        assertEquals(4, event.getMacTable().size());
    }

}
