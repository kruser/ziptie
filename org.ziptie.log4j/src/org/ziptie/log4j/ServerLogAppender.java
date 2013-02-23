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
package org.ziptie.log4j;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import org.apache.log4j.helpers.LogLog;
import org.apache.log4j.spi.LoggingEvent;
import org.apache.log4j.DailyRollingFileAppender;

/**
 * Combines the abilities of the following two appenders
 *
 *   - org.apache.log4j.RollingFileAppender
 *     Set the maximum number of backup files to keep around
 *
 *   - org.apache.log4j.DailyRollingFileAppender
 *     underlying file is rolled over at a user chosen frequency
 *
 * Assumes that at least one log message will be written during each roll period.
 */
public class ServerLogAppender extends DailyRollingFileAppender
{
    // -- Statics
    private static final int MAX_BACKUP_INDEX_DEFAULT;
    private static final List<String> DATE_PATTERNS;
    private static final Map<String, RolloverSchedule> SCHEDULES;

    // -- Members
    private int maxBackupIndex;
    private RolloverSchedule schedule;

    // -- Static initializer
    static
    {
        MAX_BACKUP_INDEX_DEFAULT = 5;
        DATE_PATTERNS = new LinkedList<String>();
        initDataPatterns();
        SCHEDULES = new HashMap<String, RolloverSchedule>(DATE_PATTERNS.size());
        initSchedules();
    }

    // ----------------------------------------------------------------------
    //   CONSTRUCTORS
    // ----------------------------------------------------------------------

    /**
     * Construct a new instance of this class.
     */
    public ServerLogAppender()
    {
        super();
        maxBackupIndex = MAX_BACKUP_INDEX_DEFAULT;
        schedule = null;
    }

    // ----------------------------------------------------------------------
    //   PUBLIC METHODS
    // ----------------------------------------------------------------------

    /**
     * Set the maximum number of backup files to keep around.
     *
     * The MaxBackupIndex option determines how many backup files are kept
     * before the oldest is erased. This option takes a positive integer
     * value. If set to zero, then there will be no backup files and the log
     * file will be truncated when it reaches MaxFileSize.
     *
     * @param maxBackups
     */
    public void setMaxBackupIndex(int maxBackups)
    {
        maxBackupIndex = maxBackups;
    }

    /**
     * @return the value of the MaxBackupIndex option.
     */
    public int getMaxBackupIndex()
    {
        return maxBackupIndex;
    }

    /**
     * @see org.apache.log4j.DailyRollingFileAppender#setDatePattern(java.lang.String)
     */
    @Override
    public void setDatePattern(String datePattern)
    {
        super.setDatePattern(datePattern);
        if (DATE_PATTERNS.contains(datePattern))
        {
            schedule = SCHEDULES.get(datePattern);
        }
        else
        {
            LogLog.error("Illegal date pattern " + datePattern);
        }
    }

    // ----------------------------------------------------------------------
    //   PROTECTED METHODS
    // ----------------------------------------------------------------------

    /**
     * This method differentiates ServerLogAppender from its super class.
     */
    protected void subAppend(LoggingEvent event)
    {
        super.subAppend(event);

        if (super.fileName != null && super.getDatePattern() != null)
        {
            pruneFile();
        }
    }

    // ----------------------------------------------------------------------
    //   PRIVATE METHODS
    // ----------------------------------------------------------------------

    private static void initDataPatterns()
    {
        DATE_PATTERNS.add("'.'yyyy-MM-dd-HH-mm"); // MINUTELY
        DATE_PATTERNS.add("'.'yyyy-MM-dd-HH"); // HOURLY
        DATE_PATTERNS.add("'.'yyyy-MM-dd-a"); // HALF_DAILY
        DATE_PATTERNS.add("'.'yyyy-MM-dd"); // DAILY
        DATE_PATTERNS.add("'.'yyyy-ww"); // WEEKLY
        DATE_PATTERNS.add("'.'yyyy-MM"); // MONTHLY
    }

    private static void initSchedules()
    {
        Iterator<String> datePatterns = DATE_PATTERNS.iterator();

        for (RolloverSchedule sched : RolloverSchedule.values())
        {
            SCHEDULES.put(datePatterns.next(), sched);
        }
    }

    private void pruneFile()
    {
        // If maxBackups <= 0, then there is no file deleting to be done.
        if (maxBackupIndex > 0)
        {
            File serverLog = new File(fileName);

            if (serverLog.exists())
            {
                File staleFile = new File(staleFileName(serverLog.lastModified()));

                if (staleFile.exists())
                {
                    staleFile.delete();
                }
            }
        }
    }

    private String staleFileName(long lastModified)
    {
        SimpleDateFormat format = new SimpleDateFormat(super.getDatePattern());

        return fileName + format.format(staleTime(lastModified));
    }

    private long staleTime(long time)
    {
        for (int i = 0; i <= maxBackupIndex; i++)
        {
            time = previousTime(time);
        }

        return time;
    }

    private long previousTime(long millis)
    {
        Calendar cal = new GregorianCalendar();
        cal.setTimeInMillis(millis);

        switch (schedule)
        {
        case MINUTELY:
            cal.add(Calendar.MINUTE, -1);
            break;
        case HOURLY:
            cal.add(Calendar.HOUR_OF_DAY, -1);
            break;
        case HALF_DAILY:
            subtractHalfDay(cal);
            break;
        case DAILY:
            cal.add(Calendar.DATE, -1);
            break;
        case WEEKLY:
            cal.add(Calendar.WEEK_OF_YEAR, -1);
            break;
        case MONTHLY:
            cal.add(Calendar.MONTH, -1);
            break;
        default:
            throw new IllegalStateException("Unknown rollover schedule.");
        }

        return cal.getTime().getTime();
    }

    private void subtractHalfDay(Calendar cal)
    {
        if (12 <= cal.get(Calendar.HOUR_OF_DAY))
        {
            cal.set(Calendar.HOUR_OF_DAY, 0);
        }
        else
        {
            cal.set(Calendar.HOUR_OF_DAY, 12);
            cal.add(Calendar.DAY_OF_MONTH, -1);
        }
    }

    // ----------------------------------------------------------------------
    //   INNER CLASSES
    // ----------------------------------------------------------------------

    private enum RolloverSchedule
    {
        MINUTELY,
        HOURLY,
        HALF_DAILY,
        DAILY,
        WEEKLY,
        MONTHLY,
    }
}
