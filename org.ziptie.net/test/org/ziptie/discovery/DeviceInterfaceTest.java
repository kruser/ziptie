/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/07/09 19:27:24 $
 * $Revision: 1.1 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/DeviceInterfaceTest.java,v $e
 */

package org.ziptie.discovery;

import org.ziptie.addressing.IPAddress;

import junit.framework.TestCase;

/**
 * Tests the SnmpIPInterface class
 * 
 * @author rkruse
 */
public class DeviceInterfaceTest extends TestCase
{
    /**
     * The lower IP'd loopback should come first
     * 
     */
    public void testTwoLoopbacks()
    {
        DeviceInterface snmpInterface1 = new DeviceInterface();
        snmpInterface1.setIfType("softwareLoopback");
        snmpInterface1.setName("int1");
        snmpInterface1.addIPAddress(new IPAddress("99.1.1.1"));

        DeviceInterface snmpInterface2 = new DeviceInterface();
        snmpInterface2.setIfType("softwareLoopback");
        snmpInterface1.setName("int2");
        snmpInterface2.addIPAddress(new IPAddress("77.1.1.1"));

        assertTrue(snmpInterface1.compareTo(snmpInterface2) > 0);
        assertTrue(snmpInterface2.compareTo(snmpInterface1) < 0);
        assertTrue(snmpInterface1.compareTo(snmpInterface1) == 0);

        // check out the equals
        DeviceInterface snmpInterface3 = new DeviceInterface();
        snmpInterface3.setIfType("softwareLoopback");
        snmpInterface3.addIPAddress(new IPAddress("77.1.1.1"));
        assertFalse(snmpInterface1.equals(snmpInterface2));
        assertEquals(snmpInterface2, snmpInterface3);
        assertEquals(snmpInterface2.hashCode(), snmpInterface3.hashCode());

    }

    /**
     * The non-loopback should be greater than the loopback
     * 
     */
    public void testOneLoopback()
    {
        DeviceInterface loopback = new DeviceInterface();
        loopback.setIfType("softwareLoopback");
        loopback.addIPAddress(new IPAddress("99.1.1.1"));

        DeviceInterface ethernet = new DeviceInterface();
        ethernet.setIfType("other");
        ethernet.addIPAddress(new IPAddress("77.1.1.1"));

        assertTrue(loopback.compareTo(ethernet) < 0);
        assertTrue(ethernet.compareTo(loopback) > 0);
        assertTrue(ethernet.compareTo(ethernet) == 0);
    }

    public void testOperStatus()
    {
        DeviceInterface int1 = new DeviceInterface();
        assertFalse(int1.isInterfaceUp());
        int1.setIfOperStatus("Up");
        assertTrue(int1.isInterfaceUp());
    }
    
    public void testSubnets()
    {
        DeviceInterface int1 = new DeviceInterface();
        assertEquals(0, int1.getSubnets().size());
    }
}

// -------------------------------------------------
// $Log: DeviceInterfaceTest.java,v $
// Revision 1.1  2008/07/09 19:27:24  rkruse
// renamed
//
// Revision 1.1  2007/03/29 20:57:32  rkruse
// adding the discovery tests
//
// Revision 1.2  2007/02/07 22:18:12  Rkruse
// populate OSPF neighbor local interface names
//
// Revision 1.1  2007/01/26 20:57:06  Rkruse
// rename
//
// Revision 1.2 2006/12/27 17:02:46 Rkruse
// sweep subnets found on device interfaces
//
// Revision 1.1 2006/12/04 19:16:24 Rkruse
// algorithm for determining adminIP
//
// Revision 1.0 Dec 1, 2006 rkruse
// Initial revision
// --------------------------------------------------
