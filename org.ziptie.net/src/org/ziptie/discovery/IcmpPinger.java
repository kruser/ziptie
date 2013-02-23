/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/07/21 20:38:56 $
 * $Revision: 1.4 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/IcmpPinger.java,v $e
 */

package org.ziptie.discovery;

import java.util.concurrent.atomic.AtomicLong;

import org.ziptie.addressing.IPAddress;
import org.ziptie.net.ping.icmp.Pinger;

/**
 * On Windows systems we shell out to the "ping.exe" program for determining device reachability.
 * 
 * @author rkruse
 */
class IcmpPinger extends AbstractPinger
{
    private AtomicLong tieBreaker;
    /**
     * @param engine
     */
    public IcmpPinger(DiscoveryEngine engine)
    {
        super(engine);
        tieBreaker = new AtomicLong();
    }

    /**
     * @see org.ziptie.discovery.AbstractPinger#ping(org.ziptie.addressing.NetworkAddress, boolean,
     *      boolean)
     */
    @Override
    void ping(IPAddress ipAddress, boolean fromInventorySource, boolean extendUsingNeighbors)
    {
        if (isRunning())
        {
            super.ping(ipAddress, fromInventorySource, extendUsingNeighbors);
            Runnable pingRunner = new PingRunnable(ipAddress, fromInventorySource, extendUsingNeighbors);
            getEngine().executeRunnable(pingRunner);
        }
    }

    /**
     * All pings are send to a thread pool outside of this class, so this pinger is never busy.
     * 
     * @see org.ziptie.discovery.AbstractPinger#getActivePings()
     */
    @Override
    int getActivePings()
    {
        return 0;
    }

    /**
     * Since each ping is synchronous we let the master thread pool in the {@link DiscoveryEngine}
     * do the work.
     * 
     * @author rkruse
     */
    private class PingRunnable implements Runnable, Comparable<DiscoveryComparator>, DiscoveryComparator
    {
        private IPAddress ipAddress;
        private boolean fromInventorySource;
        private boolean extendUsingNeighbors;
        private Long localTieBreaker;

        /**
         * 
         * @param ipAddress
         * @param fromInventorySource
         * @param extendUsingNeighbors
         */
        public PingRunnable(IPAddress ipAddress, boolean fromInventorySource, boolean extendUsingNeighbors)
        {
            this.ipAddress = ipAddress;
            this.fromInventorySource = fromInventorySource;
            this.extendUsingNeighbors = extendUsingNeighbors;
            this.localTieBreaker = tieBreaker.getAndIncrement();
        }

        /**
         * @see java.lang.Runnable#run()
         */
        @SuppressWarnings("nls")
        public void run()
        {
            Thread runner = Thread.currentThread();
            runner.setName(ipAddress.getIPAddress() + "-" + THREAD_NAME);
            DiscoveryConfig dc = getEngine().getDiscoveryConfig();
            boolean isAlive = Pinger.getInstance().ping(ipAddress, dc.getPingTimeout(), dc.getPingSize(), dc.getPingCount());

            if (isAlive)
            {
                onSuccess(ipAddress, fromInventorySource, extendUsingNeighbors);
            }
            else
            {
                onFailure(ipAddress);
            }
        }

        /**
         * @see java.lang.Comparable#compareTo(java.lang.Object)
         */
        public int compareTo(DiscoveryComparator other)
        {
            return DiscoveryElf.compare(this, other);
        }

        /**
         * @see org.ziptie.discovery.DiscoveryComparator#getPriority()
         */
        public Integer getPriority()
        {
            return DiscoveryEngine.PING_PRIORITY;
        }

        /**
         * @see org.ziptie.discovery.DiscoveryComparator#getTieBreaker()
         */
        public Long getTieBreaker()
        {
            return localTieBreaker;
        }
    }

}

