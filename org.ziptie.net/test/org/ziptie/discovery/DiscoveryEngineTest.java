/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/04 15:36:00 $
 * $Revision: 1.5 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/DiscoveryEngineTest.java,v $e
 */

package org.ziptie.discovery;

import java.io.File;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import junit.framework.TestCase;

import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.Subnet;
import org.ziptie.exception.NonContiguousSubnetMask;
import org.ziptie.exception.PersistenceException;
import org.ziptie.exception.ValueFormatFault;
import org.ziptie.net.common.NILProperties;
import org.ziptie.security.PermissionDeniedException;

/**
 * @author rkruse
 */
public class DiscoveryEngineTest extends TestCase
{
    private DiscoveryEngine engine;

    /**
     * Scratch pad test
     * 
     * @throws ValueFormatFault
     * @throws InterruptedException
     * @throws NonContiguousSubnetMask
     */
    public void testRun() throws ValueFormatFault, InterruptedException, NonContiguousSubnetMask
    {
        AddressSet addressSet = new AddressSet();
        addressSet.add(new Subnet(new IPAddress("10.10.1.0"), new IPAddress("255.255.255.128")));
        engine.pingAndDiscover(addressSet, false, true, true);

        // Let the program (server) run for a bit before killing it
        Thread.sleep(10000);

        engine.shutdown();
        engine.awaitTermination(60, TimeUnit.SECONDS);
    }

    /**
     * There is a simple call on the DiscoveryEngine to tell if it is active or idle. A new engine
     * should be idle.
     * 
     * @throws PersistenceException
     * @throws PermissionDeniedException
     * @throws NonContiguousSubnetMask
     * @throws IllegalArgumentException
     * @throws InterruptedException 
     */
    public void testIsActive() throws PermissionDeniedException, PersistenceException, IllegalArgumentException, NonContiguousSubnetMask, InterruptedException
    {
        assertFalse(engine.isActive());
        DiscoveryConfig discoveryConfig = engine.getDiscoveryConfig();
        discoveryConfig.setMasterThreads(10);
        engine.setDiscoveryConfig(discoveryConfig);
        AddressSet addressSet = new AddressSet();
        addressSet.add(new IPAddress("10.100.6.1"));
        engine.pingAndDiscover(addressSet, false, true, true);
        Thread.sleep(100);
        assertTrue(engine.isActive());
        engine.shutdown();
    }

    /**
     * After a shutdown, adding to discovery shouldn't throw a RejectedExecutionException
     * 
     */
    public void testShutdown()
    {
        engine.shutdown();
        engine.discover(new IPAddress("74.23.12.123"));
    }

    /**
     * Gives some work for the discovery engine to complete and then tries to clear all activity.
     * Afterwards we check to make sure the engine is inactive.
     * 
     * @throws NonContiguousSubnetMask
     * @throws IllegalArgumentException
     * @throws PersistenceException
     * @throws PermissionDeniedException
     * 
     */
    public void testClearAllActivity() throws IllegalArgumentException, NonContiguousSubnetMask, PermissionDeniedException, PersistenceException
    {
        assertFalse(engine.isActive());

        DiscoveryConfig discoveryConfig = engine.getDiscoveryConfig();
        discoveryConfig.setMasterThreads(1);
        engine.setDiscoveryConfig(discoveryConfig);

        AddressSet addressSet = new AddressSet();
        addressSet.add(new Subnet(new IPAddress("10.100.200.200"), new IPAddress("255.255.255.192")));
        engine.pingAndDiscover(addressSet, false, true, false);
        assertTrue(engine.isActive());
        engine.clearAllActivity();
        assertFalse(engine.isActive());
    }

    public void testStats() throws InterruptedException
    {
        DiscoveryStatus stats = engine.getStatistics();
        assertFalse(stats.isActive());

        engine.discover(new IPAddress("10.100.15.3"));
        Thread.sleep(1000);
        stats = engine.getStatistics();
        assertTrue(stats.isActive());
        assertTrue(stats.getQueueSize() > 0);
    }

    /**
     * Throws a large number of background discovery tasks on the queue. Then calls the
     * simpleDiscovery method, which should be placed at the front of the queue. After the
     * simpleDiscovery is complete there should be plenty of action in the main queue.
     * @throws PersistenceException 
     * @throws PermissionDeniedException 
     * @throws NonContiguousSubnetMask 
     * @throws IllegalArgumentException 
     * @throws ExecutionException 
     * @throws InterruptedException 
     * 
     */
    public void testPriorityQueue() throws PermissionDeniedException, PersistenceException, IllegalArgumentException, NonContiguousSubnetMask,
            InterruptedException, ExecutionException
    {
        DiscoveryConfig discoveryConfig = engine.getDiscoveryConfig();
        discoveryConfig.setMasterThreads(1);
        engine.setDiscoveryConfig(discoveryConfig);

        AddressSet addressSet = new AddressSet();
        addressSet.add(new Subnet(new IPAddress("10.100.200.0"), new IPAddress("255.255.255.0")));
        engine.pingAndDiscover(addressSet, false, true, false);

        assertTrue(engine.isActive());

        Future<DiscoveryEvent> future = engine.simpleDiscovery(new IPAddress("10.100.15.3"), false);
        DiscoveryEvent event = future.get();
        System.out.println("testPriorityQueue event: " + event.toString());

        // the pool should still be active trying to ping the rest of the 10.100.200.0 network
        assertTrue(engine.isActive());
        System.out.println("Queue size: " + engine.getStatistics().getQueueSize());
        assertTrue(engine.getStatistics().getQueueSize() > 5);
        engine.clearAllActivity();
    }

    protected void setUp()
    {
        NILProperties.setup(new File("../conf/network/nil.properties"));
        engine = DiscoveryEngine.startup(new UnitTestInventoryCallback());
        engine.registerEventHandler("UNIT TEST", new UnitTestDiscEventHandler());
    }
}
