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

import java.math.BigInteger;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.regex.Pattern;

import org.ziptie.exception.NonContiguousSubnetMask;

import sun.net.util.IPAddressUtil;

// CHECKSTYLE:ON

/**
 * NetworkAddressElf
 */
public final class NetworkAddressElf
{
    public static final Pattern VALID_HOSTNAME = Pattern.compile("((?:[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\\.)*[a-z0-9](?:[-a-z0-9]*[a-z0-9])?)");
    private static final String DB_IPV4_FORMAT = "%03d.%03d.%03d.%03d";

    private static final int HI = 0;
    private static final int LO = 1;
    private static final int OFF_0XFF = 0xff;

    private NetworkAddressElf()
    {
        // private constructor
    }

    /**
     * Parse a string representing an IP address, IP address and CIDR, or IP address range.
     *
     * @param ipStringThing the IP address string thing
     * @return a NetworkAddress
     */
    public static NetworkAddress parseAddress(String ipStringThing)
    {
        if (isValidIpAddress(ipStringThing))
        {
            return new IPAddress(ipStringThing);
        }
        else if (isValidRange(ipStringThing))
        {
            String[] addresses = ipStringThing.split("-");
            return new IPRange(addresses[0], addresses[1]);
        }
        else if (isValidCidr(ipStringThing))
        {
            String[] addresses = ipStringThing.split("/");
            return new Subnet(new IPAddress(addresses[0]), Short.parseShort(addresses[1]));
        }
        else if (isIpv4NetworkWithMask(ipStringThing))
        {
            String[] addresses = ipStringThing.split("\\s+");
            try
            {
                return new Subnet(new IPAddress(addresses[0]), new IPAddress(addresses[1]));
            }
            catch (NonContiguousSubnetMask e)
            {
                throw new RuntimeException(e);
            }
        }
        else
        {
            try
            {
                return new IPWildcard(ipStringThing);
            }
            catch (IllegalArgumentException e)
            {
                return null;
            }
        }
    }

    /**
     * This method will take an IPv4 address, IPv6 address, or a hostname and
     * convert it into a consistent format for storage in the database.  The format
     * is such that standard character collation order is capable of sorting the
     * addresses in correct ascending/decending order.  If the provided string is
     * a IPv4 address, it will be zero padded like so:
     * <pre>
     *    Input:  192.168.1.32
     *    Output: 192.168.001.032
     * </pre>
     * If the string provided is an IPv6 address, it is converted into it's
     * canonical form like so:
     * <pre>
     *    Input:  2001:db8::1428:57ab
     *    Output: 2001:0DB8:0000:0000:0000:0000:1428:57AB
     * </pre>
     * If the string provided is a hostname, it is resolved and converted to
     * IPv6 canonical form.
     *
     * @param host a String representing an IPv6 address, IPv6 address, or hostname
     * @return an IPv4 or IPv6 address suitable for storage in a database
     */
    public static String toDatabaseString(String host)
    {
        if (host == null)
        {
            return host;
        }

        String trimHost = host.trim();
        if (IPAddressUtil.isIPv4LiteralAddress(trimHost))
        {
            byte[] bs = IPAddressUtil.textToNumericFormatV4(trimHost);
            return String.format(DB_IPV4_FORMAT, getUnsignedByte(bs[0]), getUnsignedByte(bs[1]), getUnsignedByte(bs[2]), getUnsignedByte(bs[3]));
        }
        else if (IPAddressUtil.isIPv6LiteralAddress(trimHost))
        {
            byte[] bs = IPAddressUtil.textToNumericFormatV6(trimHost);
            if (bs.length == 4)
            {
                return String.format(DB_IPV4_FORMAT, getUnsignedByte(bs[0]), getUnsignedByte(bs[1]), getUnsignedByte(bs[2]), getUnsignedByte(bs[3]));
            }

            // CHECKSTYLE:OFF
            return String.format("%02X%02X:%02X%02X:%02X%02X:%02X%02X:%02X%02X:%02X%02X:%02X%02X:%02X%02X", bs[0], bs[1], bs[2], bs[3], bs[4], bs[5], bs[6],
                                 bs[7], bs[8], bs[9], bs[10], bs[11], bs[12], bs[13], bs[14], bs[15]);
            // CHECKSTYLE:ON
        }
        else
        {
            try
            {
                InetAddress byName = Inet6Address.getByName(trimHost);
                return byName.getHostAddress();
            }
            catch (UnknownHostException e)
            {
                throw new RuntimeException(e);
            }
        }
    }

    /**
     * Convert a database string representation to a normal string representation.
     * <p>
     * <p>
     * If the address is an IPv6 address, compressing it means removing any leading zeros from the beginning
     * of the address and each segment, and collapsing the longest string of zeroes with a double colon notation (::).
     * The following are some examples of collapsed IPv6 addresses:
     * <p>
     * <p>
     * "0001:0db8:0100:1000:0:1:1428:57ab" compresses to "1:db8:100:1000::1:1428:57ab"
     * "2008:757D:0737:1F5B:0000:000:00:0" compresses to "2008:757d:737:1f5b::"
     *
     * @param ipAddress The database representation of the IP address.
     * @return a String representing an IPv6 address or IPv6 address
     * @see #toDatabaseString(String)
     */
    public static String fromDatabaseString(String ipAddress)
    {
        try
        {
            if (IPAddressUtil.isIPv4LiteralAddress(ipAddress))
            {
                return InetAddress.getByAddress(null, IPAddressUtil.textToNumericFormatV4(ipAddress)).getHostAddress();
            }
            else if (IPAddressUtil.isIPv6LiteralAddress(ipAddress))
            {
                // Get the full blown IPv6 address
                String ipAddrToCompress = InetAddress.getByAddress(null, IPAddressUtil.textToNumericFormatV6(ipAddress)).getHostAddress();

                // Split the string into its 8 separate groups
                String[] ipv6Split = ipAddrToCompress.split(":");

                // Indicies to store
                int longestStartIndex = -1;
                int longestEndIndex = -1;
                int currentStartIndex = -1;
                int currentEndIndex = -1;

                // Iterate over the string array and determine the indicies that form the longest set of zeros
                for (int i = 0; i < ipv6Split.length; i++)
                {
                    // If the string is zero...
                    if (ipv6Split[i].equalsIgnoreCase("0"))
                    {
                        // See if we haven't already set the start index
                        if (currentStartIndex == -1)
                        {
                            currentStartIndex = i;
                        }

                        // Set the current end index to the current index
                        currentEndIndex = i;
                    }
                    else
                    {
                        // Otherwise, we need to close out the current search and store the indicies we
                        // captured if they represent the longest range.
                        if (currentStartIndex > longestStartIndex && (currentEndIndex - currentStartIndex) >= (longestEndIndex - longestStartIndex))
                        {
                            longestStartIndex = currentStartIndex;
                            longestEndIndex = currentEndIndex;
                        }

                        // Reset the current indicies
                        currentStartIndex = -1;
                        currentEndIndex = -1;
                    }
                }

                // Special check: Check to see if the IP address ended in trailing zeros that could represent
                // the longest sequence of zeros
                if (currentStartIndex > longestStartIndex && (currentEndIndex - currentStartIndex) >= (longestEndIndex - longestStartIndex))
                {
                    longestStartIndex = currentStartIndex;
                    longestEndIndex = currentEndIndex;
                }

                // Now it's time to construct the compress IP address.
                StringBuilder ipStrBuilder = new StringBuilder();

                for (int i = 0; i < ipv6Split.length; i++)
                {
                    // If the current index is outside of the indexed range, append the string.
                    if (i < longestStartIndex || i > longestEndIndex)
                    {
                        ipStrBuilder.append(ipv6Split[i]);

                        // Special check: If we aren't on the last string segment, append a colon.
                        // Doing this on the last string segment will result in an improper amount of
                        // colons.
                        if (i < (ipv6Split.length - 1))
                        {
                            ipStrBuilder.append(":");
                        }
                    }
                    // If this is the ending index of the longest sequence, append the proper double colon
                    else if (i == longestEndIndex)
                    {
                        // Special check: If the longest sequence started at index 0, append two colons.
                        if (longestStartIndex == 0)
                        {
                            ipStrBuilder.append("::");
                        }
                        // If we aren't on the last string segment, append just a single colon. This is because
                        // prior string segments end with a colon, so we only need one more.
                        else
                        {
                            ipStrBuilder.append(":");
                        }
                    }
                }

                // Set the compressed IP address
                return ipStrBuilder.toString();
            }
        }
        catch (UnknownHostException e)
        {
            return ipAddress;
        }
        return ipAddress;
    }

    /**
     * Resolve a hostname.
     *
     * @param ipAddress the ipAddress or hostname to resolve.
     * @return the hostname or null
     */
    public static String resolveHostname(String ipAddress)
    {
        try
        {
            InetAddress byName = InetAddress.getByName(ipAddress);
            return byName.getHostName();
        }
        catch (UnknownHostException e)
        {
            return null;
        }
    }

    /**
     * Tests whether a string is a valid hostname.
     *
     * @param hostname the hostname to check
     * @return true if valid, false otherwise
     */
    public static boolean isValidHostname(String hostname)
    {
        if (hostname == null)
        {
            return false;
        }

        return VALID_HOSTNAME.matcher(hostname).matches();
    }

    /**
     * Tests whether the address is a valid IPv4 or IPv6 address.
     *
     * @param address the address to validate
     * @return true if valid, false if not
     */
    public static boolean isValidAddress(String address)
    {
        if (address == null)
        {
            return false;
        }
        return isValidIpAddress(address) || isValidHostname(address);
    }

    /**
     * Convert and IP address (or hostname after resolution) into 'high long' and 'low long' 64-bit integers.
     * An IPv4 address will only be represented by a 'low long' value meaning that the 'high-long' will be 0.
     * An IPv6 address (128 bits) will be represented by both a 'high long' and a 'low long' value for both
     * the upper 64-bits and the lower 64-bits of the address.
     *
     * @param host the IPv4 address, IPv6 address, or hostname
     * @return an array of two longs, a "high long" and a "low long"
     */
    public static long[] getHiLo(String host)
    {
        long[] hilo = new long[2];

        if (IPAddressUtil.isIPv4LiteralAddress(host))
        {
            // No loops == very fast
            byte[] bs = IPAddressUtil.textToNumericFormatV4(host);
            hilo[LO] |= getUnsignedByte(bs[0]);
            hilo[LO] <<= 8;
            hilo[LO] |= getUnsignedByte(bs[1]);
            hilo[LO] <<= 8;
            hilo[LO] |= getUnsignedByte(bs[2]);
            hilo[LO] <<= 8;
            hilo[LO] |= getUnsignedByte(bs[3]);
        }
        else if (IPAddressUtil.isIPv6LiteralAddress(host))
        {
            // No loops == very fast
            byte[] bs = IPAddressUtil.textToNumericFormatV6(host);
            if (bs.length == 4)
            {
                hilo[LO] |= getUnsignedByte(bs[0]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[1]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[2]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[3]);
            }
            else
            {
                // CHECKSTYLE:OFF
                hilo[HI] |= getUnsignedByte(bs[0]);
                hilo[HI] <<= 8;
                hilo[HI] |= getUnsignedByte(bs[1]);
                hilo[HI] <<= 8;
                hilo[HI] |= getUnsignedByte(bs[2]);
                hilo[HI] <<= 8;
                hilo[HI] |= getUnsignedByte(bs[3]);
                hilo[HI] <<= 8;
                hilo[HI] |= getUnsignedByte(bs[4]);
                hilo[HI] <<= 8;
                hilo[HI] |= getUnsignedByte(bs[5]);
                hilo[HI] <<= 8;
                hilo[HI] |= getUnsignedByte(bs[6]);
                hilo[HI] <<= 8;
                hilo[HI] |= getUnsignedByte(bs[7]);
                hilo[LO] |= getUnsignedByte(bs[8]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[9]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[10]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[11]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[12]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[13]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[14]);
                hilo[LO] <<= 8;
                hilo[LO] |= getUnsignedByte(bs[15]);
                // CHECKSTYLE:ON
            }
        }
        else
        {
            try
            {
                InetAddress byName = Inet6Address.getByName(host);
                return getHiLo(byName.getHostAddress());
            }
            catch (UnknownHostException e)
            {
                throw new RuntimeException(e);
            }
        }

        return hilo;
    }

    /**
     * Generates an array of high and low values that represent the range of IP addresses defined by a valid
     * IP CIDR mask string.  This IP CIDR mask string must contain a valid IPv4 or IPv6 address and a valid CIDR mask,
     * delimited by a forward slash.
     * <p>
     * The array returned by a call to {@link #getHiLoRange(String)} will always contain 3 elements:
     * <p>
     * <p>
     * [0]: Hi-word value of the ending IP address in the range if and only if the IP address in the CIDR constraint
     *      is IPv6 AND the CIDR mask is less than 64 (0 - 63); otherwise, this element will be null.
     * <p>
     * [1]: If the IP address in the CIDR constraint is v4, this element will contain the low-word value of the ending
     *      IP address in the range.
     *      If the IP address in the CIDR constraint is v6 and the CIDR mask is 64 or greater, this element will contain
     *      the hi-word value of the starting IP address in the range.
     * <p>
     * [2]: Low-word value of the starting IP address in the range if and only if the IP address in the CIDR constraint
     *      is IPv4.
     * @param cidrString A string containing a valid IPv4 or IPv6 address and a valid CIDR mask, delimited by a forward slash.
     * @return An array of high and low values that represent the range of IP addresses defined by a valid IP CIDR mask string.
     */
    public static Long[] getHiLoRange(String cidrString)
    {
        Long[] range = new Long[3];

        String[] ipAndCidr = cidrString.split("/");
        if (ipAndCidr.length != 2)
        {
            throw new RuntimeException("Invalid CIDR expression");
        }

        long[] hilo = getHiLo(ipAndCidr[0]);

        int cidr = Integer.valueOf(ipAndCidr[1]);
        if (IPAddressUtil.isIPv4LiteralAddress(ipAndCidr[0]) && cidr <= 32 && cidr >= 0)
        {
            range[0] = null;

            long mask = -1L << (32 - cidr);
            long upper = (hilo[1] & mask) | ~mask;
            long lower = (hilo[1] & mask);
            range[1] = upper;
            range[2] = lower;
        }
        else if (IPAddressUtil.isIPv6LiteralAddress(ipAndCidr[0]) && cidr <= 128 && cidr >= 0)
        {
            if (cidr < 64)
            {
                range[2] = null;

                long mask = -1L << (64 - cidr);
                long upper = (hilo[0] & mask) | ~mask;
                long lower = (hilo[0] & mask);
                range[0] = upper;
                range[1] = lower;
            }
            else
            {
                range[0] = null;

                long mask = -1L << (128 - cidr);
                long upper = (hilo[1] & mask) | ~mask;
                long lower = (hilo[1] & mask);
                range[1] = upper;
                range[2] = lower;
            }
        }
        else
        {
            throw new RuntimeException("Invalid IP address.");
        }

        return range;
    }

    /**
     * Check whether the address string represents an IPv6 CIDR mask
     * or an IPv6 address.
     *
     * @param address the address string to test
     * @return true if the string represents and IPv6 CIDR mask or address,
     *    false otherwise
     */
    public static boolean isIPv6AddressOrMask(String address)
    {
        String[] ipAndMask = address.split("/");
        if (ipAndMask.length == 1)
        {
            return IPAddressUtil.isIPv6LiteralAddress(address);
        }
        else if (ipAndMask.length == 2)
        {
            return IPAddressUtil.isIPv6LiteralAddress(ipAndMask[0]);
        }

        return false;
    }

    /**
     * Takes an integer and converts it to an IPv4 {@link InetAddress}
     * @param intAddress the integer version of the address
     * @return the resulting InetAddress
     */
    public static InetAddress intToInet4Address(int intAddress)
    {
        short[] addressOctets = new short[4];
        int mask = OFF_0XFF;
        int addressOctet = 0;
        for (int i = 0; i < 4; i++)
        {
            addressOctet = intAddress & mask;
            addressOctet >>>= i * 8;
            addressOctets[4 - i - 1] = (short) addressOctet;
            mask <<= 8;
        }
        StringBuffer outStringBuffer = new StringBuffer();
        outStringBuffer.append(addressOctets[0]);
        outStringBuffer.append('.');
        outStringBuffer.append(addressOctets[1]);
        outStringBuffer.append('.');
        outStringBuffer.append(addressOctets[2]);
        outStringBuffer.append('.');
        outStringBuffer.append(addressOctets[3]);
        try
        {
            return InetAddress.getByName(outStringBuffer.toString());
        }
        catch (UnknownHostException e)
        {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    /**
     * tests a string to see if it represents an IP address range.  e.g. 10.100.20.0-10.100.20.240 would be valid.
     * @param ipStringThing the string to test
     * @return true if it is in the format of an IP range.
     */
    private static boolean isValidRange(String ipStringThing)
    {
        if (ipStringThing.contains("-"))
        {
            String[] addresses = ipStringThing.split("-");
            return isValidIpAddress(addresses[0]) && isValidAddress(addresses[1]);
        }
        return false;
    }

    /**
     * Validates a CIDR mask.
     * @param address the address.
     * @return <code>true</code> for a valid CIDR, <code>false</code> otherwise.
     */
    public static boolean isValidCidr(String address)
    {
        if (address.contains("/"))
        {
            String[] addresses = address.split("/");
            try
            {
                int bitmask = Integer.parseInt(addresses[1]);
                if (bitmask < 0)
                {
                    return false;
                }
                else if (IPAddressUtil.isIPv4LiteralAddress(addresses[0]) && bitmask <= 32)
                {
                    return true;
                }
                else if (IPAddressUtil.isIPv6LiteralAddress(addresses[0]) && bitmask <= 128)
                {
                    return true;
                }
            }
            catch (NumberFormatException e)
            {
                return false;
            }

        }
        return false;
    }

    /**
     * Since IPv4 networks can be defined with a decimal mask like '10.100.20.0 255.255.255.0',
     * this checks that case.  Note that IPv6 networks can only be defined with a CIDR bit mask.
     *
     * @param address the address and mask
     * @return true if this is a IP mask definition
     */
    private static boolean isIpv4NetworkWithMask(String address)
    {
        if (address.contains("\\s+"))
        {
            String[] addresses = address.split("\\+");
            return IPAddressUtil.isIPv4LiteralAddress(addresses[0]) && IPAddressUtil.isIPv4LiteralAddress(addresses[1]);
        }
        return false;
    }

    /**
     *
     * @param address
     * @return true if the address provided is a good IPv4 or IPv6 address
     */
    public static boolean isValidIpAddress(String address)
    {
        return (IPAddressUtil.isIPv4LiteralAddress(address) || IPAddressUtil.isIPv6LiteralAddress(address));
    }

    private static long getUnsignedByte(byte b)
    {
        return (b >= 0 ? b : (long) b + 256L);
    }

    /**
     *
     * @param integer the BigInteger value of the IP address.
     * @param version only 6 and 4 are valid values,  Anything but 6 defaults to 4.
     * @return the IPAddress
     */
    public static IPAddress bigIntToIP(BigInteger integer, int version)
    {
        int arrayLength = 4;
        if (version == 6)
        {
            arrayLength = 16;
        }
        byte[] fullByteArray = new byte[arrayLength];
        byte[] bigInt = integer.toByteArray();
        // first pad it. The motivation for the min() is that bigInt.length may actually return one bit more
        // the max arrayLength because if the high-bit of the 128 bit ipv6 address is set, it'll actually
        // add a two's-complement sign bit - effectively returning 129 bits.
        int bigIntLength = Math.min(bigInt.length, arrayLength);
        int filler = arrayLength - bigIntLength;
        for (int i = 0; i < filler; i++)
        {
            fullByteArray[i] = 0;
        }
        // now fill the rest with legitimate bytes
        for (int i = 0; i < bigIntLength; i++)
        {
            fullByteArray[i + filler] = bigInt[i];
        }

        try
        {
            return new IPAddress(InetAddress.getByAddress(fullByteArray));
        }
        catch (UnknownHostException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Tests that a MAC address has one or two hex chars between a : or - delimiter.  It can also simply be 12 hex chars without delimiters
     * @param macAddress the mac to test
     * @return true if valid
     */
    public static boolean isValidMacAddress(String macAddress)
    {
        String mac = macAddress.trim();
        if (mac.matches("(([0-9a-fA-F]){1,2}[-:]){5}([0-9a-fA-F]){1,2}"))
        {
            return true;
        }
        else if (mac.matches("([0-9a-fA-F]){12}"))
        {
            return true;
        }
        return false;
    }
}
