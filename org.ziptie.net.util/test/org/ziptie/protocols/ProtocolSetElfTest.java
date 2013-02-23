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

import junit.framework.TestCase;

/**
 * Tests out the ProtocolSetElf class
 * 
 * @author rkruse
 */
public class ProtocolSetElfTest extends TestCase
{
    public void testSingle()
    {
        ProtocolSet pSet = ProtocolSetElf.createProtocolSet("Telnet");
        assertEquals("Telnet", pSet.getName());
        assertEquals(1, pSet.getProtocols().size());
    }
    
    public void testDouble()
    {
        ProtocolSet pSet = ProtocolSetElf.createProtocolSet("Telnet-TFTP");
        assertEquals("Telnet-TFTP", pSet.getName());
        assertEquals(2, pSet.getProtocols().size());
    }
    
    public void testTriple()
    {
        ProtocolSet pSet = ProtocolSetElf.createProtocolSet("Telnet-SNMPv1-TFTP");
        assertEquals("Telnet-SNMPv1-TFTP", pSet.getName());
        assertEquals(3, pSet.getProtocols().size());
    }

}


// -------------------------------------------------
// $Log: ProtocolSetElfTest.java
// $Revision 1.1  Oct 25, 2006 rkruse
// $Code Templates
// $
// --------------------------------------------------