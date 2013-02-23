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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim.util;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * A set of utility methods for the simulator.
 */
public final class Util
{
    /**
     * Compare equality of the end of <code>str</code> with <code>suffix</code>.  This starts from the end of both strings.
     * 
     * @param str
     * @param sufix
     * @return
     */
    public static boolean reverseEndsWith(CharSequence str, CharSequence sufix)
    {
        int sufixPos = sufix.length();
        int strPos = str.length();

        if (sufixPos > strPos)
        {
            return false;
        }

        while (sufixPos > 0)
        {
            sufixPos--;
            strPos--;

            if (str.charAt(strPos) != sufix.charAt(sufixPos))
            {
                return false;
            }
        }

        return true;
    }

    /**
     * Compares equality starting with the last character moving backward.
     * 
     * @param one
     * @param two
     * @return
     */
    public static boolean reverseEquals(CharSequence one, CharSequence two)
    {
        int len = one.length();
        if (len != two.length())
        {
            return false;
        }

        return reverseEndsWith(one, two);
    }

    public static int indexOf(CharSequence str, CharSequence find)
    {
        return indexOf(str, find, 0);
    }

    public static int indexOf(CharSequence str, CharSequence find, int from)
    {
        return indexOf(str, 0, str.length(), find, 0, find.length(), from);
    }

    /**
     * Replaces all occurances of <code>old</code> with <code>newStr</code> in <code>str</code>
     * @throws IOException
     */
    public static CharSequence replaceLiteral(CharSequence str, CharSequence old, CharSequence newStr)
    {
        // If the character sequence to replace is empty, then do not try and replace it.
        if (old.length() == 0)
        {
            return new CharSequenceBuffer(toCharArray(str));
        }
        
        // start with a sufficiantly large buffer to prevent excesive resizing
        CharSequenceBuffer buf = new CharSequenceBuffer(str.length());

        char[] newCharBuf = toCharArray(newStr);

        int oldStrLen = old.length();
        int strCursor = 0;
        int index = -1;
        while ((index = indexOf(str, old, ++index)) != -1)
        {
            buf.prepareToWrite(index - strCursor);
            for (; strCursor < index; strCursor++)
            {
                buf.write(str.charAt(strCursor));
            }
            strCursor += oldStrLen;
            buf.write(newCharBuf);
        }

        // Append remaining data
        int len = str.length();
        buf.prepareToWrite(len - strCursor);
        for (; strCursor < len; strCursor++)
        {
            buf.write(str.charAt(strCursor));
        }

        return buf;
    }

    public static char[] toCharArray(CharSequence seq)
    {
        char[] buf = new char[seq.length()];
        for (int i = 0; i < buf.length; i++)
        {
            buf[i] = seq.charAt(i);
        }
        return buf;
    }

    /**
     * @see String#indexOf(char[], int, int, char[], int, int, int)
     * @param source
     * @param sourceOffset
     * @param sourceCount
     * @param target
     * @param targetOffset
     * @param targetCount
     * @param fromIndex
     * @return
     */
    static int indexOf(CharSequence source, int sourceOffset, int sourceCount, CharSequence target, int targetOffset, int targetCount, int fromIndex)
    {
        if (fromIndex >= sourceCount)
        {
            return (targetCount == 0 ? sourceCount : -1);
        }
        if (fromIndex < 0)
        {
            fromIndex = 0;
        }
        if (targetCount == 0)
        {
            return fromIndex;
        }

        char first = target.charAt(targetOffset);
        int i = sourceOffset + fromIndex;
        int max = sourceOffset + (sourceCount - targetCount);

        startSearchForFirstChar: while (true)
        {
            /* Look for first character. */
            while (i <= max && source.charAt(i) != first)
            {
                i++;
            }
            if (i > max)
            {
                return -1;
            }

            /* Found first character, now look at the rest of v2 */
            int j = i + 1;
            int end = j + targetCount - 1;
            int k = targetOffset + 1;
            while (j < end)
            {
                if (source.charAt(j++) != target.charAt(k++))
                {
                    i++;
                    /* Look for str's first char again. */
                    continue startSearchForFirstChar;
                }
            }
            return i - sourceOffset; /* Found whole string. */
        }
    }

    /**
     * The cached localhost address. 
     * @see #getLocalHost()
     */
    private static InetAddress localhost;

    /**
     * Use this instead of {@link InetAddress#getLocalHost()} to prevent multiple lookups.
     */
    public synchronized static InetAddress getLocalHost()
    {
        if (localhost == null)
        {
            try
            {
                localhost = InetAddress.getLocalHost();
            }
            catch (UnknownHostException e)
            {
                throw new RuntimeException(e);
            }
        }
        return localhost;
    }

    ///////////////////////////////////////////////////////
    // IP Address manipulation
    ///////////////////////////////////////////////////////

    /**
     * Gets the octets for the given <code>ip</code>
     * @param ip
     * @return
     */
    public static short[] getOctets(String ip)
    {
        String[] bytes = ip.split("\\.");
        if (bytes.length < 4)
        {
            throw new IllegalArgumentException("Invalid IP address: " + ip);
        }

        short[] octets = new short[bytes.length];

        for (int i = 0; i < bytes.length; i++)
        {
            octets[i] = Short.parseShort(bytes[i]);
            if (octets[i] < 0 || octets[i] > 255)
            {
                throw new IllegalArgumentException("Invalid IP address: " + ip);
            }
        }
        return octets;
    }

    /**
     * Converts the given <code>ip</code> into an int.
     * @param ip
     * @return
     */
    public static int intify(String ip)
    {
        return intify(getOctets(ip));
    }

    /**
     * Converts IP octets to an int value
     */
    public static int intify(short[] octets)
    {
        int address = octets[3] & 0xFF;
        address |= ((octets[2] << 8) & 0xFF00);
        address |= ((octets[1] << 16) & 0xFF0000);
        address |= ((octets[0] << 24) & 0xFF000000);

        return address;
    }

    /**
     * Converts an IP int to 4 octets
     */
    public static String deintify(int value)
    {
        short[] octets = new short[4];

        octets[0] = (short) ((value & 0xFF000000) >> 24);
        octets[1] = (short) ((value & 0xFF0000) >> 16);
        octets[2] = (short) ((value & 0xFF00) >> 8);
        octets[3] = (short) ((value & 0xFF));

        return String.valueOf(octets[0]) + "." + String.valueOf(octets[1]) + "." + String.valueOf(octets[2]) + "." + String.valueOf(octets[3]);
    }

    /**
     * Hidden constructor.
     */
    private Util()
    {
    }
}
