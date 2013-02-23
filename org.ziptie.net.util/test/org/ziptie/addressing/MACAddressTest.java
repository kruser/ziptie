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

import junit.framework.TestCase;

/**
 * Tests the MACAddress transient object for the proper formatting
 * 
 * @author rkruse
 */
public class MACAddressTest extends TestCase
{

    /**
     * Tests formatting a MAC that contains no delimiters
     * 
     */
    public void testMacNoDelims()
    {
        MACAddress mac = new MACAddress("abcdef123456");
        assertEquals("AB-CD-EF-12-34-56", mac.toString());
    }

    /**
     * Tests formatting a MAC that has a colon on every octet
     * 
     */
    public void testMacColons()
    {
        MACAddress mac = new MACAddress("ab:cd:ef:12:34:56");
        assertEquals("AB-CD-EF-12-34-56", mac.toString());
    }

    /**
     * Tests formatting a MAC with a % delimiter on every two octets
     * 
     */
    public void testCrazyDelimiters()
    {
        MACAddress mac = new MACAddress("abcd%ef12%3456");
        assertEquals("AB-CD-EF-12-34-56", mac.toString());
    }

    /**
     * Sometimes through SNMP we get MAC addresses between quotes, we should
     * only process what is between the quotes.
     * 
     */
    public void testPullQuotes()
    {
        MACAddress mac = new MACAddress("'0F802d7c73c0'H");
        assertEquals("0F-80-2D-7C-73-C0", mac.toString());

        MACAddress mac2 = new MACAddress("\"00802d7c73c0\"H");
        assertEquals("00-80-2D-7C-73-C0", mac2.toString());
    }

    /**
     * if an octet is shorted we should handle that
     * 
     */
    public void testShortenedMac()
    {
        MACAddress mac = new MACAddress("f:0:ab:ab:bb:cc");
        assertEquals("0F-00-AB-AB-BB-CC", mac.toString());
    }

    /**
     * Test :: as a delimiter
     * 
     */
    public void testDoubleDelimiter()
    {
        MACAddress mac = new MACAddress("f::0::ab::ab::bb::cc");
        assertEquals("0F-00-AB-AB-BB-CC", mac.toString());
    }

    /**
     * Test an already well formatted string
     * 
     */
    public void testWellFormatted()
    {
        MACAddress mac = new MACAddress("AA-BB-CC-DD-11-22");
        assertEquals("AA-BB-CC-DD-11-22", mac.toString());
    }
}
