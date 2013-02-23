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

import java.util.Set;

import junit.framework.TestCase;

/**
 * @author rkruse
 */
public class CredentialConfigTest extends TestCase
{
    /*
     * (non-Javadoc)
     * 
     * @see junit.framework.TestCase#setUp()
     */
    @Override
    protected void setUp() throws Exception
    {
        super.setUp();
    }

    public void testNew()
    {
        CredentialConfig credentialConfig = new CredentialConfig("New York Firewalls");
        assertNotNull(credentialConfig);
        assertEquals("New York Firewalls", credentialConfig.getName());
    }

    public void testWithCredentialSets()
    {
        CredentialConfig credConfig = new CredentialConfig("test2");
        CredentialSet one = new CredentialSet("first");
        one.setPriority(1);
        CredentialSet two = new CredentialSet("second");
        two.setPriority(2);

        // now add them in reverse order, they should still be returned from the
        // config in the correct order
        credConfig.addCredentialSet(two);
        credConfig.addCredentialSet(one);

        Set<CredentialSet> orderedCredentials = credConfig.getCredentialSets();
        assertEquals(2, orderedCredentials.size());

        int counter = 0;
        for (CredentialSet cs : orderedCredentials)
        {
            if (counter == 0)
            {
                assertEquals("first", cs.getName());
            }
            else
            {
                assertEquals("second", cs.getName());
            }
            counter++;
        }

    }

    /**
     * Two credential sets with the same priority should instead return the compareTo of the name
     *
     */
    public void testSamePriorities()
    {
        CredentialConfig credConfig = new CredentialConfig("test2");
        CredentialSet one = new CredentialSet("first");
        one.setPriority(1);

        credConfig.addCredentialSet(one);
        assertEquals(1, credConfig.getCredentialSets().size());

        CredentialSet two = new CredentialSet("second");
        two.setPriority(1);
        credConfig.addCredentialSet(two);
        assertEquals(2, credConfig.getCredentialSets().size());
    }

    /**
     * Equals just works on the ID
     */
    public void testEquals()
    {
        CredentialConfig one = new CredentialConfig("one");
        CredentialConfig two = new CredentialConfig("two");

        one.setPriority(5);
        assertFalse("Both CredentialConfigs have an ID of -1, so priority should be used in the equals", one.equals(two));
        one.setId(56);
        two.setId(56);
        assertEquals("Now both CredentialConfigs have a positive id, so that should be all that matters", one, two);

        one.setId(56);
        two.setId(57);
        assertFalse(one.equals(two));

    }

    /*
     * (non-Javadoc)
     * 
     * @see junit.framework.TestCase#tearDown()
     */
    @Override
    protected void tearDown() throws Exception
    {
        super.tearDown();
    }

}
