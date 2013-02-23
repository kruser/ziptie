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

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 * Class that watches the state of all operations within the simulator.
 */
public class StateWatcher implements IStateListener
{
    /**
     * The maximum number of operations' states to keep in history.
     * TODO lbayer: drive this from a property file.
     */
    private static final int MAX_HISTORICAL_OPERATIONS = 100;

    /**
     * A map of lists for each operation.
     * The list contains all the state message for the operation.
     * This map will be truncated when it becomes too large.
     * {@link Map}&lt;{@link IOperation},{@link List}&lt;{@link StateEvent}&gt;&gt;
     */
    private StateMap operationStateMap;

    /**
     * Hidden Constructor.
     * @see #getInstance()
     */
    private StateWatcher()
    {
        operationStateMap = new StateMap();
    }

    public void handle(StateEvent event)
    {
        IOperation op = event.getSource();
        List stateList = null;
        synchronized (operationStateMap)
        {
            stateList = (List) operationStateMap.get(op);
            if (stateList == null)
            {
                stateList = Collections.synchronizedList(new ArrayList());
                operationStateMap.put(op, stateList);
            }
        }
        stateList.add(event);
    }

    /**
     * This is a list of the latest state events for all available operations.
     * Returns a {@link List}&lt;{@link StateEvent}&gt;
     * Calls to this will block any operation from post events to listeners, thus temporarily pausing many operations.
     */
    public List getLatestStates()
    {
        LinkedList latest = new LinkedList();
        synchronized (operationStateMap)
        {
            Iterator iter = operationStateMap.values().iterator();
            while (iter.hasNext())
            {
                List stateList = (List) iter.next();

                /* 
                 * It is possible for a new state to have been added between the call to size() and the call to get()
                 * If this is the case we don't care, we are close enough to the last state.
                 */
                latest.add(stateList.get(stateList.size() - 1));
            }
        }
        return latest;
    }

    public List getStates(int opId)
    {
        synchronized (operationStateMap)
        {
            Iterator iter = operationStateMap.entrySet().iterator();
            while (iter.hasNext())
            {
                Entry entry = (Entry) iter.next();
                IOperation op = (IOperation) entry.getKey();
                if (op.getOperationId() == opId)
                {
                    return (List) entry.getValue();
                }
            }
        }
        return null;
    }

    /**
     * Map which expires old entries once the map has become to large.
     */
    private class StateMap extends LinkedHashMap
    {
        protected boolean removeEldestEntry(Entry eldest)
        {
            return size() > MAX_HISTORICAL_OPERATIONS;
        }
    }

    /////////////////////////////////////////////////////////
    // Factory method...
    /////////////////////////////////////////////////////////
    private static StateWatcher instance;

    public synchronized static StateWatcher getInstance()
    {
        if (instance == null)
        {
            instance = new StateWatcher();
        }
        return instance;
    }
}
