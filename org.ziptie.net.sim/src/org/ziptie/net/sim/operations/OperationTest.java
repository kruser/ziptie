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
import java.util.LinkedList;

import junit.framework.TestCase;

import org.ziptie.net.sim.config.Configuration;
import org.ziptie.net.sim.config.ConfigurationService;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.exceptions.NoSuchProtocolSessionException;
import org.ziptie.net.sim.telnet.ITelnetOutputHandler;
import org.ziptie.net.sim.telnet.ITelnetSession;
import org.ziptie.net.sim.telnet.TelnetResponse;
import org.ziptie.net.sim.util.CharSequenceBuffer;
import org.ziptie.net.sim.util.IpAddress;
import org.ziptie.net.sim.util.Util;

/**
 * Tests the {@link org.ziptie.net.sim.operations} package.
 */
public class OperationTest extends TestCase implements IStateListener
{
    TelnetResponse SESSION_CLOSED = new TelnetResponse("SESSION CLOSED", 0);
    boolean calledBack = false;
    LinkedList<TelnetResponse> responses = new LinkedList<TelnetResponse>();

    public void testOperationManager() throws NoSuchOperationException, NoSuchProtocolSessionException, IOException
    {
        OperationManager om = OperationManager.getInstance();
        IpAddress ip = IpAddress.getIpAddress(Util.getLocalHost(), "127.0.0.1");

        // This should return the smoke test operation
        IOperation op = om.getCurrentOperation(null, ip, ip);

        op.addListener(this);

        ITelnetSession session = (ITelnetSession) op.getProtocolSession(ITelnetSession.PROTOCOL_NAME);
        session.open(new OutputHandler());

        // First command of the recording should be "testlab", the username
        byte[] req = "testlab".getBytes();
        session.input(req, 0, req.length);

        IOperation otherOp = om.getCurrentOperation(null, ip, ip);
        assertSame(op, otherOp);

        req = "hobbit".getBytes();
        session.input(req, 0, req.length);

        session.close();

        assertEquals(responses.size(), 5);
        assertSame(responses.getLast(), SESSION_CLOSED);

        assertTrue(calledBack);

        otherOp = om.getCurrentOperation(null, ip, ip);
        assertNotSame(op, otherOp);
    }

    public void testMediarySession() throws Exception
    {
        Configuration config = ConfigurationService.getInstance().findConfiguration("127.0.0.1");

        CharSequenceBuffer buf = new CharSequenceBuffer();
        config.toXml(buf);

        IpAddress ip = IpAddress.getIpAddress(Util.getLocalHost(), "127.0.0.1");
        MediarySession session = new MediarySession(ip, ip);
        session.append(buf.toByteArray());

        IOperation operation = session.getOperation();
        assertNotNull(operation);
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.operations.IStateListener#handle(org.ziptie.net.sim.operations.StateEvent)
     */
    public void handle(StateEvent event)
    {
        if (event.getType().equals(StateEvent.DISCONNECTED))
        {
            calledBack = true;
        }
    }

    class OutputHandler implements ITelnetOutputHandler
    {
        /* (non-Javadoc)
         * @see org.ziptie.net.sim.telnet.ITelnetOutputHandler#close()
         */
        public void close() throws IOException
        {
            responses.add(SESSION_CLOSED);
        }

        /* (non-Javadoc)
         * @see org.ziptie.net.sim.telnet.ITelnetOutputHandler#handleOutput(org.ziptie.net.sim.telnet.TelnetResponse)
         */
        public void handleOutput(TelnetResponse resp)
        {
            responses.add(resp);
        }
    }
}
