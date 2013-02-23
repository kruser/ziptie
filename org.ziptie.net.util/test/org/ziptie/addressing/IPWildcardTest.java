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

import org.ziptie.exception.ValueFormatFault;


/**
 * Test the features of the <code>IPWildcard</code>
 * 
 * @author rkruse
 */
public class IPWildcardTest extends TestCase
{
    /**
     * All of these are valid....no exception should be thrown
     * 
     * @throws ValueFormatFault
     */
    public void testValid() throws ValueFormatFault
    {
        new IPWildcard("127.*.*.1");
        new IPWildcard("127.1*9.0.1");
        new IPWildcard("127.22.45.1");
        new IPWildcard("127.9.9.1*");
        new IPWildcard("127.9.9.*1");
        new IPWildcard("*.1.1.1");
        new IPWildcard("22*.1.1.1");
        new IPWildcard("1*7.1.1.1");
        new IPWildcard("127.*.*99.1");
        new IPWildcard("17.1.1.1??");
        new IPWildcard("17.1.?1?.1");

        // range wildcards
        new IPWildcard("*.*.*.10-20");
        new IPWildcard("*.100-200.*.1");
    }

    /**
     * A range wildcard should
     * 
     */
    public void testInvalidRange()
    {
        try
        {
            new IPWildcard("*.*.*.55-290");
            fail("this should have thrown an exception");
        }
        catch (IllegalArgumentException e)
        {
            assertTrue(true);
        }
    }

    /**
     * Tests a range octet where the start is greater than the end.
     */
    public void testBackwardsRange()
    {
        try
        {
            new IPWildcard("*.*.*.200-150");
            fail("this should have thrown an exception since 150 is less than 200");
        }
        catch (IllegalArgumentException e)
        {
            assertTrue(true);
        }
    }

    /**
     * Create an IPWildcard with something other than a digit or the * char. Catch the exception.
     * 
     */
    public void testInvalidChars()
    {
        boolean caughtException = false;
        try
        {
            new IPWildcard("127.$$.1.1");
        }
        catch (IllegalArgumentException e)
        {
            caughtException = true;
        }
        assertTrue(caughtException);
    }

    /**
     * Create one with too many octets and validate the failure
     * 
     */
    public void testLongOctets()
    {
        boolean caughtException = false;
        try
        {
            new IPWildcard("127.1.1.1.1");
        }
        catch (IllegalArgumentException e)
        {
            caughtException = true;
        }
        assertTrue(caughtException);
    }

    /**
     * Create an address outside of the valid IP address range and validate that the exception is thrown
     * 
     */
    public void testBadAddress()
    {
        boolean caughtException = false;
        try
        {
            // 500 is an invalid octet
            new IPWildcard("127.1.1.500");
        }
        catch (IllegalArgumentException e)
        {
            caughtException = true;
        }
        assertTrue(caughtException);
    }

    /**
     * Run through the .equals()
     * 
     * @throws ValueFormatFault
     */
    public void testEquals() throws ValueFormatFault
    {
        IPWildcard one = new IPWildcard("127.0.0.*");
        assertFalse(one.equals(null));

        IPWildcard two = new IPWildcard("127.0.0.*");
        assertEquals(one, two);
    }

    /**
     * Create an IPWildcard and verify that a new IPAddress can be found inside it
     * 
     * @throws ValueFormatFault
     * 
     */
    public void testContains() throws ValueFormatFault
    {
        // Tests multiple *'s in a wildcard address
        IPWildcard wildcard = new IPWildcard("*.*.*.1");
        IPAddress address = new IPAddress("10.10.10.1");
        assertTrue(wildcard.contains(address));

        // Tests multiple addresses
        IPWildcard wildcard2 = new IPWildcard("10.10.*.10");
        IPAddress address2 = new IPAddress("10.10.100.10");
        IPAddress address3 = new IPAddress("10.10.4.10");
        assertFalse(wildcard2.contains(address));
        assertTrue(wildcard2.contains(address2));
        assertTrue(wildcard2.contains(address3));

        // Tests out the ? matcher
        IPWildcard wildcard3 = new IPWildcard("10.10.10.?");
        IPAddress address4 = new IPAddress("10.10.10.1");
        IPAddress address5 = new IPAddress("10.10.10.0");
        IPAddress address6 = new IPAddress("10.10.10.9");
        IPAddress address7 = new IPAddress("10.10.10.11");
        assertTrue(wildcard3.contains(address4));
        assertTrue(wildcard3.contains(address5));
        assertTrue(wildcard3.contains(address6));
        assertFalse(wildcard3.contains(address7));
    }

    /**
     * test out the compareTo method
     * 
     * @throws ValueFormatFault
     * 
     */
    public void testCompareTo() throws ValueFormatFault
    {
        IPWildcard wildcard1 = new IPWildcard("123.123.123.???");
        IPWildcard wildcard2 = new IPWildcard("123.123.123.???");
        IPWildcard wildcard3 = new IPWildcard("123.123.123.123");

        assertEquals(0, wildcard1.compareTo(wildcard2));
        assertNotSame(0, wildcard1.compareTo(wildcard3));

        try
        {
            wildcard1.compareTo(Integer.valueOf(5));
            fail("this should throw a ClassCastException");
        }
        catch (ClassCastException cce)
        {

        }
    }
    
    /**
     * IPWildcard should always return false for this.
     * @throws ValueFormatFault 
     *
     */
    public void getExclude() throws ValueFormatFault
    {
        IPWildcard wildcard1 = new IPWildcard("123.123.123.???");
        assertFalse(wildcard1.getExclude());
    }

    /**
     * Tests a wildcard where the last octet is a range of IPs
     * 
     * @throws ValueFormatFault
     */
    public void testRangeLastOctet() throws ValueFormatFault
    {
        IPWildcard wildcard1 = new IPWildcard("10.*.*.100-200");

        IPAddress address1 = new IPAddress("10.10.10.150");
        assertTrue(wildcard1.contains(address1));

        IPAddress address2 = new IPAddress("10.10.10.99");
        assertFalse(wildcard1.contains(address2));
    }

    /**
     * Tests if a range in the second octet works properly.
     * 
     * @throws ValueFormatFault
     * 
     */
    public void testMidOctetRange() throws ValueFormatFault
    {
        IPWildcard wildcard1 = new IPWildcard("10.10.100-200.1");

        IPAddress address1 = new IPAddress("10.10.100.1");
        assertTrue(wildcard1.contains(address1));

        IPAddress address2 = new IPAddress("10.10.99.1");
        assertFalse(address2 + " is outside the range " + wildcard1, wildcard1.contains(address2));

        IPAddress address3 = new IPAddress("10.10.101.2");
        assertFalse(address2 + " doesn't match the last octed of " + wildcard1, wildcard1.contains(address3));
    }

    /**
     * In a wildcard the first address is equal to the wildcard and there is no second address
     * 
     * @throws ValueFormatFault
     */
    public void testFirstSecond() throws ValueFormatFault
    {
        IPWildcard wildcard1 = new IPWildcard("10.*.*.10-200");
        assertEquals("10.*.*.10-200", wildcard1.getFirstValue());
        assertEquals("", wildcard1.getSecondValue());
    }
    
    /**
     * An IPv4 wildcard can be short, e.g. 192.*
     * 
     * Not all octets need to be populated.
     *
     */
    public void testLenientWildcards()
    {
        IPWildcard wc = new IPWildcard("192.*");
        assertTrue(wc.contains(new IPAddress("192.168.2.3")));
    }
    
    public void testIPv6Wildcard()
    {
        IPWildcard wc = new IPWildcard("ffff:*");
        assertTrue(wc.contains(new IPAddress("ffff:cc99::5")));
        assertFalse(wc.contains(new IPAddress("aaaa:cc99::5")));
        
        wc = new IPWildcard("*::1");
        assertTrue(wc.contains(new IPAddress("abcd::1")));
        assertFalse(wc.contains(new IPAddress("abcd::2")));
        
        wc = new IPWildcard("Cfe:*:0dd::");
        assertTrue(wc.contains(new IPAddress("cfe:abcd:00dd::")));
        assertFalse(wc.contains(new IPAddress("cfe:abcd:1dd::")));
        
        wc = new IPWildcard("::dd:*:abc");
        assertTrue(wc.contains(new IPAddress("::00dd:123:abc")));
        assertFalse(wc.contains(new IPAddress("::dd:123:fabc")));
    }
    
    public void testIPv6WildcardRange()
    {
        IPWildcard wc = new IPWildcard("ffff:a-e::");
        assertTrue(wc.contains(new IPAddress("ffff:b::")));
        assertFalse(wc.contains(new IPAddress("ffff:f::")));
        
        wc = new IPWildcard("ffff:12bb-ffff::");
        assertTrue(wc.contains(new IPAddress("ffff:33cc::")));
        assertFalse(wc.contains(new IPAddress("ffff:12ba::")));
    }

}
