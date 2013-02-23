package org.ziptie.server.dispatcher;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

/**
 * The central class for submitting arbitrary tasks to be run by a pool of available
 * threads in round-robin fashion.
 * <p>
 * The primary interfaces to the class are:
 * <p>
 * <li><code>submitJobs()</code>: give a list of ITasks (essentially Runnables with
 * a lock object), an indicator of whether they must be executed sequentially or not,
 * and a listener to be notified of progress on the supplied tasks. Right now, the
 * only notification that will come is when the task completes. This returns an ID
 * for the batch.</li>
 * 
 * <li><code>cancelJobs()</code>: Given a batch ID, will cancel all of the jobs that
 * have not yet run, and will attempt to cancel those currently running.</li>
 * 
 * <li><code>resubmitJob()</code>: Attempt to resubmit the specified job to the
 * OperationManager to be run again. The only time this is guaranteed to work is
 * during a notification callback in supplied listener.</li>
 * 
 * <li><code>getStatus()</code>: Return an object describing the OperationManager's
 * current activity.</li>
 * 
 * @author chamlett
 */

// TODO <crh> Add the idea of an idle batch, that only executes if there are
// no other batches. Alternatively, add priorities, and set Idle to lowest
// TODO <crh> Add concept of delayed execution--only do the task at a specified time
public class OperationManager
{
    private static Logger DEV_LOG;

    /**
     * The schedule responsible for returning objects in a round-robin fashion.
     */
    private RoundRobinSchedule schedule;

    /** The next ID to use when a new batch is created */
    private int nextID;

    /**
     * The Executor responsible for running tasks. It has a bounded thread pool.
     */
    private OperationExecutor executor;

    static
    {
        DEV_LOG = Logger.getLogger(OperationManager.class);
    }

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------    

    /**
     * The only constructor.
     */
    public OperationManager()
    {
        schedule = new RoundRobinSchedule();
        executor = new OperationExecutor(this, schedule);
    }

    // ----------------------------------------------------------------
    //                   P U B L I C   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Submit a list of tasks to be executed.
     * 
     * @param runnables The tasks to be executed.
     * @param sequential True if they need to be executed in the supplied sequence
     * @param listener The listener, or null if you don't care what happens
     * @return The internal ID of the created batch; this ID must be supplied to <code>cancelJobs()</code>
     */
    public Integer submitJobs(List<? extends ITask> runnables, boolean sequential, ITaskListener listener)
    {
        if (runnables == null)
        {
            return null;
        }

        OperationBatch batch = null;
        synchronized (this)
        {
            // DEV_LOG.debug("Submitted batch " + nextID);
            batch = new OperationBatch(nextID++, runnables);
        }

        batch.setSequential(sequential);
        batch.setListener(listener);

        schedule.put(batch);
        // DEV_LOG.debug("\tCalling wakeup");
        executor.wakeUp();

        return batch.getID();
    }

    /**
     * Resubmit a completed job for re-execution.
     * <p>
     * It is best to call this method within the <code>eventOccurred()</code> method of a
     * notification in the original listener.  For sequential batches, this method will fail
     * (returning false) if anything but the most recently executed <code>Operation</code>
     * is resubmitted.
     * <p>
     * 
     * @param batchID The ID of the batch
     * @param jobID The ID of the Operation in that batch
     * @param task A new <code>ITask</code> for this job, if one is desired. If this parameter
     *    is null, the <code>Operation</code>'s existing task will be executed.
     * @return true if it could be resubmitted, false otherwise.
     */
    public boolean resubmitJob(Integer batchID, Integer jobID, ITask task)
    {
        // DEV_LOG.debug("Trying to resubmit " + batchID + "-" + jobID);
        return schedule.resubmitJob(batchID, jobID, task);
    }

    /**
     * Set the auto-cancel time for the <code>OperationManager</code>. Tasks that run longer
     * than this amount will be canceled. Note that this is not a hard upper bound, tasks are
     * not guaranteed to be canceled at exactly this period after beginning execution--it will
     * always be after that.
     * 
     * @param autoCancelTime The time to allow tasks to complete normally before canceling
     *   them, in milliseconds.
     */
    public void setAutoCancelTime(int autoCancelTime)
    {
        executor.setAutoCancelTime(autoCancelTime);
    }

    /**
     * Get the current status of the <code>OperationManager</code>
     * 
     * @return A <code>OperationManagerStatus</code> object containing information about
     *    the <code>OperationManager</code>'s internal status.
     */
    public OperationManagerStatus getStatus()
    {
        return schedule.getStatus();
    }

    /**
     * Return the time at which the <code>OperationManager</code> will automatically cancel
     * tasks. This is the amount of time after the <code>Operation</code> is started, not
     * after it is submitted.
     * 
     * @return The time at which a task will be cancelled, in milliseconds.
     */
    public int getAutoCancelTime()
    {
        return executor.getAutoCancelTime();
    }

    /**
     * Cancel all the jobs in a batch.
     * 
     * @param id The ID of the batch as returned from <code>submitJobs()</code>
     * @return true if the batch could be cancelled, false otherwise.
     */
    public boolean cancelJobs(Integer id)
    {
        OperationBatch batch = schedule.get(id);
        if (batch == null)
        {
            return false;
        }

        // Mark the unstarted jobs in this batch complete in the schedule. This will
        // prevent the executor from starting any of those jobs while they're being completed.
        // DEV_LOG.debug("Removing batch " + id + " from schedule");
        ArrayList<Operation> jobs = schedule.completeUnstarted(id);

        // Cancel jobs currently in the Executor. The Executor will notify the listener
        // about cancellations of running jobs DEV_LOG.debug("Removing batch " + id + " from executor");
        executor.cancelBatch(id);

        if (jobs == null)
        {
            return true;
        }

        // Notify the listener about the unstarted jobs that were cancelled
        // DEV_LOG.debug("Notifying listener about removal of batch " + id);
        for (Operation j : jobs)
        {
            TaskCompleteEvent event = new TaskCompleteEvent();
            event.setOutcome(Outcome.CANCELLED);
            event.setBatchID(id);
            event.setJobID(j.getID());
            event.setTask(j.getTask());
            batch.notifyListener(event);
        }

        return true;
    }

    /**
     * Get the number of active & idle threads
     * 
     * @return The number of active and idle threads in the executor
     */
    public int getThreadCount()
    {
        return executor.getThreadCount();
    }

    /**
     * Get the maximum number of threads that will be used to execute jobs
     * 
     * @return The maximum number of threads that can be active at one time.
     */
    public int getMaxThreadCount()
    {
        return executor.getMaximumPoolSize();
    }

    /**
     * Set the maximum number of threads to use to execute jobs. Reducing the
     * thread count will not necessarily have an immediate effect, but the count
     * will go down to the new maximum as jobs are finished.
     * 
     * @param threadCount The maximum number of threads to use.
     */
    public void setMaxThreadCount(int threadCount)
    {
        if (threadCount < 1)
        {
            return;
        }

        executor.setMaximumPoolSize(threadCount);
        executor.wakeUp();
    }

    /**
     * Shut down the <code>OperationManager</code>, this will try to cancel all
     * threads in the executor. This method tries to do the right thing, and it's
     * a good idea to call it before exiting, but it's probably not wise to reuse
     * a <code>OperationManager</code> after a shutdown.  The listeners are not
     * guaranteed to be notified of job completion.
     */
    public void shutdown()
    {
        executor.shutdown();
    }

    /**
     * Returns true if the task is canceled or if the task is not in the active pool
     * @param task The task to check.
     * @return <code>true</code> if the task is canceled, <code>false</code> otherwise.
     */
    public boolean isCanceled(ITask task)
    {
        return executor.isCanceled(task);
    }

    // ----------------------------------------------------------------
    //                   P A C K A G E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * The method called by the executor when jobs are finished.
     * It will return whatever the original task's <code>execute()</code> method generated,
     * with the following possible exceptions:
     * <li>CANCELLATION - the job was cancelled, either by execution of <code>cancelJobs()</code>
     *    or by the internal thread monitor.</li>
     * <li>EXCEPTION - the task generated a <code>Throwable</code> during execution.</li>
     * 
     * @param job The job that is finished.
     * @param outcome The <code>Outcome</code> of the <code>ITask</code>, as described above.
     * @param throwable null if it completed successfully, otherwise any throwable it produced
     */
    void jobDone(Operation job, Outcome outcome, Throwable throwable)
    {
        // DEV_LOG.debug("OperationManager.jobDone: job " + job + " is done");
        Integer batchID = job.getBatchID();
        OperationBatch batch = schedule.get(batchID);

        if (batch == null)
        {
            DEV_LOG.error("Internal error (OperationManager): lost queue " + batchID);
            return;
        }

        TaskCompleteEvent event = new TaskCompleteEvent();

        event.setOutcome(outcome);
        event.setThrowable(throwable);
        event.setBatchID(batchID);
        event.setJobID(job.getID());
        event.setTask(job.getTask());

        batch.notifyListener(event);
    }
}
