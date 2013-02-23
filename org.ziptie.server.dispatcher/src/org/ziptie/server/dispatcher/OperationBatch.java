package org.ziptie.server.dispatcher;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

/**
 * A collection of tasks to be executed by a <code>OperationManager</code>. This class is used
 * internally in the <code>RoundRobinSchedule</code> and there is no public access to this
 * class outside of this package. As such, it is not thread safe.
 * <p>
 * A OperationBatch may be specified as sequential or non-sequential. The <code>OperationManager</code>
 * will execute sequential tasks in the order they were originally specified, but non-sequential
 * tasks will be executed in an arbitrary order.
 * <p>
 * Each OperationBatch also contains the original supplied <code>ITaskListener</code>, and this
 * will be used to notify the calling code of progress for every task in the batch.
 * <p>
 * Every Operation in this <code>OperationBatch</code> must have a unique identifier, and for
 * sequential <code>OperationBatch</code>es there is a further requirement that the identifiers
 * be sequentialling incrementing <code>Integer</code>s starting at zero in the order that the
 * tasks are to be executed. As the <code>OperationBatch</code> handles creating and inserting
 * <code>Operation</code>s based on supplied <code>ITask</code>s, this is all done internally.
 * <p>
 * 
 * @author chamlett
 */
class OperationBatch
{
    private static Logger DEV_LOG;

    /**
     * The ID of this <code>OperationBatch</code>. It must be unique for all currently queued
     * <code>OperationBatch</code>es, and in the current implementation is unique for all
     * JobBatches executed since the <code>OperationManager</code> was instantiated.
     */
    private Integer id;

    /** For sequential batches, the next <code>Operation</code> to be executed. */
    private int nextRunID;

    /** A Map of jobs that have not yet been started by the <code>OperationManager</code> */
    private Map<Integer, Operation> unstarted;

    /**
     * A map of jobs that have been started by the <code>OperationManager</code>, but
     * have not yet finished.
     */
    private Map<Integer, Operation> running;

    /** A map of completed jobs */
    private Map<Integer, Operation> completed;

    /** The listener to be notified of <code>ITask</code> execution progress */
    private ITaskListener listener;

    /** Is this a sequential <code>OperationBatch</code>? */
    private boolean sequential;

    static
    {
        DEV_LOG = Logger.getLogger(OperationBatch.class);
    }

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------

    /**
     * Constructor for creating a <code>OperationBatch</code>. None of the supplied
     * parameters may be null.
     * 
     * @param batchID The ID of this <code>OperationBatch</code>. It must be unique
     *    for all batches currently contained in a <code>OperationManager</code>.
     * @param runnables A list of <code>ITask</code>s to be executed.
     */
    OperationBatch(Integer batchID, List<? extends ITask> runnables)
    {
        unstarted = new HashMap<Integer, Operation>();
        running = new HashMap<Integer, Operation>();
        completed = new HashMap<Integer, Operation>();

        id = batchID;

        if (runnables == null)
        {
            return;
        }

        int i = 0;
        for (ITask task : runnables)
        {
            Operation job = new Operation(id, i++, task);
            unstarted.put(job.getID(), job);
        }
    }

    // ----------------------------------------------------------------
    //                   P A C K A G E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Set the listener to be called when <code>Operation</code>s in this
     * <code>OperationBatch</code> are executed.
     * 
     * @param listener The listener to set.
     */
    void setListener(ITaskListener listener)
    {
        this.listener = listener;
    }

    /**
     * Get the ID supplied when this OperationBatch was created.
     * 
     * @return Returns the ID.
     */
    Integer getID()
    {
        return id;
    }

    /**
     * Is this a sequential batch or not?
     * 
     * @return Returns true if this is a sequential batch, false otherwise
     */
    boolean isSequential()
    {
        return sequential;
    }

    /**
     * Set whether this is a sequential batch of job or not. Note that it is not a good
     * idea to change this from non-sequential to sequential after the batch
     * has been queued for execution.
     * 
     * @param sequential True if the jobs must be executed in order.
     */
    void setSequential(boolean sequential)
    {
        this.sequential = sequential;
    }

    /**
     * Get the number of jobs in this batch that have not yet been submitted for execution.
     * 
     * @return The number of jobs waiting for submission.
     */
    int getUnstartedCount()
    {
        return unstarted.size();
    }

    /**
     * The count of jobs that are actively being processed.
     * 
     * @return The number of running jobs in this batch.
     */
    int getRunningCount()
    {
        return running.size();
    }

    /**
     * The count of jobs that have been processed.
     * 
     * @return The number of completed jobs in this batch.
     */
    int getCompletedCount()
    {
        return completed.size();
    }

    /**
     * Get the collection of jobs not yet executed. Note that it is not safe to modify the
     * returned <code>Collection</code>.
     * 
     * @return A <code>Collection</code> of <code>Operation</code>s currently waiting for execution.
     */
    Collection<Operation> getUnstartedJobs()
    {
        return unstarted.values();
    }

    /**
     * Get the next job to execute. For sequential batches, this will always return the same
     * <code>Operation</code>, until <code>incNextRunID()</code> is called. For non-sequential
     * batches, it will return an arbitrary <code>Operation</code> in the unstarted set.
     * 
     * The caller must supply a <code>Set</code> containing the current pool of locked
     * <code>Operation</code>s. The <code>Operation</code> returned is guaranteed to be
     * associated with an ITask whose <code>getLockObject()</code> method returns an Object
     * not in the Set.
     * 
     * @param lockSet A <code>Set</code> of locks held by currently running <code>Operation</code>s.
     * @return A <code>Operation</code> that has not yet been submitted for execution, or null
     *   if none are available.
     */
    Operation getNextJob(Set lockSet)
    {
        if (unstarted.size() < 1)
        {
            return null;
        }

        if (sequential)
        {
            if (running.size() > 0)
            {
                return null;
            }

            Integer nextID = Integer.valueOf(nextRunID);

            Operation job = unstarted.get(nextID);

            if (job != null)
            {
                Object obj = job.getTask().getLockObject();
                if (obj != null && lockSet.contains(obj))
                {
                    job = null;
                }

                return job;
            }

            DEV_LOG.error("OperationBatch internal error:  missing job " + nextID);
            // This shouldn't happen; fall through to unordered case
        }

        for (Operation job : unstarted.values())
        {
            Object lock = job.getTask().getLockObject();
            if (lock == null || !lockSet.contains(lock))
            {
                return job;
            }
        }

        return null;
    }

    /**
     * Advance to the next available Operation
     */
    void incNextRunID()
    {
        nextRunID++;
    }

    /**
     * Mark the supplied <code>Operation</code> as running. The <code>Operation</code> should
     * not yet be started for this to succeed.
     * 
     * @param job The <code>Operation</code> that is now running.
     * @return true if it could be marked running, false otherwise.
     */
    boolean setRunning(Operation job)
    {
        return moveJob(job.getID(), unstarted, running);
    }

    /**
     * Check to see if the specified <code>Operation</code> is running.
     * 
     * @param job The <code>Operation</code> to check
     * @return true if it is running, false if it is either unstarted or has already completed.
     */
    boolean isRunning(Operation job)
    {
        if (job == null)
        {
            return false;
        }

        return running.containsKey(job.getID());
    }

    /**
     * Mark the supplied <code>Operation</code> as completed. The <code>Operation</code>
     * should currently be running for this to succeed.
     * 
     * @param job The <code>Operation</code> that is now complete
     * @return true if it could be marked complete, false otherwise.
     */
    boolean setCompleted(Operation job)
    {
        return moveJob(job.getID(), running, completed);
    }

    /**
     * Restart the supplied job, returning it to unstarted status. The <code>Operation</code>
     * should currently be completed for this to succeed.
     * 
     * @param jobID The ID of the <code>Operation</code> that is to be run again
     * @param task A new <code>ITask</code> to run, if any.  If this is null, the previous
     *    <code>ITask</code> will be run.
     * @return true if it could be unstarted, false otherwise.
     */
    boolean restart(Integer jobID, ITask task)
    {
        Operation job = completed.get(jobID);

        if (isSequential())
        {
            // Should really only be restarting the most recently executed job
            if (nextRunID - 1 != jobID)
            {
                DEV_LOG.debug("Out of order restart of sequential batch:  expected " + (nextRunID - 1) + " but got " + jobID);
                return false;
            }
            nextRunID = jobID;
        }

        if (job != null && task != null)
        {
            job.setTask(task);
        }

        return moveJob(jobID, completed, unstarted);
    }

    /**
     * Mark any unstarted <code>Operation</code> as completed. Used when cancelling an entire
     * batch. This should not be called without also notifying any listeners that the
     * <code>Operation</code>s were cancelled.
     */
    void completeUnstarted()
    {
        ArrayList<Integer> al = new ArrayList<Integer>(unstarted.keySet());
        for (Integer jobID : al)
        {
            moveJob(jobID, unstarted, completed);
        }
    }

    /**
     * Notify the JobBatches listener of the supplied event.
     * 
     * @param event A TaskEvent indicating status of a job in this batch.
     */
    void notifyListener(TaskEvent event)
    {
        if (listener == null)
        {
            return;
        }

        try
        {
            listener.eventOccurred(event);
        }
        catch (Throwable t)
        {
            DEV_LOG.error("Error notifying listener of " + event, t);
        }
    }

    // ----------------------------------------------------------------
    //                   P R I V A T E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Internal utility method to move a <code>Operation</code> from one category to another.
     * 
     * @param jobID The ID of the <code>Operation</code> to move.
     * @param from The map in which it currently resides, one of unstarted, running, or completed.
     * @param to The map to which it should be moved; should be one of unstarted, running, or completed.
     * @return true if the <code>Operation</code> could be moved, false otherwise.
     */
    private boolean moveJob(Integer jobID, Map<Integer, Operation> from, Map<Integer, Operation> to)
    {
        Operation job = from.remove(jobID);

        if (job == null)
        {
            DEV_LOG.error("Internal error (OperationBatch): unable to move job " + jobID);
            return false;
        }

        to.put(jobID, job);

        return true;
    }
}
