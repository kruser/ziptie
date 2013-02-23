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

package org.ziptie.addressing;

import junit.framework.TestCase;

import org.ziptie.exception.NonContiguousSubnetMask;

/**
 */
public class SubnetTest extends TestCase
{

    /**
     * Constructor for SubnetTest.
     * @param arg0
     */
    public SubnetTest(String arg0)
    {
        super(arg0);
    }

    /*
     * Test for void Subnet()
     */
    public void testSubnet()
    {
        Subnet subnet = new Subnet();
        assertEquals("Default address must be 0.0.0.0", new IPAddress(), subnet.getNetworkAddress());
        assertEquals("Default mask must be 0", 0, subnet.getNetmaskBits());
    }

    /*
     * Test for void Subnet(IPAddress, short, boolean)
     */
    public void testSubnetIPAddressShortBoolean()
    {
        IPAddress networkAddress = new IPAddress(0x0a0a0a13); // 10.10.10.13
        short netmaskBits = 23;
        boolean exclude = true;

        Subnet subnet = new Subnet(networkAddress, netmaskBits, exclude);
        assertEquals("Address not correct ", new IPAddress(0x0a0a0a00), subnet.getNetworkAddress());
        assertEquals("Mask not correct ", 23, subnet.getNetmaskBits());
    }

    /*
     * Test for void Subnet(IPAddress, IPAddress)
     */
    public void testSubnetIPAddressMaskAddress() throws NonContiguousSubnetMask
    {
        IPAddress networkAddress = new IPAddress(0x0a0a0a13); // 10.10.10.13
        IPAddress netmask = new IPAddress(0xfffffe00); // 255.255.254.0

        Subnet subnet = new Subnet(networkAddress, netmask);
        assertEquals("Address not correct ", new IPAddress(0x0a0a0a00), subnet.getNetworkAddress());
        assertEquals("Mask not correct ", 23, subnet.getNetmaskBits());
    }

    public void testGetNetmask()
    {
        IPAddress networkAddress = new IPAddress(0x0a0a0a13); // 10.10.10.13
        IPAddress netmask = new IPAddress(0xfffffe00); // 255.255.254.0
        short netmaskBits = 23;
        boolean exclude = true;

        Subnet subnet = new Subnet(networkAddress, netmaskBits, exclude);
        assertEquals("Address not correct ", new IPAddress(0x0a0a0a00), subnet.getNetworkAddress());
        assertEquals("Mask not correct ", netmask, subnet.getNetmask());
    }

    public void testGetBroadcastAddress()
    {
        IPAddress networkAddress = new IPAddress(0x0a0a0a13); // 10.10.10.13
        new IPAddress(0xfffffe00); // 255.255.254.0
        short netmaskBits = 23;
        boolean exclude = true;

        Subnet subnet = new Subnet(networkAddress, netmaskBits, exclude);
        IPAddress broadcastAddress = subnet.getBroadcastAddress();
        assertEquals("Broadcast not equal ", new IPAddress(0x0a0a0a13 | 0x000001ff), broadcastAddress);
    }

    public void testSetNetmask()
    {
        IPAddress networkAddress = new IPAddress(0x0a0a0a13); // 10.10.10.13
        IPAddress checkNetmask1 = new IPAddress(0xffff0000); // 255.255.0.0
        IPAddress checkNetmask2 = new IPAddress(0xfffffff0); // 255.255.255.240
        short netmaskBits = 23;
        boolean exclude = true;

        Subnet subnet = new Subnet(networkAddress, netmaskBits, exclude);
        subnet.setNetmaskBits((short) 16);
        assertEquals("Address not correct ", new IPAddress(0x0a0a0000), subnet.getNetworkAddress());
        assertEquals("Mask not correct ", checkNetmask1, subnet.getNetmask());

        subnet.setNetmaskBits((short) 28);
        assertEquals("Address not correct ", new IPAddress(0x0a0a0a10), subnet.getNetworkAddress());
        assertEquals("Mask not correct ", checkNetmask2, subnet.getNetmask());
    }

    public void testContains()
    {
        IPAddress networkAddress = new IPAddress(0x0a0a0a13); // 10.10.10.13
        IPAddress ipAddress = new IPAddress(0x0a0a0b13); // 10.10.11.13
        short netmaskBits = 24;
        boolean exclude = true;

        Subnet subnet = new Subnet(networkAddress, netmaskBits, exclude);
        assertTrue("Check for contains() failed ", subnet.contains(networkAddress));
        assertFalse("Check for contains() failed ", subnet.contains(ipAddress));
    }

    /*
     * Test for boolean equals(Object)
     */
    public void testEqualsObject() throws NonContiguousSubnetMask
    {
        IPAddress networkAddress = new IPAddress(0x0a0a0a13); // 10.10.10.13
        IPAddress netmask2 = new IPAddress(0xfffffe00); // 255.255.255.240
        short netmaskBits = 23;
        boolean exclude = true;

        Subnet subnet1 = new Subnet(networkAddress, netmaskBits, exclude);
        Subnet subnet2 = new Subnet(networkAddress, netmask2);
        Subnet subnet3 = new Subnet(networkAddress, (short) (netmaskBits + 1), exclude);
        assertEquals("Subnets should be equal ", subnet1, subnet2);
        assertFalse("Subnets should be not equal ", subnet1.equals(subnet3));
    }

    /**
     * 
     *
     */
    public void testIpV6Subnet()
    {
        IPAddress host = new IPAddress("9FFE:FFFF:0:C002::1");
        short cidr = 54;

        Subnet subnet = new Subnet(host, cidr);
        System.out.println(subnet);

        IPAddress networkAddress = subnet.getNetworkAddress();
        assertEquals(networkAddress.toString(), "9ffe:ffff:0:c000::");
        assertTrue(subnet.contains(host));
    }

    public void testAnotherIpV6Subnet()
    {
        IPAddress host = new IPAddress("9FFE:FFFF:0:C002::FFdd:1");
        short cidr = 36;

        Subnet subnet = new Subnet(host, cidr);
        System.out.println(subnet);

        IPAddress networkAddress = subnet.getNetworkAddress();
        assertEquals(networkAddress.toString(), "9ffe:ffff::");
        assertTrue(subnet.contains(host));
    }

    public void testIteratingSubnet()
    {
        IPAddress host = new IPAddress("::1");
        short cidr = 126;

        Subnet subnet = new Subnet(host, cidr);
        System.out.println("Walking subnet " + subnet);
        int addressCount = 0;
        for (IPAddress address : subnet)
        {
            System.out.println(address);
            addressCount++;
        }
        assertEquals(2, addressCount);
    }

}
