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

/**
 * Unit tests for the <code>ProtocolSet</code> class.
 * @author rkruse
 */
public class ProtocolSetTest extends TestCase
{
    ProtocolSet set1;
    ProtocolSet set2;
    
    @Override
    protected void setUp()
    {
        set1 = new ProtocolSet();
        set2 = new ProtocolSet();
    }
    
    public void testID()
    {
        set1.setProtocolConfigId(123);
        assertEquals(123, set1.getProtocolConfigId());
    }
    
    public void testSetProtocols()
    {
        set1.addProtocol(new Protocol("temp", 1, 1, false));
        Set<Protocol> protocols = set1.getProtocols();
        assertEquals(1, protocols.size());
        
        for(Protocol protocol: protocols)
        {
            assertEquals("temp", protocol.getName());
        }
    }
    
    public void testEquals()
    {
        assertEquals(set1, set2);
        
        set1.setId(56);
        assertFalse("changing the ID should make these unequal", set1.equals(set2));
        
        set2.setId(56);
        assertEquals(set1, set2);
        
        set1.addProtocol(new Protocol("dude", 3, 5, false));
        assertEquals("these should stay equal since they have positive IDs.", set1, set2);
        
        set2.addProtocol(new Protocol("dude", 3, 5, false));
        assertEquals(set1, set2);
    }
    
    
    /**
     * Tests the method that is like {@link ProtocolSet#getName()} but has some of the properties inline.
     * 
     * e.g. SSH(v1|blowfish)-TFTP-SNMP(v1)
     *
     */
    public void testDetailedInfo()
    {
        ProtocolConfig pc = UnitTestProtocolConfigElf.getNewConfig();
        ProtocolSet toBuild = new ProtocolSet();
        for (Protocol protocol: pc.getProtocols())
        {
            if (protocol.getName().matches("SSH|SCP|SNMP"))
            {
                toBuild.addProtocol(protocol);
            }
        }
        
        System.out.println("ProtocolSet detailedInfo test: " + toBuild.detailedInfo());
    }
}


// -------------------------------------------------
// $Log: ProtocolSetTest.java
// $Revision 1.1  Oct 25, 2006 rkruse
// $Code Templates
// $
// --------------------------------------------------