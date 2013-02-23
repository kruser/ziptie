package org.ziptie.server.dispatcher;

/**
 * This class is used internally by the <code>OperationManager</code> to wrap a
 * submitted <code>ITask</code> with other information used during its execution.
 * 
 * @author chamlett
 */
class Operation
{
    /**
     * The internal identifier of this job. It is unique among all the Jobs in
     * a OperationBatch.
     */
    private Integer id;

    /**
     * The batch with which this Operation is associated. An individual ITask can
     * only be in a single OperationBatch.
     */
    private Integer batchID;

    /** The ITask submitted for execution. */
    private ITask task;

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------

    /**
     * Constructor for a <code>Operation</code>. It requires an externally generated
     * batch ID, job ID, and task. The job's ID should be unique among all the jobs
     * in the batch.  None of the supplied parameters can be null.
     * 
     * @param batchID The ID of the <code>OperationBatch</code> with which this
     *    Operation is associated.
     * @param id The ID of this <code>Operation</code>
     * @param task The original <code>ITask</code> to be executed.
     */
    Operation(Integer batchID, Integer id, ITask task)
    {
        this.batchID = batchID;
        this.id = id;
        this.task = task;
    }

    // ----------------------------------------------------------------
    //                   P A C K A G E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Get the <code>ITask</code> this <code>Operation</code> wraps.
     * 
     * @return The <code>ITask</code> it was created with.
     */
    ITask getTask()
    {
        return task;
    }

    /**
     * Get the ID of this <code>Operation</code>.
     * 
     * @return The ID it was created with.
     */
    Integer getID()
    {
        return id;
    }

    /**
     * Get the ID of the <code>OperationBatch</code> this <code>Operation</code>
     * was created with.
     * 
     * @return Returns the ID of the batch this Operation was created with.
     */
    Integer getBatchID()
    {
        return batchID;
    }

    /**
     * Reset the task this <code>Operation</code> is responsible for wrapping.
     * 
     * @param task The new <code>ITask</code> to execute()
     */
    void setTask(ITask task)
    {
        this.task = task;
    }

    /**
     * Calls the <code>ITask</code>'s <code>execute()</code> method.
     * 
     * @see <code>java.lang.Runnable#run()</code>
     * @return The outcome of the task, which will then be passed to the registered listener
     */
    Outcome execute() throws Exception
    {
        return task.execute();
    }
}
