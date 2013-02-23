/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/07/09 19:27:07 $
 * $Revision: 1.2 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/ArpEntryTest.java,v $e
 */

package org.ziptie.discovery;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.MACAddress;

/**
 * Test for the <code>ArpEntry</code> class
 *
 * @author rkruse
 */
public class ArpEntryTest extends TestCase
{
    public void testParams()
    {
        ArpEntry arpEntry = new ArpEntry(new IPAddress("10.100.4.8"), new MACAddress("abcdef123456"));

        assertEquals("10.100.4.8", arpEntry.getIpAddress().getIPAddress());
        assertEquals("AB-CD-EF-12-34-56", arpEntry.getMacAddress().getMACAddress());
    }

    /**
     * IP & MAC are the only fields used in the equals and hashcode
     */
    public void testEqualsAndHashCode()
    {
        ArpEntry arpEntry1 = new ArpEntry(new IPAddress("10.100.4.8"), new MACAddress("abcdef123456"));
        ArpEntry arpEntry2 = new ArpEntry(new IPAddress("10.100.4.8"), new MACAddress("abcdef123456"));
        assertEquals(arpEntry1, arpEntry2);

        arpEntry1.setInterfaceName("eth1/2");
        assertEquals(arpEntry1, arpEntry2);
        assertEquals(arpEntry1.hashCode(), arpEntry2.hashCode());

        arpEntry1.setMacAddress(new MACAddress("aaaaaaaaaaaa"));
        assertFalse(arpEntry1.equals(arpEntry2));
        assertTrue(arpEntry1.hashCode() != arpEntry2.hashCode());
    }

    public void testSimpleEntry()
    {
        ArpEntry entry = new ArpEntry(new IPAddress("10.100.4.8"), new MACAddress("abcdefabcdef"));
        assertEquals("10.100.4.8", entry.getIpAddress().getIPAddress());
        assertEquals("AB-CD-EF-AB-CD-EF", entry.getMacAddress().getMACAddress());
    }

    /**
     * Just verify there are no NPEs
     *
     */
    public void testToString()
    {
        ArpEntry arpEntry1 = new ArpEntry(new IPAddress("10.100.4.8"), new MACAddress("abcdef123456"));
        System.out.println(arpEntry1);
    }

}

// -------------------------------------------------
// $Log: ArpEntryTest.java,v $
// Revision 1.2  2008/07/09 19:27:07  rkruse
// remove ifIndex field
//
// Revision 1.1  2007/03/29 20:57:32  rkruse
// adding the discovery tests
//
// Revision 1.3  2006/12/11 17:03:00  Rkruse
// remove unused age field
//
// Revision 1.2  2006/12/05 17:08:45  MDessureault
// Fixed style issue to make eclipse happy.
//
// Revision 1.1  2006/12/04 19:16:43  Rkruse
// Neighbor discovery
//
// Revision 1.0 Dec 3, 2006 rkruse
// Initial revision
// --------------------------------------------------
