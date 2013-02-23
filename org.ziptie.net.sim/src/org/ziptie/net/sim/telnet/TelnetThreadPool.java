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

import org.apache.log4j.Logger;
import org.ziptie.net.sim.DeviceSimulator;
import org.ziptie.net.sim.util.Queue;

/**
 * ThreadPool which handles all telnet 
 */
public class TelnetThreadPool
{
    private static final Logger LOG = Logger.getLogger(TelnetThreadPool.class);

    /** {@link Queue}&lt;{@link QueueEntry}&gt; */
    private Queue queue;

    /**
     * Hidden constructor.
     * @see TelnetThreadPool#getInstance()
     */
    private TelnetThreadPool()
    {
        queue = new Queue();

        int threadCount = 5;

        String strCount = DeviceSimulator.getProperty(DeviceSimulator.TELNET_POOL_COUNT);
        if (strCount != null)
        {
            try
            {
                threadCount = Integer.parseInt(strCount);
            }
            catch (NumberFormatException e)
            {
                LOG.warn("Invalid thread count property: " + strCount, e);
            }
        }

        // Startup the threads
        ThreadGroup group = new ThreadGroup("TelnetProcessorThreads");
        group.setDaemon(true);
        for (int i = 0; i < threadCount; i++)
        {
            TelnetThread thread = new TelnetThread(group, i);
            thread.start();
        }
    }

    public void input(ITelnetSession session, byte[] data)
    {
        queue.push(new QueueEntry(QueueEntry.INPUT, session, null, data));
    }

    public void open(ITelnetSession session, ITelnetOutputHandler handler)
    {
        queue.push(new QueueEntry(QueueEntry.OPEN, session, handler, null));
    }

    private static class QueueEntry
    {
        public static final int INPUT = 0;
        public static final int OPEN = 1;

        int type;
        ITelnetSession session;
        byte[] data;
        ITelnetOutputHandler handler;

        QueueEntry(int type, ITelnetSession session, ITelnetOutputHandler handler, byte[] data)
        {
            this.type = type;
            this.session = session;
            this.data = data;
            this.handler = handler;
        }
    }

    private class TelnetThread extends Thread
    {
        public TelnetThread(ThreadGroup group, int i)
        {
            super(group, "TelnetThread-" + i);
            setDaemon(true);
        }

        public void run()
        {
            while (!isInterrupted())
            {
                QueueEntry entry = (QueueEntry) queue.shift();
                if (entry == null)
                {
                    queue.waitForMore();
                }
                else
                {
                    try
                    {
                        if (entry.type == QueueEntry.OPEN)
                        {
                            entry.session.open(entry.handler);
                        }
                        else if (entry.type == QueueEntry.INPUT)
                        {
                            byte[] arr = (byte[]) entry.data;
                            entry.session.input(arr, 0, arr.length);
                        }
                    }
                    catch (Throwable t)
                    {
                        LOG.error("An uncaught error occured within the thread pool.", t);
                    }
                }
            }
        }
    }

    //////////////////////////////////////////////////
    // Factory method...
    //////////////////////////////////////////////////
    private static TelnetThreadPool instance;

    public synchronized static TelnetThreadPool getInstance()
    {
        if (instance == null)
        {
            instance = new TelnetThreadPool();
        }
        return instance;
    }
}
