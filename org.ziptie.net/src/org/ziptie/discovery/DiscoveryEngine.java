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

import java.net.UnknownHostException;
import java.util.Collection;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.Callable;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.FutureTask;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.log4j.Logger;
import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.NetworkAddress;
import org.ziptie.addressing.Subnet;
import org.ziptie.exception.PersistenceException;
import org.ziptie.logging.LoggingConstants;
import org.ziptie.net.common.NILProperties;
import org.ziptie.security.ISecurityCheck;
import org.ziptie.security.NoSecurityCheck;
import org.ziptie.security.PermissionDeniedException;

/**
 * Offers a discovery queue as a method of supporting the idea of continuous inventory. Any service
 * is free to place data on this queue to be discovered as a manageable device. <br>
 * <br>
 * Users of the <code>DiscoveryEngine</code> should provide a {@link IInventoryCallbacks}
 * implementation on startup. Then, to process events the user should implement
 * {@link IDiscoveryEventHandler} and register that implementation through
 * {@link DiscoveryEngine#registerEventHandler(IDiscoveryEventHandler)} <br>
 * <br>
 * 
 * Following that, normal use of the engine is through the following methods
 * <li>{@link #pingAndDiscover(AddressSet, boolean, boolean, boolean)}
 * <li>{@link #discover(IPAddress, boolean, boolean, boolean)}
 * <li>{@link #simpleDiscovery(Collection, boolean)}
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
public final class DiscoveryEngine
{
    public static final int PING_PRIORITY = 3;

    private static final int HALF_SECOND = 500;
    private static final int SIXTY_SECONDS = 60;

    private static final int CORE_THREADS = 1;
    private static final int IDLE_TIMEOUT = 30;
    private static final String DISCOVERY_THREAD_NAME = "DISCOVERY";
    private static final String DISCOVERY_THREAD_NAME_USER_POOL = "DISCOVERY-UP";

    private static final int USER_DISCOVERY_PRIORITY = 1;
    private static final int BACKGROUND_DISCOVERY_PRIORITY = 2;
    private static Logger USER_LOG = Logger.getLogger(LoggingConstants.DISCOVERY);
    private static DiscoveryEngine instance;

    private DiscoveryConfig discoveryConfig;
    private IDiscoveryConfigPersister persister;
    private Map<String, IDiscoveryEventHandler> eventHandlers;
    private IInventoryCallbacks inventoryCallback;
    private ISecurityCheck securityCheck;
    private IpCache totalAnalyzedCache;
    private IpCache successfullyDiscoveredCache;
    private ResizableThreadPoolExecutor discoveryThreadPool;
    private ScheduledExecutorService cacheClearerExecutor;
    private StatTracker statTracker;
    private Lock inactiveLock;
    private Condition inactiveCondition;
    private AbstractPinger pinger;
    private AtomicLong tieBreaker;
    private Semaphore addSemaphore;

    /**
     * Private constructor
     */
    private DiscoveryEngine()
    {
    }

    /**
     * Retrieves an already setup DiscoveryEngine. Before anybody calls this method, this singleton
     * service needs to be initialized by calling <code>initialize()</code>.
     * 
     * @return the singleton {@link DiscoveryEngine}
     */
    public static DiscoveryEngine getInstance()
    {
        if (instance == null)
        {
            throw new RuntimeException("The discovery engine has not been initialized.");
        }
        return instance;
    }

    /**
     * Startup the <code>DiscoveryEngine</code>
     * 
     * @param inventoryCallback - a way to retrieve credentials
     * @return the singleton {@link DiscoveryEngine}
     */
    public static DiscoveryEngine startup(IInventoryCallbacks inventoryCallback)
    {
        return startup(inventoryCallback, new NoSecurityCheck());
    }

    /**
     * Startup the <code>DiscoveryEngine</code>
     * 
     * @param inventoryCallback - a way to retrieve credentials
     * @param securityCheck - tells the engine to check permissions on getting and setting the
     *        configuration
     * @return the singleton {@link DiscoveryEngine}
     */
    public static DiscoveryEngine startup(IInventoryCallbacks inventoryCallback, ISecurityCheck securityCheck)
    {
        return startup(inventoryCallback, securityCheck, new NoPersistence());
    }

    /**
     * Startup the <code>DiscoveryEngine</code>
     * 
     * @param inventoryCallback - a way to retrieve credentials
     * @param persister - how to save an retrieve the <code>DiscoveryConfig</code> from a database
     *        or any type of storage
     * @return the singleton {@link DiscoveryEngine}
     */
    public static DiscoveryEngine startup(IInventoryCallbacks inventoryCallback, IDiscoveryConfigPersister persister)
    {
        return startup(inventoryCallback, new NoSecurityCheck(), persister);
    }

    /**
     * 
     * @param inventoryCallback - a way to retrieve credentials
     * @param securityCheck - tells the engine to check permissions on getting and setting the
     *        configuration
     * @param persister - how to save an retrieve the <code>DiscoveryConfig</code> from a database
     *        or any type of storage
     * @return the singleton {@link DiscoveryEngine}
     */
    public static DiscoveryEngine startup(IInventoryCallbacks inventoryCallback, ISecurityCheck securityCheck, IDiscoveryConfigPersister persister)
    {
        instance = new DiscoveryEngine();
        instance.init(inventoryCallback, securityCheck, persister);
        return instance;
    }

    /**
     * Register a new {@link IDiscoveryEventHandler} with the <code>DiscoveryEngine</code>.
     * Events being generated by the engine will be dropped on each handler.
     * 
     * @param id a unique string ID to reference this handler. This is used again in the {@link #unregisterEventHandler(String)} method. 
     * @param eventHandler a way for the DiscoveryEngine to handle events
     */
    public void registerEventHandler(String id, IDiscoveryEventHandler eventHandler)
    {
        synchronized (eventHandlers)
        {
            eventHandlers.put(id, eventHandler);
        }
    }

    /**
     * Removes an event handler with the provided ID.  If the event handler doesn't exist, then this method is a no-op.
     * @param id the ID of the handler as provided in the {@link #registerEventHandler(String, IDiscoveryEventHandler)} method.
     */
    public void unregisterEventHandler(String id)
    {
        synchronized (eventHandlers)
        {
            eventHandlers.remove(id);
        }
    }

    /**
     * Intended as a way to provide device type information on user input. The addresses passed
     * through these means should be well known addresses to some user, i.e. through an import or
     * add device wizard. <br>
     * <br>
     * Uses a seperate thread pool than the background discovery and blocks until the results are
     * ready. Devices discovered through this means will not trigger additional neighbor
     * discoveries. Use the {@link #pingAndDiscover(AddressSet, boolean, boolean, boolean)} or
     * {@link #discover(AddressSet, boolean, boolean, boolean)} methods to trigger a crawling
     * discovery. <br>
     * <br>
     * This method is intended to be a way to provide efficient discovery from a user triggered
     * event such as an import or a device add. <br>
     * <br>
     * Some additional notes....
     * <li> The {@link #eventHandlers} aren't consulted since the results are delivered to the
     * caller of this method.
     * <li> It does not consult the boundaries, exclusions or discovery cache.
     * <li> Statistics for this type of discovery are not kept in the local {@link #statTracker}
     * <li> Neighbor information is never checked, such as CDP, ARP Tables, etc. So the resulting
     * list of {@link DiscoveryEvent} objects won't contain neighbors.
     * <li> The addresses are not pinged before SNMP data is tried.
     * 
     * @param ipAddress the address to be discovered
     * @param calculateAdminIp when true, the engine will calculate a preferred SNMP address
     * @return A {@link Future} that will block if you request the {@link DiscoveryEvent} from it.
     */
    public Future<DiscoveryEvent> simpleDiscovery(IPAddress ipAddress, boolean calculateAdminIp)
    {
        DiscoveryHost host = new DiscoveryHost(ipAddress);
        host.setCalculateAdminIp(calculateAdminIp);
        SimpleDiscoveryTask task = new SimpleDiscoveryTask(host);
        discoveryThreadPool.execute(task);
        return task;
    }

    /**
     * Provides a way to discovery an address asynchronously. The addresses passed into this method
     * will not be subject to a ping (ICMP or TCP). Because of this you also get access to the
     * {@link Future} object if you wish to block until the discovery task is complete. <br>
     * <br>
     * This method is best served when the addresses are well known addresses and not large blocks
     * of addresses. To discovery large subnets, like one might do when seeding an initial
     * inventory, use the {@link #pingAndDiscover(AddressSet, boolean, boolean, boolean)} method.
     * 
     * @param ipAddress the address to discover
     * @param fromInventory if set to true it saves the <code>DiscoveryEngine</code> the bother of
     *        checking back on the {@link IInventoryCallbacks} to see if this IP has a preferred IP
     *        Address.
     * @param ignoreCache when set to true the given address will be discovered even if it is
     *        currently in the cache of devices that have already been through the engine. This
     *        should be set to true if you are seeding discoveries on a timed interval so you can be
     *        sure they will be processed.
     * @param extendUsingNeighbors when set to true the engine will use the neighbor detail it has
     *        found on the given devices to crawl the network. Set this to false if you wish to
     *        restrict the scope of discovery to the addresses that were passed in. Note, when the
     *        global config option, {@link DiscoveryConfig#isDiscoverNeighbors()} is set to false
     *        this boolean has no effect.
     * @param calculateAdminIp when set to false, the engine won't calculate the administrative IP,
     *        assumes that the caller already knows the best IP to use.
     * @return a collection of {@link Future} objects that can be used to block until this discovery
     *         is complete. Note that you will only receive futures for the devices that you passed
     *         in, not their neighbor discoveries.
     * @throws NoFutureException thrown if the provided ipAddress doesn't pass a filter or cache
     */
    public Future<DiscoveryEvent> discover(IPAddress ipAddress, boolean fromInventory, boolean ignoreCache, boolean extendUsingNeighbors,
                                           boolean calculateAdminIp) throws NoFutureException
    {
        DiscoveryHost host = new DiscoveryHost(ipAddress);
        host.setCalculateAdminIp(calculateAdminIp);
        return discover(host, ignoreCache, fromInventory, extendUsingNeighbors, false);
    }

    /**
     * Provides a way to drop a quick hint to the discovery engine. The address passed in will first
     * get pinged and then be interrogated further with SNMP.
     * 
     * @param networkAddress the address(es) to discovery
     */
    public void discover(NetworkAddress networkAddress)
    {
        pingAndDiscover(networkAddress, false, false, true);
    }

    /**
     * Provides a way to discovery a set of addresses asynchronously. The addresses passed are first
     * subject to a ping tests. The ping is determined by your operating system type and may be an
     * ICMP ping or a lightweight TCP port scan. <br>
     * <br>
     * Those addresses that respond to a ping are then put on the normal discovery queue.
     * 
     * @param addressSet the addresses to discover
     * @param fromInventory when set to true the given address will be discovered even if it is
     *        currently in the cache of devices that have already been through the engine. This
     *        should be set to true if you are seeding discoveries on a timed interval so you can be
     *        sure they will be processed.
     * @param ignoreCache when set to true the given address will be discovered even if it is
     *        currently in the cache of devices that have already been through the engine. This
     *        should be set to true if you are seeding discoveries on a timed interval so you can be
     *        sure they will be processed.
     * @param extendUsingNeighbors when set to true the engine will use the neighbor detail it has
     *        found on the given devices to crawl the network. Set this to false if you wish to
     *        restrict the scope of discovery to the addresses that were passed in. Note, when the
     *        global config option, {@link DiscoveryConfig#isDiscoverNeighbors()} is set to false
     *        this boolean has no effect.
     */
    public void pingAndDiscover(Iterable<NetworkAddress> addressSet, boolean fromInventory, boolean ignoreCache, boolean extendUsingNeighbors)
    {
        try
        {
            if (!isActive())
            {
                statTracker.resetStats();
            }

            addSemaphore.acquire();
            for (NetworkAddress networkAddress : addressSet)
            {
                pingAndDiscover(networkAddress, fromInventory, ignoreCache, extendUsingNeighbors);
            }
            addSemaphore.release();
        }
        catch (InterruptedException e)
        {
            USER_LOG.error("Error while aquiring the pingAndDiscover semaphore for Discovery.", e);
        }
    }

    /**
     * @param fromInventory
     * @param ignoreCache
     * @param extendUsingNeighbors
     * @param networkAddress
     */
    private void pingAndDiscover(NetworkAddress networkAddress, boolean fromInventory, boolean ignoreCache, boolean extendUsingNeighbors)
    {
        for (IPAddress ipAddress : networkAddress)
        {
            USER_LOG.debug("Starting discovery for " + ipAddress);
            if (discoveryThreadPool.isShutdown())
            {
                break;
            }
            else
            {
                boolean runDiscovery = isHostAllowed(fromInventory, ignoreCache, new DiscoveryHost(ipAddress));
                if (runDiscovery)
                {
                    USER_LOG.debug(ipAddress + " has passed the initial discovery filters");
                    pinger.ping(ipAddress, fromInventory, extendUsingNeighbors);
                    inactiveLock.lock();
                    inactiveCondition.signalAll();
                    inactiveLock.unlock();
                }
                else
                {
                    USER_LOG.debug(ipAddress + " did not pass the discovery filters");
                }
            }
        }
    }

    /**
     * Run through a ping with a {@link DiscoveryHost}. This will be used to discovery CDP
     * neighbors. The neighbor must first respond to a ping before it will be considered for
     * addition.
     * 
     * @param discoveryHost
     * @param fromInventory
     * @param ignoreCache
     * @param extendUsingNeighbors
     */
    private void pingAndDiscover(DiscoveryHost discoveryHost, boolean fromInventory, boolean ignoreCache, boolean extendUsingNeighbors)
    {
        if (!discoveryThreadPool.isShutdown())
        {
            boolean runDiscovery = isHostAllowed(fromInventory, ignoreCache, discoveryHost);
            if (runDiscovery)
            {
                USER_LOG.debug(discoveryHost.getIpAddress() + " has passed the initial discovery filters");
                pinger.ping(discoveryHost, fromInventory, extendUsingNeighbors);
                inactiveLock.lock();
                inactiveCondition.signalAll();
                inactiveLock.unlock();
            }
            else
            {
                USER_LOG.debug(discoveryHost.getIpAddress() + " did not pass the discovery filters");
            }
        }
    }

    /**
     * Checks the cache, exclusions and boundaries. It also updates the {@link DiscoveryHost}
     * ipAddress to the preferred IP in the inventory.
     * 
     * @param fromInventory
     * @param ignoreCache
     * @param host
     * @return true if the host passes all filters
     */
    private boolean isHostAllowed(boolean fromInventory, boolean ignoreCache, DiscoveryHost host)
    {
        boolean runDiscovery = true;
        if (isHostAllowed(host, ignoreCache))
        {
            if (!fromInventory)
            {
                try
                {
                    IPAddress preferredIp = inventoryCallback.getPreferredIpAddress(host.getIpAddress());
                    if (!preferredIp.equals(host.getIpAddress()))
                    {
                        host.setIpAddress(preferredIp);
                        host.setFromInventory(true);
                        host.setCalculateAdminIp(false);
                        runDiscovery = isHostAllowed(host, ignoreCache);
                        totalAnalyzedCache.add(preferredIp);
                    }
                }
                catch (UnknownHostException e)
                {
                    host.setFromInventory(false);
                }
            }
        }
        else
        {
            runDiscovery = false;
        }
        return runDiscovery;
    }

    /**
     * @return the discoveryConfig
     * @throws PermissionDeniedException
     */
    public DiscoveryConfig getDiscoveryConfig()
    {
        return discoveryConfig;
    }

    /**
     * Saves the new {@link DiscoveryConfig} in memory for the <code>DiscoveryEngine</code> and to
     * the {@link IDiscoveryConfigPersister}.
     * 
     * @param discoveryConfig the discoveryConfig to set
     * @throws PermissionDeniedException when the caller does not have the appropriate permissions
     * @throws PersistenceException when there is a problem saving the <code>DiscoveryConfig</code> to the data store
     */
    public void setDiscoveryConfig(DiscoveryConfig discoveryConfig) throws PermissionDeniedException, PersistenceException
    {
        securityCheck.checkWritePrivileges();

        if (discoveryConfig.getClearCacheDelayMinutes() != getDiscoveryConfig().getClearCacheDelayMinutes())
        {
            resetClearCache(discoveryConfig.getClearCacheDelayMinutes());
        }
        updateThreadPool(discoveryConfig);
        updateCache(discoveryConfig);
        this.discoveryConfig = discoveryConfig;
        persister.saveDiscoveryConfig(discoveryConfig);
    }

    /**
     * Blocks until there is activity in the queue. Returns immediately if there is currently
     * activity.
     * 
     * @param time the maximum number of units of time to wait
     * @param unit type of time, seconds, ms, etc.
     * @throws InterruptedException if the thread being waited on is interrupted
     */
    public void waitForActivity(long time, TimeUnit unit) throws InterruptedException
    {
        if (!isActive())
        {
            inactiveLock.lock();
            try
            {
                inactiveCondition.await(time, unit);
            }
            finally
            {
                inactiveLock.unlock();
            }
        }
    }

    /**
     * Shuts down the main thread pool and clears out any waiting actions including pings in queue.
     * This method will block until all is complete, which could take a little while as the
     * currently running threads are allowed to gracefully finish. <br>
     * <br>
     * After all activity is cleared the main thread pool is started up once again.
     * 
     * @throws PermissionDeniedException if the user doesn't have adequate permission for this action
     */
    public void clearAllActivity() throws PermissionDeniedException
    {
        securityCheck.checkWritePrivileges();

        pinger.stop();
        discoveryThreadPool.shutdown();
        discoveryThreadPool.getQueue().clear();
        while (!discoveryThreadPool.isTerminated())
        {
            try
            {
                discoveryThreadPool.awaitTermination(HALF_SECOND, TimeUnit.MILLISECONDS);
            }
            catch (InterruptedException e)
            {
                return;
            }
        }

        try
        {
            addSemaphore.acquire();
        }
        catch (InterruptedException e)
        {
            throw new RuntimeException(e);
        }

        clearDiscoveryCache();

        // startup
        pinger.start();
        createThreadPool();
        addSemaphore.release();
    }

    /**
     * Finishes the rest of the active discovery threads but doesn't let anymore in.
     */
    public void shutdown()
    {
        discoveryThreadPool.shutdown();
    }

    /**
     * Blocks until there are no more discovery threads working. Call this after calling
     * <code>shutdown</code>
     * 
     * @param timeout how long to wait for termination
     * @param unit the <code>TimeUnit</code> that the timeout is expressed in
     * @throws InterruptedException if the wait for termination method is interrupted
     */
    public void awaitTermination(long timeout, TimeUnit unit) throws InterruptedException
    {
        discoveryThreadPool.awaitTermination(timeout, unit);
    }

    /**
     * Clears all addresses out of the pending queue.
     * 
     * @throws PermissionDeniedException if the user doesn't have adequate permission for this action
     * 
     */
    public void clearDiscoveryQueue() throws PermissionDeniedException
    {
        securityCheck.checkWritePrivileges();
        discoveryThreadPool.getQueue().clear();
        USER_LOG.debug("The Discovery task queue was cleared.");
    }

    /**
     * Clears the discovery cache. The discovery cache makes sure that a device isn't rediscovered.
     * Without it the discovery engine would run around in circles.
     * 
     * @throws PermissionDeniedException if the user doesn't have adequate permission for this action
     */
    public void clearDiscoveryCache() throws PermissionDeniedException
    {
        securityCheck.checkWritePrivileges();
        totalAnalyzedCache.clear();
        successfullyDiscoveredCache.clear();
        USER_LOG.debug("The Discovery cache was cleared.");
    }

    /**
     * Returns true if there are addresses in the engine's thread pool being worked on. Returns
     * false if the thread pool contains no runnables or active tasks.
     * 
     * @return true if the engine has active threads, false otherwise
     */
    public synchronized boolean isActive()
    {
        if (addSemaphore.availablePermits() == 0)
        {
            return true;
        }
        else if (discoveryThreadPool.getActiveCount() > 0)
        {
            return true;
        }
        else if (discoveryThreadPool.getQueue().size() > 0)
        {
            return true;
        }
        else if (pinger.getActivePings() > 0)
        {
            return true;
        }
        return false;
    }

    /**
     * The {@link StatTracker} tracks useful statistics on the <code>DiscoveryEngine</code> <br>
     * <br>
     * There is no need to call this method unless you are extending the {@link StatTracker} class.
     * 
     * @param stats the stats to set
     */
    public void setStatTracker(StatTracker stats)
    {
        if (stats != null)
        {
            this.statTracker = stats;
        }
    }

    /**
     * Pulls data from the {@link #statTracker} and makes a {@link DiscoveryStatus} with a few more
     * stats about the {@link #discoveryThreadPool}.
     * 
     * @return the <code>DiscoveryStatus</code> describing the engine's activity right now
     */
    public DiscoveryStatus getStatistics()
    {
        DiscoveryStatus status = new DiscoveryStatus();
        status.setAddressesAnalyzed(statTracker.getAddressesAnalyzed());
        status.setMatchedExclusion(statTracker.getMatchedExclusion());
        status.setOutsideBoundaries(statTracker.getOutsideBoundaries());
        status.setRespondedToSnmp(statTracker.getRespondedToSnmp());
        status.setStartedRunning(statTracker.getStartedRunning());
        status.setLastAddressDiscovered(statTracker.getLastAddressDiscovered());
        status.setActive(isActive());
        status.setQueueSize(discoveryThreadPool.getQueue().size() + discoveryThreadPool.getActiveCount() + pinger.getActivePings());
        return status;
    }

    // ------------------ package level methods ------------------ //

    /**
     * This method should only be used by the Discovery package. It allows adding to the discovery
     * queue without checking the filters (exclusion, boundaries, etc). Otherwise the functionality
     * is the same as {@link #discover(IPAddress, boolean, boolean, boolean)}.
     * 
     * @param ipAddress
     * @param ignoreCache
     * @param fromInventory
     * @param extendUsingNeighbors
     * @param alreadyPassedFilters when set to true the engine won't consult the exclusions or
     *        boundaries
     * @return
     * @throws NoFutureException if the discovery engine doesn't allow this host
     */
    Future<DiscoveryEvent> discover(DiscoveryHost host, boolean ignoreCache, boolean fromInventory, boolean extendUsingNeighbors, boolean alreadyPassedFilters)
            throws NoFutureException
    {
        boolean runDiscovery = false;
        if (!discoveryThreadPool.isShutdown())
        {
            if (alreadyPassedFilters)
            {
                runDiscovery = true;
            }
            else if (isHostAllowed(fromInventory, ignoreCache, host))
            {
                runDiscovery = true;
            }
        }
        else
        {
            USER_LOG.debug("The discovery engine is in shutdown status.  Unable to continue discovery on " + host.getIpAddress());
        }

        if (runDiscovery)
        {
            USER_LOG.debug("Now performing deeper discovery for " + host.getIpAddress());
            host.setExtendUsingNeighbors(extendUsingNeighbors);
            Future<DiscoveryEvent> future = sendToDiscovery(host);
            return future;
        }
        else
        {
            USER_LOG.debug("Discarding discovery for " + host.getIpAddress());
            throw new NoFutureException();
        }
    }

    /**
     * Increments the total addresses analyzed in the local {@link StatTracker}.
     * 
     */
    void incrementAddressesAnalyzed()
    {
        statTracker.incrementAddressesAnalyzed();
    }

    /**
     * Places a generic Runnable in the engine's thread pool.
     * 
     * @param toRun
     */
    void executeRunnable(Runnable runnable)
    {
        if (!discoveryThreadPool.isShutdown())
        {
            discoveryThreadPool.execute(runnable);
        }
    }

    // ------------------ private methods ------------------ //

    /**
     * Sends the host to discovery and return the future. Also notify any watchers of the discovery
     * statistics. This method assumes it has passed all filters.
     * 
     * @param host
     * @return
     */
    private Future<DiscoveryEvent> sendToDiscovery(DiscoveryHost host)
    {
        boolean signalWatchers = false;
        if (!isActive())
        {
            statTracker.resetStats();
            signalWatchers = true;
        }
        FullDiscoveryTask task = new FullDiscoveryTask(host);
        discoveryThreadPool.execute(task);
        if (signalWatchers)
        {
            inactiveLock.lock();
            inactiveCondition.signalAll();
            inactiveLock.unlock();
        }
        return task;
    }

    /**
     * Updates the thread pool size if any have changed.
     * 
     * @param newDiscoveryConfig
     */
    private void updateThreadPool(DiscoveryConfig newDiscoveryConfig)
    {
        if (newDiscoveryConfig.getMasterThreads() != discoveryThreadPool.getMaximumPoolSize())
        {
            discoveryThreadPool.setMaximumPoolSize(newDiscoveryConfig.getMasterThreads());
        }
    }

    /**
     * Clears out the cache if boundaries or exclusions have changed
     * 
     * @param discoveryConfig2
     * @throws PermissionDeniedException
     */
    private void updateCache(DiscoveryConfig newDiscoveryConfig) throws PermissionDeniedException
    {
        if (!newDiscoveryConfig.getBoundaryNetworks().equals(discoveryConfig.getBoundaryNetworks()))
        {
            clearDiscoveryCache();
        }
        else if (!newDiscoveryConfig.getExclusions().equals(discoveryConfig.getExclusions()))
        {
            clearDiscoveryCache();
        }
    }

    /**
     * Returns true if the given IP meets the following criteria<br>
     * <li>it is inside the boundaries if there are boundaries set
     * <li>it is not in the exclusions list
     * <li>it is not in the cache
     * 
     * @param host
     * @return
     */
    private boolean isHostAllowed(DiscoveryHost host, boolean ignoreCache)
    {
        IPAddress ipAddress = host.getIpAddress();
        // Return false if there are boundaries set and the address isn't
        // contained in them
        AddressSet boundaries = discoveryConfig.getBoundaryNetworks();
        if (boundaries.size() > 0 && !boundaries.contains(ipAddress))
        {
            statTracker.incrementOutsideBoundaries();
            return false;
        }

        // return false if it matches an exclusion
        if (discoveryConfig.getExclusions().contains(ipAddress))
        {
            statTracker.incrementMatchedExclusion();
            return false;
        }

        if (!ignoreCache)
        {
            if (host.isFromInventory())
            {
                return false;
            }

            boolean alreadyLookedAt = totalAnalyzedCache.containsThenAdd(ipAddress);
            if (alreadyLookedAt)
            {
                if (!host.isFromXdp())
                {
                    return false;
                }
                else if (successfullyDiscoveredCache.contains(ipAddress))
                {
                    return false;
                }
            }
        }
        // if it passes the above filters return true
        return true;
    }

    /**
     * Private helper to cycle through the neighbors for a given <code>DiscoveryEvent</code> and
     * add them to the discovery queue.
     * 
     * @param event
     */
    private void discoverNeighbors(DiscoveryEvent event)
    {
        // Add devices found through CDP, LLDP, etc
        if (discoveryConfig.isPollCDP())
        {
            for (XdpEntry entry : event.getXdpNeighbors())
            {
                discoverFromXdp(entry);
            }
        }

        // Add next hop routers
        if (discoveryConfig.isPollRoutingNeighbors())
        {
            for (RoutingNeighbor nextHop : event.getRoutingNeighbors())
            {
                pingAndDiscover(nextHop.getIpAddress(), false, false, true);
            }
        }

        // Add devices found in the ARP cache and ping them first
        if (discoveryConfig.isPollARP())
        {
            AddressSet arp = new AddressSet();
            for (ArpEntry entry : event.getArpTable())
            {
                arp.add(entry.getIpAddress());
            }
            if (arp.size() > 0)
            {
                pingAndDiscover(arp, false, false, true);
            }
        }
    }

    /**
     * Data from a discovery protocol has enough data that should be passed through discovery, even
     * if the device doesn't respond to SNMP. This method will take the data from the
     * {@link XdpEntry} and put it on the {@link DiscoveryHost}. <br>
     * It is the only other method besides {@link #addToDiscoveryQueue(NetworkAddress)} that should
     * add to the {@link #totalAnalyzedCache}.
     * 
     * @param entry
     */
    private void discoverFromXdp(XdpEntry entry)
    {
        if (entry.getIpAddress() != null && !entry.getIpAddress().getIPAddress().equals("0.0.0.0"))
        {
            USER_LOG.debug("Attempting to crawl to a " + entry.getType() + " neighbor with the address " + entry.getIpAddress());
            DiscoveryHost host = new DiscoveryHost(entry);
            pingAndDiscover(host, false, false, true);
        }
    }

    /**
     * <li>Builds the concurrent queue</li>
     * <li>Starts the single thread to continually read off of the queue</li>
     * <li>Creates the discoveryThreadPool that is a fixed size thread pool</li>
     * 
     * @param inventoryCallback2
     * @param securityCheck2
     * @param persister2
     */
    private void init(IInventoryCallbacks inventoryCallback2, ISecurityCheck securityCheck2, IDiscoveryConfigPersister persister2)
    {
        this.inventoryCallback = inventoryCallback2;
        this.securityCheck = securityCheck2;
        this.persister = persister2;
        this.discoveryConfig = persister.loadDiscoveryConfig();
        this.pinger = getPinger();

        addSemaphore = new Semaphore(1);
        tieBreaker = new AtomicLong();
        inactiveLock = new ReentrantLock();
        inactiveCondition = inactiveLock.newCondition();
        statTracker = new StatTracker();
        totalAnalyzedCache = new IpCache();
        successfullyDiscoveredCache = new IpCache();
        eventHandlers = new TreeMap<String, IDiscoveryEventHandler>();
        createThreadPool();
        resetClearCache(getDiscoveryConfig().getClearCacheDelayMinutes());
    }

    /**
     * Creates a new thread pool to be used as the primary <code>ExecutorService</code>
     */
    private void createThreadPool()
    {
        discoveryThreadPool = new ResizableThreadPoolExecutor(CORE_THREADS, discoveryConfig.getMasterThreads(), IDLE_TIMEOUT, TimeUnit.SECONDS,
                                                              new PriorityBlockingQueue<Runnable>(), DISCOVERY_THREAD_NAME);
    }

    /**
     * Returns an {@link AbstractPinger} appropriate for this operating system.
     * 
     * @param instance2
     * @return
     */
    private AbstractPinger getPinger()
    {
        String pingProtocol = NILProperties.getInstance().getString(NILProperties.DISCOVERY_PING_PROTOCOL);
        if (pingProtocol.equalsIgnoreCase("ICMP"))
        {
            USER_LOG.debug("Discovery is using the ICMP pinger");
            return new IcmpPinger(instance);
        }
        else if (pingProtocol.equalsIgnoreCase("TCP"))
        {
            USER_LOG.debug("Discovery is using the TCP pinger");
            return new TcpPinger(instance);
        }
        else if (System.getProperty("os.name").contains("Windows"))
        {
            USER_LOG.debug("Discovery is using the ICMP pinger");
            return new IcmpPinger(instance);
        }
        else
        {
            USER_LOG.debug("Discovery is using the TCP pinger");
            return new TcpPinger(instance);
        }
    }

    /**
     * Kills the current thread pool of cache delay and starts a new one with the fixed delay. This
     * should be called when the discoveryConfig is saved with a new clear cache delay value.
     * 
     * @param clearCacheDelayMinutes
     */
    private void resetClearCache(int clearCacheDelayMinutes)
    {
        if (cacheClearerExecutor != null)
        {
            cacheClearerExecutor.shutdownNow();
            try
            {
                cacheClearerExecutor.awaitTermination(5, TimeUnit.SECONDS);
            }
            catch (InterruptedException e)
            {
                // move along and reset if we can't shutdown the thread pool
                USER_LOG.debug(e);
            }
        }
        cacheClearerExecutor = Executors.newSingleThreadScheduledExecutor();
        long secondsDelay = clearCacheDelayMinutes * SIXTY_SECONDS;
        cacheClearerExecutor.scheduleAtFixedRate(new CacheClearer(), secondsDelay, secondsDelay, TimeUnit.SECONDS);
    }

    /**
     * Adds subnets that are allowed based on the {@link DiscoveryConfig#getMaxMaskPingSweep()} 
     * and {@link DiscoveryConfig#getMaxMaskPingSweepIpv6()} values.
     * 
     * @param subnets
     */
    private void addAllowedSubnets(Collection<Subnet> subnets)
    {
        for (Subnet subnet : subnets)
        {
            int maxMask = (subnet.getNetworkAddress().isVersion6()) ? discoveryConfig.getMaxMaskPingSweepIpv6() : discoveryConfig.getMaxMaskPingSweep();
            if (subnet.getNetmaskBits() >= maxMask)
            {
                AddressSet addressSet = new AddressSet();
                addressSet.add(subnet);
                pingAndDiscover(addressSet, false, false, true);
            }
        }
    }

    /**
     * A {@link FutureTask} that can be put right on the discoveryThreadPool using the
     * <code>execute</code> method on the thread pool.
     * 
     * This method uses the <code>Callable</code> {@link SimpleDiscoveryCallable} under the
     * covers.
     * 
     * @author rkruse
     */
    private class SimpleDiscoveryTask extends FutureTask<DiscoveryEvent> implements Comparable<DiscoveryComparator>, DiscoveryComparator
    {
        private Long localTieBreaker;

        /**
         * @param host
         */
        public SimpleDiscoveryTask(DiscoveryHost host)
        {
            super(new SimpleDiscoveryCallable(host));
            localTieBreaker = tieBreaker.getAndIncrement();
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
            return USER_DISCOVERY_PRIORITY;
        }

        /**
         * @see org.ziptie.discovery.DiscoveryComparator#getTieBreaker()
         */
        public Long getTieBreaker()
        {
            return localTieBreaker;
        }
    }

    /**
     * Callable for the user thread for times when the caller will wait for a result in the form of
     * a {@link Future<DiscoveryEvent>}. This process will not trigger a neighbor discovery.
     * 
     * @author rkruse
     */
    private class SimpleDiscoveryCallable implements Callable<DiscoveryEvent>
    {
        private DiscoveryHost host;

        /**
         * @param host - the host to discover
         */
        public SimpleDiscoveryCallable(DiscoveryHost host)
        {
            this.host = host;
        }

        public DiscoveryEvent call() throws Exception
        {
            Thread runner = Thread.currentThread();
            runner.setName(host.getIpAddress().getIPAddress() + "-" + DISCOVERY_THREAD_NAME_USER_POOL);
            DiscoveryEvent event = inventoryCallback.discoveryMethod(host, false);
            DiscoveryElf.cleanUpEvent(host, event);
            return event;
        }
    }

    /**
     * A {@link FutureTask} that can be put right on the discoveryThreadPool using the
     * <code>execute</code> method on the thread pool.
     * 
     * This method uses the <code>Callable</code> {@link FullDiscoveryCallable} under the covers.
     * 
     * @author rkruse
     */
    private class FullDiscoveryTask extends FutureTask<DiscoveryEvent> implements Comparable<DiscoveryComparator>, DiscoveryComparator
    {
        private Long localTieBreaker;

        /**
         * @param host
         */
        public FullDiscoveryTask(DiscoveryHost host)
        {
            super(new FullDiscoveryCallable(host));
            localTieBreaker = tieBreaker.getAndIncrement();
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
            return BACKGROUND_DISCOVERY_PRIORITY;
        }

        /**
         * @see org.ziptie.discovery.DiscoveryComparator#getTieBreaker()
         */
        public Long getTieBreaker()
        {
            return localTieBreaker;
        }
    }

    /**
     * Runnable that will discover details of an IP Address
     * 
     * @author rkruse
     */
    private class FullDiscoveryCallable implements Callable<DiscoveryEvent>
    {
        private DiscoveryHost host;

        /**
         * @param host - the host to discover
         */
        public FullDiscoveryCallable(DiscoveryHost host)
        {
            this.host = host;
        }

        public DiscoveryEvent call()
        {
            /*
             * Avoid double discoveries from XdpEntries that have been lying dormant in the queue
             * while other jobs discovered the same address.
             */
            if (host.isFromXdp() && successfullyDiscoveredCache.contains(host.getIpAddress()))
            {
                return new DiscoveryEvent(host.getIpAddress());
            }

            Thread runner = Thread.currentThread();
            runner.setName(host.getIpAddress().getIPAddress() + "-" + DISCOVERY_THREAD_NAME);
            DiscoveryEvent event = inventoryCallback.discoveryMethod(host, true);
            DiscoveryElf.cleanUpEvent(host, event);
            updateStatistics(event);
            updateCaches(event);
            handleEvents(event);

            if (getDiscoveryConfig().isDiscoverNeighbors() && event.isExtendUsingNeighbors())
            {
                discoverNeighbors(event);
                for (DeviceInterface snmpInterface : event.getInterfaces())
                {
                    if (snmpInterface.isInterfaceUp())
                    {
                        addAllowedSubnets(snmpInterface.getSubnets());
                    }
                }
            }
            return event;
        }

        /**
         * Update the caches to keep the engine from overworking. This method will take all of the
         * appropriate interface IPs from a target and add them to the cache as well.
         * 
         * @param event
         */
        private void updateCaches(DiscoveryEvent event)
        {

            if (event.isGoodEvent())
            {
                successfullyDiscoveredCache.add(event.getAddress());
                if (!event.getAddress().equals(host.getIpAddress()))
                {
                    totalAnalyzedCache.add(event.getAddress());
                    successfullyDiscoveredCache.add(host.getIpAddress());
                }
                for (DeviceInterface snmpInterface : event.getInterfaces())
                {
                    if (snmpInterface.isInterfaceUp())
                    {
                        for (IPAddress ip : snmpInterface.getIPAddresses())
                        {
                            totalAnalyzedCache.add(ip);
                            successfullyDiscoveredCache.add(ip);
                        }
                    }
                }
            }
        }

        /**
         * Update the <code>DiscoveryEngine</code> member variables that are tracking statistics
         * 
         * @param event
         */
        private void updateStatistics(DiscoveryEvent event)
        {
            statTracker.incrementAddressesAnalyzed();
            if (event.isGoodEvent())
            {
                statTracker.incrementRespondedToSnmp();
                statTracker.setLastAddressDiscovered(event.getAddress());
            }
        }

        /**
         * Post the events to all of the listeners
         * 
         * @param event
         */
        private void handleEvents(DiscoveryEvent event)
        {
            for (IDiscoveryEventHandler handler : eventHandlers.values())
            {
                handler.handleEvent(event);
            }
        }
    }

    /**
     * Used in the thread that periodically clears the discovery cache
     * 
     * @author rkruse
     */
    private class CacheClearer implements Runnable
    {
        /**
         * @see java.lang.Runnable#run()
         */
        public void run()
        {
            totalAnalyzedCache.clear();
            successfullyDiscoveredCache.clear();
        }
    }

    /**
     * static inner class used only to load a new <code>DiscoveryConfig</code> when the caller of
     * this service doesn't specify where to get the config from.
     * 
     * @author rkruse
     */
    private static class NoPersistence implements IDiscoveryConfigPersister
    {
        /**
         * @see org.ziptie.discovery.IDiscoveryConfigPersister#loadDiscoveryConfig()
         */
        public DiscoveryConfig loadDiscoveryConfig()
        {
            return new DiscoveryConfig();
        }

        /**
         * 
         * @see org.ziptie.discovery.IDiscoveryConfigPersister#saveDiscoveryConfig(DiscoveryConfig)
         */
        public void saveDiscoveryConfig(DiscoveryConfig discoveryConfig) throws PersistenceException
        {
            // no-op since the DiscoveryEngine updates it cache
        }
    }

}
