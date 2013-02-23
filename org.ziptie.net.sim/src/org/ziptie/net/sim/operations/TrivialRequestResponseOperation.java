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

package org.ziptie.net.sim.operations;

import java.io.IOException;

import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.telnet.ITelnetOutputHandler;
import org.ziptie.net.sim.telnet.ITelnetSession;
import org.ziptie.net.sim.telnet.TelnetResponse;
import org.ziptie.net.sim.util.CharSequenceBuffer;
import org.ziptie.net.sim.util.IpAddress;

/**
 * Simple operation that encapsulates a simple request response pattern.
 * This abstracts the operation's author from the NIO telnet backend.
 */
public abstract class TrivialRequestResponseOperation extends AbstractOperation
{
    /**
     * Handle the response from an initial connect.
     * @return The response to send or <code>null</code> if no data should be sent.
     */
    abstract public TelnetResponse connect();

    /**
     * Processes subsequent inputs.
     * @return The response to send or <code>null</code> if no data should be sent.
     */
    abstract public TelnetResponse processInput(CharSequence input);

    /**
     * Called to determine if the current input should be processed.
     */
    abstract public boolean shouldProcess(CharSequence input);

    ///////////////////////////////////////////////////////////////////
    // Implementation...
    ///////////////////////////////////////////////////////////////////

    private ITelnetSession telnetSession;

    /**
     * 
     */
    public TrivialRequestResponseOperation(WorkingConfig config, IpAddress local, IpAddress remote)
    {
        super(config, local, remote);
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.interactions.IOperation#tearDown()
     */
    public void tearDown() throws Exception
    {
        if (telnetSession != null)
        {
            telnetSession.close();
        }
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.interactions.IOperation#getProtocolSession(java.lang.String)
     */
    public IProtocolSession getProtocolSession(String name)
    {
        if (name.equals(ITelnetSession.PROTOCOL_NAME))
        {
            if (telnetSession == null)
            {
                telnetSession = new TelnetSession();
            }
            return telnetSession;
        }
        return null;
    }

    /**
     * This telnet session implementation translates simple write requests into a request response pattern.
     */
    private class TelnetSession implements ITelnetSession
    {
        private ITelnetOutputHandler out;
        private CharSequenceBuffer inputBuffer = new CharSequenceBuffer();

        /* (non-Javadoc)
         * @see org.ziptie.net.sim.telnet.ITelnetSession#open(java.nio.channels.SocketChannel)
         */
        public void open(ITelnetOutputHandler outputHandler) throws IOException
        {
            sendEvent(new StateEvent(TrivialRequestResponseOperation.this, StateEvent.CONNECTED, ">>>> Accepted connection. <<<<"));

            out = outputHandler;

            char[] neg = new char[] { IAC, WONT, ECHO };
            if (getWorkingConfig().isDoEcho())
            {
                neg[1] = WILL;
            }
            out.handleOutput(new TelnetResponse(new CharSequenceBuffer(neg), 0));

            TelnetResponse response = connect();
            if (response != null)
            {
                out.handleOutput(response);
            }
        }

        /* (non-Javadoc)
         * @see org.ziptie.net.sim.telnet.ITelnetSession#write(byte[], int, int)
         */
        public void input(byte[] b, int offset, int len) throws IOException
        {
            if (out == null)
            {
                return;
            }

            synchronized (inputBuffer)
            {
                inputBuffer.write(b, offset, len);
                if (getWorkingConfig().isDoEcho())
                {
                    out.handleOutput(new TelnetResponse(new String(b, offset, len), 0));
                }

                if (shouldProcess(inputBuffer))
                {
                    TelnetResponse response = processInput(inputBuffer);
                    if (response != null)
                    {
                        out.handleOutput(response);
                    }

                    inputBuffer.reset();
                }
                else if (inputBuffer.length() > getWorkingConfig().getMaxBufferLength())
                {
                    sendEvent(new StateEvent(TrivialRequestResponseOperation.this, StateEvent.ERROR, "Connection's buffer is too large!"));
                    out.close();
                }
            }
        }

        /* (non-Javadoc)
         * @see org.ziptie.net.sim.telnet.ITelnetSession#close()
         */
        public void close() throws IOException
        {
            if (out != null)
            {
                out.close();
                out = null;
                sendEvent(new StateEvent(TrivialRequestResponseOperation.this, StateEvent.DISCONNECTED, ">>>> Connection closed. <<<<"));
            }
        }
    }
}
