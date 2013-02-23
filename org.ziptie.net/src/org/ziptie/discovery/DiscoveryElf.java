/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/04 15:36:00 $
 * $Revision: 1.6 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/DiscoveryElf.java,v $
 */

package org.ziptie.discovery;

/**
 * Easy Little Functions for discovery
 * 
 * @author rkruse
 */
public final class DiscoveryElf
{
    /**
     * Private constructor for the <code>DiscoveryElf</code> class to disable support of a public default constructor.
     *
     */
    private DiscoveryElf()
    {
        // Does nothing.
    }

    /**
     * This is a special comparator for a <code>PritorityQueue</code> used within discovery. We
     * want to make the queue act as a pure FIFO queue when tasks have an equal priority. The
     * problem is that the <code>PriorityQueue</code> arbitrarily chooses a head of the queue when
     * the comparators are equals. In reality if all tasks are equal, the PritorityQueue effectively
     * becomes a LIFO queue, instead of the desired FIFO queue.
     * 
     * This method will do a standard compare unless they are equal, then it will do a special compare.
     * 
     * @param one the first Comparator
     * @param two the second Comparator
     * @return -1 if one is less than two, 0 if they are equal, 1 if one is greater than 2
     */
    public static int compare(DiscoveryComparator one, DiscoveryComparator two)
    {
        if (one.getPriority().equals(two.getPriority()))
        {
            return one.getTieBreaker().compareTo(two.getTieBreaker());
        }
        else
        {
            return one.getPriority().compareTo(two.getPriority());
        }
    }

    /**
     * Reconcile any missing fields from the <code>DiscoveryEvent</code> that can be populated with data from the <code>DiscoveryHost</code>
     * @param host the incoming host
     * @param event the event coming out
     */
    public static void cleanUpEvent(DiscoveryHost host, DiscoveryEvent event)
    {
        event.setExtendUsingNeighbors(host.isExtendUsingNeighbors());
        if (event.getAddress() == null)
        {
            event.setAddress(host.getIpAddress());
        }
        /*
         * Check to see if there is system data on the host, probably from a
         * LLDP or CDP neighbor
         */
        if (!event.isGoodEvent() && (host.isFromXdp()))
        {
            event.setGoodEvent(true);
            XdpEntry xdp = host.getXdpEntry();
            event.setSysOID(xdp.getSysOid());
            event.setSysName(xdp.getSysName());
            event.setSysDescr(xdp.getSysDescr());
        }
    }
}
