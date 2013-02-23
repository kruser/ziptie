/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/21 19:42:13 $
 * $Revision: 1.6 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/IpCache.java,v $
 */

package org.ziptie.discovery;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.ziptie.addressing.IPAddress;

/**
 * <code>IpCache</code> is a memory efficent way to cache {@link IPAddress} objects.  The 
 * underlying storage of the addresses is by <code>int</code> value.  The object also takes
 * care of combining adjacent entries into a range of integers.
 * 
 * The {@link #add(IPAddress)}, {@link #contains(IPAddress)} and {@link #clear()} methods
 * are all synchronized to make this a thread safe cache.
 * 
 * @author rkruse
 */
public class IpCache
{
    private Set<LongRange> ipv4Cache;
    private Set<IPAddress> ipv6Cache;

    /**
     * Create a new cache 
     *
     */
    public IpCache()
    {
        ipv4Cache = new HashSet<LongRange>();
        ipv6Cache = new HashSet<IPAddress>();
    }

    /**
     * Adds an {@link IPAddress} to the cache.  If the cache already contains this address, nothing will be done.
     * 
     * @param address the address to add
     */
    public synchronized void add(IPAddress address)
    {
        privateAdd(address);
    }

    /**
     * Returns true if the given address has previously been added to the cache.
     * 
     * @param address the address to check
     * @return true if the cache already contains this address, false otherwise
     */
    public synchronized boolean contains(IPAddress address)
    {
        return privateContains(address);
    }

    /**
     * Returns true if the cache already contains the given {@link IPAddress}.
     * 
     * If the caches doesn't contain the given IP, it will be added to the cache.
     * 
     * @param address the address to check
     * @return true if the cache already contains this address, false otherwise
     */
    public synchronized boolean containsThenAdd(IPAddress address)
    {
        if (privateContains(address))
        {
            return true;
        }
        else
        {
            privateAdd(address);
            return false;
        }
    }

    /**
     * Returns the size of the underlying data structure used within the cache.  This does not always return
     * the number of entries that have been added to the cache and therefore should only be used for 
     * troubleshooting and/or testing.
     * 
     * @return
     */
    int size()
    {
        return ipv4Cache.size() + ipv6Cache.size();
    }

    /**
     * Clears out the contents of the {@link IpCache}
     *
     */
    synchronized void clear()
    {
        ipv4Cache.clear();
        ipv6Cache.clear();
    }

    /**
     * Private, unsynchronized common contains method.
     * 
     * @param address
     * @return
     */
    private boolean privateContains(IPAddress address)
    {
        if (address.isVersion6())
        {
            return ipv6Cache.contains(address);
        }
        else
        {
            for (LongRange range : ipv4Cache)
            {
                if (range.contains(address.getHiLo()[1]))
                {
                    return true;
                }
            }
            return false;
        }
    }

    /**
     * Private, unsynchronized common add method.
     * 
     * @param address
     */
    private void privateAdd(IPAddress address)
    {
        if (address.isVersion6())
        {
            ipv6Cache.add(address);
        }
        else
        {
            long value = address.getIpLow();
            List<LongRange> adjacencies = new ArrayList<LongRange>();
            for (LongRange range : ipv4Cache)
            {
                if (range.contains(value))
                {
                    return;
                }
                else if (range.isAdjacent(value))
                {
                    adjacencies.add(range);
                }
            }

            if (adjacencies.size() > 0)
            {
                handleAdjacencies(adjacencies, value);
            }
            else
            {
                ipv4Cache.add(new LongRange(value, value));
            }
        }
    }

    /**
     * Updates and merges the given adjacent {@link LongRange} objects as necessary.
     * 
     * @param adjacencies
     * @param value
     */
    private void handleAdjacencies(List<LongRange> adjacencies, long value)
    {
        LongRange one = adjacencies.get(0);
        one.updateRange(value);
        if (adjacencies.size() == 2)
        {
            LongRange two = adjacencies.get(1);
            one.consume(two);
            ipv4Cache.remove(two);
        }
    }

    /**
     * @author rkruse
     */
    private class LongRange
    {
        private long start;
        private long end;

        LongRange(long start, long end)
        {
            this.start = start;
            this.end = end;
        }

        /**
         * Consumes another IntRange that is adjacent to this one.
         * @param range
         */
        void consume(LongRange other)
        {
            if (start <= other.getStart())
            {
                updateRange(other.getEnd());
            }
            else
            {
                updateRange(other.getStart());
            }
        }

        /**
         * Updates the start or end of this range to include the new value.
         * 
         * @param value
         */
        void updateRange(long value)
        {
            if (start - 1 == value)
            {
                start = value;
            }
            else if (end + 1 == value)
            {
                end = value;
            }
        }

        /**
         * Returns true if the given value is next to the start or the end of this range.
         * 
         * @param value
         * @return
         */
        boolean isAdjacent(long value)
        {
            return (start - 1 == value || end + 1 == value);
        }

        /**
         * Returns true if the given value is between the start and end of this range.
         * @param value
         * @return
         */
        boolean contains(long value)
        {
            return (value >= start && value <= end);
        }

        /** {@inheritDoc} */
        @Override
        public int hashCode()
        {
            final int prime = 31;
            int result = 1;
            result = prime * result + (int) (end ^ (end >>> 32));
            result = prime * result + (int) (start ^ (start >>> 32));
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
            final LongRange other = (LongRange) obj;
            if (end != other.end)
            {
                return false;
            }
            if (start != other.start)
            {
                return false;
            }
            return true;
        }

        /**
         * @return Returns the end.
         */
        long getEnd()
        {
            return end;
        }

        /**
         * @return Returns the start.
         */
        long getStart()
        {
            return start;
        }

    }

}
