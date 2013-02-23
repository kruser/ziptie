/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/07 18:26:15 $
 * $Revision: 1.9 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/RoutingNeighbor.java,v $e
 */

package org.ziptie.discovery;

import org.ziptie.addressing.IPAddress;

/**
 * OSPF or EIGRP neighbors can be represented via this object. They are
 * differentiated by the {@link #getType()} enum.
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
public class RoutingNeighbor extends TelemetryObject
{
    /**
     * Signifies the routing protocol name. e.g. IGRP, OSPF, etc.
     * 
     * @author rkruse
     */
    public enum RoutingProtocol
    {
        EIGRP,
        OSPF,
        IGRP,
        BGP,
        ISIS,
        RIP,
        RIP2,
        UNKNOWN
    }

    private RoutingProtocol routingProtocol = RoutingProtocol.UNKNOWN;
    private IPAddress ipAddress;
    private IPAddress routerId;
    private String ifName = "";

    /**
     * default constructor, only here to satisfy hibernate.
     */
    public RoutingNeighbor()
    {
    }

    /**
     * @param address the IP address of this neighbor
     */
    public RoutingNeighbor(IPAddress address)
    {
        this(address, RoutingProtocol.UNKNOWN);
    }

    /**
     * 
     * @param address the IP address of this neighbor
     * @param protocol the <code>RoutingProtocol</code> of this neighbor
     */
    public RoutingNeighbor(IPAddress address, RoutingProtocol protocol)
    {
        this.ipAddress = address;
        this.routingProtocol = protocol;
    }

    /**
     * Signifies the routing process from which this neighbor was found, e.g.
     * EIGRP or OSPF
     * 
     * @return the routingProtocol
     */
    public RoutingProtocol getRoutingProtocol()
    {
        return routingProtocol;
    }

    /**
     * @param protocol the <code>RoutingProtocol</code> of this neighbor
     */
    public void setRoutingProtocol(RoutingProtocol protocol)
    {
        this.routingProtocol = protocol;
    }

    /**
     * The {@link IPAddress} of the neighbor router
     * 
     * @return the ipAddress
     */
    public IPAddress getIpAddress()
    {
        return ipAddress;
    }

    /**
     * The name of the interface that this neighbor was found on.
     * 
     * @return the ifName - an empty string if this value hasn't been set
     */
    public String getIfName()
    {
        return ifName;
    }

    /**
     * The name of the interface that this neighbor was found on.
     * 
     * @param ifName the ifName to set
     */
    public void setIfName(String ifName)
    {
        if (ifName != null)
        {
            this.ifName = ifName;
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((ifName == null) ? 0 : ifName.hashCode());
        result = prime * result + ((ipAddress == null) ? 0 : ipAddress.hashCode());
        result = prime * result + ((routerId == null) ? 0 : routerId.hashCode());
        result = prime * result + ((routingProtocol == null) ? 0 : routingProtocol.hashCode());
        return result;
    }

    /** {@inheritDoc} */
    // CHECKSTYLE:OFF - suppresessed for Cyclomatic Complexity
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
        final RoutingNeighbor other = (RoutingNeighbor) obj;
        if (ifName == null)
        {
            if (other.ifName != null)
            {
                return false;
            }
        }
        else if (!ifName.equals(other.ifName))
        {
            return false;
        }
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
        if (routerId == null)
        {
            if (other.routerId != null)
            {
                return false;
            }
        }
        else if (!routerId.equals(other.routerId))
        {
            return false;
        }
        if (routingProtocol == null)
        {
            if (other.routingProtocol != null)
            {
                return false;
            }
        }
        else if (!routingProtocol.equals(other.routingProtocol))
        {
            return false;
        }
        return true;
    }

    // CHECKSTYLE:ON

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString()
    {
        return "Neighbor IP " + getIpAddress() + " (ID " + getRouterId() + ") found on " + getIfName() + " via " + getRoutingProtocol().name();
    }

    /**
     * The ID of this routing neighbor, which often may be different than the IP address that is known to the device.
     * @return the id
     */
    public IPAddress getRouterId()
    {
        return routerId;
    }

    /**
     * The ID of this routing neighbor, which often may be different than the IP address that is known to the device.
     * @param id the id to set
     */
    public void setRouterId(IPAddress id)
    {
        this.routerId = id;
    }

}
