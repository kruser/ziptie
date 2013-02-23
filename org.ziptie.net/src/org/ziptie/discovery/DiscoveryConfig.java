/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/21 19:41:18 $
 * $Revision: 1.10 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/DiscoveryConfig.java,v $e
 */

package org.ziptie.discovery;

import java.io.Serializable;

import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.Subnet;

/**
 * Describes the general settings for the over arching discovery engine.
 * 
 * @author rkruse
 */
public class DiscoveryConfig implements Serializable
{
    private static final int HASH_PRIME2 = 1237;
    private static final int HASH_PRIME1 = 1231;
    private static final long serialVersionUID = -3178071256033556275L;
    private static final int DEFAULT_PING_TIMEOUT = 1000;
    private static final int MAX_PINGSWEEP_MASK_IP_V4 = 28;
    private static final int MAX_PINGSWEEP_MASK_IP_V6 = 124;
    private static final int DEFAULT_CLEAR_CACHE_DELAY = 10080;
    private static final int DEFAULT_THREADS = 10;

    private AddressSet boundaryNetworks;
    private AddressSet exclusions;
    private boolean discoverNeighbors = true;
    private boolean pollARP = true;
    private boolean pollCDP = true;
    private boolean pollRoutingNeighbors = true;
    private int clearCacheDelayMinutes = DEFAULT_CLEAR_CACHE_DELAY;
    private int maxMaskPingSweep = MAX_PINGSWEEP_MASK_IP_V4;
    private int maxMaskPingSweepIpv6 = MAX_PINGSWEEP_MASK_IP_V6;
    private int pingSize = 16; // byte size of the ping packets
    private int pingCount = 2; // times to retry pinging a host
    private int pingTimeout = DEFAULT_PING_TIMEOUT; // timeout in milliseconds for a ping
    private int masterThreads = DEFAULT_THREADS;

    /**
     * Build a fresh <code>DiscoveryConfig</code>
     * 
     */
    public DiscoveryConfig()
    {
        this.boundaryNetworks = new AddressSet();

        this.exclusions = new AddressSet();
        // preset any undiscoverable addresses
        exclusions.add(new IPAddress("0.0.0.0"));
        exclusions.add(new Subnet(new IPAddress("127.0.0.0"), new Short("8")));
    }

    /**
     * @return the boundaryNetworks
     */
    public AddressSet getBoundaryNetworks()
    {
        return boundaryNetworks;
    }

    /**
     * @param boundaryNetworks the boundaryNetworks to set
     */
    public void setBoundaryNetworks(AddressSet boundaryNetworks)
    {
        if (boundaryNetworks != null)
        {
            this.boundaryNetworks = boundaryNetworks;
        }
    }

    /**
     * @return the pingCount
     */
    public int getPingCount()
    {
        return pingCount;
    }

    /**
     * @param pingCount the pingCount to set
     */
    public void setPingCount(int pingCount)
    {
        this.pingCount = pingCount;
    }

    /**
     * @return the pingSize
     */
    public int getPingSize()
    {
        return pingSize;
    }

    /**
     * @param pingSize the pingSize to set
     */
    public void setPingSize(int pingSize)
    {
        this.pingSize = pingSize;
    }

    /**
     * @return the pingTimeout
     */
    public int getPingTimeout()
    {
        return pingTimeout;
    }

    /**
     * @param pingTimeout the pingTimeout to set
     */
    public void setPingTimeout(int pingTimeout)
    {
        this.pingTimeout = pingTimeout;
    }

    /**
     * Should the ARP cache be polled to find out more about the surrounding
     * network. <br>
     * Note this is not used if {@link #discoverNeighbors()} is true.
     * 
     * @return the pollARP
     */
    public boolean isPollARP()
    {
        return pollARP;
    }

    /**
     * Should the ARP cache be polled to find out more about the surrounding
     * network. <br>
     * Note this is not used if {@link #discoverNeighbors()} is true.
     * 
     * @param pollARP the pollARP to set
     */
    public void setPollARP(boolean pollARP)
    {
        this.pollARP = pollARP;
    }

    /**
     * Should CDP table be polled for neighbors. <br>
     * Note this is not used if {@link #discoverNeighbors()} is true.
     * 
     * @return the pollCDP
     */
    public boolean isPollCDP()
    {
        return pollCDP;
    }

    /**
     * Should CDP table be polled for neighbors. <br>
     * Note this is not used if {@link #discoverNeighbors()} is true.
     * 
     * @param pollCDP the pollCDP to set
     */
    public void setPollCDP(boolean pollCDP)
    {
        this.pollCDP = pollCDP;
    }

    /**
     * @return the exclusions
     */
    public AddressSet getExclusions()
    {
        return exclusions;
    }

    /**
     * @param exclusions the exclusions to set
     */
    public void setExclusions(AddressSet exclusions)
    {
        if (exclusions != null)
        {
            this.exclusions = exclusions;
        }
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + clearCacheDelayMinutes;
        result = prime * result + (discoverNeighbors ? HASH_PRIME1 : HASH_PRIME2);
        result = prime * result + maxMaskPingSweep;
        result = prime * result + pingCount;
        result = prime * result + pingSize;
        result = prime * result + pingTimeout;
        result = prime * result + (pollARP ? HASH_PRIME1 : HASH_PRIME2);
        result = prime * result + (pollCDP ? HASH_PRIME1 : HASH_PRIME2);
        result = prime * result + (pollRoutingNeighbors ? HASH_PRIME1 : HASH_PRIME2);
        return result;
    }

    /** {@inheritDoc} */
    // CHECKSTYLE:OFF
    @Override
    public boolean equals(Object obj)
    {
        if (this == obj)
        {
            return true;
        }

        if (obj == null)
        {
            return false;
        }

        if (getClass() != obj.getClass())
        {
            return false;
        }

        final DiscoveryConfig other = (DiscoveryConfig) obj;

        if (clearCacheDelayMinutes != other.clearCacheDelayMinutes)
        {
            return false;
        }

        if (discoverNeighbors != other.discoverNeighbors)
        {
            return false;
        }

        if (maxMaskPingSweep != other.maxMaskPingSweep)
        {
            return false;
        }

        if (pingCount != other.pingCount)
        {
            return false;
        }

        if (pingSize != other.pingSize)
        {
            return false;
        }

        if (pingTimeout != other.pingTimeout)
        {
            return false;
        }

        if (pollARP != other.pollARP)
        {
            return false;
        }

        if (pollCDP != other.pollCDP)
        {
            return false;
        }

        if (pollRoutingNeighbors != other.pollRoutingNeighbors)
        {
            return false;
        }

        if (masterThreads != other.masterThreads)
        {
            return false;
        }
        return true;
    }

    // CHECKSTYLE:ON

    /**
     * wait this many minutes in between each time the discovery cache is
     * cleared
     * 
     * @return the clearCacheDelayMinutes
     */
    public int getClearCacheDelayMinutes()
    {
        return clearCacheDelayMinutes;
    }

    /**
     * wait this many minutes in between each time the discovery cache is
     * cleared
     * 
     * @param clearCacheDelayMinutes the clearCacheDelayMinutes to set
     */
    public void setClearCacheDelayMinutes(int clearCacheDelayMinutes)
    {
        this.clearCacheDelayMinutes = clearCacheDelayMinutes;
    }

    /**
     * Tells the <code>DiscoveryEngine</code> if it should feed a devices
     * neighbors back into discovery. For example, if we found device <b>Z</b>
     * in the ARP cache of device <b>A</b> while we were polling device <b>A</b>,
     * we would then run a full discovery process on device <b>Z</b>. <br>
     * <br>
     * Set this to false if you don't want the <code>DiscoveryEngine</code> to
     * walk your network.
     * 
     * @return the discoverNeighbors
     */
    public boolean isDiscoverNeighbors()
    {
        return discoverNeighbors;
    }

    /**
     * Set this to false if you don't want the <code>DiscoveryEngine</code> to
     * walk your network.
     * 
     * @param discoverNeighbors the discoverNeighbors to set
     */
    public void setDiscoverNeighbors(boolean discoverNeighbors)
    {
        this.discoverNeighbors = discoverNeighbors;
    }

    /**
     * @return the pollRoutingNeighbors
     */
    public boolean isPollRoutingNeighbors()
    {
        return pollRoutingNeighbors;
    }

    /**
     * @param pollRoutingNeighbors the pollRoutingNeighbors to set
     */
    public void setPollRoutingNeighbors(boolean pollRoutingNeighbors)
    {
        this.pollRoutingNeighbors = pollRoutingNeighbors;
    }

    /**
     * The <code>DiscoveryEngine</code> will ping(ICMP) sweep networks
     * configured on router interfaces unless they are greater than the given
     * mask. The default maximum is a 28 bit masks. It is recommended that this
     * value never be smaller than 24. <br>
     * 
     * @return the maxMaskPingSweep
     */
    public int getMaxMaskPingSweep()
    {
        return maxMaskPingSweep;
    }

    /**
     * The <code>DiscoveryEngine</code> will ping(ICMP) sweep networks
     * configured on router interfaces unless they are greater than the given
     * mask. The default maximum is a 28 bit masks. It is recommended that this
     * value never be smaller than 24. <br>
     * <br>
     * Set this to 32 to avoid sweeping altogether.
     * 
     * @param maxMaskPingSweep the maxMaskPingSweep to set
     */
    public void setMaxMaskPingSweep(int maxMaskPingSweep)
    {
        this.maxMaskPingSweep = maxMaskPingSweep;
    }

    /**
     * The number of threads on the master thread pool (concurrency).
     * @return the masterThreads
     */
    public int getMasterThreads()
    {
        return masterThreads;
    }

    /**
     * @param masterThreads the masterThreads to set
     */
    public void setMasterThreads(int masterThreads)
    {
        this.masterThreads = masterThreads;
    }

    /**
     * @return the maxMaskPingSweepIpv6
     */
    public int getMaxMaskPingSweepIpv6()
    {
        return maxMaskPingSweepIpv6;
    }

    /**
     * @param maxMaskPingSweepIpv6 the maxMaskPingSweepIpv6 to set
     */
    public void setMaxMaskPingSweepIpv6(int maxMaskPingSweepIpv6)
    {
        this.maxMaskPingSweepIpv6 = maxMaskPingSweepIpv6;
    }

}
