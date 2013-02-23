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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.discovery;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Singleton class that periodically monitors the {@link DiscoveryEngine} and
 * posts JMS alerts when there are updates to the {@link DiscoveryStatus}
 * object.
 * 
 * @author rkruse
 */
public abstract class AbstractBaseStatsMonitor
{
    private static final int DEFAULT_INTERVAL = 2;
    private DiscoveryEngine discoveryEngine;
    private DiscoveryStatus latestDiscoveryStatus;
    private ScheduledExecutorService monitorThread;

    /**
     * Private constructor
     */
    protected AbstractBaseStatsMonitor()
    {
        discoveryEngine = DiscoveryEngine.getInstance();
        latestDiscoveryStatus = discoveryEngine.getStatistics();

        // schedule future runs
        monitorThread = Executors.newSingleThreadScheduledExecutor();
        int delay = getPollingCycle();
        monitorThread.scheduleWithFixedDelay(new GetStats(), 0, delay, TimeUnit.SECONDS);
    }

    /**
     * @return the latestDiscoveryStatus
     */
    public DiscoveryStatus getLatestDiscoveryStatus()
    {
        return latestDiscoveryStatus;
    }

    /**
     * Get the polling cycle from the preference space, if we can, otherwise use
     * the default.
     * 
     * @return
     */
    protected int getPollingCycle()
    {
        return DEFAULT_INTERVAL;
    }

    /**
     * Create an event saying that there is a new {@link DiscoveryStatus}
     * object to get off the bean.
     * 
     * @param newStats
     */
    protected abstract void processJmsAlerts(DiscoveryStatus newStats);

    /**
     * Print a log message of the stats if the {@link DiscoveryEngine} went
     * from active to idle.
     * 
     * @param newStats
     */
    protected abstract void logIfIdle(DiscoveryStatus newStats);

    /**
     * Grabs a fresh {@link DiscoveryStatus} from the {@link DiscoveryEngine}
     * 
     * @author rkruse
     */
    protected class GetStats implements Runnable
    {
        private static final int THREE_HUNDRED = 300;

        /**
         * @see java.lang.Runnable#run()
         */
        @SuppressWarnings("nls")
        public void run()
        {
            // pause for activity to start again
            if (!latestDiscoveryStatus.isActive())
            {
                try
                {
                    discoveryEngine.waitForActivity(THREE_HUNDRED, TimeUnit.SECONDS);
                }
                catch (InterruptedException e)
                {
                    throw new RuntimeException("Unexpected interruption while pausing for discovery activity. ", e);
                }
            }

            DiscoveryStatus newStats = discoveryEngine.getStatistics();
            if (!newStats.equals(latestDiscoveryStatus))
            {
                logIfIdle(newStats);
                processJmsAlerts(newStats);
                latestDiscoveryStatus = newStats;
            }
        }
    }
}
