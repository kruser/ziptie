/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/07/09 19:27:07 $
 * $Revision: 1.2 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/XdpEntryTest.java,v $e
 */

package org.ziptie.discovery;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;
import org.ziptie.discovery.XdpEntry.XdpTypes;

/**
 * Tests out the <code>XdpEntry</code> class.
 * 
 * @author rkruse
 */
public class XdpEntryTest extends TestCase
{
    public void testNew()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        assertEquals("CDP", entry.getType());
    }

    public void testIP()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        assertNull(entry.getIpAddress());
        entry.setIpAddress(new IPAddress("10.100.15.1"));
        assertEquals("10.100.15.1", entry.getIpAddress().getIPAddress());
    }

    public void testSysDescr()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.EDP);
        assertEquals("EDP", entry.getType());
        assertEquals("", entry.getSysDescr());
        entry.setSysDescr("Extreme XOS");
        assertEquals("Extreme XOS", entry.getSysDescr());
    }

    public void testSysName()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        assertEquals("", entry.getSysName());
        entry.setSysName("kruse-rtr.alterpoint.com");
        assertEquals("kruse-rtr.alterpoint.com", entry.getSysName());
    }

    public void testInterfaceName()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        assertEquals("", entry.getInterfaceName());
        entry.setInterfaceName("Ethernet0/0");
        assertEquals("Ethernet0/0", entry.getInterfaceName());
    }

    public void testPlatform()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        assertEquals("", entry.getPlatform());
        entry.setPlatform("cisco WS-C3750-24P");
        assertEquals("cisco WS-C3750-24P", entry.getPlatform());
    }

    public void testLocalIfName()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        assertEquals("", entry.getLocalIfName());
        entry.setLocalIfName("eth0");
        assertEquals("eth0", entry.getLocalIfName());

        // doesn't all null to be set
        entry.setLocalIfName(null);
        assertEquals("eth0", entry.getLocalIfName());
    }

    public void testSysOid()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        assertEquals("", entry.getSysOid());
        entry.setSysOid("1.2.3.4.5.6.7");
        assertEquals("1.2.3.4.5.6.7", entry.getSysOid());
    }

    /**
     * Hashcode is built with the IP only.
     * 
     * Equals is built with the IP, ifName and ifIndex
     * 
     */
    public void testEqualsAndHashCode()
    {
        XdpEntry entry1 = new XdpEntry(XdpTypes.CDP);
        XdpEntry entry2 = new XdpEntry(XdpTypes.CDP);
        assertEquals(entry1, entry2);
        assertEquals(entry1.hashCode(), entry2.hashCode());

        entry1.setIpAddress(new IPAddress("10.10.1.1"));
        assertFalse(entry1.equals(entry2));
        assertFalse(entry1.hashCode() == entry2.hashCode());

        entry2.setIpAddress(new IPAddress("10.10.1.1"));
        assertEquals(entry1, entry2);
        assertEquals(entry1.hashCode(), entry2.hashCode());

        entry1.setSysDescr("Something that doesn't matter to the equals");
        assertEquals(entry1, entry2);
        assertEquals(entry1.hashCode(), entry2.hashCode());

        entry1.setInterfaceName("eth0");
        assertFalse(entry1.equals(entry2));
        assertEquals(entry1.hashCode(), entry2.hashCode());

        entry2.setInterfaceName("eth0");
        assertEquals(entry1, entry2);

        // this doesn't change anything
        entry1.setSysOid("1.2.3");
        assertEquals(entry1, entry2);
    }

    public void testToString()
    {
        XdpEntry entry = new XdpEntry(XdpTypes.CDP);
        entry.setIpAddress(new IPAddress("10.100.15.1"));
        entry.setInterfaceName("Ethernet0/0");
        entry.setLocalIfName("FastEthernet0/1");
        System.out.print(entry.toString());
    }
}

// -------------------------------------------------
// $Log: XdpEntryTest.java,v $
// Revision 1.2  2008/07/09 19:27:07  rkruse
// remove ifIndex field
//
// Revision 1.1  2007/03/29 20:57:32  rkruse
// adding the discovery tests
//
// Revision 1.5  2007/01/22 04:55:21  Rkruse
// Utilize CDP data when SNMP isn't available
//
// Revision 1.4 2006/12/18 19:42:02 Rkruse
// solidified the types
//
// Revision 1.3 2006/12/17 21:51:46 Rkruse
// Fill out CDP and ARP entries
//
// Revision 1.2 2006/12/14 19:44:25 Rkruse
// new equals, hashcode, tostring
//
// Revision 1.1 2006/12/12 02:02:15 Rkruse
// to be used for full CDP info
//
// Revision 1.0 Dec 11, 2006 rkruse
// Initial revision
// --------------------------------------------------
