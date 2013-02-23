package org.ziptie.addressing;

import junit.framework.TestCase;

/**
 * Tests for the IPAddress class.
 * @author rkruse
 */
public class IPAddressTest extends TestCase
{
    /**
     * Test out building an IPv6 address
     */
    public void testNewV6Address()
    {
        IPAddress ipAddress = new IPAddress("fff2::1");
        assertTrue(ipAddress.isVersion6());
        assertEquals("fff2::1", ipAddress.toString());
        assertEquals("FFF2:0000:0000:0000:0000:0000:0000:0001", ipAddress.toDatabaseString());
    }
    
    public void testCompareV6()
    {
        IPAddress ipAddress1 = new IPAddress("fff2::1");
        IPAddress ipAddress2 = new IPAddress("fff2::4");
        IPAddress ipAddress3 = new IPAddress("fff2::4");
        assertTrue(ipAddress1.compareTo(ipAddress2) < 0);
        assertTrue(ipAddress2.compareTo(ipAddress1) > 0);
        assertTrue(ipAddress3.compareTo(ipAddress2) == 0);
    }
    
    public void testCompareV6PositiveNegativeThreshold()
    {
        // Test dealing with IPv6 addresses that have HIGH and LOW values that cross
        // the positive negative threshold.  We had to adjust the comparison logic
        // on the IPAddress class to handle this.
        IPAddress lastPositiveIP = new IPAddress("7FFF:FFFF:FFFF:FFFF::");
        IPAddress firstNegativeIP = new IPAddress("8000::");
        assertTrue(lastPositiveIP.compareTo(firstNegativeIP) < 0);
        assertTrue(firstNegativeIP.compareTo(lastPositiveIP) > 0);
    }

    public void testNewV4Address()
    {
        IPAddress ipAddress = new IPAddress("10.100.19.218");
        assertFalse(ipAddress.isVersion6());
        assertEquals("010.100.019.218", ipAddress.toDatabaseString());
    }
    

    public void testNewV4Address2()
    {
        IPAddress ipAddress = new IPAddress("10.100.19.3");
        assertFalse(ipAddress.isVersion6());
        assertEquals("010.100.019.003", ipAddress.toDatabaseString());
    }
    
    public void testToStringIpV4()
    {
        String input = "010.010.123.001";
        String expected = "10.10.123.1";
        IPAddress ipAddress = new IPAddress(input);
        String returned = ipAddress.toString();
        
        System.out.println("------------------");
        System.out.println("IPv4 toString Test");
        System.out.println("------------------");
        System.out.println("Input IP: " + input);
        System.out.println("Expect IP: " + expected);
        System.out.println("Returned IP: " + returned);
        
        assertTrue(returned.equals(expected));
    }
    
    public void testToStringIpV6()
    {
        String input1 = "0001:0db8:0100:1000:0:1:1428:57ab";
        String expected1 = "1:db8:100:1000::1:1428:57ab";
        IPAddress ipAddress1 = new IPAddress(input1);
        String returned1 = ipAddress1.toString();
        
        System.out.println("\n------------------");
        System.out.println("IPv6 toString Test");
        System.out.println("------------------");
        System.out.println("Input IP: " + input1);
        System.out.println("Expected IP: " + expected1);
        System.out.println("Returned IP: " + returned1);
        
        assertTrue(returned1.equals(expected1));
        
        String input2 = "2008:757D:0737:1F5B:0000:000:00:0";
        String expected2 = "2008:757d:737:1f5b::";
        IPAddress ipAddress2 = new IPAddress(input2);
        String returned2 = ipAddress2.toString();
        
        System.out.println("\nInput IP: " + input2);
        System.out.println("Expected IP: " + expected2);
        System.out.println("Returned IP: " + returned2);
        
        assertTrue(returned2.equals(expected2));
    }
}
