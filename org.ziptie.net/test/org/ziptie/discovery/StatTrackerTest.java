/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2007/03/29 20:57:32 $
 * $Revision: 1.1 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/StatTrackerTest.java,v $e
 */

package org.ziptie.discovery;

import java.util.Date;

import junit.framework.TestCase;

/**
 * @author rkruse
 */
public class StatTrackerTest extends TestCase
{
    public void testCounters()
    {
        StatTracker stats = new StatTracker();
        assertEquals(0, stats.getAddressesAnalyzed());
        assertEquals(0, stats.getOutsideBoundaries());
        assertEquals(0, stats.getMatchedExclusion());
        assertEquals(0, stats.getRespondedToSnmp());
        assertEquals("0.0.0.0", stats.getLastAddressDiscovered().getIPAddress());
        
        stats.incrementAddressesAnalyzed();
        assertEquals(1, stats.getAddressesAnalyzed());
        stats.incrementOutsideBoundaries();
        assertEquals(1, stats.getOutsideBoundaries());
        stats.incrementMatchedExclusion();
        assertEquals(1, stats.getMatchedExclusion());
        stats.incrementRespondedToSnmp();
        assertEquals(1, stats.getRespondedToSnmp());
        
        Date start1 = stats.getStartedRunning();
        
        stats.resetStats();
        Date start2 = stats.getStartedRunning();
        assertTrue(start1.compareTo(start2) <= 0);
        assertEquals(0, stats.getAddressesAnalyzed());
        assertEquals(0, stats.getOutsideBoundaries());
        assertEquals(0, stats.getMatchedExclusion());
        assertEquals(0, stats.getRespondedToSnmp());
    }
}

// -------------------------------------------------
// $Log: StatTrackerTest.java,v $
// Revision 1.1  2007/03/29 20:57:32  rkruse
// adding the discovery tests
//
// Revision 1.3  2007/02/14 16:03:51  Rkruse
// usability & performance refactors
//
// Revision 1.2  2007/01/16 02:29:20  Rkruse
// lastAddrAnalyzed can't be null now.
//
// Revision 1.1  2007/01/14 21:57:00  Rkruse
// add monitoring
//
// Revision 1.0 Jan 14, 2007 rkruse
// Initial revision
// --------------------------------------------------
