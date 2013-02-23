/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/04/02 16:32:34 $
 * $Revision: 1.2 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/DiscoveryComparator.java,v $
 */

package org.ziptie.discovery;

/**
 * Anybody placing Runnables on the <code>DiscoveryEngine</code> thread pool needs to implement
 * this interface so the different types of Runnables can have their priority determined.
 * 
 * @author rkruse
 */
interface DiscoveryComparator
{
    /**
     * Deliver a numeric value of this objects priority. This will be used to determine how it
     * compares with another {@link DiscoveryComparator} for the priority based thread pool.
     * 
     * @return
     */
    Integer getPriority();

    /**
     * If the values are equal, the user can optionally try to use this tiebreaker long to see who
     * is first. This will allow making the <code>PriorityBlockingQueue</code> a true FIFO queue
     * when all values are equal.
     * 
     * @return
     */
    Long getTieBreaker();
}
