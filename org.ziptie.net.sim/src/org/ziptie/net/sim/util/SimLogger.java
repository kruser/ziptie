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

import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.Logger;
import org.apache.log4j.Priority;
import org.ziptie.net.sim.operations.IOperation;
import org.ziptie.net.sim.operations.IStateListener;
import org.ziptie.net.sim.operations.StateEvent;

/**
 * Manages the logging of interactions.
 */
public class SimLogger implements IStateListener
{
    private static final Map LOG_LEVELS;

    private Logger logger;
    private String simLoggerId = "";

    static
    {
        LOG_LEVELS = new HashMap();

        LOG_LEVELS.put(StateEvent.INFO, Priority.INFO);
        LOG_LEVELS.put(StateEvent.ERROR, Priority.ERROR);

        LOG_LEVELS.put(StateEvent.CONNECTED, Priority.INFO);
        LOG_LEVELS.put(StateEvent.DISCONNECTED, Priority.INFO);
        LOG_LEVELS.put(StateEvent.INPUT, Priority.DEBUG);
        LOG_LEVELS.put(StateEvent.OUTPUT, Priority.DEBUG);
    }

    public SimLogger(IOperation op)
    {
        simLoggerId = "[" + op.getOperationId() + "." + op.getRemoteIp() + "." + op.getLocalIp() + "] ";
        logger = Logger.getLogger("session");
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.operations.IStateListener#handle(org.ziptie.net.sim.operations.StateEvent)
     */
    public void handle(StateEvent event)
    {
        Priority priority = (Priority) LOG_LEVELS.get(event.getType());
        logger.log(priority, simLoggerId + event.getMessage(), event.getThrowable());
    }
}
