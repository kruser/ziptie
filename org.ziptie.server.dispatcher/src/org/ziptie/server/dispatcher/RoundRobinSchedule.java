package org.ziptie.server.dispatcher;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

/**
 * The schedule is responsible, when called, for iterating through the list of available
 * batches and finding a <code>Operation</code> for execution.
 * <p>
 * For sequential batches, that batch cannot currently be running another
 * <code>Operation</code>. Also for sequential batches, if the next task is already locked
 * for exection (in another batch), it will skip that batch. For non-sequential batches it
 * will choose any task that has not yet been started and is not locked by another batch.
 * 
 * @author chamlett
 */
class RoundRobinSchedule
{
    private static Logger DEV_LOG;

    /** The next batch to check for available <code>Operation</code>s */
    private int next;

    /** The ordered list of batch IDs used to enforce round-robin behavior */
    private List<Integer> keys;

    /** All of the <code>OperationBatch</code>es submitted so far, indexed by their ID */
    private Map<Integer, OperationBatch> batches;

    /** The list of locks for current running tasks. */
    private Set<Object> locks;

    static
    {
        DEV_LOG = Logger.getLogger(RoundRobinSchedule.class);
    }

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------

    /**
     * Constructor
     */
    RoundRobinSchedule()
    {
        keys = new ArrayList<Integer>();
        batches = new HashMap<Integer, OperationBatch>();
        locks = new HashSet<Object>();
    }

    // ----------------------------------------------------------------
    //                   P A C K A G E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Add a <code>OperationBatch</code> to the existing schedule. It will be placed at
     * the end of the list of <code>OperationBatch</code>es to execute.
     * 
     * @param batch The <code>OperationBatch</code> to be added.
     * @return The <code>OperationBatch</code>, if it could be added.
     */
    synchronized OperationBatch put(OperationBatch batch)
    {
        keys.add(batch.getID());
        return batches.put(batch.getID(), batch);
    }

    /**
     * Get a <code>OperationBatch</code> by ID
     * 
     * @param key The ID of the <code>OperationBatch</code> we wish to retrieve.
     * @return A <code>OperationBatch</code> if it still exists in the schedule, or null.
     */
    synchronized OperationBatch get(Integer key)
    {
        return batches.get(key);
    }

    /**
     * @return The number of <code>OperationBatch</code>es currently in the schedule
     */
    synchronized int getBatchCount()
    {
        return batches.size();
    }

    /**
     * Take a running <code>Operation</code> and mark it as completed.
     * 
     * @param job The <code>Operation</code> to complete.
     * @return true if the job was running, false if it wasn't (or if the batch
     *    could not be found)
     */
    synchronized boolean completeRunningJob(Operation job)
    {
        OperationBatch batch = get(job.getBatchID());

        if (batch == null)
        {
            return false;
        }

        boolean running = batch.isRunning(job);
        if (running)
        {
            batch.setCompleted(job);
        }

        locks.remove(job.getTask().getLockObject());

        return running;
    }

    /**
     * Complete all of the unstarted <code>Operation</code>s associated with
     * the specified <code>OperationBatch</code>
     * 
     * @param id The ID of a <code>OperationBatch</code>
     * @return the list of jobs that were completed, or null if the batch could
     *    not be found.
     */
    synchronized ArrayList<Operation> completeUnstarted(Integer id)
    {
        OperationBatch batch = get(id);
        if (batch == null)
        {
            return null;
        }

        ArrayList<Operation> jobs = new ArrayList<Operation>(batch.getUnstartedJobs());
        batch.completeUnstarted();

        return jobs;
    }

    /**
     * Get the next <code>Operation</code> to execute.
     * 
     * @return The next <code>Operation</code> available for execution, or null if either
     *    the schedule is empty or all <code>OperationBatch</code>es are locked.
     */
    synchronized Operation getNextJob()
    {
        OperationBatch batch = getNextBatch();
        if (batch == null)
        {
            return null;
        }

        Operation job = batch.getNextJob(locks);
        if (job == null)
        {
            return null;
        }

        batch.setRunning(job);
        batch.incNextRunID();

        locks.add(job.getTask().getLockObject());

        return job;
    }

    /**
     * Mark a completed <code>Operation</code> as needing re-execution.
     * 
     * @param batchID The batch containing the <code>Operation</code> we need to resubmit
     * @param jobID The ID of the <code>Operation</code> needing resubmission
     * @param task a new <code>ITask</code> to execute, if one is desired.  If null, the
     *    old <code>ITask</code> will be used.
     * @return true if it could be resubmitted, false otherwise
     */
    synchronized boolean resubmitJob(Integer batchID, Integer jobID, ITask task)
    {
        OperationBatch batch = get(batchID);

        if (batch == null)
        {
            DEV_LOG.error("Resubmitting job for invalid batch " + batchID);
            return false;
        }

        if (!batch.restart(jobID, task))
        {
            DEV_LOG.error("Unable to restart job " + jobID);
            return false;
        }

        return true;
    }

    /**
     * <code>OperationManager.getStatus()</code> passes through to this method, where
     * all of the <code>OperationBatch</code>es are actually held.
     * 
     * @return a <code>OperationManagerStatus</code> with all of the information
     *    concerning all of the <code>OperationBatch</code>es in the schedule
     */
    synchronized OperationManagerStatus getStatus()
    {
        OperationManagerStatus status = new OperationManagerStatus();
        for (OperationBatch jb : batches.values())
        {
            status.addBatchStatus(jb);
        }

        return status;
    }

    // ----------------------------------------------------------------
    //                   P R I V A T E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Find the next <code>OperationBatch</code> with a <code>Operation</code> that
     * can be executed. Will return null if there are none.
     * <p>
     * This method remembers its state between calls through the use of the <code>next</code>
     * member, which always points to an index of the <code>keys</code> list.
     * 
     * @return A <code>OperationBatch</code> with an executable <code>Operation</code>,
     *    if one could be found.
     */
    private synchronized OperationBatch getNextBatch()
    {
        if (keys.size() < 1)
        {
            return null;
        }

        assert (next >= 0 && next < keys.size());

        OperationBatch batch = null;
        boolean first = true;

        for (int i = next;; i++)
        {
            if (i >= keys.size())
            {
                i = 0;
            }

            Integer batchID = keys.get(i);

            if (!first && i == next)
            {
                break; // We've looped all batches
            }

            batch = batches.get(batchID);

            // Is there anything left to start?
            if (batch.getUnstartedCount() < 1)
            {
                // No. If nothing's running, batch is finished
                if (batch.getRunningCount() < 1)
                {
                    removeByKeyIndex(i);
                    if (keys.size() < 1)
                    {
                        return null; // Last batch finished
                    }

                    i--; // We just removed this batch, don't skip the next one.

                    continue;
                }
            }
            else if (!(batch.isSequential() && batch.getRunningCount() > 0) && batch.getNextJob(locks) != null)
            {
                // If it's a sequential batch and has one running, OR we can't lock the next job, we can't use it.
                // Otherwise, return this batch.
                next = i + 1;
                if (next >= keys.size())
                {
                    next = 0;
                }

                return batch;
            }
            first = false;
        }

        return null;
    }

    // ----------------------------------------------------------------
    //                   P R I V A T E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Remove a <code>OperationBatch</code> by index in the <code>keys</code> list.
     * 
     * @param key An integer pointing to an entry in the <code>keys</code> list.
     * @return The <code>OperationBatch</code> that was removed, if any.
     */
    private OperationBatch removeByKeyIndex(int key)
    {
        assert (key >= 0 && key < keys.size());

        Integer id = keys.remove(key);
        if (key < next)
        {
            next--;
        }

        assert (next >= 0);

        if (next >= keys.size())
        {
            next = 0;
        }

        return batches.remove(id);
    }
}
