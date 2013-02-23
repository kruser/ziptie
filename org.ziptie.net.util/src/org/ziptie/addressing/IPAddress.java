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

import java.io.Serializable;
import java.math.BigInteger;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Iterator;
import java.util.StringTokenizer;

import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.Transient;

import org.hibernate.annotations.AccessType;

import sun.net.util.IPAddressUtil;

/** An IP Address */
@Embeddable
@AccessType("field")
public class IPAddress implements NetworkAddress, Comparable, Serializable
{
    static final long serialVersionUID = -7645763967202294158L;

    private static final int BITMASK_255 = 0xff;

    private static final String ERROR_MSG_INVALID_TERM = "Term '%s' is not a valid number within an IP address";
    private static final char WILDCARD1 = '*';
    private static final char WILDCARD2 = '?';
    private static final char CIDRMASK = '/';
    private static final int IPV4_MAX_ELEMENTS = 4;
    private static final short IPV4_MAX_NODE_VALUE = 255;
    private static final short IPV4_MIN_NODE_VALUE = 0;

    @Column(name = "IP_LOW")
    private long ipLow;

    @Column(name = "IP_HIGH")
    private long ipHigh;

    /** A padded version of the IP address in a string format, useful for database persistence **/
    @Column(name = "IP_ADDRESS")
    private String ipAddress;

    @Transient
    private boolean hasNext = true;

    /**
     * Default IPv4 Address 
     *
     */
    public IPAddress()
    {
        try
        {
            InetAddress inetAddress = InetAddress.getByName("0.0.0.0");
            ipAddress = NetworkAddressElf.toDatabaseString(inetAddress.getHostAddress());
            long[] hiLo = NetworkAddressElf.getHiLo(ipAddress);
            ipHigh = hiLo[0];
            ipLow = hiLo[1];
        }
        catch (UnknownHostException e)
        {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    /**
     * Creates a new IP address from the provided InetAddress
     * @param inetAddress the address
     */
    public IPAddress(InetAddress inetAddress)
    {
        ipAddress = NetworkAddressElf.toDatabaseString(inetAddress.getHostAddress());
        long[] hiLo = NetworkAddressElf.getHiLo(ipAddress);
        ipHigh = hiLo[0];
        ipLow = hiLo[1];
    }

    /**
     * Create a new IP address from a string
     * @param strAddress = The stringified IP address
     */
    public IPAddress(String strAddress)
    {
        ipAddress = NetworkAddressElf.toDatabaseString(strAddress);
        long[] hiLo = NetworkAddressElf.getHiLo(ipAddress);
        ipHigh = hiLo[0];
        ipLow = hiLo[1];
    }

    /**
     * Creates an IPv4 address from the provided Integer
     * @param intAddress the int value of the address
     */
    public IPAddress(int intAddress)
    {
        this(NetworkAddressElf.intToInet4Address(intAddress));
    }

    /**
     * Creates an IPv4 address from the provided Long
     * @param longAddress the long value of the address
     */
    public IPAddress(long longAddress)
    {
        this((int) longAddress);
    }

    /**
     * Returns the {@link InetAddress} representation
     * @return the InetAddress
     */
    public InetAddress getInetAddress()
    {
        try
        {
            return InetAddress.getByName(ipAddress);
        }
        catch (UnknownHostException he)
        {
            return null;
        }
    }

    /**
     * @return the IP in string form
     * 
     */
    public String getIPAddress()
    {
        return toString();
    }

    /**
     * Get both the high and low values.
     * @return the array of size 2
     */
    public long[] getHiLo()
    {
        return new long[] { ipHigh, ipLow };
    }

    /**
     * Get the high long
     * @return the high long
     */
    public long getIpHigh()
    {
        return ipHigh;
    }

    /**
     * Get the low long
     * @return the low long
     */
    public long getIpLow()
    {
        return ipLow;
    }

    /** Compares two IP Addresses numerically.
     *
     * @param   other   the <code>IPAddress</code> to be compared.
     * @return  the value <code>0</code> if the argument IPAddress is equal to
     *          this IPAddress; a value less than <code>0</code> if this IPAddress
     *          is numerically less than the IPAddress argument; and a
     *          value greater than <code>0</code> if this IPAddress is
     *          numerically greater than the IPAddress argument
     *          (signed comparison).
     */
    public int compareTo(IPAddress other)
    {
        // The highest positive value the IP_LOW or IP_HIGH can be is 7FFF:FFFF:FFFF:FFFF,
        // which is represented numerically as 9,223,372,036,854,775,807
        // 
        // Once IP_LOW/IP_HIGH becomes 8000:0000:0000:0000, the 64th bit is toggled,
        // triggering the value to be represented as a negative number due to two's compliment.
        // 8000:0000:0000:0000 is numerically represented as -9,223,372,036,854,775,808.
        //
        // Once greater than 8000:0000:0000:0000, the numerical representation increases.
        // Eventually, the limit is reached when we reach FFFF:FFFF:FFFF:FFFF.
        // At this point, the numerical representation is -1.
        //
        // We must handle the scenario of a range crossing over the positive/negative threshold.

        // If the HI values are equal to each other, we can focus our comparison logic just on
        // the LOW values.
        if (ipHigh == other.ipHigh)
        {
            return compareLowValues(other);
        }

        // Otherwise, we only need to compare the HIGH values
        return compareHighValues(other);
    }

    /**
     * Private method only used by the {@link #compareTo(IPAddress)} method to compare
     * the LOW values from two {@link IPAddress} classes.
     * 
     * @param other The other IP address to compare to.
     * @return -1 if the left-handed IP address' LOW value is smaller than the right-handed IP address' LOW value;
     * 1 if the left handed IP address' LOW value is greater than the right-handed IP address' LOW value;
     * 0 if they are equal.
     */
    private int compareLowValues(IPAddress other)
    {
        // The highest positive value the IP_LOW or IP_HIGH can be is 7FFF:FFFF:FFFF:FFFF,
        // which is represented numerically as 9,223,372,036,854,775,807
        // 
        // Once IP_LOW/IP_HIGH becomes 8000:0000:0000:0000, the 64th bit is toggled,
        // triggering the value to be represented as a negative number due to two's compliment.
        // 8000:0000:0000:0000 is numerically represented as -9,223,372,036,854,775,808.
        //
        // Once greater than 8000:0000:0000:0000, the numerical representation increases.
        // Eventually, the limit is reached when we reach FFFF:FFFF:FFFF:FFFF.
        // At this point, the numerical representation is -1.
        //
        // We must handle the scenario of a range crossing over the positive/negative threshold.

        // If the LOW values are equal to each other, the IP addresses are identical
        if (ipLow == other.ipLow)
        {
            return 0;
        }
        // Verify that both of the LOW values are on the same side of the positive/negative threshold.
        // This will allow for simple greater than or less than checks.
        else if ((ipLow < 0 && other.ipLow < 0) || (ipLow >= 0 && other.ipLow >= 0))
        {
            if (ipLow < other.ipLow)
            {
                return -1;
            }

            return 1;
        }
        // Otherwise, the LOW values are on both sides of the positive/negative threshold and we must
        // adjust comparison logic accordingly.
        else
        {
            // Check to see if the left-handed LOW value is greater than zero.
            //
            // If so, we know that the LOW value that is positive is actually
            // the smaller of the two LOW values due to numerical representation of
            // a 64-bit value switching signs once the 64th bit has been toggled.
            //
            // Read the comment at the top of this method for more clarification.
            if (ipLow >= 0)
            {
                return -1;
            }

            return 1;
        }
    }

    /**
     * Private method only used by the {@link #compareTo(IPAddress)} method to compare
     * the HIGH values from two {@link IPAddress} classes.
     * 
     * @param other The other IP address to compare to.
     * @return -1 if the left-handed IP address' HIGH value is smaller than the right-handed IP address' HIGH value;
     * 1 if the left handed IP address' HIGH value is greater than the right-handed IP address' HIGH value;
     * 0 if they are equal.
     */
    private int compareHighValues(IPAddress other)
    {
        // The highest positive value the IP_LOW or IP_HIGH can be is 7FFF:FFFF:FFFF:FFFF,
        // which is represented numerically as 9,223,372,036,854,775,807
        // 
        // Once IP_LOW/IP_HIGH becomes 8000:0000:0000:0000, the 64th bit is toggled,
        // triggering the value to be represented as a negative number due to two's compliment.
        // 8000:0000:0000:0000 is numerically represented as -9,223,372,036,854,775,808.
        //
        // Once greater than 8000:0000:0000:0000, the numerical representation increases.
        // Eventually, the limit is reached when we reach FFFF:FFFF:FFFF:FFFF.
        // At this point, the numerical representation is -1.
        //
        // We must handle the scenario of a range crossing over the positive/negative threshold.

        // Verify that both of the HIGH values are on the same side of the positive/negative threshold
        // This will allow for simple greater than or less than checks.
        if ((ipHigh < 0 && other.ipHigh < 0) || (ipHigh >= 0 && other.ipHigh >= 0))
        {
            if (ipHigh < other.ipHigh)
            {
                return -1;
            }

            return 1;
        }

        // Otherwise, the HIGH values are on both sides of the positive/negative threshold and we must
        // adjust comparison logic accordingly.
        else
        {
            // Check to see if the left-handed HIGH value is greater than zero.
            //
            // If so, we know that the HIGH value that is positive is actually
            // the smaller of the two HIGH values due to numerical representation of
            // a 64-bit value switching signs once the 64th bit has been toggled.
            //
            // Read the comment at the top of this method for more clarification.
            if (ipHigh >= 0)
            {
                return -1;
            }

            return 1;
        }
    }

    /** Compares this IPAddress to another Object.  If the Object is a IPAddress,
     * this function behaves like <code>compareTo(IPAddress)</code>.  Otherwise,
     * it throws a <code>ClassCastException</code> (as IPAddresses are comparable
     * only to other IPAddresses).
     *
     * @param   o the <code>Object</code> to be compared.
     * @return  the value <code>0</code> if the argument is a IPAddress
     *   numerically equal to this IPAddress; a value less than
     *   <code>0</code> if the argument is a IPAddress numerically
     *   greater than this IPAddress; and a value greater than
     *   <code>0</code> if the argument is a IPAddress numerically
     *   less than this IPAddress.
     * @see     java.lang.Comparable */
    public int compareTo(Object o)
    {
        return compareTo((IPAddress) o);
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj instanceof IPAddress)
        {
            IPAddress other = (IPAddress) obj;
            return ipLow == other.ipLow && ipHigh == other.ipHigh;
        }
        else
        {
            return false;
        }
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return ipAddress.hashCode();
    }

    /**
     * @param addressMask the mask
     * @return the network address
     */
    public IPAddress mask(IPAddress addressMask)
    {
        if (isVersion6())
        {
            BigInteger address = new BigInteger(getInetAddress().getAddress());
            BigInteger mask = new BigInteger(addressMask.getInetAddress().getAddress());
            return NetworkAddressElf.bigIntToIP(address.and(mask), 6);
        }
        else
        {
            long maskedAddress = ipLow & addressMask.ipLow;
            return new IPAddress(maskedAddress);
        }
    }

    /**
     * @param maskBits how to mask this address
     * @return the IP
     */
    public IPAddress mask(short maskBits)
    {
        if (isVersion6())
        {
            BigInteger bigInt = new BigInteger(getInetAddress().getAddress());
            BigInteger minLong = BigInteger.valueOf(Long.MIN_VALUE);
            BigInteger minBig = minLong.multiply(minLong).negate();
            BigInteger integer = bigInt.and(minBig.shiftRight(maskBits - 1));
            return NetworkAddressElf.bigIntToIP(integer, 6);
        }
        else
        {
            long maskedAddress = ipLow & Integer.MIN_VALUE >> (maskBits - 1);
            return new IPAddress(maskedAddress);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString()
    {
        return NetworkAddressElf.fromDatabaseString(ipAddress);
    }

    /**
     * Returns true if this IPAddress is an IPv6 address.  Returns false if it is an IPv4 address.
     * @return true if IPv6
     */
    public boolean isVersion6()
    {
        return IPAddressUtil.isIPv6LiteralAddress(ipAddress);
    }

    /**
     * Returns a padded string version of this IP Address that can be easily sorted.
     * 
     * For example, 192.168.1.50 will return as 192.168.001.050
     * @return The padded string version of the IP address that this {@link IPAddress} object represents.
     */
    public String toDatabaseString()
    {
        return ipAddress;
    }

    /**
     * @param inputPattern the filter patter
     * @return the filter string
     */
    public static String toFilterString(String inputPattern)
    {
        StringTokenizer strTok = new StringTokenizer(inputPattern, ".");
        StringBuffer buffer = new StringBuffer();
        int tokenCount = 0;

        while (strTok.hasMoreTokens())
        {
            tokenCount++;
            if (tokenCount > IPV4_MAX_ELEMENTS)
            {
                throw new IllegalArgumentException("Invalid filter pattern");
            }
            buffer.append(getTokenPattern(strTok.nextToken()));
            if (strTok.hasMoreTokens())
            {
                buffer.append('.');
            }
        }
        return buffer.toString().intern();
    }

    private static void validateToken(String token)
    {
        if (token.indexOf('%') > -1 || token.indexOf('_') > -1)
        {
            return;
        }

        if (token.indexOf('*') > -1 || token.indexOf('?') > -1)
        {
            return;
        }

        if (!isShort(token))
        {
            throw new IllegalArgumentException(String.format(ERROR_MSG_INVALID_TERM, token));
        }
        if (!isInRange(Short.parseShort(token)))
        {
            throw new IllegalArgumentException("Term '" + token + "' is not between " + IPV4_MIN_NODE_VALUE + " and " + IPV4_MAX_NODE_VALUE);
        }
    }

    /**
     * @param token an IP string
     * @return true if the given string is a valid IP address
     */
    public static boolean isValidIPAddress(String token)
    {
        if (!isShort(token))
        {
            return false;
        }
        return isInRange(Short.parseShort(token));
    }

    private static boolean isShort(String token)
    {
        try
        {
            Short.parseShort(token);
            return true;
        }
        catch (NumberFormatException nfe)
        {
            return false;
        }
    }

    private static boolean isInRange(short term)
    {
        if (term > IPV4_MAX_NODE_VALUE || term < IPV4_MIN_NODE_VALUE)
        {
            return false;
        }
        return true;
    }

    private static String getTokenPattern(String token)
    {
        int digitCount = 0;
        int wildcardCount = 0;
        boolean digitFirst = false;

        for (int i = 0; i < token.length(); i++)
        {
            char tokenChar = token.charAt(i);
            if (Character.isDigit(tokenChar))
            {
                digitCount++;
                if (i == 0)
                {
                    digitFirst = true;
                }
            }
            else if (tokenChar == WILDCARD1 || tokenChar == WILDCARD2 || tokenChar == CIDRMASK)
            {
                wildcardCount++;
            }
        }

        if (wildcardCount == 0)
        {
            validateToken(token);
            return new String(zeroFillNumber(token));
        }
        else
        {
            return fillPatternToken(token, digitFirst);
        }
    }

    private static char[] zeroFillNumber(String number)
    {
        char[] buf = new char[] { '0', '0', '0' };

        number.getChars(0, number.length(), buf, 3 - number.length());

        return buf;
    }

    private static String fillPatternToken(String token, boolean digitFirst)
    {
        StringBuffer pattern = new StringBuffer(3);
        char lastCharacter = 0;
        char tokenChar;
        int size = token.length();
        for (int i = 0; i < size; i++)
        {
            tokenChar = token.charAt(i);
            if (tokenChar == lastCharacter && (tokenChar == WILDCARD1))
            {
                // skip the insert
                lastCharacter = tokenChar;
            }
            else
            {
                pattern.insert(i, tokenChar);
                lastCharacter = tokenChar;
            }
        }

        if (token.indexOf(WILDCARD2) > -1)
        {
            String cleantoken = token.replaceAll("\\*", "");
            for (int i = cleantoken.length(); i < 3; i++)
            {
                pattern.insert(0, '0');
            }
        }

        return pattern.toString();
    }

    /**
     * {@inheritDoc}
     */
    public String getFirstValue()
    {
        return toString().intern();
    }

    /**
     * {@inheritDoc}
     */
    public String getSecondValue()
    {
        return "";
    }

    /**
     * {@inheritDoc}
     */
    public boolean getExclude()
    {
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public boolean contains(IPAddress testAddress)
    {
        return equals(testAddress);
    }

    /** {@inheritDoc} */
    @Override
    public IPAddress clone() throws CloneNotSupportedException
    {
        // do nothing more than copy the atomic primitives.
        return (IPAddress) super.clone();
    }

    /**
     * {@inheritDoc}
     */
    public Iterator<IPAddress> iterator()
    {
        hasNext = true; // reset the iterator variables
        return this;
    }

    /**
     * {@inheritDoc}
     */
    public boolean hasNext()
    {
        return hasNext;
    }

    /**
     * {@inheritDoc}
     */
    public IPAddress next()
    {
        if (hasNext)
        {
            hasNext = false;
        }
        return this;
    }

    /**
     * @see java.util.Iterator#remove()
     */
    public void remove()
    {
        throw new UnsupportedOperationException();
    }
}
