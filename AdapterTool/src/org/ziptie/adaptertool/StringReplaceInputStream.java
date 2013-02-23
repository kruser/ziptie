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
package org.ziptie.adaptertool;

import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Wraps an input stream to provide inline string replace functionality.
 * All matches will be replaced with a given replace string as the stream is read. 
 */
public class StringReplaceInputStream extends FilterInputStream
{
    private String match;
    private String replace;

    private boolean replacing;
    private int replaceCursor;

    private int[] rrbuffer;
    private int bufferCursor;

    private boolean eof;

    /**
     * Wrap the given input stream.
     * @param match The string to match.
     * @param replace The string used as the replacement.
     * @param in The stream that will be wrapped.
     */
    public StringReplaceInputStream(String match, String replace, InputStream in)
    {
        super(in);

        this.match = match;
        this.replace = replace;
    }

    private void fillBuffer() throws IOException
    {
        bufferCursor = 0;

        byte[] buf = new byte[match.length()];
        int len = 0;
        int cursor = 0;
        while ((len = super.read(buf, cursor, buf.length - cursor)) > 0)
        {
            cursor += len;
        }

        if (cursor < buf.length)
        {
            // eof in first read. 
            rrbuffer = new int[cursor + 1];
            rrbuffer[cursor] = -1;
        }
        else
        {
            rrbuffer = new int[cursor];
        }

        for (int i = 0; i < buf.length; i++)
        {
            rrbuffer[i] = buf[i];
        }
    }

    /** {@inheritDoc} */
    @Override
    public int read(byte[] b, int off, int len) throws IOException
    {
        if (eof)
        {
            return -1;
        }

        if (len == 0)
        {
            return 0;
        }

        int total = 0;

        for (int i = off; i < off + len; i++)
        {
            int r = read();
            if (r < 0)
            {
                break;
            }

            total++;

            b[i] = (byte) r;
        }

        if (total == 0)
        {
            return -1;
        }

        return total;
    }

    /** {@inheritDoc} */
    @Override
    public int read() throws IOException
    {
        if (eof)
        {
            return -1;
        }

        if (replacing)
        {
            if (replaceCursor < replace.length())
            {
                return replace.charAt(replaceCursor++);
            }
            replacing = false;
        }

        if (rrbuffer == null)
        {
            fillBuffer();
        }
        else
        {
            int ndx = bufferCursor - 1;
            if (ndx < 0)
            {
                ndx = rrbuffer.length - 1;
            }
            rrbuffer[ndx] = super.read();
        }

        if (bufferMatches())
        {
            rrbuffer = null;
            replaceCursor = 0;

            if (replaceCursor < replace.length())
            {
                replacing = true;
                return replace.charAt(replaceCursor++);
            }
        }

        int r = rrbuffer[bufferCursor++];
        if (r == -1)
        {
            eof = true;
        }
        if (bufferCursor == rrbuffer.length)
        {
            bufferCursor = 0;
        }
        return r;
    }

    private boolean bufferMatches()
    {
        int cursor = bufferCursor;
        for (int i = 0; i < rrbuffer.length; i++)
        {
            char c = match.charAt(i);

            if (cursor == rrbuffer.length)
            {
                cursor = 0;
            }

            if (c != rrbuffer[cursor++])
            {
                return false;
            }
        }
        return true;
    }

    /** {@inheritDoc} */
    @Override
    public int available() throws IOException
    {
        return super.available() == 0 ? 0 : 1;
    }
}
