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

import java.util.HashSet;
import java.util.Set;

import junit.framework.TestCase;

/**
 * Tests a <code>CredentialSet</code>
 * 
 * @author rkruse
 */
public class CredentialSetTest extends TestCase
{
    private CredentialSet credentialSet;

    @Override
    protected void setUp()
    {
    }

    public void testNew()
    {
        credentialSet = new CredentialSet("test1", testCredentials());
        assertNotNull(credentialSet);
        assertEquals(-1, credentialSet.getId());
    }

    public void testCredentialByName() throws CredentialNotSetException
    {
        credentialSet = new CredentialSet("test1", testCredentials());
        String credentialValue = credentialSet.getCredentialValue("username");
        assertEquals("testlab", credentialValue);
    }

    /**
     * This should throw an exception since we'll ask for a bogus credential
     * name
     * 
     */
    public void testUnknownCredential()
    {
        credentialSet = new CredentialSet("test1", testCredentials());
        try
        {
            credentialSet.getCredentialValue("bobby");
            fail("This credential is not set and there should have been an exception");
        }
        catch (CredentialNotSetException cns)
        {
            assertTrue(true);
        }
    }

    /**
     * <code>CredentialSet</code> objects will be ordered and should implement
     * comparable based on their priority
     * 
     */
    public void testComparable()
    {
        CredentialSet credSet1 = new CredentialSet("test1", testCredentials());
        credSet1.setPriority(1);
        CredentialSet credSet2 = new CredentialSet("test2", testCredentials());
        credSet2.setPriority(2);
        assertTrue(credSet1.compareTo(credSet2) < 0);
    }

    /**
     * You can also create a <code>CredentialSet</code>
     * 
     * @throws CredentialNotSetException
     */
    public void testAddCreds() throws CredentialNotSetException
    {
        CredentialSet credSet = new CredentialSet("austin routers");
        credSet.addCredential(new Credential("username", "mint"));

        assertEquals("mint", credSet.getCredentialValue("username"));
    }

    /**
     * Doesn't assert anything...just runs the toString()
     * 
     */
    public void testToString()
    {
        CredentialSet credSet = new CredentialSet("yo");
        credSet.addCredential(new Credential("username", "mint"));
        credSet.addCredential(new Credential("password", "sweet"));
        credSet.addCredential(new Credential("enablePassword", "rad"));
        System.out.println(credSet.toString());
    }

    /**
     * Tests the addOrUpdate method
     * 
     * @throws CredentialNotSetException
     * 
     */
    public void testAddOrUpdate() throws CredentialNotSetException
    {
        CredentialSet credSet = new CredentialSet("Test");
        credSet.addCredential(new Credential("username", "mint"));
        credSet.addCredential(new Credential("password", "sweet"));
        credSet.addCredential(new Credential("enablePassword", "rad"));

        assertEquals(credSet.getCredentialValue("username"), "mint");
        assertEquals(3, credSet.getCredentials().size());

        // now add or update
        credSet.addOrUpdate("username", "new guy");
        assertEquals(credSet.getCredentialValue("username"), "new guy");
        assertEquals(3, credSet.getCredentials().size());
    }

    /**
     * Similar to the equals check but this one only checks if the underlying
     * credentials are the same
     */
    public void testHasSameCredentials()
    {
        CredentialSet c1 = new CredentialSet("Test One");
        CredentialSet c2 = new CredentialSet("Test Two");

        assertTrue(c1.credentialsEqual(c2));
        c1.addCredential(new Credential("dude", "myCar"));
        assertFalse(c1.credentialsEqual(c2));

        /*
         * create the other one with a crazy ID....they should still be equal
         */
        Credential withId = new Credential("dude", "myCar");
        withId.setId(5555);
        c2.addCredential(withId);
        assertTrue(c1.credentialsEqual(c2));
    }

    private Set<Credential> testCredentials()
    {
        Set<Credential> newCreds = new HashSet<Credential>();
        newCreds.add(new Credential("username", "testlab"));
        newCreds.add(new Credential("password", "hobbit"));
        return newCreds;
    }

    @Override
    protected void tearDown()
    {

    }
}

/**
 * ------------------------------------------------- $Log:
 * CredentialSetTest.java $Revision 1.1 Oct 22, 2006 rkruse $Code Templates $
 * --------------------------------------------------
 */
