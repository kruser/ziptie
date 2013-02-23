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
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */



package org.ziptie.protocols;

import java.util.LinkedList;
import java.util.List;

import junit.framework.TestCase;

/**
 * Test class to tests the functionality of the <code>org.ziptie.protocols.Protocol</code> class.
 * 
 * @author dwhite
 */
public class ProtocolTest extends TestCase
{
    private Protocol protocol;

    private static final String NAME = "Telnet";

    private static final int PORT = 23;

    private static final int PRIORITY = 1;

    private List<ProtocolProperty> PROPERTIES;

    private static final String[] KEYS = { "testKey1", "testKey2", "testKey3" };

    private static final String[] VALUES = { "testValue1", "testValue2", "testValue3" };

    /**
     * Set up the testing framework for a new test by creating a new <code>Protocol</code>.
     * 
     * @see junit.framework.TestCase#setUp()
     */
    @Override
    public void setUp()
    {
        protocol = new Protocol(NAME, PORT, PRIORITY, true);
        PROPERTIES = new LinkedList<ProtocolProperty>();
        for (int i = 0; i < KEYS.length; i++)
        {
            PROPERTIES.add(new ProtocolProperty(KEYS[i], VALUES[i]));
        }
        protocol.setProperties(PROPERTIES);
    }

    /**
     * Test creating a new <code>Protocol</code>.
     * 
     */
    public void testCreateProtocol()
    {
        Protocol tempProtocol = new Protocol();
        assertNotNull(tempProtocol);
    }

    /**
     * Test retrieveing the name of a <code>Protocol</code>.
     * 
     */
    public void testGetName()
    {
        assertEquals(NAME, protocol.getName());
    }

    /**
     * Test setting the name of a <code>Protocol</code>.
     * 
     */
    public void testSetName()
    {
        final String tempName = "bogusProtocol";
        protocol.setName(tempName);
        assertEquals(tempName, protocol.getName());
    }

    /**
     * Test retrieving the port value of <code>Protocol</code>.
     * 
     */
    public void testGetPort()
    {
        assertEquals(PORT, protocol.getPort());
    }

    /**
     * Test setting the port value of a <code>Protocol</code>.
     * 
     */
    public void testSetPort()
    {
        final int tempPort = 999;
        protocol.setPort(tempPort);
        assertEquals(tempPort, protocol.getPort());
    }

    /**
     * Test retrieving the priority value of <code>Protocol</code>.
     * 
     */
    public void testGetPriority()
    {
        assertEquals(PRIORITY, protocol.getPriority());
    }

    /**
     * Test setting the priority value of a <code>Protocol</code>.
     * 
     */
    public void testSetPriority()
    {
        final int tempPriority = 1234567;
        protocol.setPriority(tempPriority);
        assertEquals(tempPriority, protocol.getPriority());
    }

    /**
     * Test retrieving the a property value of a <code>Protocol</code>.
     * 
     */
    public void testGetProperty()
    {
        for (int i = 0; i < KEYS.length; i++)
        {
            assertEquals(VALUES[i], protocol.getProperty(KEYS[i]));
        }
    }

    /**
     * Test setting a property on a <code>Protocol</code>.
     * 
     */
    public void testSetProperty()
    {
        String tempKey = "someRandomKey";
        String tempValue = "someRandomValue";
        protocol.setProperty(tempKey, tempValue);
        assertEquals(tempValue, protocol.getProperty(tempKey));
    }

    /**
     * Test retrieving the entire property <code>HashMap</code> from a <code>Protocol</code>.
     * 
     */
    public void testGetProperties()
    {
        assertEquals(PROPERTIES, protocol.getProperties());
        Protocol testProtocol = new Protocol();
        assertNotNull(testProtocol.getProperties());
        assertEquals(0, testProtocol.getProperties().size());
    }

    /**
     * Test setting the <code>HashMap</code> containing all the properties for a <code>Protocol</code>.
     * 
     */
    public void testSetProperties()
    {
        List<ProtocolProperty> tempList = new LinkedList<ProtocolProperty>();
        tempList.add(new ProtocolProperty("newKey", "newValue"));
        protocol.setProperties(tempList);
        assertEquals(tempList, protocol.getProperties());
        assertFalse(PROPERTIES.equals(protocol.getProperties()));
    }

    /**
     * Test whether another <code>Protocol</code> object is equal to this <code>Protocol</code> object. Two
     * <code>Protocol</code> objects are equal if their names, port values and priority values match.
     * 
     */
    public void testEquals()
    {
        String testName = "iThinkItCouldBeBig";
        int testPort = 5309;
        int testPriority = 867;

        Protocol other = new Protocol(testName, testPort, testPriority, false);
        assertFalse(protocol.equals(other));
        assertFalse(other.equals(protocol));
        assertFalse(other.isTCP());

        other.setName(NAME);
        assertFalse(protocol.equals(other));
        assertFalse(other.equals(protocol));

        other.setPort(PORT);
        assertFalse(protocol.equals(other));
        assertFalse(other.equals(protocol));

        other.setPriority(PRIORITY);
        assertEquals(protocol, other);
        assertEquals(other, protocol);
    }

    public void testComparable()
    {
        Protocol one = new Protocol("one", 23, 1, true);
        Protocol two = new Protocol("two", 22, 2, true);
        assertEquals(-1, one.compareTo(two));
    }

    public void testBadCompare()
    {
        Protocol one = new Protocol("one", 23, 1, true);
        try
        {
            one.compareTo(Integer.valueOf(5));
            fail("This should throw a ClassCastException");
        }
        catch (ClassCastException cce)
        {
            assertTrue(true);
        }

    }
    
    public void testEnabled()
    {
        Protocol one = new Protocol("tftp", 69, 33, false);
        assertTrue(one.isEnabled());
        
        one.setEnabled(false);
        assertFalse(one.isEnabled());
    }
    
    public void testIsTCP()
    {
        Protocol one = new Protocol("tftp", 69, 33, false);
        assertFalse(one.isTCP());
        one.setTCP(true);
        assertTrue(one.isTCP());
    }
    
    public void testConstructors()
    {
        Protocol one = new Protocol("SSH", 22, 1, true, false);
        assertFalse(one.isEnabled());
        
        Protocol two = new Protocol("SSH", 22, 1, true, true);
        assertTrue(two.isEnabled());
    }

    /**
     * Tear down the test framework so a new test can run. This simply cleans out out test <code>Protocol</code>
     * object by setting it to <i>null</i>.
     * 
     * @see junit.framework.TestCase#tearDown()
     */
    @Override
    public void tearDown()
    {
        protocol = null;
        PROPERTIES = null;
    }
}

// -------------------------------------------------
// $Log: ProtocolTest.java,v $
// Revision 1.11  2007/08/28 20:50:05  dwhite
// A Protocol object no longer contains a Map of String/String properties.  It contains a list of ProtocolProperty objects that represent all of the possible properties.
//
// Revision 1.10  2007/04/04 16:13:30  brettw
// Eclipse recommended cleanup
//
// Revision 1.9  2007/03/15 00:57:03  brettw
// FindBugs: efficiency suggestions
//
// Revision 1.8  2007/03/06 17:35:50  rkruse
// merge in the latest protocol manager code
//
// Revision 1.4  2006/11/03 22:02:42  Rkruse
// merging from ziptie
//
// Revision 1.6  2006/11/02 02:00:37  lbayer
// new improved license headers
//
// Revision 1.5  2006/11/02 00:57:21  lbayer
// apply ziptie license header to all java files
//
// Revision 1.4  2006/10/31 21:31:26  rkruse
// add some toStrings, disable ssh, tftp, ftp and scp OOTB
//
// Revision 1.3  2006/10/20 22:56:37  rkruse
// merging from hammerhead
//
// Revision 1.3  2006/10/18 20:02:09  Rkruse
// add security mechanism and tcp port scanning to the protocol manager
//
// Revision 1.2  2006/10/17 23:29:22  Rkruse
// ProtocolManager using ziptie Protocols
//
// Revision 1.1 2006/10/16 21:52:50 Rkruse
// moving from the NIL
//
// Revision 1.1 2006/10/13 19:58:31 Dwhite
// Merging NIL specific Credential and Protocol objects from Ziptie into Hammerhead.
//
// Revision 1.1 2006/10/13 16:45:42 dwhite
// Unit test to test the functionality of the com.alterpoint.net.credentials.Protocol object.
//
// Revision 1.0 Oct 12, 2006 dwhite
// Initial revision
// --------------------------------------------------
