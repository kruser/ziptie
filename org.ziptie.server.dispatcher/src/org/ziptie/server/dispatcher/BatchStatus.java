package org.ziptie.server.dispatcher;

/**
 * An class representing the status of a single batch. It is created with a
 * <code>OperationBatch</code>, which it queries to get the number of unstarted,
 * running, and completed <code>Operation</code>s in that batch.
 * 
 * @author chamlett
 */
public class BatchStatus
{
    private Integer batchID;

    /** The number of <code>Operation</code>s in that batch that have not yet been started */
    private int unstartedCount;

    /** The number of currently executing <code>Operation</code>s. */
    private int runningCount;

    /** The number of <code>Operation</code>s that have completed */
    private int completedCount;

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------

    /**
     * Constructor. It requires a non-null <code>OperationBatch</code>
     * 
     * @param batch The batch to generate status for.
     */
    BatchStatus(OperationBatch batch)
    {
        batchID = batch.getID();
        unstartedCount = batch.getUnstartedCount();
        runningCount = batch.getRunningCount();
        completedCount = batch.getCompletedCount();
    }

    // ----------------------------------------------------------------
    //                   P U B L I C   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * @return The number of <code>Operation</code>s completed to date
     */
    public int getCompletedCount()
    {
        return completedCount;
    }

    /**
     * @return The number of <code>Operation</code>s currently running
     */
    public int getRunningCount()
    {
        return runningCount;
    }

    /**
     * @return The number of <code>Operation</code>s not yet started
     */
    public int getUnstartedCount()
    {
        return unstartedCount;
    }

    /**
     * @return a String of the form "ID- unstarted: # running: # completed; #" 
     * where ID is the actual ID, and # is the appropriate number of each type.
     */
    public String toString()
    {
        return String.format("%d- unstarted: %d running: %d completed: %d", batchID, getUnstartedCount(), getRunningCount(), getCompletedCount());
    }
}
