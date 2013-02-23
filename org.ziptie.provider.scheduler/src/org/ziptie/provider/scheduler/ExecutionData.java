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
package org.ziptie.provider.scheduler;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.TableGenerator;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

/**
 * Represents a run of a job.
 */
@XmlRootElement
@Entity(name = "ExecutionData")
@Table(name = "execution_history")
public class ExecutionData
{
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen",
                    table = "persistent_key_gen",
                    pkColumnName = "seq_name",
                    valueColumnName = "seq_value",
                    pkColumnValue = "Execution_Data_seq",
                    initialValue = 1,
                    allocationSize = 1)
    @Column(name = "id")
    private int id;

    @Column(name = "trigger_name")
    private String triggerName;

    @Column(name = "trigger_group")
    private String triggerGroup;

    @Column(name = "job_name")
    private String jobName;

    @Column(name = "job_group")
    private String jobGroup;

    @Column(name = "job_type")
    private String jobType;

    @Column(name = "job_class")
    private String jobClass;

    @Column(name = "executor")
    private String executor;

    @Column(name = "start_time")
    @Temporal(value = TemporalType.TIMESTAMP)
    private Date startTime;

    @Column(name = "end_time")
    @Temporal(value = TemporalType.TIMESTAMP)
    private Date endTime;

    @Column(name = "canceled")
    private boolean canceled;

    /**
     * Default Constructor
     */
    public ExecutionData()
    {
        id = -1;
    }

    /**
     * The ID of the execution.
     * @return The unique execution ID.
     */
    public int getId()
    {
        return id;
    }

    /**
     * Set the ID
     * @param id The unique execution ID
     */
    public void setId(int id)
    {
        this.id = id;
    }

    /**
     * The name of the trigger that caused the execution.
     * A trigger with this name might not still exist.
     * @return The trigger name.
     */
    public String getTriggerName()
    {
        return triggerName;
    }

    /**
     * Set the name of the trigger.
     * @param triggerName the trigger name.
     */
    public void setTriggerName(String triggerName)
    {
        this.triggerName = triggerName;
    }

    /**
     * The trigger's group
     * @return the trigger group
     */
    public String getTriggerGroup()
    {
        return triggerGroup;
    }

    /**
     * Set the group of the trigger that caused the execution.
     * @param triggerGroup The trigger group
     */
    public void setTriggerGroup(String triggerGroup)
    {
        this.triggerGroup = triggerGroup;
    }

    /**
     * Get the name of the job that was executed.
     * This job might not still exist.
     * @return The job name.
     */
    public String getJobName()
    {
        return jobName;
    }

    /**
     * Sets the job name.
     * @param jobName the job name
     */
    public void setJobName(String jobName)
    {
        this.jobName = jobName;
    }

    /**
     * Gets the group of the job that caused the execution.
     * @return The job group
     */
    public String getJobGroup()
    {
        return jobGroup;
    }

    /**
     * Sets the job group.
     * @param jobGroup The job group
     */
    public void setJobGroup(String jobGroup)
    {
        this.jobGroup = jobGroup;
    }

    /**
     * Gets the job type.
     * @return The job type.
     */
    public String getJobType()
    {
        return jobType;
    }

    /**
     * Set the job type.
     * @param jobType The job type.
     */
    public void setJobType(String jobType)
    {
        this.jobType = jobType;
    }

    /**
     * Get the class name for the job type.
     * @return The job class name.
     */
    @XmlTransient
    public String getJobClass()
    {
        return jobClass;
    }

    /**
     * Set the job class name.
     * @param jobClass The class name
     */
    public void setJobClass(String jobClass)
    {
        this.jobClass = jobClass;
    }

    /**
     * Gets whether the job has been canceled.
     * @return <code>true</code> if the execution was canceled.
     */
    public boolean isCanceled()
    {
        return canceled;
    }

    /**
     * Set the canceled state of the execution.
     * @param canceled <code>true</code> if the execution was canceled.
     */
    public void setCanceled(boolean canceled)
    {
        this.canceled = canceled;
    }

    /**
     * Gets the time that the execution started.
     * @return The start time of the execution.
     */
    public Date getStartTime()
    {
        return startTime;
    }

    /**
     * Sets the time that the execution started.
     * @param startTime The start time of the execution.
     */
    public void setStartTime(Date startTime)
    {
        this.startTime = startTime;
    }

    /**
     * Gets the time that the execution completed.
     * @return The end time, or <code>null</code> if the job hasn't yet completed.
     */
    public Date getEndTime()
    {
        return endTime;
    }

    /**
     * Sets the time that the execution completed.
     * @param endTime The end time.
     */
    public void setEndTime(Date endTime)
    {
        this.endTime = endTime;
    }
    
    /**
     * Get the name of the user who executed the job.
     *
     * @return the name of the user who executed the job.
     */
    public String getExecutor()
    {
        return executor;
    }

    /**
     * Set the name of the user who executed the job.
     *
     * @param executor the name of the user who executed the job.
     */
    public void setExecutor(String executor)
    {
        this.executor = executor;
    }
}
