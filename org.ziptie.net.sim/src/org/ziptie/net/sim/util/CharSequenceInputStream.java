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

/**
 * An InputStream that reads from a CharSequence.  
 */
public class CharSequenceInputStream extends InputStream
{
    /** The current cursor location. */
    private int cursor;
    private int len;

    /** The sequence which is read from. */
    private CharSequence sequence;

    public CharSequenceInputStream(CharSequence sequence)
    {
        this(sequence, 0, sequence.length());
    }

    public CharSequenceInputStream(CharSequence sequence, int offset, int len)
    {
        this.sequence = sequence;
        this.len = len;
        this.cursor = offset;
    }

    /* (non-Javadoc)
     * @see java.io.InputStream#available()
     */
    public int available() throws IOException
    {
        return len - cursor;
    }

    /* (non-Javadoc)
     * @see java.io.InputStream#read()
     */
    public int read() throws IOException
    {
        return (cursor < len) ? (sequence.charAt(cursor++) & 0xff) : -1;
    }
}
