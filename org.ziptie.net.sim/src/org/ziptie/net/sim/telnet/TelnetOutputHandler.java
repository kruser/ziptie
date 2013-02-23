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

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.SocketChannel;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.log4j.Logger;
import org.ziptie.net.sim.util.Queue;

/**
 * Manages the output of data onto a telnet channel.
 */
public class TelnetOutputHandler implements ITelnetOutputHandler
{
    private static final Logger LOG = Logger.getLogger(TelnetOutputHandler.class);

    /** The timer for all enablement tasks. */
    private static final Timer TIMER = new Timer();

    private SelectionKey key;

    /** {@link Queue}&lt;{@link TelnetResponse}&gt; */
    private Queue writeQueue;

    public TelnetOutputHandler(SelectionKey key)
    {
        this.key = key;
        this.writeQueue = new Queue();
    }

    /**
     * Writes any available response to the channel.
     * @throws IOException
     */
    public void writeAvailable() throws IOException
    {
        TelnetResponse resp = (TelnetResponse) writeQueue.shift();
        if (resp == null)
        {
            // remove interest for write
            key.interestOps(key.interestOps() & ~SelectionKey.OP_WRITE);
            return;
        }

        byte[] bbuf = resp.getBytes();
        int cursor = resp.getCursor();
        int len = bbuf.length - cursor;
        ByteBuffer buf = ByteBuffer.wrap(bbuf, cursor, len);

        cursor = ((SocketChannel) key.channel()).write(buf);

        if (cursor < len)
        {
            // If the response isn't fully written, move the repsonses cursor
            resp.skip(cursor);

            // place this response back on the front of the queue
            writeQueue.unshift(resp);
        }
        else if (writeQueue.isEmpty())
        {
            // remove interest for write
            key.interestOps(key.interestOps() & ~SelectionKey.OP_WRITE);
        }
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.telnet.ITelnetOutputHandler#handleOutput(org.ziptie.net.sim.operations.Response)
     */
    public void handleOutput(TelnetResponse resp)
    {

        long delay = resp.getResponseTimeMillis();
        if (delay > 0)
        {
            String cleanString = resp.toString().replaceAll("(\n|\r)", "");
            int endIndex = Math.min(20, cleanString.length() - 1);
            
            // Make sure the end index isn't less than 0
            endIndex = endIndex < 0 ? 0 : endIndex;
            
            String respStart = cleanString.substring(0, endIndex);
            LOG.info("Response: \"" + respStart + "...\" will be sent in " + delay + " ms.");
        }
        TIMER.schedule(new EnableWriteTask(resp), delay);
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.telnet.ITelnetOutputHandler#close()
     */
    public void close() throws IOException
    {
        key.channel().close();
    }

    /**
     * TimerTask which will enable WRITE interest for this channel.
     * This is what makes sure that the response is rate limited.
     */
    private class EnableWriteTask extends TimerTask
    {

        protected TelnetResponse resp = null;

        public EnableWriteTask(TelnetResponse resp)
        {
            this.resp = resp;
        }

        public void run()
        {
            try
            {
                if (key.isValid())
                {
                    writeQueue.push(resp);
                    key.interestOps(key.interestOps() | SelectionKey.OP_WRITE);
                    key.selector().wakeup();
                }
                else
                {
                    LOG.warn("Key is not valid! The connection was probably prematurely closed by the remote host.");
                }
            }
            catch (Throwable t)
            {
                LOG.error("An error occured modifying interest ops for key.", t);
            }
        }
    }
}
