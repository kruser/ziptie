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

import org.ziptie.net.sim.operations.IProtocolSession;

/**
 * Interface for all telnet sessions.
 */
public interface ITelnetSession extends IProtocolSession
{
    public static final int IAC = 255;
    public static final int DONT = 254;
    public static final int DO = 253;
    public static final int WONT = 252;
    public static final int WILL = 251;
    public static final int SB = 250;
    public static final int SE = 240;
    public static final int ECHO = 1;

    public static final String PROTOCOL_NAME = "TELNET";

    /**
     * Called when the connection is open for this TelnetSession
     * @param channel The nio SocketChannel
     * @param outputHandler Handler for all telnet output
     * @throws IOException
     */
    public void open(ITelnetOutputHandler outputHandler) throws IOException;

    /**
     * Called when additional input is read from the telnet connection.
     *
     * @param b The input
     * @param offset The offset where the input starts in the array
     * @param len The length of the input
     * @throws IOException
     */
    public void input(byte[] b, int offset, int len) throws IOException;

    /**
     * Called when the connection is closed by the remote host
     * @throws IOException
     */
    public void close() throws IOException;
}
