package org.ziptie.nio.nioagent;

import java.nio.channels.SelectionKey;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.locks.ReentrantLock;

import org.ziptie.nio.common.ILogger;


public class RetransmitExtension implements WriterExtension
{

    // -- fields
    private static final Timer retransmitTimer = new Timer("Retransmit", true);
    long delay;
    int maxRetransmits;
    ReentrantLock lock;
    TimerTask retransmitTask;
    volatile int retransmitCount;
    ILogger logger;

    // -- constructors
    private RetransmitExtension()
    {
        // do nothing
    }

    // -- public methods
    public static WriterExtension create(final long delay, final int maxRetransmits, final ILogger logger)
    {
        RetransmitExtension impl = new RetransmitExtension();
        impl.delay = delay;
        impl.maxRetransmits = maxRetransmits;
        impl.lock = new ReentrantLock();
        impl.retransmitTask = null;
        impl.retransmitCount = 0;
        impl.logger = logger;
        return impl;
    }

    //    * WriterExtension methods
    public void cancel()
    {
        cancelRetransmitTask();
    }

    public void notIgnored()
    {
        cancelRetransmitTask();
    }

    public void readyToWrite(long delay)
    {
        retransmitCount = 0;
        delay = 0L == delay ? delay : delay;
    }

    public void successfulWrite(SelectionKey key)
    {
        retransmitTask = new RetransmitTask(key);
        retransmitTimer.schedule(retransmitTask, delay);
    }

    // -- package-private methods
    void cancelRetransmitTask()
    {
        if (null != retransmitTask)
        {
            lock.lock();
            try
            {
                retransmitTask.cancel();
            }
            catch (RuntimeException e)
            {
                logger.error("Failed to cancel retransmit task.", e);
                throw e;
            }
            finally
            {
                lock.unlock();
            }
        }
    }

    // -- inner classes
    private class RetransmitTask extends TimerTask
    {
        final SelectionKey key;

        RetransmitTask(final SelectionKey key)
        {
            this.key = key;
        }

        @Override
        public void run()
        {
            if (lock.tryLock())
            {
                try
                {
                    retransmitOrDie();
                }
                catch (RuntimeException e)
                {
                    logger.error("Failed to run retransmit task.", e);
                    key.cancel();
                    throw e;
                }
                finally
                {
                    lock.unlock();
                }
            }
        }

        void retransmitOrDie()
        {
            if (key.isValid())
            {
                if (maxRetransmits > retransmitCount)
                {
                    retransmitCount++;
                    key.interestOps(SelectionKey.OP_WRITE);
                    key.selector().wakeup();
                }
                else
                {
                    if (null != key.selector())
                    {
                        key.cancel();
                    }
                }
            }
        }
    }

}
