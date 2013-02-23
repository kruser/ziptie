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

package org.ziptie.net.sim.telnet;

/**
 * This represents a block of data that is to be sent to a telnet client. 
 */
public class TelnetResponse
{
    private CharSequence seq;
    private long responseTimeMillis;
    private int cursor;
    private byte[] buf;

    /**
     * @param str The CharSequence to send.
     * @param responseTimeMillis The length it should take to send.
     */
    public TelnetResponse(CharSequence str, long responseTimeMillis)
    {
        this.seq = str;
        this.responseTimeMillis = responseTimeMillis;
    }

    /**
     * @return The sequence to send
     */
    public CharSequence getSequence()
    {
        return seq;
    }

    /**
     * All the bytes starting at <code>cursor</code> still have yet to be writen.
     * @return The byte buffer
     */
    public byte[] getBytes()
    {
        if (buf == null)
        {
            int len = seq.length();
            buf = new byte[len];
            for (int i = 0; i < len; i++)
            {
                buf[i] = (byte) seq.charAt(i);
            }
        }
        return buf;
    }

    /**
     * Move the cursor <code>count</code>
     * @param count
     */
    public void skip(int count)
    {
        cursor += count;
    }

    /**
     * The location at which to start writing from the byte buffer.
     * @return The cursor position for .getBytes()
     */
    public int getCursor()
    {
        return cursor;
    }

    /**
     * @return Returns the responseTimeMillis.
     */
    public long getResponseTimeMillis()
    {
        return responseTimeMillis;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    public String toString()
    {
        return seq.toString();
    }
}
