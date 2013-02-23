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

import java.util.Date;
import java.util.Map;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;

/**
 * This class encapsulates the time of the schedule.  The trigger name, trigger group,
 * jobName, and cron expression are required fields.
 *
 */
@XmlAccessorType(XmlAccessType.FIELD)
public class TriggerData
{
    private static final long serialVersionUID = 5528691279403668737L;

    private String triggerName;
    private String triggerGroup;
    private String jobName;
    private String jobGroup;
    private String cronExpression;
    private boolean paused;
    private Date startTime;
    private Date endTime;
    private String timeZone;
    private String description;
    private String filterName;
    private Date finalFireTime;
    private Date nextFireTime;
    private Date previousFireTime;
    private Map<String, String> jobParameters;

    /**
     * Default constructor used by Axis
     */
    public TriggerData()
    {
        // nothing
    }

    /**
     * Get the name of the group this trigger is in.
     *
     * @return the trigger group name
     */
    public String getTriggerGroup()
    {
        return triggerGroup;
    }

    /**
     * Set the name of the group this trigger is in.
     *
     * @param triggerGroup the trigger group
     */
    public void setTriggerGroup(String triggerGroup)
    {
        this.triggerGroup = triggerGroup;
    }

    /**
     * Get the unique name of the trigger.
     *
     * @return the trigger name
     */
    public String getTriggerName()
    {
        return triggerName;
    }

    /**
     * Set the unique name of the trigger.
     *
     * @param triggerName the trigger name
     */
    public void setTriggerName(String triggerName)
    {
        this.triggerName = triggerName;
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
     * Get the date/time when the schedule will begin to be honored.
     *
     * @return the starting date/time
     */
    public Date getStartTime()
    {
        return startTime;
    }

    /**
     * Set the date/time when the schedule will begin to be honored.
     * 
     * @param startTime the starting date/time
     */
    public void setStartTime(Date startTime)
    {
        this.startTime = startTime;
    }

    /**
     * Get the date/time when the schedule will cease to be honored.
     * 
     * @return the date/time
     */
    public Date getEndTime()
    {
        return endTime;
    }

    /**
     * Set the date/time when the schedule will cease to be honored.
     * 
     * @param endTime the cutoff date/time
     */
    public void setEndTime(Date endTime)
    {
        this.endTime = endTime;
    }

    /**
     * Get the time zone which the schedule date/time is relative to.  This is expressed as a String.
     *
     * @return the time zone of the schedule
     */
    public String getTimeZone()
    {
        return timeZone;
    }

    /**
     * Set the time zone which the schedule date/time is relative to.
     *
     * @param timeZone the time zone of the schedule
     */
    public void setTimeZone(String timeZone)
    {
        this.timeZone = timeZone;
    }

    /**
     * Get the user defined description of this trigger.
     *
     * @return the description
     */
    public String getDescription()
    {
        return description;
    }

    /**
     * Set the user defined description of this trigger.
     *
     * @param description the description to set
     */
    public void setDescription(String description)
    {
        this.description = description;
    }

    /**
     * Get the last time this trigger will fire.  If this trigger will run
     * indefinitely, then <code>null</code> is returned.
     *
     * @return the the last time this trigger will fire, or <code>null</code for
     *   indefinite triggers.
     */
    public Date getFinalFireTime()
    {
        return finalFireTime;
    }

    /**
     * Get the next time this trigger will fire.  If this trigger will never run
     * again then <code>null</code> is returned.
     *
     * @return the next time this trigger will fire, or <code>null</code> if never
     */
    public Date getNextFireTime()
    {
        return nextFireTime;
    }

    /**
     * Get the last time this trigger fired.  If this trigger never ran before
     * then <code>null</code> will be returned.
     *
     * @return the last time this trigger fired, or <code>null</code> if never
     */
    public Date getPreviousFireTime()
    {
        return previousFireTime;
    }

    /**
     * Get the name of the job this JobData pertains to.
     *
     * @return the job name
     */
    public String getJobName()
    {
        return jobName;
    }

    /**
     * Set the name of the job this JobData pertains to.
     *
     * @param jobName the job name
     */
    public void setJobName(String jobName)
    {
        this.jobName = jobName;
    }

    /**
     * Get the group name of the job this JobData pertains to.
     *
     * @return the job name
     */
    public String getJobGroup()
    {
        return jobGroup;
    }

    /**
     * Get the group name of the job this JobData pertains to.
     * 
     * @param jobGroup the job group name
     */
    public void setJobGroup(String jobGroup)
    {
        this.jobGroup = jobGroup;
    }

    /**
     * Get the value associated with the supplied name.
     *
     * @param name the name of the value to retrieve
     * @return the value of the parameter with the supplied name, or null if it does not exist
     */
    public String getJobParameter(String name)
    {
        return jobParameters.get(name);
    }

    /**
     * Set a value into the internal job data map under the supplied name.  If that name already
     * exists it's value will be replaced by the one provided here.  Neither the name nor value
     * can be null.
     *
     * @param name the name of the job parameter
     * @param value the value of the job parameter
     */
    public void setJobParameter(String name, String value)
    {
        if (name == null || value == null)
        {
            throw new IllegalArgumentException("Neither the name nor the value of the job parameter can be null.");
        }

        jobParameters.put(name, value);
    }

    /**
     * Gets the mutable map of name/value pair job parameters.  This method should not be used, it is here to
     * aid SOAP serialization.
     *
     * @return the map of job parameters
     */
    public Map<String, String> getJobParameters()
    {
        return jobParameters;
    }

    /**
     * Sets the mutable map of name/value pair job parameters.  This method should not be used, it is here to
     * aid SOAP serialization.
     *
     * @param jobParameters a map of job parameters
     */
    public void setJobParameters(Map<String, String> jobParameters)
    {
        this.jobParameters = jobParameters;
    }

    /**
     * Get the name of the Filter associated with this Trigger (if any).
     *
     * @return the name of the Filter associated with this Trigger, null if there is none
     */
    public String getFilterName()
    {
        return filterName;
    }

    /**
     * Set the name of the Filter associated with this Trigger.
     *
     * @param filterName the name of the Filter
     */
    public void setFilterName(String filterName)
    {
        this.filterName = filterName;
    }

    /**
     * Determines whether this is a paused Trigger.
     *
     * @return true if the Trigger is paused, false otherwise
     */
    public boolean isPaused()
    {
        return paused;
    }

    /**
     * Sets the flag indicating that this schedule is paused.  Setting this
     * flag has no affect on actively pausing the job or its persistence.
     *
     * @param paused true if the Trigger is paused, false otherwise
     */
    public void setPaused(boolean paused)
    {
        this.paused = paused;
    }

    /**
     * Set the final fire time.
     *
     * @param finalFireTime the final fire time.
     */
    public void setFinalFireTime(Date finalFireTime)
    {
        this.finalFireTime = finalFireTime;
    }

    /**
     * Set the next fire time.
     *
     * @param nextFireTime the next fire time.
     */
    public void setNextFireTime(Date nextFireTime)
    {
        this.nextFireTime = nextFireTime;
    }

    /**
     * Set the previous fire time.
     *
     * @param previousFireTime the previous fire time
     */
    public void setPreviousFireTime(Date previousFireTime)
    {
        this.previousFireTime = previousFireTime;
    }
}
