/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2007/06/15 17:33:59 $
 * $Revision: 1.3 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/NoFutureException.java,v $e
 */

package org.ziptie.discovery;

/**
 * Thrown by the <code>DiscoveryEngine</code> if a request to discover doesn't
 * make it into the thread pool.
 * 
 * @author rkruse
 */
public class NoFutureException extends Exception
{

    /**
     * 
     */
    private static final long serialVersionUID = 8367484682688918349L;

    /**
     * 
     */
    public NoFutureException()
    {
    }

    /**
     * @param   message   the detail message. The detail message is saved for 
     *          later retrieval by the {@link #getMessage()} method.
     */
    public NoFutureException(String message)
    {
        super(message);
    }

    /**
     * @param  cause the cause (which is saved for later retrieval by the
     *         {@link #getCause()} method).  (A <tt>null</tt> value is
     *         permitted, and indicates that the cause is nonexistent or
     *         unknown.)
     */
    public NoFutureException(Throwable cause)
    {
        super(cause);
    }

    /**
     * @param  message the detail message (which is saved for later retrieval
     *         by the {@link #getMessage()} method).
     * @param  cause the cause (which is saved for later retrieval by the
     *         {@link #getCause()} method).  (A <tt>null</tt> value is
     *         permitted, and indicates that the cause is nonexistent or
     *         unknown.)
     */
    public NoFutureException(String message, Throwable cause)
    {
        super(message, cause);
    }

}
