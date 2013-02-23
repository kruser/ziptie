/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2007/03/29 20:57:32 $
 * $Revision: 1.1 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/DiscoveryStatusTest.java,v $e
 */

package org.ziptie.discovery;

import junit.framework.TestCase;

/**
 * @author rkruse
 */
public class DiscoveryStatusTest extends TestCase
{
    public void testCounters()
    {
        DiscoveryStatus stats = new DiscoveryStatus();
        assertEquals(0, stats.getAddressesAnalyzed());
        assertEquals(0, stats.getOutsideBoundaries());
        assertEquals(0, stats.getMatchedExclusion());
        assertEquals(0, stats.getRespondedToSnmp());

        stats.setAddressesAnalyzed(5);
        assertEquals(5, stats.getAddressesAnalyzed());
        stats.setOutsideBoundaries(6);
        assertEquals(6, stats.getOutsideBoundaries());
        stats.setMatchedExclusion(4);
        assertEquals(4, stats.getMatchedExclusion());
        stats.setRespondedToSnmp(99);
        assertEquals(99, stats.getRespondedToSnmp());
    }

    public void testEquals()
    {
        DiscoveryStatus stat1 = new DiscoveryStatus();
        DiscoveryStatus stat2 = new DiscoveryStatus();
        doEquals(stat1, stat2);
        
        stat1.setActive(true);
        doNotEquals(stat1, stat2);
        stat2.setActive(true);
        doEquals(stat1, stat2);
        
        stat1.setAddressesAnalyzed(500);
        doNotEquals(stat1, stat2);
        stat2.setAddressesAnalyzed(500);
        doEquals(stat1, stat2);
    }
    
    /**
     * checks equals and hashcode methods to make sure they differ
     * @param stat1
     * @param stat2
     */
    private void doNotEquals(DiscoveryStatus stat1, DiscoveryStatus stat2)
    {
        assertFalse(stat1.equals(stat2));
        assertFalse(stat1.hashCode() == stat2.hashCode());
    }

    /**
     * checks equals and hashcode methods
     * @param stat1
     * @param stat2
     */
    private void doEquals(DiscoveryStatus stat1, DiscoveryStatus stat2)
    {
        assertEquals(stat1, stat2);
        assertEquals(stat2.hashCode(), stat2.hashCode());
    }
}

// -------------------------------------------------
// $Log: DiscoveryStatusTest.java,v $
// Revision 1.1  2007/03/29 20:57:32  rkruse
// adding the discovery tests
//
// Revision 1.2  2007/02/14 16:03:51  Rkruse
// usability & performance refactors
//
// Revision 1.1  2007/01/14 21:57:00  Rkruse
// add monitoring
//
// Revision 1.0 Jan 14, 2007 rkruse
// Initial revision
// --------------------------------------------------
