/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2005
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/04 15:36:00 $
 * $Revision: 1.3 $
 *  $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/DiscoveryConfigTest.java,v $
 */

package org.ziptie.discovery;

import junit.framework.TestCase;

import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.IPRange;
import org.ziptie.addressing.NetworkAddress;
import org.ziptie.addressing.Subnet;

/**
 * Test out reading and writing to the discoveryConfig
 */
public class DiscoveryConfigTest extends TestCase
{

    /**
     * Boundaries can't be duplicated
     * @throws Exception when bad stuff happens
     */
    public void testDuplicateBoundary() throws Exception
    {
        DiscoveryConfig dc = new DiscoveryConfig();
        try
        {
            AddressSet boundry = new AddressSet();
            NetworkAddress bn1 = new Subnet(new IPAddress("10.10.10.1"), new Short("24"));
            NetworkAddress bn2 = new Subnet(new IPAddress("10.10.10.1"), new Short("24"));
            NetworkAddress bn3 = new IPAddress("10.10.10.1");
            NetworkAddress bn4 = new IPRange("192.168.1.0", "192.168.1.200");
            NetworkAddress bn5 = new IPAddress("192.168.1.100");

            boundry.add(bn1);
            boundry.add(bn1);
            boundry.add(bn1);
            boundry.add(bn1);
            boundry.add(bn2);
            boundry.add(bn3);
            boundry.add(bn4);
            boundry.add(bn5);

            dc.setBoundaryNetworks(boundry);

            assertEquals(4, dc.getBoundaryNetworks().size());
            boundry.remove(bn1);
            dc.setBoundaryNetworks(boundry);
            assertEquals(3, dc.getBoundaryNetworks().size());
            boundry.remove(bn5);
            dc.setBoundaryNetworks(boundry);
            assertEquals(2, dc.getBoundaryNetworks().size());

        }
        catch (Exception e)
        {
            throw e;
        }

    }

    /**
     * set up the ping pieces
     *
     */
    public void testSetPingConfigs()
    {
        DiscoveryConfig dc = new DiscoveryConfig();
        dc.setPingCount(59);
        assertEquals(59, dc.getPingCount());

        dc.setPingTimeout(20000);
        assertEquals(20000, dc.getPingTimeout());

        dc.setPingSize(256);
        assertEquals(256, dc.getPingSize());
    }

    /**
     * 
     *
     */
    public void testSetGlobals()
    {
        DiscoveryConfig dc = new DiscoveryConfig();
        dc.setDiscoverNeighbors(true);
        assertTrue(dc.isDiscoverNeighbors());

        dc.setPingSize(35);
        assertEquals(35, dc.getPingSize());

        assertTrue(dc.isPollARP());
        dc.setPollARP(false);
        assertFalse(dc.isPollARP());
    }

    /**
     * The DiscoveryConfig has an indicator for how long to wait in between each time the discovery cache is cleared.  
     * The default should be 1 day (1440 minutes)
     *
     */
    public void testClearCacheDelay()
    {
        DiscoveryConfig dc = new DiscoveryConfig();
        assertEquals(10080, dc.getClearCacheDelayMinutes()); // default
        dc.setClearCacheDelayMinutes(100);
        assertEquals(100, dc.getClearCacheDelayMinutes()); // default
    }

    /**
     * 
     *
     */
    public void testRoutingOptions()
    {
        DiscoveryConfig dc = new DiscoveryConfig();

        // defaults
        assertTrue(dc.isPollRoutingNeighbors());

        dc.setPollRoutingNeighbors(false);
        assertFalse(dc.isPollRoutingNeighbors());
    }

    /**
     * 
     */
    public void testEqualsAndHashCode()
    {
        AddressSet testAddrs = new AddressSet();
        testAddrs.add(new IPAddress("10.100.10.0"));

        DiscoveryConfig dc1 = new DiscoveryConfig();
        assertFalse(dc1.equals(null));

        DiscoveryConfig dc2 = new DiscoveryConfig();

        assertEquals(dc1, dc2);
        assertEquals(dc1.hashCode(), dc2.hashCode());

        dc1.setPingSize(15);
        assertFalse(dc1.equals(dc2));
        assertTrue(dc1.hashCode() != dc2.hashCode());
        dc2.setPingSize(15);
        assertEquals(dc1, dc2);
        assertEquals(dc1.hashCode(), dc2.hashCode());

        dc1.setDiscoverNeighbors(true);
        dc2.setDiscoverNeighbors(false);
        assertFalse(dc1.equals(dc2));
        assertTrue(dc1.hashCode() != dc2.hashCode());
        dc2.setDiscoverNeighbors(true);
        assertEquals(dc1, dc2);
        assertEquals(dc1.hashCode(), dc2.hashCode());

        dc1.setPingCount(6);
        dc2.setPingCount(5460);
        assertFalse(dc1.equals(dc2));
        assertTrue(dc1.hashCode() != dc2.hashCode());
        dc2.setPingCount(6);
        assertEquals(dc1, dc2);
        assertEquals(dc1.hashCode(), dc2.hashCode());

        dc1.setPingTimeout(6);
        dc2.setPingTimeout(5460);
        assertFalse(dc1.equals(dc2));
        assertTrue(dc1.hashCode() != dc2.hashCode());
        dc2.setPingTimeout(6);
        assertEquals(dc1, dc2);
        assertEquals(dc1.hashCode(), dc2.hashCode());

        dc1.setPollARP(true);
        dc2.setPollARP(false);
        assertFalse(dc1.equals(dc2));
        assertTrue(dc1.hashCode() != dc2.hashCode());
        dc2.setPollARP(true);
        assertEquals(dc1, dc2);
        assertEquals(dc1.hashCode(), dc2.hashCode());
    }

    /**
     * 
     *
     */
    public void testPoolSizes()
    {
        DiscoveryConfig dc1 = new DiscoveryConfig();
        dc1.setMasterThreads(5);
        assertEquals(5, dc1.getMasterThreads());
    }

    /**
     * 
     *
     */
    public void testInitialization()
    {
        DiscoveryConfig config = new DiscoveryConfig();
        assertNotNull(config.getBoundaryNetworks());
        assertNotNull(config.getExclusions());
    }

}

// ------------------------------------------------- 
// $Log: DiscoveryTest.java 
// $Revision 1.1 Jun 9, 2005 rkruse 
// $Code Templates 
// $ 
// --------------------------------------------------