/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/07/09 19:26:28 $
 * $Revision: 1.7 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/DiscoveryHost.java,v $e
 */

package org.ziptie.discovery;

import org.ziptie.addressing.IPAddress;

/**
 * Holds data about an end node prior to the discovery of its detailed data.
 * This class is used to add addresses to the <code>DiscoveryQueue</code>.
 * 
 * @author rkruse
 */
/**
 * DiscoveryHost
 */
public class DiscoveryHost
{
    private IPAddress ipAddress;
    private XdpEntry xdpEntry;
    private boolean fromInventory;
    private boolean calculateAdminIp = true;
    private boolean bypassCache;
    private boolean extendUsingNeighbors = true;

    /**
     * Constructs a DiscoveryHost from an {@link XdpEntry}
     * @param xdpEntry
     */
    public DiscoveryHost(XdpEntry xdpEntry)
    {
        ipAddress = xdpEntry.getIpAddress();
        this.xdpEntry = xdpEntry;
    }

    /**
     * Constructor.
     *
     * @param address the IP address
     */
    public DiscoveryHost(IPAddress address)
    {
        ipAddress = address;
    }

    /**
     * @return the ipAddress
     */
    public IPAddress getIpAddress()
    {
        return ipAddress;
    }

    /**
     * @param ipAddress the ipAddress to set
     */
    public void setIpAddress(IPAddress ipAddress)
    {
        this.ipAddress = ipAddress;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((ipAddress == null) ? 0 : ipAddress.hashCode());
        return result;
    }

    /** {@inheritDoc} */
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
        final DiscoveryHost other = (DiscoveryHost) obj;
        if (ipAddress == null)
        {
            if (other.ipAddress != null)
            {
                return false;
            }
        }
        else if (!ipAddress.equals(other.ipAddress))
        {
            return false;
        }
        return true;
    }

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    @Override
    public String toString()
    {
        StringBuilder me = new StringBuilder();
        me.append(ipAddress);
        return me.toString();
    }

    /**
     * When <b>true</b>, discovery will attempt to determine the preferred IP
     * Address.
     * 
     * @return the calculateAdminIp
     */
    public boolean isCalculateAdminIp()
    {
        return calculateAdminIp;
    }

    /**
     * When <b>true</b>, discovery will attempt to determine the preferred IP
     * Address.
     * 
     * @param calculateAdminIp the calculateAdminIp to set
     */
    public void setCalculateAdminIp(boolean calculateAdminIp)
    {
        this.calculateAdminIp = calculateAdminIp;
    }

    /**
     * When <b>true</b>, indicates that this host discovery request came from a
     * device that is in the inventory of the server. This tells the
     * <code>DiscoveryEngine</code> that it doesn't need to check for a
     * preferred IP address with the server since that can be expensive.
     * 
     * @return the fromInventory
     */
    public boolean isFromInventory()
    {
        return fromInventory;
    }

    /**
     * When <b>true</b>, indicates that this host discovery request came from a
     * device that is in the inventory of the server. This tells the
     * <code>DiscoveryEngine</code> that it doesn't need to check for a
     * preferred IP address with the server since that can be expensive.
     * 
     * @param fromInventory the fromInventory to set
     */
    public void setFromInventory(boolean fromInventory)
    {
        this.fromInventory = fromInventory;
    }

    /**
     * When set to true, the <code>DiscoveryEngine</code> should scan this
     * <code>DiscoveryHost</code> even if it is in the cache of already
     * scanned addresses.
     * 
     * @return the bypassCache
     */
    public boolean isBypassCache()
    {
        return bypassCache;
    }

    /**
     * When set to true, the <code>DiscoveryEngine</code> should scan this
     * <code>DiscoveryHost</code> even if it is in the cache of already
     * scanned addresses.
     * 
     * @param bypassCache the bypassCache to set
     */
    public void setBypassCache(boolean bypassCache)
    {
        this.bypassCache = bypassCache;
    }

    /**
     * If the <code>DiscoveryConfig</code> allows crawling of the network,
     * this value will be consulted to determine if this specific discovery
     * should extend or not.
     * 
     * @return the extendUsingNeighbors
     */
    public boolean isExtendUsingNeighbors()
    {
        return extendUsingNeighbors;
    }

    /**
     * If the <code>DiscoveryConfig</code> allows crawling of the network,
     * this value will be consulted to determine if this specific discovery
     * should extend or not.
     * 
     * @param extendUsingNeighbors the extendUsingNeighbors to set
     */
    public void setExtendUsingNeighbors(boolean extendUsingNeighbors)
    {
        this.extendUsingNeighbors = extendUsingNeighbors;
    }

    /**
     * Returns true if the host was created from an {@link XdpEntry}
     * @return Returns the fromXdp.
     */
    public boolean isFromXdp()
    {
        return (xdpEntry != null);
    }

    /**
     * @return the xdpEntry
     */
    public XdpEntry getXdpEntry()
    {
        return xdpEntry;
    }

    /**
     * @param xdpEntry the xdpEntry to set
     */
    public void setXdpEntry(XdpEntry xdpEntry)
    {
        this.xdpEntry = xdpEntry;
    }
}
