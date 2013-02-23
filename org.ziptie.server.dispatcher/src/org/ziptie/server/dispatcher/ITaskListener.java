package org.ziptie.server.dispatcher;

/**
 * This is a callback interface for a <code>OperationManager</code> as it executes
 * <code>ITask</code>s. The <code>eventOccurred()</code> method will be called
 * as work is performed on the list of <code>ITask</code>s submitted for execution.
 * <p>
 * This listener will potentially called by several different threads and, if the
 * batch is non-sequential those calls can be contemporaneous. It is important
 * that it be properly synchronized when handling the events.
 * <p>
 * 
 * @author chamlett
 */
public interface ITaskListener
{
    /**
     * Called as the <code>OperationManager</code> executes <code>ITasks</code>,
     * including when the run is complete.
     * <p>
     * 
     * @param pEvent An event describing the current status of an <code>ITask</code>.
     */
    void eventOccurred(TaskEvent pEvent);
}
