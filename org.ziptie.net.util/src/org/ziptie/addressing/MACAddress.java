/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint. Portions created by
 * AlterPoint are Copyright (C) 2006, AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.addressing;

/**
 * Media Access Control address, a hardware address that uniquely identifies each node of a network. This class provides
 * a common formatting technique but can be created from most formats. <br>
 * <br>
 * E.g. <b>abcdef123456</b> will format to <b>AB-CD-EF-12-34-56</b>
 */
public class MACAddress
{
    private static final int MAC_ADDRESS_LENGTH = 12;
    private long macAddress;

    /**
     * Build a MAC address
     * @param address the MAC address in string form
     */
    public MACAddress(String address)
    {
        setMACAddress(address);
    }

    /**
     * Create a MAC from the integer representation
     * @param address the long representation of an address
     */
    public MACAddress(long address)
    {
        this.macAddress = address;
    }

    /**
     * The MAC address is an address that uniquely identifies each node of a network.
     * @return the MAC
     */
    public String getMACAddress()
    {
        // Add - delimiters at every two chars
        StringBuilder withDelimiters = new StringBuilder();
        String hexString = Long.toHexString(macAddress).toUpperCase();
        StringBuilder padZeros = new StringBuilder();
        for (int i = 0; i < (MAC_ADDRESS_LENGTH - hexString.length()); i++)
        {
            padZeros.append("0");
        }
        padZeros.append(hexString);
        char[] macChars = padZeros.toString().toCharArray();
        for (int i = 0; i < macChars.length; i++)
        {
            withDelimiters.append(macChars[i]);
            if ((i + 1) % 2 == 0 && i < macChars.length - 1)
            {
                withDelimiters.append("-");
            }
        }
        return withDelimiters.toString();
    }

    /**
     * Return the MAC address as a long
     * @return the long version of the MAC
     */
    public long getMacLong()
    {
        return macAddress;
    }

    /**
     * @param address the MAC address in string form
     */
    public void setMACAddress(String address)
    {
        String formatted = address;

        // Remove anything not a HEX char, delimiter or search char (? or *)
        formatted = formatted.replaceAll("[^A-Fa-f0-9\\.:\\-]", "");

        // Now replace any shorted sections with the correct padding
        StringBuilder builder = new StringBuilder();
        formatted = formatted.toUpperCase();
        String[] splits = formatted.split("[\\.:\\-]");
        for (int i = 0; i < splits.length; i++)
        {
            if (splits[i].length() == 1)
            {
                builder.append("0");
            }
            builder.append(splits[i]);
        }
        macAddress = Long.parseLong(builder.toString(), 16);
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return getMACAddress();
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (macAddress ^ (macAddress >>> 32));
        return result;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (this == obj)
        {
            return true;
        }
        if (obj == null)
        {
            return false;
        }
        if (getClass() != obj.getClass())
        {
            return false;
        }
        final MACAddress other = (MACAddress) obj;
        if (macAddress != other.macAddress)
        {
            return false;
        }
        return true;
    }
}
