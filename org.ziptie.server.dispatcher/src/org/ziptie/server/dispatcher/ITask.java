package org.ziptie.server.dispatcher;

/**
 * An interface that must be implemented to submit tasks to a OperationManager.
 * <p>
 * It must contain a <code>run()</code> method and a <code>getLockObject()</code>
 * method. <code>getLockObject()</code> should return an object with <code>hashCode()</code>
 * and <code>equals()</code> defined, or null if this task has no dependencies. The
 * OperationManager will only run one task associated with this object at a time no
 * matter how many have been queued. It may return null if this task has no locking
 * dependencies.
 * <p>
 * 
 * @author chamlett
 */
public interface ITask
{
    /**
     * Return an object suitable for locking this task. The <code>OperationManager</code> 
     * will only run one task associated with the returned object at a time. The returned
     * object should implement <code>hashCode()</code> and <code>equals()</code>, as it
     * will be placed in a <code>Set</code> of locks.
     * 
     * @return Any object implementing <code>hashCode()</code> and <code>equals()</code>,
     *    or null if this task has no dependencies.
     */
    Object getLockObject();

    /**
     * Do some work. This is analogous to <code>Runnable.run()</code> with the addition
     * that it returns an Outcome of the task. This <code>Outcome</code> will be provided
     * to the listener provided when it was submitted for execution.
     * 
     * @return SUCCESS, WARNING, or FAILURE, depending on task-specific criteria.
     * @throws Exception to exit with an EXCEPTION outcome.
     */
    Outcome execute() throws Exception;
}
