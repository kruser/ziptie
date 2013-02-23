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

package org.ziptie.perl;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.ReentrantReadWriteLock;

/**
 * A class providing a pool of PerlServer instances.  The pool has the following properties:
 * 
 * 1) Once filled, the pool will maintain at least a minimum number of instances in the pool.
 * 2) The pool is unbounded in the number of instances it will give out, but bounded in the
 *    number of instances allowed back in the pool.
 * 3) Once filled to a maximum level, all returning instances to the pool are discarded.
 * 4) If the pool has more than the minimum number of instances, but less than the maximum
 *    level, a returning Perl will "linger" for a short time.  If it is unused during that
 *    time, it will be discarded.  But not if it would take the pool below the mimimum level
 *    (see (1) above).
 * 5) A Perl script that uses a PerlServer cannot run any longer than defined by the 
 *    'maxPerlLifeSeconds'.  By default this value is 1800 (30 minutes).  By setting this
 *    value to '0' PerlServer instances will never timeout.  Only do this if you are
 *    sure that you will have forever running Perls.
 *
 * The "lingering" behavior of the pool provides very good throughput when a large number of
 * PerlServers are needed for a sustained duration of time.  At the same time, it allows the
 * pool to shrink to its minimum size once the demand drops off.
 *
 * The pool has a number of configurable parameters controlled by system properties:
 * 
 * minPerlPoolSize       - the minimum number of instances to keep in the pool
 * lingerPerlPoolSize    - the maximum number of instances allowed in the pool
 * perlLingerTimeSeconds - the length of time an idle server will stay in the pool
 * maxUseThreshold       - the maximum number of times to use a PerlServer before discarding
 * debugPerlPool         - the level of detail in logging desired (0-3).  0 being none.
 * maxPerlLifeSeconds    - the number of seconds that any single Perl script is allowed to run.
 * 
 * @author bwooldridge
 */
@SuppressWarnings("nls")
public class PerlPoolManager
{
    private static final int ONE_THOUSAND_MILLIS = 1000;
    private static final int DEFAULT_REUSE_THRESHOLD = 100;
    private static final int DEFAULT_LINGER_POOLSIZE = 10;
    private static final int DEFAULT_MAX_PERL_LIFE_SECONDS = 1800;
    private static final int HIGH_USE_COUNT = 1000000;
    private static final int THIRTY_SECONDS = 30;
    private static final int TEN_SECONDS = 10;
    private static final int QUARTER_SECOND = 250;
    private static final int DEBUG_LEVEL1 = 1;
    private static final int DEBUG_LEVEL2 = 2;
    private static final int DEBUG_LEVEL3 = 3;

    /** A timer used to retire idle PerlServers that have lingered too long */
    private static final Timer LINGER_EXPIRATION_TIMER;
    /** A Read/Write lock used to control access to the pool collections */
    private static final ReentrantReadWriteLock RW_LOCK;
    /** The primary pool of idle/ready PerlServers */
    private static final ConcurrentLinkedQueue<PerlServer> POOL;
    /** A collection of PerlServers that are currently in use [by clients] outside of the pool.  If there was a concurrent Set we would use it. */
    private static final ConcurrentHashMap<PerlServer, Date> OUTSTANDING;
    /** An atomic integer to track the pool size, calling size() on ConcurrentLinkedQueue is unreliable */
    private static final AtomicInteger POOL_SIZE;

    /** The minimum pool size.  Once the pool fills, it won't drop below this level */
    private static int minPoolSize;
    /** The size above which PerlServers returning to the pool will simply be discarded */
    private static int lingerPoolSize;
    /** The maximum number of times a PerlServer instance will be used before discarding */
    private static int maxUseThreshold;
    /** The length of time an idle server lingers before being discarded */
    private static int lingerTimeMillis;
    /** The number of times to retry a failed PerlServer creation */
    private static int creationRetries;
    /** A debug level flag.  See the list of properties in the class documentation */
    private static int DEBUG;
    /** the maximum number of seconds that a single Perl script can run inside a PerlServer */
    private static long maxPerlLifeMillis;

    private static PerlServerConfig perlServerConfig;

    static
    {
        POOL_SIZE = new AtomicInteger(0);

        RW_LOCK = new ReentrantReadWriteLock();
        POOL = new ConcurrentLinkedQueue<PerlServer>();
        OUTSTANDING = new ConcurrentHashMap<PerlServer, Date>();

        Integer poolSize = Integer.getInteger("lingerPerlPoolSize", DEFAULT_LINGER_POOLSIZE);
        lingerPoolSize = Math.max(0, poolSize.intValue());

        poolSize = Integer.getInteger("minPerlPoolSize", 0);
        minPoolSize = Math.max(0, poolSize.intValue());

        Integer perlLife = Integer.getInteger("maxPerlLifeSeconds", DEFAULT_MAX_PERL_LIFE_SECONDS);
        maxPerlLifeMillis = Math.max(0, perlLife.intValue() * ONE_THOUSAND_MILLIS);

        Integer useThreshold = Integer.getInteger("maxPerlUseThreshold", DEFAULT_REUSE_THRESHOLD);
        maxUseThreshold = Math.max(0, useThreshold.intValue());

        Integer linger = Integer.getInteger("perlLingerTimeSeconds", THIRTY_SECONDS);
        lingerTimeMillis = Math.max(TEN_SECONDS, linger.intValue()) * ONE_THOUSAND_MILLIS;

        LINGER_EXPIRATION_TIMER = new Timer("Perl Pool Expiration Timer", true);
        LINGER_EXPIRATION_TIMER.schedule(new ExpirationTimer(), lingerTimeMillis, lingerTimeMillis);

        Integer retries = Integer.getInteger("creationRetries", 3);
        creationRetries = Math.max(3, retries);

        Integer debug = Integer.getInteger("debugPerlPool");
        if (debug != null)
        {
            DEBUG = debug.intValue();
            if (DEBUG > 0)
            {
                System.err.printf("minPerlPoolSize: %d\n", minPoolSize);
                System.err.printf("lingerPerlPoolSize: %d\n", lingerPoolSize);
                System.err.printf("maxPerlUseThreshold: %d\n", maxUseThreshold);
                System.err.printf("perlLingerTimeSeconds: %d\n", lingerTimeMillis / ONE_THOUSAND_MILLIS);
                System.err.printf("maxPerlLifeSeconds: %d\n", maxPerlLifeMillis / ONE_THOUSAND_MILLIS);
            }
        }

        perlServerConfig = new PerlServerConfig();
    }

    // =====================================================================
    //                 P A C K A G E    M E T H O D S
    // =====================================================================

    /**
     * This method returns a PerlServer for use by a client. If one exists in the pool,
     * it is returned, if the pool is empty it creates a new instance of a PerlServer
     * and returns it.  This means this method never blocks waiting for a PerlServer,
     * and means that the pool is inbounded in the number of Perl processes it will
     * spawn.  Capping the number of concurrent evaluations using PerlServers is left
     * to the consumer of the pool.
     * 
     * The read lock is used to prevent certain operations, see flush(), from running while
     * we're interacting with the pool collections.  However, it does not prevent returns
     * to the pool.  Because of the concurrent collections, PerlServers can be taken and
     * returned to the pool with non-blocking performance.
     * 
     * @throws PerlException thrown if the underlying process could not be started three
     *         times in a row.
     * @return an instance of PerlServer
     */
    public PerlServer getPerlServer() throws PerlException
    {
        RW_LOCK.readLock().lock();

        try
        {
            PerlServer perlServer = POOL.poll();
            if (perlServer != null)
            {
                POOL_SIZE.decrementAndGet();
                if (!perlServer.isAlive())
                {
                    logDebug(DEBUG_LEVEL2, perlServer, "Discarding dead PerlServer found in pool.");
                    // try again (recursive)
                    perlServer = getPerlServer();
                }
            }
            else
            {
                perlServer = newPerlServer();
            }

            OUTSTANDING.put(perlServer, new Date());

            return perlServer;
        }
        finally
        {
            RW_LOCK.readLock().unlock();
        }
    }

    /**
     * This method returns a PerlServer instance (allocated by getPerlServer()) to the pool.
     * If the pool is full, the use count exceeded, or it came back DOA, then the PerlServer
     * instance is terminated.
     * 
     * The read lock is used to prevent certain operations, see flush(), from running while
     * we're interacting with the pool collections.  However, it does not prevent 'takes'
     * from the pool.  Because of the concurrent collections, PerlServers can be taken and
     * returned to the pool with non-blocking performance.
     * 
     * @param perlServer the PerlServer instance to return.
     */
    public void returnPerlServer(PerlServer perlServer)
    {
        RW_LOCK.readLock().lock();
        try
        {
            OUTSTANDING.remove(perlServer);

            if (POOL_SIZE.get() >= lingerPoolSize)
            {
                logDebug(DEBUG_LEVEL2, perlServer, "Pool is full upon return.");
                perlServer.terminate();
            }
            else if (perlServer.getUseCount() > maxUseThreshold)
            {
                logDebug(DEBUG_LEVEL2, perlServer, "Use count exceeded upon return.");
                perlServer.terminate();
            }
            else if (!perlServer.isAlive())
            {
                logDebug(DEBUG_LEVEL2, perlServer, "PerlServer was DOA upon return.");
                perlServer.terminate();
            }
            else
            {
                POOL.offer(perlServer);
                POOL_SIZE.incrementAndGet();

                logDebug(DEBUG_LEVEL2, perlServer, "Returning PerlServer to pool.");
            }
        }
        finally
        {
            RW_LOCK.readLock().unlock();
        }
    }

    /**
     * This method will flush the existing Perl instances from the pool, terminating them,
     * and will mark all outstanding Perl instances with a sufficiently high use count to
     * ensure they do not return to the pool (but does not terminate them).
     *
     * The write lock prevents anyone from entering or leaving the pool
     * while this operation is iterating (see getPerlServer() and returnPerlServer()).
     */
    public void flush()
    {
        RW_LOCK.writeLock().lock();
        try
        {
            perlServerConfig = new PerlServerConfig();

            // Mark the outstanding (running) PerlServers with a high use
            // count, so they won't be allowed back into the pool.
            for (PerlServer perlServer : OUTSTANDING.keySet())
            {
                perlServer.setUseCount(HIGH_USE_COUNT);
            }

            // Kill all the Perls that are waiting in the pool to be used.
            Iterator<PerlServer> iter = POOL.iterator();
            while (iter.hasNext())
            {
                PerlServer perlServer = iter.next();
                iter.remove();
                perlServer.terminate();
            }

            POOL.clear();
            POOL_SIZE.set(0);
        }
        finally
        {
            RW_LOCK.writeLock().unlock();
        }
    }

    /**
     * Forcibly terminate all Perl instances both inside the pool and currently
     * outstanding.
     *
     * The write lock prevents anyone from entering or leaving the pool
     * while this operation is iterating.
     */
    public void shutdown()
    {
        RW_LOCK.writeLock().lock();
        try
        {
            // Kill the outstanding (running) Perls.
            for (PerlServer perlServer : OUTSTANDING.keySet())
            {
                perlServer.terminate();
            }

            OUTSTANDING.clear();

            // Kill all the Perls that are waiting in the pool.
            for (PerlServer perlServer : POOL)
            {
                perlServer.terminate();
            }

            POOL.clear();
            POOL_SIZE.set(0);
        }
        finally
        {
            RW_LOCK.writeLock().unlock();
        }
    }

    /**
     * Determine how many PerlServers are outstanding (i.e. in active use).
     *
     * @return the count
     */
    public int getOutstanding()
    {
        return OUTSTANDING.size();
    }

    /**
     * Determine the number of idle PerlServers are currently in the pool.  As mentioned
     * in the comments for poolSize, the size() method on a ConcurrentLinkedQueue is
     * documented as not reliable -- and they are correct (I tried).  So, I keep track
     * of the pool size separately -- in the poolSize atomic variable.
     *
     * @return the pool size
     */
    public int getPoolSize()
    {
        return POOL_SIZE.get();
    }

    // =====================================================================
    //                      P R I V A T E   M E T H O D S
    // =====================================================================

    /**
     * A helper method used to create a new PerlServer.  It will try three times, with a
     * 100ms sleep in between, to successfuly create a PerlServer.  We have to do this
     * because constructing a PerlServer spawns an instance of a Perl processa and under
     * Windows this is a dicey proposition.  We have several challenges.
     * 
     * 1) Sometimes when spawning processes too fast we get this native error from Java:
     *       IOException: CreateProcess: perl -I. -I. .\PerlServer.pl error=5
     * 2) Sometimes the process spawns [apparently] successfully, but subsequently fails a
     *    test to see whether it is alive.  Possibly this is a Java issue.
     *
     * The first is hard to know whether to blame the OS or Perl's DLL initialization.  The
     * second is a race condition that is problematic across the Windows platform.  When
     * creating a process, the OS allocates the process, creates a thread and schedules it
     * to run, and then returns immediately.  At that point the process has not run through
     * it's shared library initialization.  From the user's perspective, the process is off
     * and running (the launch call returned without error).  The reality is that the 
     * process may fail to initialize and start.  Windows provides no method to determine
     * whether a process is running, other than polling it's state; and sometimes polling
     * its state immediately after launch spuriously indicates that the process is dead.
     * More information can be found here (read the discussion comments):
     * 
     *   http://blogs.msdn.com/oldnewthing/archive/2005/01/19/356048.aspx
     *
     * Suffice it to say that there are a myriad of ways in which creating the process
     * can fail sporadically in a way that may not and probably will not occur on the
     * next attempt to create that same exact process.  As a result, our blunt three-try
     * logic has eliminated all (or nearly all) observed sporadic launch failures. 
     * 
     * @return a new PerlServer instance
     * @throws newPerlServer thrown if the underlying process could not be started three
     *         times in a row.
     */
    private PerlServer newPerlServer() throws PerlException
    {
        int tries = 0;

        while (true)
        {
            try
            {
                PerlServer perlServer = new PerlServer(perlServerConfig);
                logDebug(DEBUG_LEVEL3, perlServer, "Created new PerlServer.");
                return perlServer;
            }
            catch (Exception e)
            {
                if (tries++ > creationRetries)
                {
                    String msg = "Unable to retrieve PerlServer instance from pool, or create a new one.";
                    if (e instanceof PerlException)
                    {
                        throw (PerlException) e;
                    }
                    logDebug(DEBUG_LEVEL1, null, msg);
                    if (DEBUG >= DEBUG_LEVEL1)
                    {
                        e.printStackTrace();
                    }
                    throw new PerlException(msg, e);
                }

                try
                {
                    Thread.sleep(QUARTER_SECOND);
                }
                catch (InterruptedException ie)
                {
                    throw new PerlException("Thread interrupted during creation of a new PerlServer.", ie);
                }
            }
        }
    }

    /**
     * A utility logging method that reduces code clutter by avoiding code like...
     * 
     * if (DEBUG >= debuglevel)
     * {
     *     System.err.println("something");
     * }
     * 
     * ... sprinkled all over the code.
     *
     * @param debugLevel the debug level required before the message will appear
     * @param perlServer a PerlServer instance, or null
     * @param message a text message to "log" (print)
     */
    private void logDebug(int debugLevel, PerlServer perlServer, String message)
    {
        if (DEBUG >= debugLevel)
        {
            System.err.printf("(%d) %d: %s: %08d: %s\n", System.identityHashCode(this), System.nanoTime(), Thread.currentThread().getName(),
                              (perlServer != null ? System.identityHashCode(perlServer) : 0), message);
        }
    }

    // =====================================================================
    //                      I N N E R   C L A S S E S
    // =====================================================================

    /**
     * This is an inner timer class used to expire idle PerlServers after they've
     * sat around unused for too long.  It should be noted here that the iteration
     * order of the queue is head-to-tail, meaning oldest to newest.  Because we
     * retain the first minPoolSize number of entries, this has an interesting
     * side-effect of evicting younger PerlServer instances.  The additional work
     * required to always expire oldest before youngest is:
     *
     * 1) Not worth the additional computation, and
     * 2) Not worth the additional complexity.  Keep it dead simple.
     * 3) Not the responsibility of this task.
     *
     * The truth is, in an active server these PerlServers should rotate fairly
     * often through the queue, ensuring essentially an equal opportunity for
     * expiration.  This is sufficient.  It is the maxUseThreshold that is meant
     * to remove old PerlServers from the pool upon return, not this task.  This
     * task is merely meant to remove idle PerlServers; we shouldn't confuse the
     * two semantics.
     *
     * @author bwooldridge
     */
    private static class ExpirationTimer extends TimerTask
    {
        public void run()
        {
            RW_LOCK.writeLock().lock();
            try
            {
                long now = System.currentTimeMillis();
                int expired = 0;
                int leftInPool = 0;

                Iterator<PerlServer> iter = POOL.iterator();
                while (iter.hasNext())
                {
                    PerlServer perlServer = iter.next();

                    long deltaMillis = now - perlServer.getLastUseTime();
                    if (leftInPool >= minPoolSize && deltaMillis > lingerTimeMillis)
                    {
                        iter.remove();
                        POOL_SIZE.getAndDecrement();
                        perlServer.terminate();
                        ++expired;
                    }
                    else
                    {
                        ++leftInPool;
                    }
                }

                if (DEBUG > DEBUG_LEVEL1 && expired > 0)
                {
                    System.err.printf("Expired %d idle PerlServers.  %d PerlServers left in the pool.", expired, leftInPool);
                }

                // terminate any PerlServers that have been checked out for too long.
                if (maxPerlLifeMillis > 0)
                {
                    Set<PerlServer> deadPerlServers = new HashSet<PerlServer>();
                    for (Map.Entry<PerlServer, Date> entry : OUTSTANDING.entrySet())
                    {
                        Date startTime = entry.getValue();
                        long elapsedMillis = now - startTime.getTime();
                        if (elapsedMillis > maxPerlLifeMillis)
                        {
                            entry.getKey().terminate();
                            deadPerlServers.add(entry.getKey());
                        }
                    }
                    for (PerlServer deadPerl : deadPerlServers)
                    {
                        OUTSTANDING.remove(deadPerl);
                    }
                }
            }
            finally
            {
                RW_LOCK.writeLock().unlock();
            }
        }
    }
}
