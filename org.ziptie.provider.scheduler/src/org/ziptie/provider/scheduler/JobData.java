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

import java.util.Map;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;

/**
 * JobData
 */
@XmlAccessorType(XmlAccessType.FIELD)
public class JobData
{
    private String jobName;
    private String jobGroup;
    private String description;
    private String jobType;
    private boolean persistent;
    private Map<String, String> jobParameters;

    /**
     * Default constructor used by Axis.
     */
    public JobData()
    {
        // nothing
    }

    /**
     * Default constructor.
     *
     * @param name the name of the Job
     * @param group the name of the Job Group
     */
    public JobData(String name, String group)
    {
        this.jobName = name;
        this.jobGroup = group;
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
     * Get the "type" of Job.  This string is essentially one of an enumeration of available job types exposed
     * by the ZipTie server.
     *
     * @return the type of job
     */
    public String getJobType()
    {
        return jobType;
    }

    /**
     * Set the "type" of a the Job.  This string is essentially one of an enumeration of available job types
     * exposed by the ZipTie server.
     *
     * @param jobType the jobType to set
     */
    public void setJobType(String jobType)
    {
        this.jobType = jobType;
    }

    /**
     * Get the user defined description of this job.
     *
     * @return the description
     */
    public String getDescription()
    {
        return description;
    }

    /**
     * Set the user defined description of the Job.  This field is not used by the Scheduler and is for
     * display purposes.
     *
     * @param description the description
     */
    public void setDescription(String description)
    {
        this.description = description;
    }

    /**
     * Determine whether the Job defined by this instance is persistent or not.
     *
     * @return true if this Job is persistent, false otherwise
     */
    public boolean isPersistent()
    {
        return persistent;
    }

    /**
     * Set whether this Job is persistent or transient.
     *
     * @param persistent true if persistent, false otherwise
     */
    public void setPersistent(boolean persistent)
    {
        this.persistent = persistent;
    }
}
