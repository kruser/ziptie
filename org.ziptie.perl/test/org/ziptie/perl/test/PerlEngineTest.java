package org.ziptie.perl.test;


import java.util.concurrent.Semaphore;

import junit.framework.TestCase;

import org.ziptie.perl.PerlException;
import org.ziptie.perl.PerlPoolManager;
import org.ziptie.perl.PerlServer;

@SuppressWarnings("nls")
public class PerlEngineTest extends TestCase
{
    private static PerlPoolManager perlPoolManager;

    static
    {
        perlPoolManager= new PerlPoolManager();
    }

    {
        System.setProperty("perlLingerTimeSeconds", "10");
    }

    private void eval(String script, String[] args) throws PerlException
    {
        PerlServer server = perlPoolManager.getPerlServer();
        try
        {
            server.eval(script, args, null, null);
        }
        finally
        {
            perlPoolManager.returnPerlServer(server);
        }
    }

    /**
     * Simplist possible test.
     *
     * @throws PerlException
     */
    public void test0() throws PerlException
    {
        eval("my $foo = 1024 * 1024;\n", null);

        perlPoolManager.flush();
        assertEquals(0, perlPoolManager.getPoolSize());

        System.out.println("Test 0 completed.");
        System.out.flush();
    }

    /**
     * Test basic execution and pool reuse.  Runs a number of threads (10), but pauses for
     * one second when half have been started.  This should be enough time for the initial
     * launched PerlServers to return to the pool, and the last half of the threads should
     * get 100% reuse in the pool.
     *
     * @throws PerlException
     * @throws InterruptedException
     */
    public void test1() throws InterruptedException
    {
        // I only use a StringBuilder because it makes the script line up nicely.
        StringBuilder sb = new StringBuilder();
        sb.append("#!/bin/perl\n");
        sb.append("print STDERR \"Hello World!  *\" . $ENV{'guid'} . \"*\\n\";\n");
        sb.append("my $foo = 1024 * 1024;\n");
        sb.append("# exit(2);\n");
        sb.append("# die \"Help me I'm dying!\\n\";\n");

        final String script = sb.toString();

        final String[] commandArgs = { "test1", "test2", "weird1'", "weird2,", "\"weird3" };

        Runnable runnable = new Runnable()
        {
            public void run()
            {
                try
                {
                    eval(script, commandArgs);
                }
                catch (PerlException e)
                {
                    e.printStackTrace();
                }
            }
        };

        Thread[] threads = new Thread[10];
        for (int i = 0; i < threads.length; i++)
        {
            threads[i] = new Thread(runnable, "Test1: Test Thread " + i);
            threads[i].start();
            if (i == (threads.length / 2))
            {
                sleep(1000);
            }
        }

        for (int i = 0; i < threads.length; i++)
        {
            threads[i].join();
        }

        perlPoolManager.flush();
        assertEquals(0, perlPoolManager.getPoolSize());

        System.out.println("Test 1 completed.");
        System.out.flush();
    }

    /**
     * This test launches 100 threads that will eval a simple script.  However, we use a
     * semaphore with a lease of 10 to restrict how many threads are concurrently executing.
     * After warming up the pool, we let the 100 threads rip, and time how long it takes
     * until the last one completes.
     *
     * @throws PerlException
     */
    public void test2() throws PerlException
    {
        // I only use a StringBuilder because it makes the script line up nicely.
        StringBuilder sb = new StringBuilder();
        sb.append("#!/bin/perl\n");
        sb.append("# print STDERR \"Hello World!\\n\";\n");
        sb.append("my $foo = 1024 * 1024;\n");
        sb.append("# exit(2);\n");
        sb.append("# die \"Help me I'm dying!\\n\";\n");

        final String script = sb.toString();

        // Only allow 10 threads to eval() at a time
        final Semaphore sem = new Semaphore(30);

        Runnable runnable = new Runnable()
        {
            public void run()
            {
                try
                {
                    // Each thread eval() 10 times
                    for (int i = 0; i < 10; i++)
                    {
                        try
                        {
                            sem.acquire();
                            eval(script, null);
                        }
                        finally
                        {
                            sem.release();
                        }
                    }
                }
                catch (PerlException e)
                {
                    e.printStackTrace();
                }
                catch (InterruptedException e)
                {
                    e.printStackTrace();
                }
            }
        };

        // Initialize pool of perl engines
        Thread[] threads = new Thread[sem.availablePermits()];
        for (int i = 0; i < threads.length; i++)
        {
            threads[i] = new Thread(runnable, "Test2: Test Thread " + i);
            threads[i].start();
        }

        for (int i = 0; i < threads.length; i++)
        {
            try
            {
                threads[i].join();
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
                fail();
            }
        }

        threads = new Thread[100];
        long start = System.nanoTime();
        for (int i = 0; i < threads.length; i++)
        {
            threads[i] = new Thread(runnable, "Test2: Test Thread " + i);
            threads[i].start();
        }

        for (int i = 0; i < threads.length; i++)
        {
            try
            {
                threads[i].join();
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
                fail();
            }
        }

        double elapsed = (System.nanoTime() - start) / 1000000.0;
        System.out.printf("Execution time: %5.3fms (%5.0f scripts/ms)\n",  elapsed, ((threads.length * 10.0) / (elapsed / 1000.0)));

        perlPoolManager.flush();
        assertEquals(0, perlPoolManager.getPoolSize());

        System.out.println("Test 2 completed.");
        System.out.flush();
    }

    /**
     * Test overridden Perl exit() -- see PerlServer.pl, where we override exit().
     *
     * @throws PerlException
     */
    public void test5() throws PerlException
    {
        eval("exit(-1);", null);

        perlPoolManager.flush();
        assertEquals(0, perlPoolManager.getPoolSize());

        System.out.println("Test 5 completed.");
        System.out.flush();
    }

    /**
     * Test die.
     *
     * @throws PerlException 
     */
    public void test6() throws PerlException
    {
        try
        {
            eval("die \"I can't take any more!\\n\";", null);

            fail("Script should have thrown an exception.");
        }
        catch (PerlException e)
        {
            // this is expected! don't fail.
            // System.out.println("Expected exception occurred.");
        }

        perlPoolManager.flush();
        assertEquals(0, perlPoolManager.getPoolSize());

        System.out.println("Test 6 completed.");
        System.out.flush();
    }

    /**
     * Test CORE::exit().  There's nothing we can do in Perl to override this, so this call
     * will blow out the Perl process.  The result is that the DOA PerlServer will not be
     * put back into the pool, and the pool will skrink by one.
     *
     * @throws PerlException
     */
    public void test7() throws PerlException
    {
        // Put a process into the pool
        eval("my $foo = 1024 * 1024;\n", null);
        
        // Now kill it by running this script
        eval("CORE::exit(-1);", null);

        int size = perlPoolManager.getPoolSize();
        assertEquals(0, size);

        perlPoolManager.flush();

        // assertEquals(0, ((PerlEngine) engine).getPerlPoolManager().getPoolSize());
        // assertEquals(0, ((PerlEngine) engine).getPerlPoolManager().getOutstanding());

        System.out.println("Test 7 completed.");
        System.out.flush();
    }

    /**
     * Test script that shuts down stderr.
     *
     * @throws PerlException
     */
    public void test8() throws PerlException
    {
        // I only use a StringBuilder because it makes the script line up nicely.
        StringBuilder sb = new StringBuilder();
        sb.append("#!/bin/perl\n");
        sb.append("print STDERR \"Hello World!\\n\";\n");
        sb.append("close(STDERR);\n");

        eval(sb.toString(), null);

        perlPoolManager.flush();

        System.out.println("Test 8 completed.");
        System.out.flush();
    }

    /**
     * Test interrupting a thread running a script.  It should die quickly.
     *
     * @throws InterruptedException
     * @throws PerlException
     */
    public void test11() throws InterruptedException, PerlException
    {
        System.out.println("Test 11 starting...");
        System.out.flush();

        Runnable runnable = new Runnable()
        {
            public void run()
            {
                try
                {
                    for (int i = 0; i < 10; i++)
                    {
                        eval("sleep(4000); # 4000 seconds", null);
                    }
                }
                catch (PerlException e)
                {
                    // do nothing
                }
            }
        };

        Thread t = new Thread(runnable, "Test 11: Thread 1");
        t.start();

        sleep(2000);
        System.out.println("Pre-interrupt active thread count : " + Thread.activeCount());
        assertTrue(t.isAlive());
        t.interrupt();
        sleep(3000);
        System.out.println("Post-interrupt active thread count: " + Thread.activeCount());
        assertFalse(t.isAlive());

        perlPoolManager.flush();

        // Give the PerlServers time to exit
        sleep(1000);

        System.out.println("Test 11 completed.");
        System.out.flush();
    }

    /**
     * Test the linger time management of the pool.  Set the linger time to 10 seconds.
     */
    public void test12() throws PerlException
    {
        System.out.println("Test 12 starting...takes 35 seconds.");
        System.out.flush();

        Runnable runnable = new Runnable()
        {
            public void run()
            {
                try
                {
                    eval("sleep(8);\nprint STDERR \"foo\\n\";\n", null);
                }
                catch (PerlException e)
                {
                    // do nothing
                }
            }
        };

        // Start 10 threads, wait 2 seconds, start 10 more
        System.out.println("Starting 10 threads.");
        for (int i = 0; i < 20; i++)
        {
            Thread t = new Thread(runnable, "Test 12: Thread " + i);
            if (i == 10)
            {
                sleep(2000);
                System.out.println("Starting 10 more threads.");
            }
            t.start();
        }
        sleep(1000);

        int size = perlPoolManager.getPoolSize() + perlPoolManager.getOutstanding();
        assertEquals(20, size);
        System.out.println("Pre-expiration pool size: " + size);

        // Sleep until they've returned to the pool.  Only 10 should be allowed back in because
        // lingerPoolSize=10.
        sleep(8000);
        size = perlPoolManager.getPoolSize() + perlPoolManager.getOutstanding();
        System.out.println("Post return pool size: " + size);
        assertEquals(10, size);

        // Sleep a few more seconds -- by this time the lingering servers should be gone, and only
        // minPoolSize remain.
        sleep(9000);
        size = perlPoolManager.getPoolSize() + perlPoolManager.getOutstanding();
        System.out.println("Post-expiration pool size: " + size);
        assertEquals(2, size);

        // Assert that there are no outstanding Perl instances
        assertEquals(0, perlPoolManager.getOutstanding());

        perlPoolManager.flush();
        assertEquals(0, perlPoolManager.getPoolSize());

        System.out.println("Test 12 completed.");
        System.out.flush();
    }

    private static void sleep(long sleep)
    {
        try
        {
        	if (sleep <= 3000)
        	{
        		Thread.sleep(sleep);
        	}
        	else
        	{
        		while (sleep > 0)
        		{
    				System.out.print(".");
        			if (sleep > 1000)
        			{
        				Thread.sleep(1000);
        				sleep -= 1000;
        			}
        			else
        			{
        				Thread.sleep(sleep);
        				System.out.print("\n");
        				sleep = 0;
        			}
        		}
        	}
        }
        catch (InterruptedException e)
        {
        }
    }
}
