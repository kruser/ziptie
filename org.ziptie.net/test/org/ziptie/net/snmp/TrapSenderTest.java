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
 */
package org.ziptie.net.snmp;

import java.io.File;

import junit.framework.TestCase;

import org.ziptie.net.common.NILProperties;

/**
 * TrapSenderTest
 */
public class TrapSenderTest extends TestCase
{
    public void setUp()
    {
        NILProperties.setup(new File("../conf/network/nil.properties"));
    }
    
    /**
     * Tests out sending a config change SNMP trap.  It doesn't 
     * really assert anything at this point, so it is more of a 
     * means to run the trap.  To make this test full we would 
     * simultaneously startup a trap receiver and verify that the 
     * trap was indeed received.
     */
    public void testSendingConfigChangeTrap()
    {
        TrapSender trapSender = TrapSender.getInstance();
        trapSender.sendConfigChangeTrap("router.kruseonline.net", "192.168.1.1", "Home", "running-config");
    }
    
    public void testSendingAddTrap()
    {
        TrapSender trapSender = TrapSender.getInstance();
        trapSender.sendAddDeviceTrap("newRouters.gw.alterpoint.com", "5.5.5.5", "default", "ZipTie::Adapters::Cisco::IOS", "Cisco IOS");
    }
    
    public void testSendingFailedOperationTrap()
    {
        TrapSender trapSender = TrapSender.getInstance();
        trapSender.sendFailedOperationTrap("newRouters.gw.alterpoint.com", "5.5.5.5", "default", "backup", "Invalid Credentials");
    }

}
