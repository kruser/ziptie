package org.ziptie.addressing;

import junit.framework.TestCase;

public class IPRangeTest extends TestCase
{

    public void testIPv4Range()
    {
        IPRange range = new IPRange("1.2.3.4", "1.2.3.10");
        assertTrue(range.contains(new IPAddress("1.2.3.6")));
    }

    public void testIPv6Range()
    {
        IPRange range = new IPRange("aaa::1", "aaa::5");
        assertTrue(range.contains(new IPAddress("aaa::4")));
    }

    public void testUnorderedIpV6Range()
    {
        try
        {
            new IPRange("99ff:d::", "99ff:c::");
            fail("This should have thrown an exception");
        }
        catch (IllegalArgumentException e)
        {
            System.out.println("Noticed the bad range...yay.");
        }
    }

    /**
     * Give one IPv4 and one IPv6 address.   Make sure it blows up.
     */
    public void testIpV4andV6Mix()
    {
        try
        {
            new IPRange("10.100.20.22", "aaa::5");
            fail("This should have thrown an exception");
        }
        catch (IllegalArgumentException e)
        {
            System.out.println("Noticed the bad range...yay.");
        }
    }

    public void testWalkIPv6Range()
    {
        IPRange range = new IPRange("::1", "::5");
        int counter = 0;
        for (IPAddress ipAddress : range)
        {
            System.out.println(ipAddress);
            counter++;
        }
        assertEquals(counter, 5);
    }
    
    public void testContains()
    {
        IPRange range = new IPRange("9FFE:FFFF:0:C002::", "9FFE:FFFF:0:C002::3");
        assertTrue(range.contains(new IPAddress("9FFE:FFFF:0:C002::"))); 
    }

}
