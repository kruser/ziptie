package org.ziptie.server.dispatcher;

import java.util.ArrayList;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import junit.textui.TestRunner;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.ziptie.server.dispatcher.BatchStatus;
import org.ziptie.server.dispatcher.ITask;
import org.ziptie.server.dispatcher.ITaskListener;
import org.ziptie.server.dispatcher.OperationManager;
import org.ziptie.server.dispatcher.OperationManagerStatus;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.dispatcher.TaskCompleteEvent;
import org.ziptie.server.dispatcher.TaskEvent;

/**
 * @author chamlett
 */
public class OperationManagerUnitTest extends TestCase
{
    private static Logger DEV_LOG;
    
    /** The number of <i>nanoseconds</i> to spend doing work. It's annoying to work with nanoseconds, but necessary if we're doing a lot of tasks */
    private static final long DEFAULT_TASK_TIME = 0;

    /** For a test with multiple batches, the number of batches to submit */
    private static int batchCount = 200;

    /** For each batch, the number of jobs to execute */
    private static int jobCount = 50;

    /** The total number of jobs run for all tests */
    private static long jobsRun;
    
    /** The time this class is loaded, in msec */
    private static long testStart;

    /** The <code>OperationManager</code> we're testing */
    private static OperationManager jobManager;

    static
    {
        BasicConfigurator.configure();
        DEV_LOG = Logger.getLogger(OperationManagerUnitTest.class);
        jobManager = new OperationManager();
        testStart = System.currentTimeMillis();
    }
    
    // ----------------------------------------------------------------
    //                   P U B L I C   M E T H O D S
    // ----------------------------------------------------------------

    /**
     * By default, it runs the suit() 300 times, alternating between the default number of worker threads, 1 worker thread, and 20 worker threads.
     * 
     * @param args Ignored
     */
    public static void main(String[] args)
    {
        DEV_LOG.debug("OperationManagerUnitTest starting");
        int defaultCount = jobManager.getMaxThreadCount();
        final int total = batchCount;
        for (jobCount = 1; jobCount < total; jobCount++) 
        {
            batchCount = total - jobCount;
            
            DEV_LOG.debug("Batches: " + batchCount + " jobs " + jobCount);
            DEV_LOG.debug("Normal run ");
            TestRunner.run(suite());
            DEV_LOG.debug("Single thread run");
            jobManager.setMaxThreadCount(1);
            TestRunner.run(suite());
            DEV_LOG.debug("20 thread run");
            jobManager.setMaxThreadCount(20);
            TestRunner.run(suite());
            jobManager.setMaxThreadCount(defaultCount);
        }
    }

    /**
     * @return <code>new TestSuite(OperationManagerUnitTest.class)</code>
     */
    public static Test suite()
    {
        return new TestSuite(OperationManagerUnitTest.class);
    }

    /**
     * Overloaded but currently does nothing.
     */
    public void setUp()
    {
    }

    /**
     * Calls <code>OperationManager.shutdown()</code>
     */
    public void tearDown()
    {
        jobManager.shutdown();
    }
    
    /**
     * Test a single sequential batch. Test verifies that all jobs complete and that they do so in order.
     */
    public void testOneSequential()
    {
        ArrayList<ITask> al = new ArrayList<ITask>(jobCount);
        for (int i = 0; i < jobCount; i++)
        {
            al.add(new BasicTask(i));
        }

        SequentialListener listener = new SequentialListener(al.size());
        jobManager.submitJobs(al, true, listener);

        listener.sleepUntilDone();
        assertTrue(listener.isSuccess());
    }

    /**
     * Test multiple simultaneous batches. Test verifies that all batches complete and that the
     * tasks in each batch complete in order.
     */
    public void testMultipleSequential()
    {
        ArrayList<SequentialListener> al = new ArrayList<SequentialListener>(batchCount);
        for (int i = 0; i < batchCount; i++)
        {
            al.add(new SequentialListener(jobCount));
        }

        for (SequentialListener sl : al)
        {
            ArrayList<ITask> tasks = new ArrayList<ITask>(jobCount);
            for (int i = 0; i < jobCount; i++)
            {
                tasks.add(new BasicTask(i));
            }

            jobManager.submitJobs(tasks, true, sl);
        }

        for (SequentialListener sl : al)
        {
            sl.sleepUntilDone();
            assertTrue(sl.isSuccess());
        }
    }

    /**
     * Test a single non-sequential batch. Test makes sure all tasks in that batch complete.
     */
    public void testOneNonSequential()
    {
        ArrayList<ITask> al = new ArrayList<ITask>(jobCount);
        for (int i = 0; i < jobCount; i++)
        {
            al.add(new BasicTask(i));
        }

        CountingListener listener = new CountingListener(al.size());
        jobManager.submitJobs(al, false, listener);

        listener.sleepUntilDone();
        assertTrue(listener.isSuccess());
    }

    /**
     * Test multiple non-sequential batches. Test makes sure all tasks in all batches complete.
     */
    public void testMultipleNonSequential()
    {
        ArrayList<CountingListener> al = new ArrayList<CountingListener>(batchCount);
        for (int i = 0; i < batchCount; i++)
        {
            al.add(new CountingListener(jobCount));
        }

        for (CountingListener nsl : al)
        {
            ArrayList<ITask> tasks = new ArrayList<ITask>(jobCount);
            for (int i = 0; i < jobCount; i++)
            {
                tasks.add(new BasicTask(i));
            }

            jobManager.submitJobs(tasks, true, nsl);
        }
        for (CountingListener nsl : al)
        {
            nsl.sleepUntilDone();
            assertTrue(nsl.isSuccess());
        }
    }

    /**
     * Test and make sure auto-cancellation is working when the <code>OperationManager</code> has to kill long-running threads. In this test case, we define
     * 'long-running' as 'more than 1 second'.
     */
    public void testAutoCancel()
    {
        int cancelTime = jobManager.getAutoCancelTime();

        // Set the manager to autocancel in 1 second
        jobManager.setAutoCancelTime(1000);

        // Add some tasks that take 10 seconds
        ArrayList<ITask> al = new ArrayList<ITask>(10);
        for (int i = 0; i < 10; i++)
        {
            al.add(new BasicTask(i, 10000000000L));
        }

        // Wait for them to be cancelled
        CancelListener listener = new CancelListener(al.size());
        jobManager.submitJobs(al, false, listener);

        listener.sleepUntilDone();

        // Reset the manager's cancel time
        jobManager.setAutoCancelTime(cancelTime);

        assertTrue(listener.isSuccess());
    }

    /**
     * This test tries three bad things: first, it runs a sequential batch and in the listener tries to resubmit a bad job (the previous one rather than the
     * current one). Second, it runs a sequential batch and tries to resubmit a completely nonexistent job. Third, it resubmits with a bogus batch ID.
     */
    public void testBadResubmission()
    {
        // Test resubmitting the wrong one in a sequential task
        ArrayList<ITask> al = new ArrayList<ITask>(jobCount);
        for (int i = 0; i < jobCount; i++)
        {
            al.add(new BasicTask(i));
        }

        BadResubmitListener listener = new BadResubmitListener(al.size(), 0);
        jobManager.submitJobs(al, true, listener);

        listener.sleepUntilDone();
        assertTrue(listener.isSuccess());

        // Test resubmitting a completely bogus task
        listener = new BadResubmitListener(al.size(), 1);
        jobManager.submitJobs(al, true, listener);

        listener.sleepUntilDone();
        assertTrue(listener.isSuccess());

        // Test resubmitting a task on a bogus batch
        listener = new BadResubmitListener(al.size(), 2);
        jobManager.submitJobs(al, true, listener);

        listener.sleepUntilDone();
        assertTrue(listener.isSuccess());
    }

    /**
     * Test a non-sequential task switching. It creates a simple task and the listener resubmits it with a different task.
     */
    public void testNonSequentialTaskSwitch()
    {
        TaskSwitchListener tsl = new TaskSwitchListener(5);
        ArrayList<ITask> tasks = new ArrayList<ITask>(5);
        for (int i = 0; i < 5; i++)
        {
            tasks.add(new BasicTask(1));
        }

        // First try non-sequential
        jobManager.submitJobs(tasks, false, tsl);

        tsl.sleepUntilDone();
        assertTrue(tsl.isSuccess());
    }

    /**
     * Test sequential task switching. It creates simple tasks and the listener switches them when notified.
     */
    public void testSequentialTaskSwitch()
    {
        TaskSwitchListener tsl = new TaskSwitchListener(5);
        ArrayList<ITask> tasks = new ArrayList<ITask>(5);
        for (int i = 0; i < 5; i++)
        {
            tasks.add(new BasicTask(1));
        }

        jobManager.submitJobs(tasks, true, tsl);

        tsl.sleepUntilDone();
        assertTrue(tsl.isSuccess());
    }

    /**
     * Test all of the possible outcomes from an <code>ITask.execute()</code>
     */
    public void testReturnValues()
    {
        ArrayList<ITask> tasks = new ArrayList<ITask>(Outcome.values().length);

        for (Outcome outcome : Outcome.values())
        {
            tasks.add(new OutcomeTask(outcome));
        }

        OutcomeListener ol = new OutcomeListener(tasks.size());
        jobManager.submitJobs(tasks, false, ol);

        ol.sleepUntilDone();
        assertTrue(ol.isSuccess());
    }

    /**
     * Try to cancel a non-existent batch
     */
    public void testCancelNonexistentBatch()
    {
        jobManager.cancelJobs(Integer.MAX_VALUE);
    }

    /**
     * Run a variety of sequential batches with differing run times and batch lengths to try and exercise code in the <code>RoundRobinScheduler</code> that
     * may not otherwise get excercised (specifically, the case of removeByKeyIndex() where the removed batch is lower in the index than the next batch to be
     * run).
     * <p>
     * Batches will be in a stairstep fashion, where the batch added first will run quickly, the next slightly longer, continuing to increase to a maximum at
     * the middle batch added and then with decreasing run times until the final batch.
     */
    public void testStairStep()
    {
        ArrayList<CountingListener> al = new ArrayList<CountingListener>(10);
        for (int i = 0; i < 10; i++)
        {
            al.add(new CountingListener(5));
        }

        int min = 100;
        int max = 10000;
        int mid = al.size() / 2;
        for (int i = 0; i < al.size(); i++)
        {
            long time = max - (max - min) * Math.abs((mid - i)) / min;

            ArrayList<ITask> tasks = new ArrayList<ITask>(5);
            for (int j = 0; j < 5; j++)
            {
                tasks.add(new BasicTask(j, time));
            }

            jobManager.submitJobs(tasks, false, al.get(i));
        }

        for (CountingListener sl : al)
        {
            sl.sleepUntilDone();
            if (!sl.isSuccess())
            {
                DEV_LOG.debug("Stair step failed: " + sl);
            }
            assertTrue(sl.isSuccess());
        }
    }

    /**
     * A test to make sure the manager honors our thread count requests
     */
    public void testChangeThreadCount()
    {
        int start = jobManager.getMaxThreadCount();

        // Give it a batch of 1000 tasks that will take 30 seconds to run total. That's 0.3 seconds per task, times the max number of threads.
        ArrayList<ITask> tasks = new ArrayList<ITask>(1000);
        for (int i = 0; i < 1000; i++)
        {
            tasks.add(new BasicTask(i, 300000000L));
        }

        Integer id = jobManager.submitJobs(tasks, false, null);

        // Wait for the job to start
        try
        {
            Thread.sleep(1000);
        }
        catch (InterruptedException ie)
        {
            return;
        }

        // Try increasing the max thread count
        jobManager.setMaxThreadCount(start + 4);

        int i = 0;
        for (i = 0; i < 100; i++)
        {
            if (jobManager.getThreadCount() > start + 4)
            {
                assertTrue(false);
            }

            if (jobManager.getThreadCount() == start + 4)
            {
                break;
            }

            try
            {
                Thread.sleep(10);
            }
            catch (InterruptedException ie)
            {
                return;
            }
        }

        if (i >= 100)
        {
            DEV_LOG.debug("Failed to set thread count up to " + (start + 4) + "; ended at " + jobManager.getThreadCount());
        }

        assertTrue(i < 100);

        // Now try decreasing it back to normal
        jobManager.setMaxThreadCount(start);

        try
        {
            Thread.sleep(1000);
        }
        catch (InterruptedException ie)
        {
            return;
        }

        if (jobManager.getThreadCount() > start)
        {
            DEV_LOG.debug("Failed to reset thread count to " + start + " ended at " + jobManager.getThreadCount());
        }

        assertTrue(jobManager.getThreadCount() <= start);

        // Cancel our job
        jobManager.cancelJobs(id);
    }

    /**
     * Test to make sure tasks are executed in round-robin order. It uses sequential batches with tasks that all lock on the same object to avoid timing
     * problems, although alternatively it could limit the <code>OperationManager</code> to a single thread.
     * <p>
     * Test verifies that all tasks complete, and that batches are serviced in round-robin order. Because the <code>OperationManager</code> could start executing
     * batches before we are finished adding them, the test is not an exact one.
     * <p>
     * Note: it is not safe to run this test while any other batches are in the OperationManager.
     */
    public void testRoundRobin()
    {
        final int TASK_COUNT = 5;
        final int SEQUENCE_COUNT = 10;
        RoundRobinListener rrl = new RoundRobinListener(TASK_COUNT, SEQUENCE_COUNT);

        for (int i = 0; i < SEQUENCE_COUNT; i++)
        {
            ArrayList<ITask> tasks = new ArrayList<ITask>(TASK_COUNT);

            for (int j = 0; j < TASK_COUNT; j++)
            {
                tasks.add(new RoundRobinTask());
            }

            jobManager.submitJobs(tasks, true, rrl);
        }

        DEV_LOG.debug("Manager status is " + jobManager.getStatus());

        rrl.sleepUntilDone();
        assertTrue(rrl.isSuccess());
    }

    /**
     * Test resubmission of tasks to a <code>OperationManager</code>. Test verifies that every task runs three times, and that all tasks complete successfully. All
     * tests are on non-sequential batches.
     */
    public void testMultipleNonSequentialResubmit()
    {
        ArrayList<ResubmitListener> al = new ArrayList<ResubmitListener>(batchCount);
        for (int i = 0; i < batchCount; i++)
        {
            al.add(new ResubmitListener(jobCount, 3));
        }

        for (ResubmitListener nsl : al)
        {
            ArrayList<ITask> tasks = new ArrayList<ITask>(jobCount);
            for (int i = 0; i < jobCount; i++)
            {
                tasks.add(new ResubmitTask());
            }

            jobManager.submitJobs(tasks, false, nsl);
        }
        for (ResubmitListener nsl : al)
        {
            nsl.sleepUntilDone();
            assertTrue(nsl.isSuccess());
        }
    }

    /**
     * Test resubmission of tasks to a <code>OperationManager</code>. Test verifies that every task runs three times, and that all tasks complete successfully. All
     * tests are on sequential batches.
     */
    public void testMultipleSequentialResubmit()
    {
        ArrayList<ResubmitListener> al = new ArrayList<ResubmitListener>(batchCount);
        for (int i = 0; i < batchCount; i++)
        {
            al.add(new ResubmitListener(jobCount, 3));
        }

        for (ResubmitListener nsl : al)
        {
            ArrayList<ITask> tasks = new ArrayList<ITask>(jobCount);
            for (int i = 0; i < jobCount; i++)
            {
                tasks.add(new ResubmitTask());
            }

            jobManager.submitJobs(tasks, true, nsl);
        }

        for (ResubmitListener nsl : al)
        {
            nsl.sleepUntilDone();
            assertTrue(nsl.isSuccess());
        }
    }

    /**
     * Test to make sure the OperationManager can handle bad tasks. Each task throws a NullPointerException when it runs.
     */
    public void testMultipleException()
    {
        ArrayList<ExceptionListener> al = new ArrayList<ExceptionListener>(batchCount);
        for (int i = 0; i < batchCount; i++)
        {
            al.add(new ExceptionListener(jobCount));
        }

        for (ExceptionListener nsl : al)
        {
            ArrayList<ITask> tasks = new ArrayList<ITask>(jobCount);
            for (int i = 0; i < jobCount; i++)
            {
                tasks.add(new ExceptionTask());
            }

            jobManager.submitJobs(tasks, true, nsl);
        }

        for (ExceptionListener nsl : al)
        {
            nsl.sleepUntilDone();
            assertTrue(nsl.isSuccess());
        }
    }

    /**
     * Test a listener that throws an exception in its callback
     */
    public void testBadListener()
    {
        ArrayList<ITask> tasks = new ArrayList<ITask>(1);
        tasks.add(new BasicTask(0));
        jobManager.submitJobs(tasks, false, new BadListener(1));
    }

    /**
     * Test the behavior of evil tasks that never complete and ignore any attempt to interrupt them. The test then cancels the submitted tasks as they will
     * never end on their own.
     * <p>
     * Test verifies that all submitted jobs result in cancel notifications
     * <p>
     * Note: this will leave a number of threads running that will ordinarily never end. We cheat in the task, though, and exit once the name of the thread has
     * been changed to start with ZOMBIE--this indicates that the OperationManager has given up on it. We do this to prevent overloading the host OS with threads
     * during multiple executions of the test suite.
     */
    public void testEvil()
    {
        ArrayList<ITask> al = new ArrayList<ITask>(jobCount);
        for (int i = 0; i < jobCount; i++)
        {
            al.add(new EvilTask());
        }

        EvilListener el = new EvilListener(jobCount);
        Integer id = jobManager.submitJobs(al, false, el);
        try
        {
            Thread.sleep(1000);
        }
        catch (Exception ex)
        {
        }

        jobManager.cancelJobs(id);

        el.sleepUntilDone();

        // Now test to make sure we can still submit jobs
        testOneNonSequential();
    }
    
    /**
     * A test that will make sure the OperationManager eventually zombie-fies undending threads.  This requires us to bump the autoCancelTime way down and 
     * run an EvilTask; once it's made into a zombie the task will end.
     */
    public void testZombie() 
    {
        int defaultTime = jobManager.getAutoCancelTime();
        jobManager.setAutoCancelTime(100);
        ArrayList<ITask> tasks = new ArrayList<ITask>(1);
        tasks.add(new EvilTask());

        CancelListener cl = new CancelListener(tasks.size());
        jobManager.submitJobs(tasks, false, cl);
        
        cl.sleepUntilDone();
        
        jobManager.setAutoCancelTime(defaultTime);
        
        assertTrue(cl.isSuccess());
    }

    /**
     * Test submitting tasks from multiple threads simultaneously. It will create 10 threads; 5 will call <code>testMultipleSequential()</code> and 5 will
     * call <code>testMultipleNonSequential()</code>. It will then wait for all 10 threads to complete.
     */
    public void testMultiThreaded()
    {
        Thread threads[] = new Thread[10];

        for (int i = 0; i < threads.length; i++)
        {
            if ((i % 2) == 0)
            {
                threads[i] = new Thread()
                {
                    public void run()
                    {
                        testMultipleNonSequential();
                    }
                };
            }
            else
            {
                threads[i] = new Thread()
                {
                    public void run()
                    {
                        testMultipleSequential();
                    }
                };
            }
        }

        for (int i = 0; i < threads.length; i++)
        {
            threads[i].start();
        }

        for (int i = 0; i < threads.length; i++)
        {
            try
            {
                threads[i].join();
            }
            catch (InterruptedException ie)
            {
                break;
            }
        }
    }

    /**
     * Run a huge test. This test will create a monitor thread that periodically polls and prints the OperationManager's status, and then call testMultiThreaded()
     * a bunch of times.
     */
    public void testHuge()
    {
        Thread thread = new Thread(new Runnable()
        {
            public void run()
            {
                while (true)
                {
                    try
                    {
                        Thread.sleep(5000);
                    }
                    catch (InterruptedException ie)
                    {
                        return;
                    }

                    OperationManagerStatus jms = jobManager.getStatus();
                    int[] iTotal = new int[3];
                    for (BatchStatus bs : jms.getBatchStatuses())
                    {
                        iTotal[0] += bs.getUnstartedCount();
                        iTotal[1] += bs.getRunningCount();
                        iTotal[2] += bs.getCompletedCount();
                    }

                    long l = System.currentTimeMillis() - testStart;
                    String str = (l > 0) ? "" + (jobsRun / l) : "-";
                    DEV_LOG.debug("Status: " + iTotal[0] + " unstarted; " + iTotal[1] + " running; " + iTotal[2] + " completed; " + str + "/msec");
                }
            }
        });

        thread.start();

        for (int i = 0; i < 50; i++)
        {
            testMultiThreaded();
        }

        for (int i = 0; i < 10; i++)
        {
            try
            {
                thread.interrupt();
                thread.join(100);
            }
            catch (InterruptedException ie)
            {
                break;
            }
        }

        DEV_LOG.debug("At end, manager status is: " + jobManager.getStatus());
    }

    /**
     * A simple task that takes an externally defined ID and a time to sleep, in nanoseconds.
     * When it runs, it simply sleeps for the defined period of time and then exits.
     */
    private class BasicTask implements ITask
    {
        private long sleepTime;

        private int id;

        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------        
        
        /**
         * Constructor allowing the specification of an ID and sleep time
         * @param id the ID of the task; not used internally, but is accessible
         * @param sleepTime the period of time to sleep in <i>nanoseconds</i>
         */
        BasicTask(int id, long sleepTime)
        {
            this.id = id;
            this.sleepTime = sleepTime;
        }

        /**
         * Same as <code>this(id, DEFAULT_TASK_TIME)</code>;
         * 
         * @param id The ID of the task
         */
        BasicTask(int id)
        {
            this(id, DEFAULT_TASK_TIME);
        }

        /**
         * Same as <code>this(0, DEFAULT_TASK_TIME)</code>;
         */
        BasicTask()
        {
            this(0, DEFAULT_TASK_TIME);
        }

        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------
        
        /**
         * @see ITask#getLockObject()
         * @return null
         */
        public Object getLockObject()
        {
            return null;
        }

        /**
         * Sleeps for the tasks defined number of nanoseconds, then returns <code>Outcome.SUCCESS</code>
         * @see ITask#execute()
         * @return Outcome.SUCCESS, unless cancelled by the <code>OperationManager</code>
         */
        public Outcome execute()
        {
            jobsRun++;
            if (sleepTime < 1)
            {
                return Outcome.SUCCESS;
            }

            try
            {
                Thread.sleep(sleepTime / 1000000L, (int) (sleepTime % 1000000));
            }
            catch (InterruptedException ie)
            {
            }
            /*
             * long end = System.nanoTime() + sleepTime; int i = 0, j = 1; while (System.nanoTime() <= end) { i++; j *= 2; }
             */

            return Outcome.SUCCESS;
        }        
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return The ID originally specified in the constructor, or zero if none were provided.
         */
        int getID()
        {
            return id;
        }
    }

    /**
     * A listener that simply counts the number of times it is called.  When constructed the expected number of
     * calls should be provided.
     */
    private class CountingListener implements ITaskListener
    {
        protected int expectedCount;

        protected int outcomes[] = new int[Outcome.values().length];

        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------
        
        /**
         * @param expectedCount The number of times this listener should be called before the code is complete.
         */
        CountingListener(int expectedCount)
        {
            this.expectedCount = expectedCount;
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @see ITaskListener#eventOccurred(TaskEvent)
         * @param event the TaskEvent
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            if (!(event instanceof TaskCompleteEvent))
            {
                return;
            }

            TaskCompleteEvent tce = (TaskCompleteEvent) event;
            outcomes[tce.getOutcome().ordinal()]++;
        }
        
//        /**
//         * @see java.lang.Object#toString()
//         * @return a String listing all of the possible outcomes and the count of how many times each occurred on a single line
//         */
//        public synchronized String toString()
//        {
//            String str = "";
//            for (Outcome outcome : Outcome.values())
//            {
//                str += outcome + ": " + outcomes[outcome.ordinal()] + " ";
//            }
//            return str;
//        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return true when the listener has been called the number of times specified in the constructor.
         */
        synchronized boolean isDone()
        {
            int total = 0;
            for (int i = 0; i < outcomes.length; i++)
            {
                total += outcomes[i];
            }

            return total == expectedCount;
        }

        /**
         * @return true if every <code>TaskCompleteEvent</code> provided to the <code>eventOccurred()</code> method had a status of <code>Outcome.SUCCESS</code>
         */
        synchronized boolean isSuccess()
        {
            return outcomes[Outcome.SUCCESS.ordinal()] == expectedCount;
        }

        /**
         * Calling this method will cause the calling thread to go to sleep until isDone() is true.
         */
        void sleepUntilDone()
        {
            while (!isDone())
            {
                try
                {
                    Thread.sleep(100);
                }
                catch (InterruptedException ie)
                {
                    break;
                }
            }
        }
    }

    /**
     * A listener that verifies all of the tasks are completed sequentially. It requires that the tasks used extend BasicTask and that getID() for each return
     * an integer starting at zero and increasing by one for each task in order.
     */
    private class SequentialListener extends CountingListener
    {
        private boolean success = true;

        private int nextID;
        
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------

        /**
         * A constructor providing the number of times this listener should be called
         * @param expectedCount The expected number of times it will be called.
         */
        SequentialListener(int expectedCount)
        {
            super(expectedCount);
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Checks to make sure the listener is called sequentially--that is, the ID of each task monotonically increases.
         * @see ITaskListener#eventOccurred(TaskEvent)
         * @param event The event
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);
            BasicTask task = (BasicTask) event.getTask();
            if (task.getID() != nextID++)
            {
                DEV_LOG.debug("SequentialListener:  expected " + (nextID - 1) + " but got " + task.getID());
                success = false;
            }
        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return true if all of the tasks executed in order and all of them succeeded. 
         * @see OperationManagerUnitTest.CountingListener#isSuccess()
         */
        synchronized boolean isSuccess()
        {
            return success && super.isSuccess();
        }
    }

    /**
     * A RoundRobinTask is simply a BasicTask that implements the same lock object for all tasks.
     */
    private class RoundRobinTask extends BasicTask
    {
        /**
         * @return Boolean.TRUE
         * @see ITask#getLockObject()
         */
        public Object getLockObject()
        {
            return Boolean.TRUE;
        }
    }

    /**
     * A listener that verifies that batches are executed in order. It is intended to be a listener for multiple
     * sequential batches, each with the same number of jobs, each locking on the same object.
     */
    private class RoundRobinListener extends CountingListener
    {
        private boolean success = true;

        private int nextBatch;

        private int expectedJobs;

        private ArrayList<int[]> counts = new ArrayList<int[]>();
        
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------

        /**
         * @param expectedJobs The number of jobs per batch
         * @param batchCount The number of batches total
         */
        RoundRobinListener(int expectedJobs, int batchCount)
        {
            super(expectedJobs * batchCount);
            this.expectedJobs = expectedJobs;
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Handle the notification that an event has occurred. If it is a <code>TaskCompleteEvent</code>, the
         * listener will verify that it is the next batch that was expected to execute if the
         * <code>OperationManager</code> is truly processing batches in round robin order.
         * 
         * @param event a <code>TaskCompleteEvent</code>
         * @see ITaskListener#eventOccurred(TaskEvent)
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);

            // DEV_LOG.debug("Expecting index " + nextBatch);

            int i = 0;
            int ref[] = null;
            int maxID = -1;
            for (i = 0; i < counts.size(); i++)
            {
                ref = counts.get(i);
                if (i == 0 || ref[0] > maxID)
                {
                    maxID = ref[0];
                }

                if (ref[0] == event.getBatchID())
                {
                    break;
                }
            }

            if (i >= counts.size())
            {
                ref = new int[2];
                ref[0] = event.getBatchID();
                ref[1] = 0;
                counts.add(ref);

                // Make sure this has a higher ID than anything in the list
                if (event.getBatchID() < maxID)
                {
                    DEV_LOG.debug("Internal error:  new batch with lower ID than one already in the list" + ref[0] + " < " + maxID);
                }
            }
            else
            {
                if (nextBatch >= counts.size())
                {
                    nextBatch = 0;
                }
            }

            // DEV_LOG.debug("\tgot index " + i + " of " + counts.size() + " batch " + ref[0] + " count " + (ref[1]+1) + " expecting " + nextBatch);

            if (i != nextBatch)
            {
                // DEV_LOG.debug("\twrong index: " + i + " vs " + nextBatch);
                nextBatch = i;
                success = false;
            }

            if (++ref[1] >= expectedJobs)
            {
                counts.remove(i);
                nextBatch--;
            }
            nextBatch++;
        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return true if batches were always executed in round-robin order and all
         *    tasks completed successfully.
         * @see OperationManagerUnitTest.CountingListener#isSuccess()
         */
        synchronized boolean isSuccess()
        {
            return success && super.isSuccess();
        }
    }

    /**
     * A class intended to verify that tasks can be cancelled.  It will only be successful
     * if all tasks return <code>Outcome.CANCELLED</code>
     */
    private class CancelListener extends CountingListener
    {
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------
        
        /**
         * @param expectedCount The expected number of tasks
         */
        CancelListener(int expectedCount)
        {
            super(expectedCount);
        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return true if every task ended with <code>Outcome.CANCELLED</code>
         * @see OperationManagerUnitTest.CountingListener#isSuccess()
         */
        synchronized boolean isSuccess()
        {
            return outcomes[Outcome.CANCELLED.ordinal()] == expectedCount;
        }
    }
    /**
     * A BasicTask that throws a NullPointerException when executing
     */
    private class ExceptionTask extends BasicTask
    {
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------
        
        /**
         * @return This should never return, it should instead raise a NullPointerException.
         * @see ITask#execute()
         */
        public Outcome execute()
        {
            Integer i = null;
            i.intValue();
            return Outcome.SUCCESS;
        }
    }

    /**
     * A listener that verifies that all tasks end with an exception.
     */
    private class ExceptionListener extends CountingListener
    {
        private boolean success = true;

        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------
        
        /**
         * @param expectedCount The expected number of tasks
         */
        ExceptionListener(int expectedCount)
        {
            super(expectedCount);
        }

        /**
         * @param event a <code>TaskCompleteEvent</code>
         * @see ITaskListener#eventOccurred(TaskEvent)
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);
            TaskCompleteEvent tce = (TaskCompleteEvent) event;
            if (tce.getThrowable() == null || !(tce.getThrowable() instanceof NullPointerException))
            {
                success = false;
            }
        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return true if all expected tasks return <code>Outcome.EXCEPTION</code>
         * @see OperationManagerUnitTest.CountingListener#isSuccess()
         */
        synchronized boolean isSuccess()
        {
            return success && outcomes[Outcome.EXCEPTION.ordinal()] == expectedCount;
        }
    }

    /**
     * A BasicTask that keeps track of how many times its been resubmitted.
     */
    private class ResubmitTask extends BasicTask
    {
        private int resubmissions;
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return the number of resubmissions so far
         */
        int getResubmissions()
        {
            return resubmissions;
        }

        /**
         * Increment the number of resubmission so far
         */
        void incResubmissions()
        {
            resubmissions++;
        }
    }

    /**
     * A class responsible for resubmitting tasks as they end.
     */
    private class ResubmitListener extends CountingListener
    {
        private int resubmits;
        
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------

        /**
         * @param expectedCount The number of tasks originally submitted
         * @param resubmits The number of times they should be resubmitted after the first run.
         */
        ResubmitListener(int expectedCount, int resubmits)
        {
            super(expectedCount * (resubmits + 1));
            this.resubmits = resubmits;
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Each time this method is called when a task completes, the listener will resubmit
         * it if it has not yet been submitted the number of times specified in the listener's
         * constructor.
         * 
         * @param event A <code>TaskCompleteEvent</code>
         * @see ITaskListener#eventOccurred(TaskEvent)
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);
            ResubmitTask rt = (ResubmitTask) event.getTask();
            if (rt.getResubmissions() < resubmits)
            {
                rt.incResubmissions();
                // DEV_LOG.debug(event.getBatchID() + "-" + event.getJobID() + " up to " + rt.getResubmissions() + " of " + resubmits);
                jobManager.resubmitJob(event.getBatchID(), event.getJobID(), null);
            }
        }
    }

    /**
     * A listener that attempts bad resubmissions
     */
    private class BadResubmitListener extends SequentialListener
    {
        private int badLevel;

        private boolean success = true;
        
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------

        /**
         * This constructor allows the specification of how many tasks will notify this listener,
         * and what bad thing to do when that notification is received:
         * <p>
         * <li>0: resubmit the previous job
         * <li>1: resubmit a nonexistent job
         * <li>2: resubmit a nonexistent batch
         * <p> 
         * @param expectedCount The expected number of tasks to recieve notifications about
         * @param badLevel What incorrect behavior to take when the task completes.
         */
        BadResubmitListener(int expectedCount, int badLevel)
        {
            super(expectedCount);
            this.badLevel = badLevel;
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Attempts to resubmit a job in an illegal fashion upon notification.
         * 
         * @param event a <code>TaskCompleteEvent</code>
         * @see ITaskListener#eventOccurred(TaskEvent)
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);

            Integer batchID = event.getBatchID();
            Integer jobID = event.getJobID();
            switch (badLevel)
            {
            case 0:
                jobID--;
                break;
            case 1:
                jobID = expectedCount + 1;
                break;
            case 2:
                batchID = Integer.MAX_VALUE;
                break;
            }
            if (jobManager.resubmitJob(batchID, jobID, null))
            {
                success = false;
            }
        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return true if all tasks completed successfully and none of the illegal
         *    resubmissions succeeded.
         * @see OperationManagerUnitTest.CountingListener#isSuccess()
         */
        synchronized boolean isSuccess()
        {
            return success && super.isSuccess();
        }
    }

    /**
     * An evil task that runs forever and ignores any attempt to interrupt them.
     */
    private class EvilTask extends BasicTask
    {
        /**
         * @return Returns Outcome.SUCCESS once the executing thread has a name starting
         *    with "ZOMBIE". However, long before then any listener will have
         *    received an <code>Outcome.CANCELLED</code> notification when the OperationManager
         *    is forced to end the task.
         * @see ITask#execute()
         */
        public Outcome execute()
        {
            while (true)
            {
                try
                {
                    Thread.sleep(100);
                    // Give the scheduler a break, so our long-running
                    // tasks don't really live forever.
                    if (Thread.currentThread().getName().startsWith("ZOMBIE"))
                    {
                        break;
                    }
                }
                catch (InterruptedException ie)
                {
                }
            }
            return Outcome.SUCCESS;
        }
    }

    /**
     * A class that listens for <code>EvilTask</code> completion
     */
    private class EvilListener extends CountingListener
    {
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------
        
        /**
         * @param expectedCount the expected number of evil tasks.
         */
        EvilListener(int expectedCount)
        {
            super(expectedCount);
        }
    }

    /**
     * A poorly implemented listener
     */
    private class BadListener extends CountingListener
    {
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------
        
        /**
         * @param expectedCount The expected number of tasks
         */
        BadListener(int expectedCount)
        {
            super(expectedCount);
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * When notified, this listener will throw a NullPointerException
         * 
         * @param event a <code>TaskCompleteEvent</code>
         * @see ITaskListener#eventOccurred(TaskEvent)
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);
            // DEV_LOG.debug("Before throwing the exception, manager is " + jobManager.getStatus());
            Integer test = null;
            test.intValue();
        }
    }

    /**
     * A listener that attempts to resubmit jobs with a new task.  Each task will be resubmitted
     * 5 times with new tasks 
     */
    private class TaskSwitchListener extends CountingListener
    {
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------
        
        /**
         * @param expectedCount The expected number of tasks.
         */
        TaskSwitchListener(int expectedCount)
        {
            super(5 * expectedCount);
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * When called, this listener will resubmit the job with a new Task.
         * 
         * @param event a <code>TaskCompleteEvent</code>
         * @see ITaskListener#eventOccurred(TaskEvent)
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);
            BasicTask bt = (BasicTask) event.getTask();

            int id = bt.getID();

            if (id < 5)
            {
                jobManager.resubmitJob(event.getBatchID(), event.getJobID(), new BasicTask(id + 1));
            }
        }
    }

    /**
     * A task that will return an outcome specified in the constructor.
     */
    private class OutcomeTask extends BasicTask
    {
        private Outcome expectedOutcome;
        
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------

        /**
         * @param expectedOutcome The outcome the task should return after <code>execute()</code>
         */
        OutcomeTask(Outcome expectedOutcome)
        {
            this.expectedOutcome = expectedOutcome;
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Simply returns the outcome provided when the task was constructed.
         * @see ITask#execute()
         * @return the original outcome
         */
        public Outcome execute()
        {
            return expectedOutcome;
        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Get the expected outcome provided when the task was constructed
         * @return the original outcome.
         */
        Outcome getExpectedOutcome()
        {
            return expectedOutcome;
        }
    }

    /**
     * A class that verifies that <code>OutcomeTasks</code> produce notifications consistent
     * with their specified outcomes.
     */
    private class OutcomeListener extends CountingListener
    {
        private boolean success = true;
        
        // ----------------------------------------------------------------
        //                    C O N S T R U C T O R S
        // ----------------------------------------------------------------

        /**
         * @param expectedCount the expected number of outcome tasks
         */
        OutcomeListener(int expectedCount)
        {
            super(expectedCount);
        }
        
        // ----------------------------------------------------------------
        //                   P U B L I C   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * Notification when an event occurred.  Note that the event <i>must</i> be a 
         * <code>TaskCompleteEvent</code>, and its task <i>must</i> be an <code>OutcomeTask</code>
         *
         * @param event a <code>TaskCompleteEvent</code>
         * @see ITaskListener#eventOccurred(TaskEvent)
         */
        public synchronized void eventOccurred(TaskEvent event)
        {
            super.eventOccurred(event);
            OutcomeTask bt = (OutcomeTask) event.getTask();

            TaskCompleteEvent tce = (TaskCompleteEvent) event;

            if (!bt.getExpectedOutcome().equals(tce.getOutcome()))
            {
                success = false;
            }
        }
        
        // ----------------------------------------------------------------
        //                   P A C K A G E   M E T H O D S
        // ----------------------------------------------------------------

        /**
         * @return true if every <code>OutcomeTask</code> completed with its expected outcome.
         * @see OperationManagerUnitTest.CountingListener#isSuccess()
         */
        synchronized boolean isSuccess()
        {
            return success;
        }
    }
}
