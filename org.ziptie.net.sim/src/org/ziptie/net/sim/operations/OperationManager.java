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
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.WeakHashMap;

import org.apache.log4j.Logger;
import org.ziptie.net.sim.DeviceSimulator;
import org.ziptie.net.sim.config.Configuration;
import org.ziptie.net.sim.config.ConfigurationService;
import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.exceptions.NoSuchFactoryException;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.multiop.MultiOperationFactory;
import org.ziptie.net.sim.recording.RecordingLoader;
import org.ziptie.net.sim.util.IpAddress;
import org.ziptie.net.sim.util.SimLogger;

/**
 * Retrieves IOperations for connections based on the remote hosts configuration.
 * <p>Also maintains the lifecycle for all operations.
 */
public class OperationManager implements IStateListener
{
    private static final Logger LOG = Logger.getLogger(OperationManager.class);

    /** One minute in milliseconds */
    private static final int ONE_MINUTE = 60000;

    private Object mutex = new Object();

    /**
     * Map&lt;{@link String}, {@link IOperationFactory}&gt;
     */
    private Map operationFactories;

    /**
     * Map&lt;{@link OperationEntryKey}, {@link OperationEntry}&gt;
     */
    private Map currentOperations;

    /**
     * Map&lt;{@link IOperation}, {@link OperationEntryKey}&gt;
     */
    private Map operationKeys;

    /**
     * Timer for lifecycle management of operations.
     */
    private Timer timer;

    private StateWatcher stateWatcher;

    /**
     * Hidden constructor
     * @see OperationManager#getInstance()
     */
    private OperationManager()
    {
        // Map<String, ISessionFactory>
        operationFactories = new HashMap();

        // Load all available IOperationFactorys
        operationFactories.put(RecordingLoader.getInstance().getPathPrefix(), RecordingLoader.getInstance());
        operationFactories.put(MultiOperationFactory.getInstance().getPathPrefix(), MultiOperationFactory.getInstance());

        // Map<OperationEntryKey, OperationEntry>
        currentOperations = new HashMap();

        // Map<IOperation, OperationEntryKey>
        operationKeys = new WeakHashMap();

        String show = DeviceSimulator.getProperty(DeviceSimulator.LOG_STORE_STATE);
        if (show != null && show.equalsIgnoreCase("true"))
        {
            stateWatcher = StateWatcher.getInstance();
        }

        timer = new Timer(true);
    }

    public IOperation getCurrentOperation(Configuration config, IpAddress localIp, IpAddress remoteIp) throws NoSuchOperationException
    {
        OperationEntryKey key = new OperationEntryKey(localIp, remoteIp);
        IOperation operation = getOperation(key);
        if (operation == null)
        {
            if (config == null)
            {
                config = ConfigurationService.getInstance().findConfiguration(remoteIp.getIp());
            }

            // Find the session name for this local IP
            // And then find the factory associated with the session name
            WorkingConfig wc = config.findOperation(localIp.getIp());
            URI opUri = wc.getOperationUri();

            IOperationFactory factory = null;
            try
            {
                factory = getFactory(opUri);
            }
            catch (NoSuchFactoryException e)
            {
                throw new NoSuchOperationException("No such operation: " + opUri, e);
            }

            // create the operation
            operation = factory.createOperation(wc, remoteIp, localIp);
            addListeners(operation);

            addOperation(key, operation, wc);
        }
        return operation;
    }

    private void addListeners(IOperation op)
    {
        op.addListener(this);
        if (stateWatcher != null)
        {
            op.addListener(stateWatcher);
        }
        op.addListener(new SimLogger(op));
    }

    public IOperationFactory getFactory(URI uri) throws NoSuchFactoryException
    {
        IOperationFactory factory = (IOperationFactory) operationFactories.get(uri.getScheme());
        if (factory == null)
        {
            throw new NoSuchFactoryException("No factory exists for URI: " + uri.toString());
        }
        return factory;
    }

    private IOperation getOperation(OperationEntryKey key)
    {
        synchronized (mutex)
        {
            OperationEntry entry = (OperationEntry) currentOperations.get(key);
            return entry == null ? null : entry.operation;
        }
    }

    /**
     * Adds <code>op</code> to the map of current operations. This also schedules the assassin task for the operation.
     * @param key The identifier key for this operation.
     * @param op The operation itself
     * @param config The configuration used for this operation.
     */
    private void addOperation(OperationEntryKey key, IOperation op, WorkingConfig config)
    {
        AssassinTask assassin = new AssassinTask(key);

        timer.schedule(assassin, ONE_MINUTE * config.getOperationTimeout());

        synchronized (mutex)
        {
            currentOperations.put(key, new OperationEntry(op, assassin));

            operationKeys.put(op, key);
        }
    }

    private void destroyOperation(IOperation op) throws Exception
    {
        OperationEntryKey key;
        OperationEntry entry;
        synchronized (mutex)
        {
            key = (OperationEntryKey) operationKeys.get(op);
            entry = (OperationEntry) currentOperations.get(key);
        }

        entry.assassinTask.cancel();

        try
        {
            op.tearDown();
        }
        finally
        {
            synchronized (mutex)
            {
                operationKeys.remove(op);
                currentOperations.remove(key);
            }
        }
    }

    /**
     * Returns a collection of available operations.
     * <p>Returns a Collection&lt;{@link URI}&gt;
     * @return A Collection of Identifiers for available operations.
     */
    public Collection enumerateSessions()
    {
        List list = new LinkedList();

        Iterator iter = operationFactories.values().iterator();
        while (iter.hasNext())
        {
            IOperationFactory factory = (IOperationFactory) iter.next();

            list.addAll(factory.enumerateSessions());
        }
        return list;
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.operations.IStateListener#handle(org.ziptie.net.sim.operations.StateEvent)
     */
    public void handle(StateEvent event)
    {
        try
        {
            IOperation operation = (IOperation) event.getSource();
            String type = event.getType();

            if (StateEvent.DISCONNECTED.equals(type))
            {
                destroyOperation(operation);
            }
        }
        catch (Throwable e)
        {
            LOG.error("Error occured handling event: " + event, e);
        }
    }

    private static class OperationEntry
    {
        IOperation operation;
        AssassinTask assassinTask;

        OperationEntry(IOperation operation, AssassinTask assassinTask)
        {
            this.operation = operation;
            this.assassinTask = assassinTask;
        }
    }

    /**
     * Identifier key for the current operations Map.  An operation entry is defined with a local/remote IpAddress pair.
     */
    private static class OperationEntryKey
    {
        IpAddress local, remote;
        int hash;

        OperationEntryKey(IpAddress local, IpAddress remote)
        {
            this.local = local;
            this.remote = remote;
            this.hash = (local.getIp() + remote.getIp()).hashCode();
        }

        public boolean equals(Object obj)
        {
            try
            {
                OperationEntryKey other = (OperationEntryKey) obj;
                return other.local.equals(local) && other.remote.equals(remote);
            }
            catch (ClassCastException e)
            {
                return false;
            }
        }

        public int hashCode()
        {
            return hash;
        }
    }

    /**
     * A {@link TimerTask} which will assassinate old operations.
     */
    private class AssassinTask extends TimerTask
    {
        private OperationEntryKey key;

        public AssassinTask(OperationEntryKey key)
        {
            this.key = key;
        }

        public void run()
        {
            OperationEntry entry = (OperationEntry) currentOperations.get(key);
            if (entry != null)
            {
                try
                {
                    LOG.warn("Assassinating operation for " + key.remote + "-" + key.local);
                    destroyOperation(entry.operation);
                }
                catch (Throwable e)
                {
                    LOG.error("An error occured while assassinating the operation for " + key.remote + " " + key.local, e);
                }
            }
            else
            {
                LOG.warn("Could not find operation to assassinate for " + key.remote + "-" + key.local);
            }
        }
    }

    ///////////////////////////////////////////////////////
    // Factory....
    ///////////////////////////////////////////////////////
    private static OperationManager instance;

    public synchronized static OperationManager getInstance()
    {
        if (instance == null)
        {
            instance = new OperationManager();
        }
        return instance;
    }
}
