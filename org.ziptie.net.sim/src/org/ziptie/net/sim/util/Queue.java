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

import java.util.LinkedList;

/**
 * A queue classes based on a linked list.
 * These methods map directly to the semantic of a perl array.
 */
public class Queue
{
    private LinkedList queue;

    public Queue()
    {
        queue = new LinkedList();
    }

    /**
     * Push <code>entry</code> onto the end of the queue and notify the threads.
     */
    public void push(Object entry)
    {
        synchronized (queue)
        {
            queue.addLast(entry);
            queue.notify();
        }
    }

    /**
     * Pop the last entry off of the end of the queue.
     */
    public Object pop()
    {
        synchronized (queue)
        {
            if (queue.size() == 0)
            {
                return null;
            }

            Object entry = queue.getLast();
            queue.removeLast();
            return entry;
        }
    }

    /**
     * Unshift <code>entry</code> onto the begining of the queue and notify the threads.
     */
    public void unshift(Object entry)
    {
        synchronized (queue)
        {
            queue.addFirst(entry);
            queue.notify();
        }
    }

    /**
     * Shift the first entry off of the begining of the queue.
     */
    public Object shift()
    {
        synchronized (queue)
        {
            if (isEmpty())
            {
                return null;
            }

            Object entry = queue.getFirst();
            queue.removeFirst();
            return entry;
        }
    }

    public boolean isEmpty()
    {
        synchronized (queue)
        {
            return queue.size() == 0;
        }
    }

    public void waitForMore()
    {
        synchronized (queue)
        {
            try
            {
                queue.wait();
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
            }
        }
    }
}
