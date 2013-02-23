package org.ziptie.server.dispatcher;

import java.util.ArrayList;
import java.util.List;

/**
 * A class representing the current status of a <code>OperationManager</code>.
 * Call <code>OperationManager.getStatus()</code> to retrieve one.
 * 
 * @author chamlett
 */
public class OperationManagerStatus
{
    /** A list with one entry per batch, representing the status of that batch */
    private ArrayList<BatchStatus> batchStatuses;

    // ----------------------------------------------------------------
    //                    C O N S T R U C T O R S
    // ----------------------------------------------------------------

    /**
     * The only constructor; initializes internal variables.
     */
    public OperationManagerStatus()
    {
        batchStatuses = new ArrayList<BatchStatus>();
    }

    // ----------------------------------------------------------------
    //                   P U B L I C   M E T H O D S
    // ----------------------------------------------------------------

    /** 
     * Get the list of batch statuses 
     * @return a List of status objects, one per batch still in the schedule
     * */
    public List<BatchStatus> getBatchStatuses()
    {
        return batchStatuses;
    }

    /**
     * @return A String with a summary line followed by 0 or more lines with a
     *    summary of one batch per line.
     */
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        sb.append(batchStatuses.size()).append(" batches\n");

        for (BatchStatus bs : batchStatuses)
        {
            sb.append('\t').append(bs).append('\n');
        }

        return sb.toString();
    }

    // ----------------------------------------------------------------
    //                   P A C K A G E   M E T H O D S
    // ----------------------------------------------------------------

    /** 
     * Add a new batch status to the list.  
     * @param batch the OperationBatch to add.
     */
    void addBatchStatus(OperationBatch batch)
    {
        batchStatuses.add(new BatchStatus(batch));
    }
}
