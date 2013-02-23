package org.ziptie.addressing;

import junit.framework.TestCase;

public class NetworkAddressElfTest extends TestCase
{
    public void testIpV6()
    {
        String ip = "::1";
        NetworkAddress address = NetworkAddressElf.parseAddress(ip);
        assertTrue(address instanceof IPAddress);
        
        IPAddress ipAddress = (IPAddress) address;
        assertTrue(ipAddress.isVersion6());
    }
    
    public void testIpV4()
    {
        String ip = "1.2.3.4";
        NetworkAddress address = NetworkAddressElf.parseAddress(ip);
        assertTrue(address instanceof IPAddress);
        
        IPAddress ipAddress = (IPAddress) address;
        assertFalse(ipAddress.isVersion6());
    }

    public void testCompressIpV4()
    {
        String input = "010.010.123.001";
        String expected = "10.10.123.1";
        String returned = NetworkAddressElf.fromDatabaseString(input);
        
        System.out.println("--------------------------");
        System.out.println("Compress IPv4 Address Test");
        System.out.println("--------------------------");
        System.out.println("Input IP: " + input);
        System.out.println("Expected IP: " + expected);
        System.out.println("Returned IP: " + returned);
        
        assertTrue(returned.equals(expected));
    }
    
    public void testCompressIpV6()
    {
        String input1 = "0001:0db8:0100:1000:0:1:1428:57ab";
        String expected1 = "1:db8:100:1000::1:1428:57ab";
        String returned1 = NetworkAddressElf.fromDatabaseString(input1);
        
        System.out.println("\n--------------------------");
        System.out.println("Compress IPv6 Address Test");
        System.out.println("--------------------------");
        System.out.println("Input IP: " + input1);
        System.out.println("Expected IP: " + expected1);
        System.out.println("Returned IP: " + returned1);
        
        assertTrue(returned1.equals(expected1));
        
        String input2 = "2008:757D:0737:1F5B:0000:000:00:0";
        String expected2 = "2008:757d:737:1f5b::";
        String returned2 = NetworkAddressElf.fromDatabaseString(input2);
        
        System.out.println("\nInput IP: " + input2);
        System.out.println("Expected IP: " + expected2);
        System.out.println("Returned IP: " + returned2);
        
        assertTrue(returned2.equals(expected2));
    }
    
    public void testMacAddress()
    {
        assertTrue(NetworkAddressElf.isValidMacAddress("00:12:3f:96:da:d6"));   // colon delimiter
        assertTrue(NetworkAddressElf.isValidMacAddress("  00:12:3f:96:da:d6")); // extra whitespace OK
        assertTrue(NetworkAddressElf.isValidMacAddress("  00-12-3f-96-da-d6")); // dash delimiter
        assertTrue(NetworkAddressElf.isValidMacAddress("00123f96dad6")); // no delimiter
        assertFalse(NetworkAddressElf.isValidMacAddress("3f96dad6")); // not enough
        assertFalse(NetworkAddressElf.isValidMacAddress("X0123f96dad6")); // not all hex
        assertFalse(NetworkAddressElf.isValidMacAddress("fe80::212:3fff:fe96:dad6")); // ipv6 - not a mac
    }
}
