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
import java.io.InputStream;

import junit.framework.TestCase;

/**
 * This classes tests the functionality of the utility methods on {@link Util}
 */
public class UtilTest extends TestCase
{
    public void testIndexOf()
    {
        assertEquals(Util.indexOf("This is a test.", "a te"), 8);
        assertEquals(Util.indexOf("This is a test.", "atest"), -1);
        assertEquals(Util.indexOf("2 test test.", "test", 3), 7);
        assertEquals(Util.indexOf("This is a test.", "test.this"), -1);
        assertEquals(Util.indexOf("This is a test.", "\nThis"), -1);
    }

    public void testReplaceLiteral()
    {
        String str = "This is the base string! The second sentence.";

        CharSequence result = Util.replaceLiteral(str, "base", "example");
        assertEquals(result.toString(), result, "This is the example string! The second sentence.");

        result = Util.replaceLiteral(str, "he", "HE");
        assertEquals(result.toString(), result, "This is tHE base string! THE second sentence.");

        // tests that recursion does not occur
        result = Util.replaceLiteral(str, "base", "two bases");
        assertEquals(result.toString(), result, "This is the two bases string! The second sentence.");
    }

    public void testCharSequenceBuffer() throws IOException
    {
        String str = "This is a test.";
        CharSequenceBuffer buf = new CharSequenceBuffer();

        buf.write(str.toCharArray());

        assertEquals(str.length(), buf.length());

        for (int i = 0; i < str.length(); i++)
        {
            assertEquals(str.charAt(i), buf.charAt(i));
        }

        assertEquals(buf.toString(), str);
    }

    public void testCharSequenceInputStream() throws IOException
    {
        String str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=!@#$%^&*()_+";
        InputStream is = new CharSequenceInputStream(str);

        CharSequenceBuffer buffer = new CharSequenceBuffer();
        while (is.available() > 0)
        {
            buffer.write(is.read());
        }
        assertEquals(buffer.length(), str.length());
        assertEquals(buffer.toString(), str);
    }

    public void testQueue()
    {
        Queue queue = new Queue();
        assertTrue(queue.isEmpty());

        for (int i = 0; i < 500; i++)
        {
            queue.push(new Integer(i));
        }

        assertFalse(queue.isEmpty());
        for (int i = 0; i < 500; i++)
        {
            Integer shift = (Integer) queue.shift();

            assertEquals(i, shift.intValue());

            queue.push(shift);
        }

        assertFalse(queue.isEmpty());

        for (int i = 499; i >= 0; i--)
        {
            Integer pop = (Integer) queue.pop();
            assertEquals(i, pop.intValue());

            queue.unshift(pop);
        }

        assertFalse(queue.isEmpty());

        for (int i = 0; i < 500; i++)
        {
            Integer shift = (Integer) queue.shift();
            assertEquals(i, shift.intValue());
        }

        assertTrue(queue.isEmpty());
    }
}
