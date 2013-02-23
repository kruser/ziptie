package org.ziptie.server.dispatcher;

import java.io.Serializable;
import java.util.Date;

/**
 * The base class for notification of events resulting from <code>ITask</code>
 * execution by a <code>OperationManager</code>.
 * 
 * @author chamlett
 */
public class TaskEvent implements Serializable
{
    static final long serialVersionUID = -737784502096460166L;

    /** The date the event ocurred */
    private Date date;

    /** The ID of the batch the <code>ITask</code> was associated with */
    private Integer batchID;

    /** The ID of the job created to reference the <code>ITask</code> */
    private Integer jobID;

    /** The original <code>ITask</code> submitted to the OperationManager */
    private ITask task;

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------

    /**
     * Constructor
     */
    public TaskEvent()
    {
        date = new Date();
    }

    // ----------------------------------------------------------------
    //                   P U B L I C   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Get the ID of the <code>OperationBatch</code> with which the <code>Operation</code>
     * is associated.
     * 
     * This can be used by the listener that receives this event to cancel the batch or
     * resubmit the <code>Operation</code>
     * 
     * @return Returns the <code>OperationBatch</code>'s ID.
     */
    public Integer getBatchID()
    {
        return batchID;
    }

    /**
     * Get the <code>ITask</code> associated with this event.
     * 
     * @return Returns the task.
     */
    public ITask getTask()
    {
        return task;
    }

    /**
     * Get the date this <code>TaskEvent</code> occurred.
     * 
     * @return Returns the date.
     */
    public Date getDate()
    {
        return date;
    }

    /**
     * Get the ID of the <code>Operation</code> that wrapped the original <code>ITask</code>.
     * This is used if the listener that received this event needs to resubmit the
     * <code>ITask</code> for execution.
     * 
     * @return Returns the jobID.
     */
    public Integer getJobID()
    {
        return jobID;
    }

    // ----------------------------------------------------------------
    //                   P A C K A G E   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * Set the <code>ITask</code> associated with this event.
     * 
     * @param task The task to set.
     */
    void setTask(ITask task)
    {
        this.task = task;
    }

    /**
     * Set the ID of the <code>Operation</code>.
     * 
     * @param jobID The jobID to set.
     */
    void setJobID(Integer jobID)
    {
        this.jobID = jobID;
    }

    /**
     * Set the ID of the <code>OperationBatch</code>
     * 
     * @param batchID The batch ID to set
     */
    void setBatchID(Integer batchID)
    {
        this.batchID = batchID;
    }
}
