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
 */

package org.ziptie.provider.scheduler;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;

/**
 * This class defines a named Filter that encapsulates a cron expression and
 * timezone.  The timezone is an optional attribute, and if not present will be
 * assumed to be GMT.  The cron expression and filter name are both required
 * to be set in order for the Filter definition to be valid.
 */
@XmlAccessorType(XmlAccessType.FIELD)
public class FilterData
{
    private String filterName;
    private String cronExpression;
    private String timeZone;

    /**
     * Default constructor.  All members are <code>null</code> by default and
     * at least the Filter name and a cron expression must be set for this to
     * be a valid Filter definition.
     */
    public FilterData()
    {
        // default constructor
    }

    /**
     * Get the cron expression string.
     *
     * @return the cron expression string
     */
    public String getCronExpression()
    {
        return cronExpression;
    }

    /**
     * Set the cron expression string.
     *
     * @param cronExpression a cron expression
     */
    public void setCronExpression(String cronExpression)
    {
        this.cronExpression = cronExpression;
    }

    /**
     * Get the name of the Filter.
     *
     * @return the name of the Filter.
     */
    public String getFilterName()
    {
        return filterName;
    }

    /**
     * Set the name of the Filter.  The name of the Filter must be set for this to be
     * a valid Filter definition.
     *
     * @param filterName the name of the Filter
     */
    public void setFilterName(String filterName)
    {
        this.filterName = filterName;
    }

    /**
     * Get the time zone which the filter date/time is relative to.  This is expressed as a String.
     *
     * @return the time zone of the filter
     */
    public String getTimeZone()
    {
        return timeZone;
    }

    /**
     * Set the time zone which the filter date/time is relative to.
     *
     * @param timeZone the time zone of the filter
     */
    public void setTimeZone(String timeZone)
    {
        this.timeZone = timeZone;
    }
}
