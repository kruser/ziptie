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
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.util.IpAddress;

/**
 * Convenience Operation class that holds basic operation data needed by most oeprations.
 */
public abstract class AbstractOperation implements IOperation
{
    private IpAddress local;
    private IpAddress remote;
    private WorkingConfig config;
    private List listeners = new LinkedList();
    private int id;

    public AbstractOperation(WorkingConfig config, IpAddress local, IpAddress remote)
    {
        this.local = local;
        this.remote = remote;
        this.config = config;

        this.id = getNextId();
    }

    public int getOperationId()
    {
        return id;
    }

    public IpAddress getRemoteIp()
    {
        return remote;
    }

    public IpAddress getLocalIp()
    {
        return local;
    }

    public WorkingConfig getWorkingConfig()
    {
        return config;
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.operations.IOperation#getUri()
     */
    public URI getUri()
    {
        return config.getOperationUri();
    }

    public void addListener(IStateListener listener)
    {
        listeners.add(listener);
    }

    /**
     * Send a state event to all listeners.
     * @param event
     */
    public void sendEvent(StateEvent event)
    {
        Iterator iter = listeners.iterator();
        while (iter.hasNext())
        {
            ((IStateListener) iter.next()).handle(event);
        }
    }

    private static int nextId = 0;

    private synchronized static int getNextId()
    {
        return nextId++;
    }
}
