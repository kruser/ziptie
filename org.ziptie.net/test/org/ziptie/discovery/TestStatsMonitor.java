/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/09/02 16:43:01 $
 * $Revision: 1.4 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/TestStatsMonitor.java,v $e
 */

package org.ziptie.discovery;

import java.util.Date;

/**
 * Implementation of the {@link AbstractBaseStatsMonitor} for testing.
 * 
 * @author rkruse
 */
public final class TestStatsMonitor extends AbstractBaseStatsMonitor
{
    private static TestStatsMonitor instance;

    /**
     * Private constructor
     */
    private TestStatsMonitor()
    {
        super();
    }

    /**
     * Retrieve <i>THE</i> instance of the <code>TestStatsMonitor</code>.
     * Starts a new monitor if it hasn't already been started.
     * 
     * @return the monitor
     */
    public static synchronized TestStatsMonitor getInstance()
    {
        if (instance == null)
        {
            instance = new TestStatsMonitor();
        }
        return instance;
    }

    /**
     * @see com.alterpoint.discovery.AbstractBaseStatsMonitor#logIfIdle(org.ziptie.discovery.DiscoveryStatus)
     */
    protected void logIfIdle(DiscoveryStatus newStats)
    {
        if (!newStats.isActive() && getLatestDiscoveryStatus().isActive())
        {
            String timeDiff = TimeElf.getDuration(newStats.getStartedRunning(), new Date());
            String logMessage = "The Discovery Engine went idle after " + timeDiff + ". "
                    + newStats.getAddressesAnalyzed() + " total addresses analyzed, " + newStats.getRespondedToSnmp()
                    + " were SNMP enabled.";
            System.out.println(logMessage);
        }
    }

    /**
     * Create an event saying that there is a new {@link DiscoveryStatus} object
     * to get off the bean.
     * 
     * @param newStats
     */
    protected void processJmsAlerts(DiscoveryStatus newStats)
    {
        System.out.println("****STAT UPDATE****\n" + newStats.toString());
    }
}
