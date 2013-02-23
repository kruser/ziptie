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
package org.ziptie.net.ping.icmp;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;

/**
 * PingerTest
 */
public class PingerTest extends TestCase
{

    /** {@inheritDoc} */
    protected void setUp() throws Exception
    {
        super.setUp();
    }

    /**
     * Pinging the network address will result in a good ping, but still should be
     * false for us, since the response is coming from another host.
     * 
     * For example, pinging 10.100.20.0, you will get replies from another address.
     *
     */
    public void testPingNetwork()
    {
        Pinger pinger = Pinger.getInstance();
        boolean result = pinger.ping(new IPAddress("10.100.20.0"));
        assertFalse(result);
    }

    /**
     * Ping a real address, assert result is true
     */
    public void testGoodPing()
    {
        Pinger pinger = Pinger.getInstance();
        boolean result = pinger.ping(new IPAddress("10.100.20.215"));
        assertTrue(result);
    }

    /**
     * we'll get a reply of an unreachable network, this should also be false
     */
    public void testUnreachable()
    {
        Pinger pinger = Pinger.getInstance();
        boolean result = pinger.ping(new IPAddress("192.168.200.200"));
        assertFalse(result);
    }
    
    /**
     * This is a ping of an IP in a reachable network, but the host doesn't exist.  This should
     * produce a plain exit code of 1 on the ping and be false.
     */
    public void testNoResponse()
    {
        Pinger pinger = Pinger.getInstance();
        boolean result = pinger.ping(new IPAddress("10.100.4.254"));
        assertFalse(result);
    }
}
