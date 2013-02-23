/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2007/03/05 15:03:21 $
 * $Revision: 1.1 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net.util/test/org/ziptie/addressing/NetworkAddressTest.java,v $
 */

package org.ziptie.addressing;

import org.ziptie.exception.NonContiguousSubnetMask;

import junit.framework.TestCase;

/**
 * JUnit tests for the {@link NetworkAddress} objects.
 * @author rkruse
 */
public class NetworkAddressTest extends TestCase
{
    /**
     * Walk over an IP...should only return itself
     *
     */
    public void testIterableIp()
    {
        IPAddress ipAddress = new IPAddress("10.100.4.8");
        int counter = 0;
        for (IPAddress ip : ipAddress)
        {
            counter++;
        }
        assertEquals(1, counter);

        int counter2 = 0;
        for (IPAddress ip : ipAddress)
        {
            counter2++;
        }
        assertEquals(1, counter2);
    }

    /**
     * Walk over a subnet twice, make sure we get the same results each time
     * @throws NonContiguousSubnetMask 
     * @throws IllegalArgumentException 
     *
     */
    public void testIterableSubnet() throws IllegalArgumentException, NonContiguousSubnetMask
    {
        Subnet subnet = new Subnet(new IPAddress("10.100.4.0"), new IPAddress("255.255.255.0"));
        int counter = 0;
        for (IPAddress ip : subnet)
        {
            counter++;
        }
        assertEquals(256, counter);

        int counter2 = 0;
        for (IPAddress ip : subnet)
        {
            counter2++;
        }
        assertEquals(256, counter2);
    }

    /**
     * Tests walking over an {@link IPRange}
     *
     */
    public void testIterableIpRange()
    {
        IPRange range = new IPRange("10.100.4.10", "10.100.4.20");
        int counter = 0;
        for (IPAddress ip : range)
        {
            counter++;
        }
        assertEquals(11, counter);

        int counter2 = 0;
        for (IPAddress ip : range)
        {
            counter2++;
        }
        assertEquals(11, counter2);
    }

    /**
     * You cannot iterate an {@link IPWildcard}, but it should not throw an error....it should just return false for hasNext() always.
     *
     */
    public void testIterableIpWildcard()
    {
        IPWildcard wc = new IPWildcard("10.*.*.*");
        int counter = 0;
        for (IPAddress ip : wc)
        {
            counter++;
        }
        assertEquals(0, counter);
    }
}

// -------------------------------------------------
// $Log: NetworkAddressTest.java,v $
// Revision 1.1  2007/03/05 15:03:21  rkruse
// get rid of the AddressExploder in favor of the Iterable<IPAddress>.
//
// Revision 1.1  2007/03/01 14:51:15  Rkruse
// replace the AddressExploder with Iterable NetworkAddresses since the AddressExploder blows up the server (see class name).
//
// Revision 1.0 Feb 28, 2007 rkruse
// Initial revision
// --------------------------------------------------
