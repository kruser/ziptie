/**
 * 
 */
package org.ziptie.discovery;

import java.util.Random;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import junit.framework.TestCase;

import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.IPRange;

/**
 * Unit tests for the {@link IpCache}
 * @author rkruse
 */
public class IpCacheTest extends TestCase
{
    /**
     * How much is too much for an <code>AddressSet</code> based cache??
     * 
     * ...the answer is 16 million objects
     */
    public void disabledtestBlowUpAddressSet()
    {
        IpCache cache = new IpCache();
        IPRange range = new IPRange("10.0.0.0", "10.255.255.255");
        for (IPAddress ip : range)
        {
            cache.add(ip);
        }
        assertEquals(1, cache.size());
    }

    /**
     * The IpCache object streamlines IPAddresses into integers and maps adjacent integers into ranges 
     * when possible to conserve memory space.
     *
     */
    public void testNewCache()
    {
        IpCache cache = new IpCache();
        cache.add(new IPAddress("10.100.1.1"));
        assertEquals(1, cache.size());

        /*
         * Add another, it shouldn't increase the cache size
         */
        cache.add(new IPAddress("10.100.1.1"));
        assertEquals(1, cache.size());
    }

    /**
     * 
     *
     */
    public void testContains()
    {
        IpCache cache = new IpCache();
        cache.add(new IPAddress("10.100.1.1"));
        assertTrue(cache.contains(new IPAddress("10.100.1.1")));
    }
    
    /**
     * see {@link IpCache#containsThenAdd(IPAddress)}
     *
     */
    public void testContainsThenAdd()
    {
        IPAddress ip = new IPAddress("10.100.1.1");
        IpCache cache = new IpCache();
        assertFalse(cache.containsThenAdd(ip));
        assertTrue(cache.contains(ip));
    }

    /**
     * Test the ability to clear out the cache
     *
     */
    public void testClear()
    {
        IpCache cache = new IpCache();
        cache.add(new IPAddress("10.100.1.1"));
        cache.add(new IPAddress("10.100.1.2"));
        cache.add(new IPAddress("10.100.1.3"));
        cache.add(new IPAddress("10.100.1.4"));
        cache.add(new IPAddress("10.100.99.99"));
        assertEquals(2, cache.size());

        cache.clear();
        assertEquals(0, cache.size());
    }

    /**
     * When we add a new address that is adjacent to a previous one, it should simply extend the current entry
     * and not increase the overall size of the cache.
     *
     */
    public void testAdjacent()
    {
        IpCache cache = new IpCache();
        cache.add(new IPAddress("10.100.1.1"));
        assertEquals(1, cache.size());
        assertFalse(cache.contains(new IPAddress("10.100.1.2")));

        cache.add(new IPAddress("10.100.1.2"));
        assertEquals(1, cache.size());
        assertTrue(cache.contains(new IPAddress("10.100.1.2")));
    }

    /**
     * If two ranges are adjacent to a new range that is being added, they should be combined into
     * a single larger range.
     *
     */
    public void testDoubleAdjacencies()
    {
        IpCache cache = new IpCache();
        cache.add(new IPAddress("10.100.1.1"));
        cache.add(new IPAddress("10.100.1.3"));
        assertEquals(2, cache.size());
        assertFalse(cache.contains(new IPAddress("10.100.1.2")));

        cache.add(new IPAddress("10.100.1.2"));
        assertTrue(cache.contains(new IPAddress("10.100.1.2")));
        assertEquals(1, cache.size());
    }
    
    public void testIpv6()
    {
        IpCache cache = new IpCache();
        IPAddress ip1 = new IPAddress("fe80::212:3fff:fe96:dad6");
        IPAddress ip2 = new IPAddress("ae80::212:3fff:fe96:dad6");
        cache.add(ip1);
        assertEquals(cache.size(), 1);
        assertTrue(cache.contains(ip1));
        assertFalse(cache.contains(ip2));
    }

    /**
     * Tests out using the {@link IpCache#add(IPAddress)} and {@link IpCache#contains(IPAddress)] methods randomly 
     * and concurrently from multiple threads.
     * 
     * @throws InterruptedException
     */
    public void testConcurrency() throws InterruptedException
    {
        IpCacheExecutor threadPool = new IpCacheExecutor(50, 50, 1, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
        IpCache cache = new IpCache();

        for (int i = 0; i < 50; i++)
        {
            threadPool.execute(new CrazyIpCacheRunner(cache));
        }
        threadPool.shutdown();
        threadPool.awaitTermination(200, TimeUnit.SECONDS);
        if (threadPool.isCaughtConcurrentModificationException())
        {
            fail("Caught the ConcurrentModificationException when we shouldn't have");
        }
    }

    /**
     * Used for the concurrent test of {@link IpCache}
     * @author rkruse
     */
    private class CrazyIpCacheRunner implements Runnable
    {
        private IpCache cache;
        private Random generator;

        CrazyIpCacheRunner(IpCache cache)
        {
            this.cache = cache;
            this.generator = new Random();
        }

        public void run()
        {
            for (int j = 0; j < 100; j++)
            {
                IPAddress randomIP = new IPAddress(generator.nextInt(255) + "." + generator.nextInt(255) + "." + generator.nextInt(255) + "."
                        + generator.nextInt(255));

                // Randomly add or iterate the cache
                int decision = generator.nextInt(3);
                switch (decision)
                {
                case 1:
                    cache.add(randomIP);
                    break;
                case 2:
                    cache.contains(randomIP);
                    break;
                default:
                    cache.clear();
                    break;
                }

                // now randomly pause to screw things up a little more
                try
                {
                    Thread.sleep(generator.nextInt(25));
                }
                catch (InterruptedException e)
                {
                    throw new RuntimeException(e);
                }
            }
        }

    }
}