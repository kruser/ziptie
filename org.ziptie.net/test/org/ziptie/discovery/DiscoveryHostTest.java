/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/07/09 19:27:39 $
 * $Revision: 1.2 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/DiscoveryHostTest.java,v $e
 */

package org.ziptie.discovery;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;
import org.ziptie.exception.ValueFormatFault;

public class DiscoveryHostTest extends TestCase
{
    public DiscoveryHost host;

    protected void setUp()
    {
        host = new DiscoveryHost(new IPAddress("10.100.4.8"));
    }

    public void testSetupByIP()
    {
        assertNotNull(host);
    }

    public void testIPAddress() throws ValueFormatFault
    {
        host.setIpAddress(new IPAddress("10.100.4.8"));
        assertEquals("10.100.4.8", host.getIpAddress().getIPAddress());
    }

    /**
     * There is an algorithm to determine the best administrative IP for a
     * device. Normally this will be used unless the boolean for
     * 'calculateAdminIp' is set to false.
     * 
     */
    public void testCalculateAdminIp()
    {
        assertTrue(host.isCalculateAdminIp());
        host.setCalculateAdminIp(false);
        assertFalse(host.isCalculateAdminIp());
    }

    /**
     * Test out a default value
     * 
     */
    public void testDefaults()
    {
        assertFalse(host.isBypassCache());
        host.setBypassCache(true);
        assertTrue(host.isBypassCache());
    }

}