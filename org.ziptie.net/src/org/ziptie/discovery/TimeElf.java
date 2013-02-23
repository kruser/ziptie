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
 */
package org.ziptie.discovery;

import java.util.Date;

/**
 * TimeElf
 */
public final class TimeElf
{
    private static final int MINUTE_IN_MILLISECONDS = 60000;
    private static final int HOUR_IN_MILLISECONDS = 3600000;
    private static final int THOUSAND_MILLISECONDS = 1000;

    /**
     * hidden
     */
    private TimeElf()
    {
    }

    /**
     * Computes a human readable time difference from two dates. Example output is<br>
     * 45 hours, 10 minutes, 4 seconds.
     *
     * This only computes hours, minutes and seconds and should be used for durations.
     *
     * @param startTime should be earlier than the finishedTime
     * @param finishedTime when the duration ended
     * @return the duration
     */
    public static String getDuration(Date startTime, Date finishedTime)
    {
        StringBuilder toReturn = new StringBuilder();
        long diff = finishedTime.getTime() - startTime.getTime();
        if (diff < THOUSAND_MILLISECONDS)
        {
            return "< 1 second";
        }

        boolean foundHours = false;
        boolean foundMin = false;
        if (diff > HOUR_IN_MILLISECONDS)
        {
            long hours = diff / HOUR_IN_MILLISECONDS;
            diff -= (hours * HOUR_IN_MILLISECONDS);
            toReturn.append(hours + " hour(s)");
            foundHours = true;
        }

        if (diff > MINUTE_IN_MILLISECONDS)
        {
            long minutes = diff / MINUTE_IN_MILLISECONDS;
            diff -= (minutes * MINUTE_IN_MILLISECONDS);
            if (foundHours)
            {
                toReturn.append(", ");
            }
            toReturn.append(minutes + " minute(s)");
            foundMin = true;
        }

        if (diff > THOUSAND_MILLISECONDS)
        {
            long seconds = diff / THOUSAND_MILLISECONDS;
            if (foundHours || foundMin)
            {
                toReturn.append(", ");
            }
            toReturn.append(seconds + " second(s)");
        }

        return toReturn.toString();
    }

}
