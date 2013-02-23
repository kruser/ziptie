/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/04 15:36:00 $
 * $Revision: 1.2 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/RoutingNeighborTest.java,v $e
 */

package org.ziptie.discovery;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;
import org.ziptie.discovery.RoutingNeighbor.RoutingProtocol;

/**
 * @author rkruse
 */
public class RoutingNeighborTest extends TestCase
{
    public void testConstructor()
    {
        RoutingNeighbor rn = new RoutingNeighbor(new IPAddress("10.100.4.8"), RoutingProtocol.EIGRP);
        assertEquals("EIGRP", rn.getRoutingProtocol().name());
        assertEquals("10.100.4.8", rn.getIpAddress().getIPAddress());
    }
    
    public void testIfName()
    {
        RoutingNeighbor rn = new RoutingNeighbor(new IPAddress("10.100.4.8"));
        assertEquals("", rn.getIfName());
        rn.setIfName("GigabitEthernet0/1");
        assertEquals("GigabitEthernet0/1", rn.getIfName());
    }
    
    public void testToStringAndHashcode()
    {
        RoutingNeighbor rn1 = new RoutingNeighbor(new IPAddress("10.100.4.8"));
        RoutingNeighbor rn2 = new RoutingNeighbor(new IPAddress("10.100.4.8"));
        RoutingNeighbor rn3 = new RoutingNeighbor(new IPAddress("99.99.99.99"));
        
        assertEquals(rn1, rn2);
        assertFalse(rn1.equals(rn3));
        
        rn2.setIfName("something");
        assertFalse(rn1.equals(rn2));
        assertFalse(rn1.hashCode() == rn2.hashCode());
        rn1.setIfName("something");
        assertEquals(rn1, rn2);
        assertEquals(rn1.hashCode(), rn2.hashCode());
        
        rn1.setRoutingProtocol(RoutingProtocol.ISIS);
        assertFalse(rn1.equals(rn2));
        assertFalse(rn1.hashCode() == rn2.hashCode());
    }
    
    /**
     * make sure there are no exception
     */
    public void testToString()
    {
        RoutingNeighbor rn1 = new RoutingNeighbor(new IPAddress("10.100.4.8"));
        rn1.setIfName("Serial0");
        System.out.println(rn1.toString());
    }
}
