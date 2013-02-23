/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/07/21 20:38:56 $
 * $Revision: 1.3 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/StatTracker.java,v $e
 */

package org.ziptie.discovery;

import java.util.Date;
import java.util.concurrent.atomic.AtomicLong;

import org.ziptie.addressing.IPAddress;

/**
 * Holds the statistics for the {@link DiscoveryEngine} instance. Most counters
 * are reset when the engine goes from 'idle' to 'active' per the
 * {@link DiscoveryEngine#isActive()} method. <br>
 * <br>
 * If this class is extended each overridden method must take care to call the
 * super method to keep the stats accurate.
 * 
 * @author rkruse
 */
public class StatTracker
{
    private AtomicLong addressesAnalyzed;
    private AtomicLong respondedToSnmp;
    private AtomicLong outsideBoundaries;
    private AtomicLong matchedExclusion;
    private Date startedRunning = new Date();
    private IPAddress lastAddressDiscovered = new IPAddress();

    /**
     * 
     */
    public StatTracker()
    {
        resetStats();
    }

    /**
     * Resets the counters and sets the {@link #startedRunning}
     * <code>Date</code> to now.
     */
    public void resetStats()
    {
        addressesAnalyzed = new AtomicLong(0);
        respondedToSnmp = new AtomicLong(0);
        outsideBoundaries = new AtomicLong(0);
        matchedExclusion = new AtomicLong(0);
        startedRunning = new Date();
    }

    /**
     * @return the addressesAnalyzed
     */
    public long getAddressesAnalyzed()
    {
        return addressesAnalyzed.get();
    }

    /**
     * Adds one to the count
     */
    public void incrementAddressesAnalyzed()
    {
        addressesAnalyzed.incrementAndGet();
    }

    /**
     * @return the matchedExclusion
     */
    public long getMatchedExclusion()
    {
        return matchedExclusion.get();
    }

    /**
     * Adds one to the count
     */
    public void incrementMatchedExclusion()
    {
        matchedExclusion.incrementAndGet();
    }

    /**
     * @return the outsideBoundries
     */
    public long getOutsideBoundaries()
    {
        return outsideBoundaries.get();
    }

    /**
     * Adds one to the count
     */
    public void incrementOutsideBoundaries()
    {
        outsideBoundaries.incrementAndGet();
    }

    /**
     * @return the respondedToSnmp
     */
    public long getRespondedToSnmp()
    {
        return respondedToSnmp.get();
    }

    /**
     * Adds one to the count
     */
    public void incrementRespondedToSnmp()
    {
        respondedToSnmp.incrementAndGet();
    }

    /**
     * This should be the time when the {@link DiscoveryEngine} last went from
     * idle to active
     * 
     * @return the startedRunning
     */
    public Date getStartedRunning()
    {
        return startedRunning;
    }

    /**
     * This should be the time when the {@link DiscoveryEngine} last went from
     * idle to active
     * 
     * @param startedRunning the startedRunning to set
     */
    public void setStartedRunning(Date startedRunning)
    {
        this.startedRunning = startedRunning;
    }

    /**
     * The last IP through the <code>DiscoveryEngine</code>
     * 
     * @return the lastAddressDiscovered
     */
    public IPAddress getLastAddressDiscovered()
    {
        return lastAddressDiscovered;
    }

    /**
     * @param lastAddressDiscovered the lastAddressDiscovered to set
     */
    public void setLastAddressDiscovered(IPAddress lastAddressDiscovered)
    {
        this.lastAddressDiscovered = lastAddressDiscovered;
    }
}
