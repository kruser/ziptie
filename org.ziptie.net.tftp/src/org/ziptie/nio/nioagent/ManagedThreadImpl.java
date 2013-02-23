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
package org.ziptie.nio.nioagent;

import org.ziptie.nio.nioagent.Interfaces.ManagedThread;

public class ManagedThreadImpl implements ManagedThread
{

    // -- fields
    volatile Thread thread;
    Runnable runnable;
    String name;

    // -- constructors
    private ManagedThreadImpl()
    {
        // do nothing
    }

    // -- public methods
    public static ManagedThread createAndStart(Runnable runnable, String name)
    {
        ManagedThreadImpl impl = new ManagedThreadImpl();
        impl.runnable = runnable;
        impl.name = name;
        impl.thread = null;
        impl.start();
        return impl;
    }

    //    * ManagedThread
    public void start()
    {
        if (null == thread)
        {
            thread = new Thread(new Runnable()
            {
                public void run()
                {
                    while (null != thread)
                    {
                        runnable.run();
                    }
                }
            }, name);
            thread.setDaemon(true);
            thread.start();
        }
    }

    public void stop()
    {
        if (null != thread)
        {
            Thread moribund = thread;
            thread = null;
            moribund.interrupt();
        }
    }

}
