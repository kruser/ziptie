/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2007/06/15 17:33:59 $
 * $Revision: 1.4 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/ResizableThreadPoolExecutor.java,v $e
 */

package org.ziptie.discovery;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.RejectedExecutionHandler;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * An instance of the {@link ThreadPoolExecutor} that resizes its core pool size
 * based on activity.
 * 
 * @author rkruse
 */
public class ResizableThreadPoolExecutor extends ThreadPoolExecutor
{
    private int corePoolSize;
    private String idleThreadName;

    /**
     * @param corePoolSize the number of threads to keep in the
     * pool, even if they are idle.
     * @param maximumPoolSize the maximum number of threads to allow in the
     * pool.
     * @param keepAliveTime when the number of threads is greater than
     * the core, this is the maximum time that excess idle threads
     * will wait for new tasks before terminating.
     * @param unit the time unit for the keepAliveTime
     * argument.
     * @param workQueue the queue to use for holding tasks before they
     * are executed. This queue will hold only the <tt>Runnable</tt>
     * tasks submitted by the <tt>execute</tt> method.
     * creates a new thread.
     * @param coreName the name of the thread
     */
    @SuppressWarnings("nls")
    public ResizableThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue,
            final String coreName)
    {
        super(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue, new ThreadFactory()
        {
            public Thread newThread(Runnable r)
            {
                return new Thread(r, coreName);
            }
        });
        this.corePoolSize = corePoolSize;
        this.idleThreadName = coreName + " IDLE";
    }

    /**
     * @param corePoolSize the number of threads to keep in the
     * pool, even if they are idle.
     * @param maximumPoolSize the maximum number of threads to allow in the
     * pool.
     * @param keepAliveTime when the number of threads is greater than
     * the core, this is the maximum time that excess idle threads
     * will wait for new tasks before terminating.
     * @param unit the time unit for the keepAliveTime
     * argument.
     * @param workQueue the queue to use for holding tasks before they
     * are executed. This queue will hold only the <tt>Runnable</tt>
     * tasks submitted by the <tt>execute</tt> method.
     * @param threadFactory the factory to use when the executor
     * creates a new thread.
     */
    public ResizableThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue,
            ThreadFactory threadFactory)
    {
        super(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue, threadFactory);
        this.corePoolSize = corePoolSize;
    }

    /**
     * @param corePoolSize the number of threads to keep in the
     * pool, even if they are idle.
     * @param maximumPoolSize the maximum number of threads to allow in the
     * pool.
     * @param keepAliveTime when the number of threads is greater than
     * the core, this is the maximum time that excess idle threads
     * will wait for new tasks before terminating.
     * @param unit the time unit for the keepAliveTime
     * argument.
     * @param workQueue the queue to use for holding tasks before they
     * are executed. This queue will hold only the <tt>Runnable</tt>
     * tasks submitted by the <tt>execute</tt> method.
     * @param handler the handler to use when execution is blocked
     * because the thread bounds and queue capacities are reached.
     */
    public ResizableThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue,
            RejectedExecutionHandler handler)
    {
        super(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue, handler);
        this.corePoolSize = corePoolSize;
    }

    /**
     * @param corePoolSize the number of threads to keep in the
     * pool, even if they are idle.
     * @param maximumPoolSize the maximum number of threads to allow in the
     * pool.
     * @param keepAliveTime when the number of threads is greater than
     * the core, this is the maximum time that excess idle threads
     * will wait for new tasks before terminating.
     * @param unit the time unit for the keepAliveTime
     * argument.
     * @param workQueue the queue to use for holding tasks before they
     * are executed. This queue will hold only the <tt>Runnable</tt>
     * tasks submitted by the <tt>execute</tt> method.
     * @param threadFactory the factory to use when the executor
     * creates a new thread.
     * @param handler the handler to use when execution is blocked
     * because the thread bounds and queue capacities are reached.
     */
    public ResizableThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue,
            ThreadFactory threadFactory, RejectedExecutionHandler handler)
    {
        super(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue, threadFactory, handler);
        this.corePoolSize = corePoolSize;
    }

    /**
     * After executing a <code>Runnable</code> pause the thread for a set
     * number of milliseconds.
     * 
     * @see java.util.concurrent.ThreadPoolExecutor#afterExecute(java.lang.Runnable,
     *      java.lang.Throwable)
     */
    @Override
    protected void afterExecute(Runnable r, Throwable t)
    {
        super.afterExecute(r, t);

        int queueSize = this.getQueue().size();
        if (queueSize < this.getMaximumPoolSize())
        {
            this.setCorePoolSize(Math.max(queueSize, corePoolSize));
        }
        else
        {
            this.setCorePoolSize(this.getMaximumPoolSize());
        }

        if (idleThreadName != null)
        {
            Thread runner = Thread.currentThread();
            runner.setName(idleThreadName);
        }
    }
}
