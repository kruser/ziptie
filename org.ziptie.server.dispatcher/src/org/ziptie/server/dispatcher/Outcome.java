package org.ziptie.server.dispatcher;

/**
 * A class for specifying the outcome of a running <code>ITask.execute()</code>.
 * The listener will be notified of the completion of the task with the Outcome
 * that it produced.  If the ITask did not finish, the listener will still be
 * notified that the task is complete with an Outcome of either EXCEPTION or
 * CANCELLED.  See the discussion in <code>OperationManager</code> for how that
 * can happen.
 * 
 * @author chamlett
 */
public enum Outcome
{
    SUCCESS,
    FAILURE,
    WARNING,
    EXCEPTION,
    CANCELLED
}
