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



package org.ziptie.credentials;

import org.ziptie.credentials.Credential;

import junit.framework.TestCase;

/**
 * Test class to tests the functionality of the <code>org.ziptie.credentials.Credential</code> class.
 * @author dwhite
 */
public class CredentialTest extends TestCase
{
    private Credential credential;

    private static final String NAME = "username";

    private static final String VALUE = "secretValue";

    /**
     * Set up the testing framework for a new test by creating a new <code>Credential</code>.
     * 
     * @see junit.framework.TestCase#setUp()
     */
    @Override
    public void setUp()
    {
        credential = new Credential(NAME, VALUE);
    }

    /**
     * Test creating a new <code>Credential</code>.
     * 
     */
    public void testCreateCredential()
    {
        Credential tempCredential = new Credential();
        assertNotNull(tempCredential);
    }

    /**
     * Test retrieveing the name of a <code>Credential</code>.
     *
     */
    public void testGetName()
    {
        assertEquals(NAME, credential.getName());
    }

    /**
     * Test setting the name of a <code>Credential</code>.
     *
     */
    public void testSetName()
    {
        final String tempName = "somethingDifferent";
        credential.setName(tempName);
        assertEquals(tempName, credential.getName());
    }

    /**
     * Test retrieving the value of <code>Credential</code>.
     *
     */
    public void testGetValue()
    {
        assertEquals(VALUE, credential.getValue());
    }

    /**
     * Test setting the value of a <code>Credential</code>.
     *
     */
    public void testSetValue()
    {
        final String tempValue = "totallyRandomDude";
        credential.setValue(tempValue);
        assertEquals(tempValue, credential.getValue());
    }

    /**
     * Test whether another <code>Credential</code> object is equal to this <code>Credential</code> object.
     * Two <code>Credential</code> objects are equal if their names and values match.
     * 
     */
    public void testEquals()
    {
        String testName = "blahblah";
        String testValue = "shinji";

        Credential other = new Credential(testName, testValue);
        assertFalse(credential.equals(other));
        assertFalse(other.equals(credential));

        other.setName(NAME);
        assertFalse(credential.equals(other));
        assertFalse(other.equals(credential));

        other.setName(testName);
        other.setValue(VALUE);
        assertFalse(credential.equals(other));
        assertFalse(other.equals(credential));

        other.setName(NAME);
        assertEquals(credential, other);
        assertEquals(other, credential);
    }
    
    public void testToString()
    {
        Credential one = new Credential("username", "holiday");
        assertEquals("username(holiday)", one.toString());
    }

    /**
     * Tear down the test framework so a new test can run.  This simply cleans out out test <code>Credential</code>
     * object by setting it to <i>null</i>.
     * 
     * @see junit.framework.TestCase#tearDown()
     */
    @Override
    public void tearDown()
    {
        credential = null;
    }
}

// -------------------------------------------------
// $Log: CredentialTest.java,v $
// Revision 1.8  2007/04/04 16:13:30  brettw
// Eclipse recommended cleanup
//
// Revision 1.7  2007/03/06 17:34:16  rkruse
// Merge in the latest credentials code
//
// Revision 1.2  2006/11/03 22:02:43  Rkruse
// merging from ziptie
//
// Revision 1.5  2006/11/02 02:00:37  lbayer
// new improved license headers
//
// Revision 1.4  2006/11/02 00:57:21  lbayer
// apply ziptie license header to all java files
//
// Revision 1.3  2006/10/31 20:36:19  rkruse
// reformat the toStrings
//
// Revision 1.2  2006/10/17 19:21:17  dwhite
// Updated references from "com.alterpoint.net.credentials.Protocol" to "org.ziptie.protocols.Protocol" and "com.alterpoint.net.credentials.Credential" to "org.ziptie.credentials.Credential".
//
// Revision 1.1  2006/10/17 17:18:53  dwhite
// Genesis of ZUtilities, formerly known as DAUtilities - now with half the calories!
//
// Revision 1.1  2006/10/16 21:52:48  Rkruse
// moving from the NIL
//
// Revision 1.1  2006/10/13 19:58:31  Dwhite
// Merging NIL specific Credential and Protocol objects from Ziptie into Hammerhead.
//
// Revision 1.2  2006/10/13 16:45:15  dwhite
// Formatting update.
//
// Revision 1.1  2006/10/12 23:35:56  dwhite
// Test class to test the functionality of the org.ziptie.credentials.Credential class.
//
// Revision 1.0 Oct 12, 2006 dwhite
// Initial revision
// --------------------------------------------------
