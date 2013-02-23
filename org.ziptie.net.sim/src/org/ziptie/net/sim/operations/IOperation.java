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

import java.net.URI;

import org.ziptie.net.sim.exceptions.NoSuchProtocolSessionException;
import org.ziptie.net.sim.util.IpAddress;

/**
 * This directly reflects the lifecycle of an operation on DeviceAuthority (ie: backup)
 * <p>One IOperation may contain one-to-many {@link IProtocolSession}s just as one backup operation
 * on DeviceAuthority might contain one or more sessions.
 */
public interface IOperation
{
    /**
     * @return This operation's unique identifier.
     */
    public int getOperationId();

    /**
     * @return The IP of the remote host for which this operation is simulating
     */
    public IpAddress getRemoteIp();

    /**
     * @return The IP address which has been connected to for this operation.
     */
    public IpAddress getLocalIp();

    /**
     * This is guarenteed to be called when the Operation is no longer in use.
     * <p>In a success case this will be called when the last {@link IProtocolSession} is closed.
     * <p>In a failure case this will be called after the Simulator has waited for a sufficiantly long timeout period.
     * @throws Exception
     */
    public void tearDown() throws Exception;

    /**
     * Return the current {@link IProtocolSession} for the give protocol <code>name</code>
     * @param name The protocol name (ie: Telnet, SNMP, HTTP)
     * @throws NoSuchProtocolSessionException If there is no protocol session for the given name.
     */
    public IProtocolSession getProtocolSession(String name) throws NoSuchProtocolSessionException;

    /**
     * Adds a state listener which will be called back on state change events.
     * @param listener The state listener.
     */
    public void addListener(IStateListener listener);

    /**
     * @return The URI which was used to create this operation
     */
    public URI getUri();
}
