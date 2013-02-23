/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.discovery;

import java.io.Serializable;
import java.util.Date;

import org.ziptie.addressing.IPAddress;

/**
 * POJO that houses data from the {@link StatTracker} in a nice format. The
 * counter values are reset when the engine goes from idle to running status.
 * 
 * @author rkruse
 */
public class DiscoveryStatus implements Serializable
{
    private static final int HASH_PRIME2 = 1237;
    private static final int HASH_PRIME1 = 1231;

    private static final long serialVersionUID = -4987774405643055662L;

    private long addressesAnalyzed;
    private long respondedToSnmp;
    private long outsideBoundaries;
    private long matchedExclusion;
    private long queueSize;
    private boolean isActive;
    private Date startedRunning = new Date();
    private IPAddress lastAddressDiscovered = new IPAddress();

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (addressesAnalyzed ^ (addressesAnalyzed >>> 32));
        result = prime * result + (isActive ? HASH_PRIME1 : HASH_PRIME2);
        result = prime * result + ((lastAddressDiscovered == null) ? 0 : lastAddressDiscovered.hashCode());
        result = prime * result + (int) (matchedExclusion ^ (matchedExclusion >>> 32));
        result = prime * result + (int) (outsideBoundaries ^ (outsideBoundaries >>> 32));
        result = prime * result + (int) (queueSize ^ (queueSize >>> 32));
        result = prime * result + (int) (respondedToSnmp ^ (respondedToSnmp >>> 32));
        result = prime * result + ((startedRunning == null) ? 0 : startedRunning.hashCode());
        return result;
    }

    /**
     * {@inheritDoc}
     */
    @SuppressWarnings("nls")
    @Override
    public String toString()
    {
        return "Active: " + isActive + "\nAnalyzed: " + addressesAnalyzed + "\nQueue Size: " + queueSize + "\nSNMP Devices: " + respondedToSnmp;
    }

    /**
     * {@inheritDoc}
     */
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
        final DiscoveryStatus other = (DiscoveryStatus) obj;
        if (addressesAnalyzed != other.addressesAnalyzed)
        {
            return false;
        }
        if (isActive != other.isActive)
        {
            return false;
        }
        if (lastAddressDiscovered == null)
        {
            if (other.lastAddressDiscovered != null)
            {
                return false;
            }
        }
        else if (!lastAddressDiscovered.equals(other.lastAddressDiscovered))
        {
            return false;
        }
        if (matchedExclusion != other.matchedExclusion)
        {
            return false;
        }
        if (outsideBoundaries != other.outsideBoundaries)
        {
            return false;
        }
        if (queueSize != other.queueSize)
        {
            return false;
        }
        if (respondedToSnmp != other.respondedToSnmp)
        {
            return false;
        }
        if (startedRunning == null)
        {
            if (other.startedRunning != null)
            {
                return false;
            }
        }
        else if (!startedRunning.equals(other.startedRunning))
        {
            return false;
        }
        return true;
    }

    /**
     * The number of IP addresses that have been through the
     * <code>DiscoveryEngine</code> since it last moved to running status.
     * 
     * @return the addressesAnalyzed
     */
    public long getAddressesAnalyzed()
    {
        return addressesAnalyzed;
    }

    /**
     * @param addressesAnalyzed the addressesAnalyzed to set
     */
    public void setAddressesAnalyzed(long addressesAnalyzed)
    {
        this.addressesAnalyzed = addressesAnalyzed;
    }

    /**
     * Returns <code>true</code> if there are IP addresses being actively
     * pursued by the engine.
     * 
     * @return the isActive
     */
    public boolean isActive()
    {
        return isActive;
    }

    /**
     * @param active the isActive to set
     */
    public void setActive(boolean active)
    {
        this.isActive = active;
    }

    /**
     * A count of the number of IP addresses that matched an exclusion as
     * defined in the <code>DiscoveryConfig</code>
     * 
     * @return the matchedExclusion
     */
    public long getMatchedExclusion()
    {
        return matchedExclusion;
    }

    /**
     * @param matchedExclusion the matchedExclusion to set
     */
    public void setMatchedExclusion(long matchedExclusion)
    {
        this.matchedExclusion = matchedExclusion;
    }

    /**
     * A count of the IP addresses that were outside of the boundary networks as
     * defined by the <code>DiscoveryConfig</code>
     * 
     * @return the outsideBoundaries
     */
    public long getOutsideBoundaries()
    {
        return outsideBoundaries;
    }

    /**
     * @param outsideBoundaries the outsideBoundaries to set
     */
    public void setOutsideBoundaries(long outsideBoundaries)
    {
        this.outsideBoundaries = outsideBoundaries;
    }

    /**
     * The number of IP addresses in the discovery engine's pool plus the number
     * of active jobs
     * 
     * @return the queueSize
     */
    public long getQueueSize()
    {
        return queueSize;
    }

    /**
     * @param queueSize the queueSize to set
     */
    public void setQueueSize(long queueSize)
    {
        this.queueSize = queueSize;
    }

    /**
     * A count of the number of IP addresses that responded to an SNMP query.
     * 
     * @return the respondedToSnmp
     */
    public long getRespondedToSnmp()
    {
        return respondedToSnmp;
    }

    /**
     * @param respondedToSnmp the respondedToSnmp to set
     */
    public void setRespondedToSnmp(long respondedToSnmp)
    {
        this.respondedToSnmp = respondedToSnmp;
    }

    /**
     * The <code>Date</code> at which the <code>DiscoveryEngine</code> went
     * from <b>idle</b> to <b>active</b> status.
     * 
     * @return the startedRunning
     */
    public Date getStartedRunning()
    {
        return startedRunning;
    }

    /**
     * @param startedRunning the startedRunning to set
     */
    public void setStartedRunning(Date startedRunning)
    {
        this.startedRunning = startedRunning;
    }

    /**
     * The <code>IPAddress</code> that was last through the
     * <code>DiscoveryEngine</code>
     * 
     * @return the lastAddressDiscovered - will be 0.0.0.0 if nothing has ever been discovered 
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

