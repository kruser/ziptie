package org.ziptie.server.dispatcher;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.log4j.Logger;

/**
 * A class for running <code>Operation</code>s. It implements a bounded pool of threads;
 * as <code>OperationBatch</code>es are submitted it will add threads to the pool until
 * the maximum number is reached. Once all existing <code>Operation</code>s have been
 * executed, each thread will wait for a specified period of time before exiting.
 * <p>
 * Once at least one thread is active, an internal monitoring thread will be created to
 * periodically check active threads. If a thread has been running long enough, it will
 * be interrupted and the <code>Operation</code> marked cancelled, and the thread moved
 * to a separate pool of inactive threads not counted against the active pool bound.
 * <p>
 * As cancelled threads continue to run they will be periodically interrupted by the
 * monitor thread; if they run long enough (more than twice the auto-cancel time) they
 * will be marked as zombie threads and have their priority reduced to the minimum allowed.
 * <p>
 * Every <code>OperationExecutor</code> is associated with a <code>OperationManager</code>
 * upon creation. As <code>Operation</code>s complete (or are cancelled internally), the
 * <code>OperationManager</code>'s <code>jobDone()</code> method will be called.
 * <p>
 * Threads will be named to reflect their current operational status. That breakdown is:
 * <p>
 * <table>
 * <tr>
 * <th>Status</th>
 * <th>Name</th>
 * <th>Description</th>
 * </tr>
 * <tr>
 * <td>IDLE</td>
 * <td>Idle-#</td>
 * <td>A thread waiting for a new task</td>
 * </tr>
 * <tr>
 * <td>RUNNING</td>
 * <td>Running-#</td>
 * <td>Currently running a task</td>
 * </tr>
 * <tr>
 * <td>CANCELLED</td>
 * <td>CANCELLED-#</td>
 * <td>Cancelled either by calling code or by the internal monitor</td>
 * </tr>
 * <tr>
 * <td>ZOMBIE</td>
 * <td>ZOMBIE-#</td>
 * <td>A cancelled thread that will not die</td>
 * </tr>
 * </table>
 * <p>
 * In each case, # is the internal ID of the thread.
 * <p>
 * This class is intended to be thread safe.
 * <p>
 * 
 * @author chamlett
 */
class OperationExecutor
{
    private static final int INTERRUPT_COUNT = 10;
    private static final int TEN_MILLISECONDS = 10;
    private static final int ONE_SECOND = 1000;
    private static final int ONE_MINUTE = 60000;
    private static final int ONE_HOUR = 3600000;

    private static Logger DEV_LOG;

    /** Next ID to be used when creating new threads */
    private AtomicInteger nextID;

    /** The maximum number of threads to create */
    // TODO <crh>: Get thread count from properties?
    private AtomicInteger maxPoolSize;

    /** The maximum time a thread should be allowed to run before being auto-cancelled*/
    private AtomicInteger autoCancelTime;

    /** How long should a worker thread wait for a new <code>Operation</code> when none are available? */
    private int keepAlive = ONE_MINUTE;

    /** Threads either running tasks or idle waiting for tasks */
    private HashSet<JobThread> activePool;

    /** Threads that have been marked as cancelled or zombie */
    private HashSet<JobThread> inactivePool;

    /** The <code>OperationManager</code> to be notified when jobs are done */
    private OperationManager manager;

    /** The schedule responsible for returning jobs to execute */
    private RoundRobinSchedule schedule;

    /** The thread responsible for monitoring jobs and removing long-running ones */
    private Thread jobMonitor;

    /** An atomic boolean for checking to see if the monitor is running or not */
    private AtomicBoolean monitorRunning;

    /** The lock that must be obtained before accessing the active and inactive thread pools */
    private Object poolLock;

    /** The lock that must be obtained when getting new jobs from the schedule */
    private Object jobLock;

    /** The number of threads currently idle waiting for jobs */
    private int idle;

    static
    {
        DEV_LOG = Logger.getLogger(OperationExecutor.class);
    }

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------

    /**
     * Constructor. The supplied <code>OperationManager</code> must not be null.
     * 
     * @param manager The manager to be notified when <code>Operation</code>s complete.
     * @param schedule The schedule containing the <code>Operation</code>s to run.
     */
    OperationExecutor(OperationManager manager, RoundRobinSchedule schedule)
    {
        this.manager = manager;
        this.schedule = schedule;

        activePool = new HashSet<JobThread>(4);
        inactivePool = new HashSet<JobThread>();
        nextID = new AtomicInteger(1);
        monitorRunning = new AtomicBoolean(false);
        maxPoolSize = new AtomicInteger(4);
        autoCancelTime = new AtomicInteger(ONE_HOUR);
        poolLock = new Object();
        jobLock = new Object();
    }

    // ----------------------------------------------------------------
    //                   P U B L I C   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Return the time at which the <code>OperationManager</code> will automatically
     * cancel tasks. This is the amount of time after the <code>Operation</code> is
     * started, not after it is submitted.
     * 
     * @return The time at which a task will be cancelled, in milliseconds.
     */
    public int getAutoCancelTime()
    {
        return autoCancelTime.get();
    }

    /**
     * Set the auto-cancel time for the <code>OperationManager</code>. Tasks that run
     * longer than this amount will be canceled. Note that this is not a hard upper
     * bound, tasks are not guaranteed to be canceled at exactly this period after
     * beginning execution--it will always be after that.
     * 
     * @param autoCancelTime The time to allow tasks to complete normally before
     *    canceling them, in milliseconds.
     */
    public void setAutoCancelTime(int autoCancelTime)
    {
        this.autoCancelTime.set(autoCancelTime);
    }

    /**
     * Returns true if the task is canceled or if the task is not in the active pool
     * @param task The task to check.
     * @return <code>true</code> if the task is canceled, <code>false</code> otherwise.
     */
    public boolean isCanceled(ITask task)
    {
        synchronized (poolLock)
        {
            for (JobThread thread : activePool)
            {
                Operation job = thread.getJob();
                if (job != null && job.getTask() == task)
                {
                    return thread.getStatus() == Status.CANCELLED;
                }
            }

            return true;
        }
    }

    // ----------------------------------------------------------------
    //                   P A C K A G E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * The maximum number of simultaneous active threads. This will not cause the
     * premature cancellation of any active threads.
     * 
     * @param maximumPoolSize The desired maximum. Must be greater than zero.
     */
    void setMaximumPoolSize(int maximumPoolSize)
    {
        int newSize = Math.max(1, maximumPoolSize);

        if (newSize == maxPoolSize.get())
        {
            return;
        }

        maxPoolSize.set(newSize);

        wakeUp();
    }

    /**
     * Get the maximum number of threads that will be used to execute jobs.
     * 
     * @return the maximum number of threads that can be active (or idle) at one time
     *    while executing jobs.
     */
    int getMaximumPoolSize()
    {
        return maxPoolSize.get();
    }

    /**
     * Wake up the executor. This will create a new thread to handle scheduled jobs (if not at
     * the pool maximum) and wake up any threads currently waiting for jobs to become available.
     * Always be sure to update the schedule before calling this method.
     */
    void wakeUp()
    {
        // Add a thread to handle the new work, if we can
        addThread();

        // Wake up any threads waiting for new work
        synchronized (jobLock)
        {
            jobLock.notifyAll();
        }
    }

    /**
     * Return the count of active threads.
     * 
     * @return The number of active threads. They may be running a <code>Operation</code>, or
     * they may be idle waiting for a new one.
     */
    int getThreadCount()
    {
        synchronized (poolLock)
        {
            return activePool.size();
        }
    }

    /**
     * Cancel an entire batch. If any threads in this executor are currently executing
     * <code>Operation</code>s in the specified batch, the <code>OperationManager</code>
     * will be notified that the task has been cancelled
     * 
     * @param batchID The ID of the <code>OperationBatch</code> to be cancelled.
     * @return true, even if the batch is not actively being processed.
     */
    boolean cancelBatch(Integer batchID)
    {
        synchronized (poolLock)
        {
            // DEV_LOG.debug("OperationExecutor.cancelBatch: " + batchID);
            for (JobThread thread : activePool)
            {
                Operation job = thread.getJob();
                // DEV_LOG.debug(thread.getName() + " " + job);
                if (job == null || !job.getBatchID().equals(batchID))
                {
                    continue;
                }

                // DEV_LOG.debug(thread.getName() + " cancelling " + job);
                thread.setStatus(Status.CANCELLED);
                thread.jobDone(Outcome.CANCELLED, null);
            }

            return true;
        }
    }

    /**
     * Attempt to shutdown the <code>Executor</code> by interrupting all of the active threads.
     * It will interrupt the worker threads (and the internal monitor) and wait up to 100 msec
     * for each one to finish.
     */
    void shutdown()
    {
        ArrayList<Thread> al = null;
        synchronized (poolLock)
        {
            al = new ArrayList<Thread>(activePool);
            if (jobMonitor != null)
            {
                al.add(jobMonitor);
            }
        }

        // Try to interrupt and join the active threads a few times before giving up
        for (Thread thread : al)
        {
            for (int i = 0; i < INTERRUPT_COUNT; i++)
            {
                thread.interrupt();
                try
                {
                    thread.join(TEN_MILLISECONDS);
                    if (!thread.isAlive())
                    {
                        break;
                    }
                }
                catch (InterruptedException ie)
                {
                    break;
                }
            }
        }

        synchronized (poolLock)
        {
            // Mark any remaining active threads as inactive.  Note this does not currently notify the listeners
            for (JobThread thread : activePool)
            {
                thread.setStatus(Status.CANCELLED);
            }

            inactivePool.addAll(activePool);
            activePool.clear();
        }
    }

    // ----------------------------------------------------------------
    //                   P R I V A T E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Start the internal monitor thread if it is not already running.
     */
    private void startMonitor()
    {
        if (monitorRunning.getAndSet(true))
        {
            return;
        }

        jobMonitor = new Thread(new JobMonitor(), "JobMonitor");
        jobMonitor.start();
    }

    /**
     * Add a new thread to the pool of active threads if we are not yet at the maximum.
     * 
     * @return true if a thread could be created, false otherwise.
     */
    private boolean addThread()
    {
        synchronized (poolLock)
        {
            if (activePool.size() >= maxPoolSize.get())
            {
                return false;
            }

            JobThread thread = new JobThread();
            activePool.add(thread);
            thread.start();
            startMonitor();
            return true;
        }
    }

    /**
     * Try to remove a thread from the executor. Perhaps counterintuitively, this method can add a
     * new thread if removing the specified thread leaves the Executor with no active threads and
     * tasks remaining in the scheduler. This condition should be rare--it can only happen if all
     * active threads are trying to end while new items are being added to the schedule.
     * 
     * @param thread The thread to remove
     * @return true if it could be removed, false otherwise
     */
    private boolean removeThread(JobThread thread)
    {
        synchronized (poolLock)
        {
            if (activePool.remove(thread))
            {
                // If all of our threads have ended at once, make sure something remains to handle any existing jobs
                // DEV_LOG.debug("Removing thread " + thread + " down to " + activePool.size());
                checkActive();
                return true;
            }

            return inactivePool.remove(thread);
        }
    }

    /**
     * Check and make sure there is at least one active thread if there is anything in the
     * scheduler. Because of the number of different ways a thread can be made inactive,
     * this is its own method.
     */
    private void checkActive()
    {
        final int batches = schedule.getBatchCount();
        synchronized (poolLock)
        {
            if (activePool.size() == 0 && batches > 0)
            {
                addThread();
            }
        }
    }

    // ----------------------------------------------------------------
    //                   I N N E R   C L A S S E S
    // ----------------------------------------------------------------

    /**
     * Status Enum
     */
    private static enum Status
    {
        IDLE,
        RUNNING,
        CANCELLED,
        ZOMBIE
    };

    /**
     * An internal thread class containing a <code>Operation</code> to run,
     * a status, and the time the run started.
     */
    private class JobThread extends Thread
    {
        /** The <code>Operation</code> currently being executed, if any */
        private Operation job;

        /** The thread's status */
        private Status status = Status.IDLE;

        /** An identifier for this thread */
        private int id;

        /** The time the current <code>Operation</code> began execution (if any) */
        private Date startDate;

        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------

        /**
         * Constructor. Creates an <code>IDLE</code> thread.
         */
        JobThread()
        {
            setDaemon(true);

            id = nextID.getAndIncrement();

            updateName();
        }

        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * The main <code>run()</code> method of this thread. It continually loops polling
         * the <code>schedule</code> by calling <code>schedule.getNextJob()</code> and running
         * the returned <code>Operation</code> until that method returns null.
         * <p>
         * Once the <code>schedule</code> indicates there are no more <code>Operation</code>s
         * currently available, the thread will sleep for up to <code>keepAlive</code> milliseconds.
         * At that point, if there are no more <code>Operation</code>s in the scheduler, the thread
         * will exit.
         * <p>
         * It will also exit when interrupted if it is not currently executing a <code>Operation</code>
         */
        @Override
        public void run()
        {
            try
            {
                long end = System.currentTimeMillis() + keepAlive;
                while (true)
                {
                    if (getThreadCount() > getMaximumPoolSize())
                    {
                        break;
                    }

                    synchronized (jobLock)
                    {
                        // Check to make sure this thread hasn't been cancelled since it last woke up
                        if (getStatus() == Status.CANCELLED)
                        {
                            break;
                        }

                        job = schedule.getNextJob();
                        //DEV_LOG.debug("Got job from schedule " + job);
                        if (job == null)
                        {
                            try
                            {
                                long sleepTime = end - System.currentTimeMillis();
                                if (sleepTime < ONE_SECOND)
                                {
                                    sleepTime = ONE_SECOND;
                                }
                                idle++;
                                jobLock.wait(sleepTime);
                                idle--;

                                if (schedule.getBatchCount() < 1 && System.currentTimeMillis() >= end)
                                {
                                    // DEV_LOG.debug("Ending - no more batches");
                                    break;
                                }
                            }
                            catch (InterruptedException ie)
                            {
                                // DEV_LOG.debug("Ending - interrupted");
                                break;
                            }

                            continue;
                        }
                        else
                        {
                            setStatus(Status.RUNNING);
                            setStartDate(new Date());

                            // If any other threads are idle, wake another one up to help out
                            if (idle > 0)
                            {
                                jobLock.notify();
                            }
                        }
                    }

                    // We got a job! Add another thread, if we can, to handle any remaining jobs
                    addThread();

                    if (!runJob())
                    {
                        break;
                    }

                    end = System.currentTimeMillis() + keepAlive;
                }
            }
            catch (Exception ex)
            {
                DEV_LOG.debug("Exception running jobs", ex);
            }
            finally
            {
                removeThread(this);
            }
        }

        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Get the start date for the current <code>Operation</code>. This is the time
         * it began execution, not when it was submitted.
         * 
         * @return The date the current <code>Operation</code> started running
         */
        Date getStartDate()
        {
            return startDate;
        }

        /**
         * The status of this thread. See the class description for a discussion of
         * what the allowed values are.
         * 
         * @return The threads current status
         */
        synchronized Status getStatus()
        {
            return status;
        }

        /**
         * Get the current <code>Operation</code>, if any
         * 
         * @return The <code>Operation</code> this thread is executing, or null if
         * it does not currently have anything to do.
         */
        synchronized Operation getJob()
        {
            return job;
        }

        /**
         * Set the status of this thread. This will also update the thread's name
         * to reflect that status.
         * 
         * @param status The new status of the thread.
         */
        synchronized void setStatus(Status status)
        {
            if (this.status != status)
            {
                this.status = status;
                updateName();
            }
        }

        // ----------------------------------------------------------------
        //                   P R I V A T E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Set the date this thread started running a <code>Operation</code>
         * 
         * @param startDate the date it started.
         */
        private synchronized void setStartDate(Date startDate)
        {
            this.startDate = startDate;
        }

        /**
         * Update the name of the thread to reflect its current status, so we get
         * some idea of what is going on when looking at stack traces. See the class
         * description for a list of what those names can be.
         */
        private synchronized void updateName()
        {
            String taskName = (job != null && job.getTask() != null ? job.getTask().toString() : "none");
            switch (status)
            {
            case IDLE:
                setName("Idle-" + id);
                break;
            case RUNNING:
                setName(String.format("Running-%d (%s)", id, taskName));
                break;
            case CANCELLED:
                setName(String.format("Cancelled-%d (%s)", id, taskName));
                break;
            case ZOMBIE:
                setName(String.format("Zombie-%d (%s)", id, taskName));
                break;
            default:
                setName("UNKNOWN" + id);
            }
        }

        /**
         * Run the current <code>Operation</code>
         * 
         * @return true if it could be executed completely, false if it was cancelled
         *    during the run.
         */
        private boolean runJob()
        {
            Throwable throwable = null;
            Outcome outcome = null;
            try
            {
                outcome = job.execute();
            }
            catch (Throwable t)
            {
                throwable = t;
                outcome = Outcome.EXCEPTION;
            }

            setStartDate(null);
            // If we were cancelled during the run, end. The manager should have been 
            // notified at the time of cancellation
            if (getStatus() != Status.RUNNING)
            {
                return false;
            }
            else
            {
                setStatus(Status.IDLE);
                jobDone(outcome, throwable);
                return true;
            }
        }

        /**
         * A convenience method for notifying our <code>OperationManager</code> of <code>Operation</code>
         * completion. Note that no other jobs will start or finish while the manager is being notified.
         * 
         * @param outcome The <code>Outcome</code> of the task's execution as returned by the 
         *    <code>ITask.execute()</code> method
         * @param t A <code>Throwable</code> if the execution of this job caused one to be thrown.
         */
        private void jobDone(Outcome outcome, Throwable t)
        {
            // We have to lock the schedule so no other jobs end while we're notifying.
            // Otherwise notifications may be delivered out of order.
            synchronized (schedule)
            {
                if (schedule.completeRunningJob(job))
                {
                    manager.jobDone(job, outcome, t);
                }
            }
        }
    }

    /**
     * A runnable intended to monitor the other threads in this executor. The active threads will
     * be periodically checked to make sure they haven't been running for too long; if they have
     * the monitor will attempt to interrupt them and mark them inactive.
     * <p>
     * Once all other threads have ended, this runnable will exit.
     */
    private class JobMonitor implements Runnable
    {
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Continuously monitor all threads produced by this <code>Executor</code>, once per second
         * as long as any threads exist.
         * <p>
         * The active threads will be checked to see if they have run too long; if so, they will be
         * cancelled and the manager notified of the cancellation.
         * <p>
         * Cancelled threads that have not yet ended will be periodically interrupted in the hopes
         * that they will then end. If they don't, they will eventually be marked as zombies and
         * have their priority reduced to minimum.
         */
        public void run()
        {
            try
            {
                while (true)
                {
                    synchronized (poolLock)
                    {
                        checkInactiveThreads();

                        if (checkActiveThreads())
                        {
                            // Try and replace any threads we may have removed
                            wakeUp();
                        }

                        if (activePool.size() == 0 && inactivePool.size() == 0)
                        {
                            break;
                        }
                    }

                    try
                    {
                        Thread.sleep(ONE_SECOND);
                    }
                    catch (InterruptedException ie)
                    {
                        break;
                    }
                }
            }
            finally
            {
                monitorRunning.set(false);
                jobMonitor = null;
            }
        }

        // ----------------------------------------------------------------
        //                   P R I V A T E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Check any inactive threads and try to interrupt them.  If they have been running for
         * too long, set them to zombie status and reduce their priority to the minimum. 
         */
        private void checkInactiveThreads()
        {
            final long now = System.currentTimeMillis();

            for (JobThread thread : inactivePool)
            {
                Date date = thread.getStartDate();
                if (date == null)
                {
                    continue; // Error--remove it?
                }

                if (thread.getStatus() != Status.ZOMBIE && now - date.getTime() > 2 * getAutoCancelTime())
                {
                    // We have a problem thread
                    thread.setStatus(Status.ZOMBIE);
                    thread.setPriority(Thread.MIN_PRIORITY);
                }

                thread.interrupt();
            }
        }

        /**
         * Check the activeThreads and make sure they haven't been running too long.
         * If they have, mark them as cancelled, notify the manager, and move them to
         * the inactive pool
         * 
         * @return true if any threads were removed from the active pool
         */
        private boolean checkActiveThreads()
        {
            final long now = System.currentTimeMillis();

            // Use an iterator so can remove from the collection during the loop
            Iterator<JobThread> iter = activePool.iterator();
            boolean removedAny = false;
            while (iter.hasNext())
            {
                JobThread thread = iter.next();
                Date date = thread.getStartDate();
                //DEV_LOG.debug("Polling " + thread.getName() + " start is " + date);
                if (date == null)
                {
                    continue;
                }

                boolean cancelled = (thread.getStatus() == Status.CANCELLED);
                if (cancelled || now - date.getTime() > getAutoCancelTime())
                {
                    thread.setStatus(Status.CANCELLED);
                    iter.remove();
                    //DEV_LOG.debug("Thread " + thread.getName() + " has run too long");
                    inactivePool.add(thread);
                    removedAny = true;

                    if (!cancelled && thread.getJob() != null)
                    {
                        thread.jobDone(Outcome.CANCELLED, null);
                        thread.interrupt();
                    }
                }
            }

            return removedAny;
        }
    }
}
