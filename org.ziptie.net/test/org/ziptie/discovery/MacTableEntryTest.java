/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/04 15:36:00 $
 * $Revision: 1.2 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/MacTableEntryTest.java,v $e
 */

package org.ziptie.discovery;

import org.ziptie.addressing.MACAddress;

import junit.framework.TestCase;

/**
 * Tests for the MacTableEntry Class
 * @author rkruse
 */
public class MacTableEntryTest extends TestCase
{
    public void testNew()
    {
       MacTableEntry entry = new MacTableEntry(new MACAddress("abcdefabcdef")); 
       assertEquals("AB-CD-EF-AB-CD-EF", entry.getMacAddress().getMACAddress());
    }
    
    public void testIfName()
    {
       MacTableEntry entry = new MacTableEntry(new MACAddress("abcdefabcdef")); 
       assertEquals("", entry.getInterfaceName());
       entry.setInterfaceName("ethernet0");
       assertEquals("ethernet0", entry.getInterfaceName());
       
       // don't allow nulls
       entry.setInterfaceName(null);
       assertEquals("ethernet0", entry.getInterfaceName());
    }
    
    public void testEquals()
    {
       MacTableEntry entry1 = new MacTableEntry(new MACAddress("abcdefabcdef")); 
       MacTableEntry entry2 = new MacTableEntry(new MACAddress("abcdefabcdef")); 
       assertEquals(entry1, entry2);
    }
    
    public void testToString()
    {
       MacTableEntry entry = new MacTableEntry(new MACAddress("abcdefabcdef")); 
       entry.setInterfaceName("ethernet0");
       System.out.println("MAC TABLE ENTRY: " + entry);
    }
    
    public void testVlan()
    {
       MacTableEntry entry1 = new MacTableEntry(new MACAddress("abcdefabcdef")); 
       assertEquals("", entry1.getVlan());
       entry1.setVlan("1");
       assertEquals("1", entry1.getVlan());
    }
}

// -------------------------------------------------
// $Log: MacTableEntryTest.java,v $
// Revision 1.2  2008/08/04 15:36:00  rkruse
// remove unnecessary Neighbors object and markup the rest for persistence
//
// Revision 1.1  2007/03/29 20:57:32  rkruse
// adding the discovery tests
//
// Revision 1.2  2007/01/27 21:39:09  Rkruse
// add vlan string....not populating yet
//
// Revision 1.1  2006/12/18 19:42:35  Rkruse
// populate the mac address table (mac to port)
//
// Revision 1.0 Dec 18, 2006 rkruse
// Initial revision
// --------------------------------------------------
