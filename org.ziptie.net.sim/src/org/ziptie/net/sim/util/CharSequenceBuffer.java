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

import java.io.OutputStream;

/**
 * A OutputStream which implements CharSequence backed by a char array.
 * This is helpful as a no-copy writeable string buffer.
 */
public class CharSequenceBuffer extends OutputStream implements CharSequence
{
    private final Object mutex = new Object();
    protected char[] buf;
    protected int count;
    protected int hash;

    public CharSequenceBuffer()
    {
        this(32);
    }

    public CharSequenceBuffer(int size)
    {
        buf = new char[size];
    }

    public CharSequenceBuffer(char[] buf)
    {
        this.buf = buf;
        count = buf.length;
    }

    public int length()
    {
        return count;
    }

    /* (non-Javadoc)
     * @see java.lang.CharSequence#charAt(int)
     */
    public char charAt(int index)
    {
        synchronized (mutex)
        {
            if (index >= count)
            {
                throw new IndexOutOfBoundsException(String.valueOf(index));
            }
            return buf[index];
        }
    }

    public void append(CharSequence seq)
    {
        synchronized (mutex)
        {
            if (seq instanceof CharSequenceBuffer)
            {
                appendBuffer((CharSequenceBuffer) seq, 0, seq.length());
                return;
            }

            int len = seq.length();
            prepareToWrite(len);
            for (int i = 0; i < len; i++)
            {
                buf[count++] = seq.charAt(i);
            }
        }
    }

    public void appendBuffer(CharSequenceBuffer seq, int off, int len)
    {
        write(seq.buf, 0, seq.length());
    }

    public void write(int b)
    {
        synchronized (mutex)
        {
            prepareToWrite(1);
            buf[count++] = (char) b;
        }
    }

    public void write(byte[] c, int off, int len)
    {
        synchronized (mutex)
        {
            prepareToWrite(len);

            for (; off < len; off++)
            {
                buf[count++] = (char) c[off];
            }
        }
    }

    public void write(byte[] cbuf)
    {
        write(cbuf, 0, cbuf.length);
    }

    public void write(char[] cbuf)
    {
        write(cbuf, 0, cbuf.length);
    }

    public void write(char[] cbuf, int off, int len)
    {
        synchronized (mutex)
        {
            prepareToWrite(len);
            System.arraycopy(cbuf, off, buf, count, len);
            count += len;
        }
    }

    /**
     * Resets this buffer so that its length is zero.
     */
    public void reset()
    {
        count = 0;
    }

    /* (non-Javadoc)
     * @see java.lang.CharSequence#subSequence(int, int)
     */
    public CharSequence subSequence(int start, int end)
    {
        char[] chars;
        synchronized (mutex)
        {
            if (start < 0 || start > count || end < start || end > count)
            {
                throw new IllegalArgumentException("start=" + start + " end=" + end);
            }

            chars = new char[end - start];

            System.arraycopy(buf, start, chars, 0, chars.length);
        }

        return new CharSequenceBuffer(chars);
    }

    /**
     * Ensures that the buffer size is large enough to support <code>len</code> more characters.
     * This will prevent excesive resizing.
     */
    public synchronized void prepareToWrite(int len)
    {
        synchronized (mutex)
        {
            int newcount = count + len;
            if (newcount > buf.length)
            {
                char newbuf[] = new char[Math.max(buf.length << 1, newcount)];
                System.arraycopy(buf, 0, newbuf, 0, count);
                buf = newbuf;
            }
        }
    }

    public byte[] toByteArray()
    {
        synchronized (mutex)
        {
            byte[] bytes = new byte[buf.length];
            for (int i = 0; i < buf.length; i++)
            {
                bytes[i] = (byte) (buf[i] & 0xFF);
            }
            return bytes;
        }
    }

    /* (non-Javadoc)
     * @see java.lang.CharSequence#toString()
     */
    public String toString()
    {
        return new String(buf, 0, count);
    }

    /////////////////////////////////////////////////////
    // equals() and hashCode() are implemented such that
    // a String with the same contants will be seen as 
    // the same.
    //
    // String str = "example";
    // CharSequenceBuffer b = new CharSequenceBuffer("example".toCharArray());
    //
    // b.equals(str) == true
    /////////////////////////////////////////////////////

    /**
     * Checks to see if two CharSequences are equal.
     */
    public boolean equals(Object obj)
    {
        try
        {
            synchronized (mutex)
            {
                CharSequence seq = (CharSequence) obj;

                if (seq.length() != count)
                {
                    return false;
                }
                for (int i = 0; i < count; i++)
                {
                    if (seq.charAt(i) != buf[i])
                    {
                        return false;
                    }
                }
                return true;
            }
        }
        catch (ClassCastException e)
        {
            return false;
        }
    }

    /**
     * Returns a hash code for this string. The hash code for a
     * <code>String</code> object is computed as
     * <blockquote><pre>
     * s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
     * </pre></blockquote>
     * using <code>int</code> arithmetic, where <code>s[i]</code> is the
     * <i>i</i>th character of the string, <code>n</code> is the length of
     * the string, and <code>^</code> indicates exponentiation.
     * (The hash value of the empty string is zero.)
     *
     * @return  a hash code value for this object.
     * @see String#hashCode()
     */
    public int hashCode()
    {
        synchronized (mutex)
        {
            int h = hash;
            if (h == 0)
            {
                char val[] = buf;
                int len = count;
                for (int i = 0; i < len; i++)
                {
                    h = 31 * h + val[i];
                }
                hash = h;
            }
            return h;
        }
    }
}
