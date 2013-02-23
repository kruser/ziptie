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

import java.util.Set;

import junit.framework.TestCase;

public class ProtocolConfigTest extends TestCase
{
    public void testNewProtocolConfig()
    {
        ProtocolConfig config = new ProtocolConfig();
        assertNotNull(config);
    }

    public void testAddAFewProtocols()
    {
        ProtocolConfig config = new ProtocolConfig();
        config.addProtocol(new Protocol("Telnet", 23, 2, true));
        config.addProtocol(new Protocol("SSH", 22, 1, true));

        // now find out if these are ordered properly according to their priority
        Set<Protocol> protocols = config.getProtocols();
        assertEquals(2, protocols.size());
        Protocol[] protArray = protocols.toArray(new Protocol[protocols.size()]);
        assertEquals("SSH", protArray[0].getName());
        assertEquals("Telnet", protArray[1].getName());
    }

    public void testEquals()
    {
        ProtocolConfig config1 = new ProtocolConfig();
        ProtocolConfig config2 = new ProtocolConfig();
        assertEquals(config1, config2);

        config2.setPriority(22);
        assertFalse(config1.equals(config2));

        config2.setId(3);
        assertFalse(config1.equals(config2));

        config1.setId(3);
        assertEquals("Even though the priorities are different, they should be equal because of the positive IDs.", config1, config2);

        Protocol test = new Protocol("hey", 1, 1, true);
        config1.addProtocol(test);
        assertEquals("Should still equal because they have positive IDs.", config1, config2);
    }

    public void testName()
    {
        ProtocolConfig config1 = new ProtocolConfig();
        config1.setName("arbitrary");
        assertEquals("arbitrary", config1.getName());
    }

    public void testClone()
    {
        ProtocolConfig config1 = new ProtocolConfig();
        config1.setName("abc");
        config1.setId(3);
        config1.setPriority(2);

        ProtocolConfig config2 = config1.clone();

        assertEquals("abc", config2.getName());
        assertEquals(3, config2.getId());
        assertEquals(2, config2.getPriority());
    }

    /**
     * Don't assert anything....just make sure the toString doesn't throw an exception
     *
     */
    public void testToString()
    {
        ProtocolConfig config1 = new ProtocolConfig();
        config1.setName("default");
        config1.setId(5);
        config1.addProtocol(new Protocol("SSH", 22, 3, true));
        config1.addProtocol(new Protocol("Telnet", 23, 1, true));
        config1.addProtocol(new Protocol("SCP", 22, 4, true));
        config1.addProtocol(new Protocol("TFTP", 69, 2, false));

        System.out.println(config1.toString());
    }
}
