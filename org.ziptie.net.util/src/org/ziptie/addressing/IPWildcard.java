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
import java.util.Iterator;

/**
 * IPWildcard allows the user to define a set of IPAddresses by wildcards. For example, if one always wants to match IP
 * addresses with a last octet of .1 the <code>Subnet</code>, <code>IPAddress</code> and <code>IPRange</code>
 * classes won't do. By using an <code>IPWildcard<code> of *.*.*.1 matching could be done.
 * 
 * Wildcards can be either ? or *.  Their functional regex equivalients are:<br>
 * ? = \d<br>
 * * = \d+<br>
 * <br>
 * <br>
 * Additionally octets can specify a range instead of a wildcard.  This is helpful to provide support
 * for addressing schemes.  For example, a network addressing scheme may specify that on every subnet 
 * the addresses 20-40 are reserved for servers.  The wildcard for this scheme would be:<br>
 * *.*.*.20-40
 * 
 * @author rkruse
 */
public class IPWildcard implements Comparable, Serializable, NetworkAddress
{
    private static final int BITMASK_255 = 0xFF;

    private static final long serialVersionUID = -2386859853068097496L;

    private static final String ERROR_MSG = "The address '%s' is not a valid IP address wildcard.";

    private static final short MAX_IPV4_OCTET_VALUE = 255;
    private static final short MIN_IPV4_OCTET_VALUE = 0;

    private String[] addressChunks;
    private boolean ipv6;

    /**
     * Constructor
     * 
     * @param wildcard an IP wildcard expression
     */
    public IPWildcard(String wildcard)
    {
        setIpAddress(wildcard);
    }

    /** {@inheritDoc} */
    public boolean contains(IPAddress testAddress)
    {
        if (isIpv6())
        {
            String[] addressPieces = testAddress.getInetAddress().getHostAddress().split(":");
            for (int i = 0; i < addressChunks.length; i++)
            {
                if (isRangeOctet(addressChunks[i]))
                {
                    if (!inIpV6Range(addressChunks[i], addressPieces[i]))
                    {
                        return false;
                    }
                }
                else
                {
                    String regexEquivalentOctet = resolveToRegex(addressChunks[i]);
                    if (!addressPieces[i].matches(regexEquivalentOctet))
                    {
                        return false;
                    }
                }
            }
            return true;
        }
        else
        {
            byte[] realOctets = testAddress.getInetAddress().getAddress();
            for (int i = 0; i < addressChunks.length; i++)
            {
                int realOctet = (int) realOctets[i] & BITMASK_255;
                if (isRangeOctet(addressChunks[i]))
                {
                    if (!isOctetInsideRange(addressChunks[i], realOctet))
                    {
                        return false;
                    }
                }
                else
                {
                    String regexEquivalentOctet = resolveToRegex(addressChunks[i]);
                    if (!Integer.toString(realOctet).matches(regexEquivalentOctet))
                    {
                        return false;
                    }
                }
            }
            return true;
        }
    }

    /** {@inheritDoc} */
    public int compareTo(Object anotherWildcard)
    {
        return getAddress().compareTo(((IPWildcard) anotherWildcard).getAddress());
    }

    /** {@inheritDoc} */
    public boolean getExclude()
    {
        return false;
    }

    /** {@inheritDoc} */
    public String getFirstValue()
    {
        return getAddress();
    }

    /** {@inheritDoc} */
    public String getSecondValue()
    {
        return "";
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj != null)
        {
            if (obj instanceof IPWildcard)
            {
                IPWildcard that = (IPWildcard) obj;
                return getAddress().equals(that.getAddress());
            }
        }
        return false;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return toString().hashCode();
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return getAddress();
    }

    /**
     * @return the string representation
     */
    public String getAddress()
    {
        StringBuilder toReturn = new StringBuilder();

        for (int i = 0; i < addressChunks.length; i++)
        {
            toReturn.append(addressChunks[i]);
            if (i < addressChunks.length - 1)
            {
                if (isIpv6())
                {
                    toReturn.append(":");
                }
                else
                {
                    toReturn.append(".");
                }
            }
        }
        return toReturn.toString();
    }

    /**
     * Returns true if the incoming string is an octet range.
     * 
     * This validates a few things.<br>
     * <li>the octet is in the form <i>digit-digit</i></li>
     * <li>the second part of the range is numerically greater than the first</li>
     * 
     * @param string
     * @return
     */
    private boolean isRangeOctet(String octetString)
    {
        if (isIpv6())
        {
            return (octetString.matches("[A-Za-z0-9]+-[A-Za-z0-9]+"));
        }
        else
        {

            if (octetString.matches("\\d{1,3}-\\d{1,3}"))
            {
                String[] digits = octetString.split("-");
                int dig1 = Integer.parseInt(digits[0]);
                int dig2 = Integer.parseInt(digits[1]);
                if (dig1 <= MAX_IPV4_OCTET_VALUE && dig2 <= MAX_IPV4_OCTET_VALUE && (dig1 < dig2))
                {
                    return true;
                }
            }
            return false;
        }
    }

    /**
     * Set up the octets and validate each one individually
     * 
     * @param wildcard
     * @throws IllegalArgumentException
     */
    private void setIpAddress(String wildcard)
    {
        if (wildcard.contains("."))
        {
            this.ipv6 = false;
            addressChunks = wildcard.split("\\.");
            if (addressChunks.length > 4)
            {
                throw new IllegalArgumentException("The wildcard " + wildcard + " is too long for an IPv4 wildcard.");
            }
            for (int i = 0; i < addressChunks.length; i++)
            {
                validateSection(addressChunks[i]);
            }
        }
        else if (wildcard.contains(":"))
        {
            this.ipv6 = true;
            String ipv6Wildcard = wildcard.toLowerCase();
            if (ipv6Wildcard.contains("::"))
            {
                if (ipv6Wildcard.endsWith("::"))
                {
                    ipv6Wildcard = ipv6Wildcard + "0";
                }
                else if (ipv6Wildcard.startsWith("::"))
                {
                    ipv6Wildcard = "0" + ipv6Wildcard;
                }
                int sectionCount = ipv6Wildcard.split(":").length;
                StringBuilder replacementString = new StringBuilder();
                int totalSections = 8;
                for (int i = sectionCount - 1; i <= totalSections; i++)
                {
                    replacementString.append(":");
                    if (i != totalSections)
                    {
                        replacementString.append("0");
                    }
                }
                ipv6Wildcard = ipv6Wildcard.replace("::", replacementString.toString());
            }
            addressChunks = ipv6Wildcard.split(":");
            if (addressChunks.length > 8)
            {
                throw new IllegalArgumentException("The wildcard " + wildcard + " is too long for an IPv6 wildcard.");
            }
            for (int i = 0; i < addressChunks.length; i++)
            {
                addressChunks[i] = addressChunks[i].replaceFirst("^0+(?=\\w)", ""); //remove leading 0's.  make '0ddd' into 'ddd'
                validateSection(addressChunks[i]);
            }
        }
    }

    /**
     * Validates that the string is either a valid IP address octet or it has some wildcard characters in it.
     * 
     * @param piece
     * @throws IllegalArgumentException
     */
    private void validateSection(String piece)
    {
        if (isIpv6())
        {
            if (!piece.matches("[\\dA-Fa-f*?]{1,4}") && !isRangeOctet(piece))
            {
                throw new IllegalArgumentException(String.format(ERROR_MSG, piece));
            }
        }
        else
        {
            if (piece.matches("\\d+"))
            {
                int intVal = Integer.parseInt(piece);
                if ((intVal >= MIN_IPV4_OCTET_VALUE) && (intVal <= MAX_IPV4_OCTET_VALUE))
                {
                    return;
                }
            }
            else if (piece.matches("[\\d*?]{1,3}"))
            {
                return;
            }
            else if (isRangeOctet(piece))
            {
                return;
            }
            throw new IllegalArgumentException(String.format(ERROR_MSG, piece));
        }
    }

    /**
     * Replace the wildcard characters with their regex equivalents
     * 
     * @param string
     * @return
     */
    private String resolveToRegex(String string)
    {
        String replacement = "\\\\d";
        if (isIpv6())
        {
            replacement = "\\\\da-zA-Z";
        }
        String toReturn = string.replaceAll("\\*", "[" + replacement + "]+");
        toReturn = toReturn.replaceAll("\\?", replacement);
        return toReturn;
    }

    /**
     * Identifies if a given short (45) is in between a string representation of a range (20-100).
     * 
     * @param rangeOctet
     * @param realOctet
     * @return
     */
    private boolean isOctetInsideRange(String rangeOctet, int realOctet)
    {
        String[] digits = rangeOctet.split("-");
        int dig1 = Integer.parseInt(digits[0]);
        int dig2 = Integer.parseInt(digits[1]);

        return (dig1 <= realOctet && realOctet <= dig2);
    }

    /**
     * 
     * First split the range into two hex values.  Convert the start and end to an int value.  Also convert
     * the real hex value to an int and then do a simple integer comparison.
     * 
     * @param range
     * @param realSection
     * @return true if the <code>realSection</code> is inside the <code>range</code>
     */
    private boolean inIpV6Range(String range, String realSection)
    {
        String[] rangePieces = range.split("-");
        int start = Integer.parseInt(rangePieces[0], 16);
        int end = Integer.parseInt(rangePieces[1], 16);
        int real = Integer.parseInt(realSection, 16);
        return (real >= start && real <= end);
    }

    /** {@inheritDoc} */
    @Override
    public IPWildcard clone() throws CloneNotSupportedException
    {
        // do nothing more than copy the atomic primitives.
        return (IPWildcard) super.clone();
    }

    /** {@inheritDoc} */
    public Iterator<IPAddress> iterator()
    {
        return this;
    }

    /** {@inheritDoc} */
    public boolean hasNext()
    {
        return false;
    }

    /** {@inheritDoc} */
    public IPAddress next()
    {
        return new IPAddress();
    }

    /** {@inheritDoc} */
    public void remove()
    {
        throw new UnsupportedOperationException();
    }

    /**
     * Returns true if this is an IPv6 wildcard, false otherwise.
     * 
     * @return the ipv6
     */
    public boolean isIpv6()
    {
        return ipv6;
    }
}
