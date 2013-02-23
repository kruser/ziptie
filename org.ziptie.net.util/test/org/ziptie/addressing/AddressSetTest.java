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

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import junit.framework.TestCase;

import org.ziptie.exception.ValueFormatFault;

/**
 */
public class AddressSetTest extends TestCase
{

    /**
     * Constructor for AddressSetTest.
     * 
     * @param arg0
     */
    public AddressSetTest(String arg0)
    {
        super(arg0);
    }

    /*
     * @see TestCase#setUp()
     */
    @Override
    protected void setUp() throws Exception
    {
        super.setUp();
    }

    /*
     * @see TestCase#tearDown()
     */
    @Override
    protected void tearDown() throws Exception
    {
        super.tearDown();
    }

    public void testAdd() throws ValueFormatFault
    {
        IPAddress address1 = new IPAddress(0x0a0a0a01);
        Subnet subnet1 = new Subnet(new IPAddress(0x0a0a0b01), (short) 24);
        IPRange range1 = new IPRange(new IPAddress(0x0a0a0c01), new IPAddress(0x0a0a0c10));
        AddressSet addressSet = new AddressSet();
        addressSet.add(address1);
        addressSet.add(subnet1);
        addressSet.add(range1);

        assertEquals("Element count incorrect ", 3, addressSet.size());
    }

    public void testRemove() throws ValueFormatFault
    {
        IPAddress address1 = new IPAddress(0x0a0a0a01);
        Subnet subnet1 = new Subnet(new IPAddress(0x0a0a0b01), (short) 24);
        IPRange range1 = new IPRange(new IPAddress(0x0a0a0c01), new IPAddress(0x0a0a0c10));
        AddressSet addressSet = new AddressSet();
        addressSet.add(address1);
        addressSet.add(subnet1);
        addressSet.add(range1);

        addressSet.remove(subnet1);
        assertEquals("Element count incorrect ", 2, addressSet.size());
    }

    public void testContains() throws ValueFormatFault
    {
        IPAddress address1 = new IPAddress(0x0a0a0a01);
        IPAddress address2 = new IPAddress(0x0a0a0a02);
        IPAddress address3 = new IPAddress(0x0a0a0b02);
        IPAddress address4 = new IPAddress(0x0a0a0c02);
        Subnet subnet1 = new Subnet(new IPAddress(0x0a0a0b00), (short) 24);
        Subnet subnet2 = new Subnet(new IPAddress(0x0a0a0d00), (short) 24);
        IPRange range1 = new IPRange(new IPAddress(0x0a0a0c01), new IPAddress(0x0a0a0c10));
        IPRange range2 = new IPRange(new IPAddress(0x0a0a0c10), new IPAddress(0x0a0a0c20));
        IPRange range3 = new IPRange(new IPAddress(0x0a0a0c11), new IPAddress(0x0a0a0c20));
        IPRange range4 = new IPRange(new IPAddress(0x0a0a0bf0), new IPAddress(0x0a0a0bf8));
        AddressSet addressSet = new AddressSet();
        addressSet.add(address1);
        addressSet.add(subnet1);
        addressSet.add(range1);

        assertTrue("Contains test failed", addressSet.contains(address1));
        assertFalse("Contains test failed", addressSet.contains(address2));
        assertTrue("Contains test failed", addressSet.contains(address3));
        assertTrue("Contains test failed", addressSet.contains(address4));
        assertTrue("Contains test failed", addressSet.contains(range1));
        assertTrue("Contains test failed", addressSet.contains(range2));
        assertFalse("Contains test failed", addressSet.contains(range3));
        assertTrue("Contains test failed", addressSet.contains(range4));
        assertTrue("Contains test failed", addressSet.contains(subnet1));
        assertFalse("Contains test failed", addressSet.contains(subnet2));
    }

    /**
     * Adds <code>IPWildCard</code> to an <code>AddressSet</code> and checks
     * the contains() methods out.
     * 
     * @throws ValueFormatFault
     * 
     */
    public void testIPWildCard() throws ValueFormatFault
    {
        IPWildcard wildcard1 = new IPWildcard("127.0.0.1?");
        AddressSet set = new AddressSet();
        set.add(wildcard1);

        IPAddress tester = new IPAddress("127.0.0.11");
        assertTrue(set.contains(tester));

        IPAddress tester2 = new IPAddress("127.0.0.2");
        assertFalse(set.contains(tester2));

        IPRange range1 = new IPRange("127.0.0.1", "127.0.0.10");
        assertTrue(set.contains(range1));
    }

    public void testSetId()
    {
        AddressSet as = new AddressSet();
        as.setId(10000);
        assertEquals(10000, as.getId());
        
        // Make sure that an ID of 0 is not allowed
        as.setId(0);
        assertEquals(AddressSet.UNSAVED_ID, as.getId());
    }

    public void testIterable() throws ValueFormatFault
    {
        AddressSet as = new AddressSet();
        as.add(new IPAddress("10.10.10.10"));
        as.add(new IPRange("10.10.10.0", "10.10.255.255"));

        assertEquals(2, as.size());
    }

    public void testClearAddressSet()
    {
        AddressSet as = new AddressSet();
        as.add(new IPAddress("10.10.10.10"));
        as.add(new IPRange("10.10.10.0", "10.10.255.255"));
        assertEquals(2, as.size());

        as.clear();
        assertEquals(0, as.size());
    }

    /**
     * Spin up 50 threads and randomly do things to a single AddressSet. No
     * assertions, just making sure there are no
     * ConcurrentModificationExceptions thrown.
     * 
     * @throws InterruptedException
     * 
     */
    public void testConcurrency() throws InterruptedException
    {
        TrackingThreadPoolExecutor threadPool = new TrackingThreadPoolExecutor(50, 50, 1, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
        AddressSet addressSet = new AddressSet();
        for (int i = 0; i < 50; i++)
        {
            threadPool.execute(new CrazyAddressSetRunner(addressSet));
        }
        threadPool.shutdown();
        threadPool.awaitTermination(30, TimeUnit.SECONDS);
        if (threadPool.isCaughtConcurrentModificationException())
        {
            fail("Caught the ConcurrentModificationException when we shouldn't have");
        }
    }
    
    /**
     * Tests an AddressSet that has IPv6 members
     */
    public void testIpv6Members()
    {
        AddressSet addressSet = new AddressSet();
        IPRange range = new IPRange("9FFE:FFFF:0:C002::", "9FFE:FFFF:0:C002::3");
        addressSet.add(range);
        
        assertTrue(addressSet.contains(new IPAddress("9FFE:FFFF:0:C002::")));
    }
}
