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

import java.util.List;

import javax.jws.WebService;

import org.ziptie.provider.scheduler.internal.SchedulerActivator;

/**
 * This is a delegate class that is instantiated by the Metro service for
 * invocations coming from SOAP clients.  It delegates to a Scheduler
 * whose lifecycle is managed by the Activator for this bundle.  The
 * decoupling of the lifecycle was necessary because we want OSGi to
 * manage the lifecycle, not Metro; so Metro is not allowed to instantiate
 * a real Scheduler.
 * 
 * Both this class and the Scheduler to which it delegates both implement
 * the IScheduler interface, helping to enforce the one-to-one delegation
 * mapping between their exposed public methods.
 */
@WebService(endpointInterface = "org.ziptie.provider.scheduler.IScheduler",
            serviceName = "SchedulerService", portName = "SchedulerPort")
public class SchedulerDelegate implements IScheduler
{
    /**
     * Default constructor.
     */
    public SchedulerDelegate()
    {
        // nothing
    }

    /** {@inheritDoc} */
    public void scheduleJob(TriggerData triggerData)
    {
        getScheduler().scheduleJob(triggerData);
    }

    /** {@inheritDoc} */
    public boolean unscheduleJob(String triggerName, String groupName)
    {
        return getScheduler().unscheduleJob(triggerName, groupName);
    }

    /** {@inheritDoc} */
    public String[] getJobGroupNames()
    {
        return getScheduler().getJobGroupNames();
    }

    /** {@inheritDoc} */
    public JobMetadata[] getJobMetadataByGroup(String jobGroup)
    {
        return getScheduler().getJobMetadataByGroup(jobGroup);
    }

    /** {@inheritDoc} */
    public TriggerData getTrigger(String triggerName, String groupName)
    {
        return getScheduler().getTrigger(triggerName, groupName);
    }

    /** {@inheritDoc} */
    public boolean interruptJob(int jobId)
    {
        return getScheduler().interruptJob(jobId);
    }

    /** {@inheritDoc} */
    public void pauseTrigger(String triggerName, String groupName)
    {
        getScheduler().pauseTrigger(triggerName, groupName);
    }

    /** {@inheritDoc} */
    public void resumeTrigger(String triggerName, String groupName)
    {
        getScheduler().resumeTrigger(triggerName, groupName);
    }

    /** {@inheritDoc} */
    public void addJob(JobData jobData, boolean replace)
    {
        getScheduler().addJob(jobData, replace);
    }

    /** {@inheritDoc} */
    public boolean deleteJob(String jobName, String jobGroup)
    {
        return getScheduler().deleteJob(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    public JobData getJob(String jobName, String jobGroup)
    {
        return getScheduler().getJob(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    public List<JobType> getJobTypes()
    {
        return getScheduler().getJobTypes();
    }

    /** {@inheritDoc} */
    public String[] getTriggerGroupNames()
    {
        return getScheduler().getTriggerGroupNames();
    }

    /** {@inheritDoc} */
    public String[] getTriggerNames(String groupName)
    {
        return getScheduler().getTriggerNames(groupName);
    }

    /** {@inheritDoc} */
    public List<TriggerData> getTriggersOfJob(String jobName, String jobGroup)
    {
        return getScheduler().getTriggersOfJob(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    public void pauseJob(String jobName, String jobGroup)
    {
        getScheduler().pauseJob(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    public void resumeJob(String jobName, String jobGroup)
    {
        getScheduler().resumeJob(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    public void addFilter(FilterData filterData, boolean replace, boolean updateTriggers)
    {
        getScheduler().addFilter(filterData, replace, updateTriggers);
    }

    /** {@inheritDoc} */
    public boolean deleteFilter(String filterName)
    {
        return getScheduler().deleteFilter(filterName);
    }

    /** {@inheritDoc} */
    public FilterData getFilter(String filterName)
    {
        return getScheduler().getFilter(filterName);
    }

    /** {@inheritDoc} */
    public FilterData[] getAllFilters()
    {
        return getScheduler().getAllFilters();
    }

    /** {@inheritDoc} */
    public String[] getFilterNames()
    {
        return getScheduler().getFilterNames();
    }

    /** {@inheritDoc} */
    public ExecutionData runNow(JobData jobData)
    {
        return getScheduler().runNow(jobData);
    }

    /** {@inheritDoc} */
    public ExecutionData runExistingJobNow(String jobName, String jobGroup)
    {
        return getScheduler().runExistingJobNow(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    public ExecutionData getExecutionDataById(int executionId)
    {
        return getScheduler().getExecutionDataById(executionId);
    }

    /** {@inheritDoc} */
    public PageData getExecutionData(PageData pageData, String sortColumn, boolean descending)
    {
        return getScheduler().getExecutionData(pageData, sortColumn, descending);
    }

    /**
     * This is an accessor to get the 'true' scheduler as a service.  If the bundle
     * has been restarted, this may return a different Scheduler than previous
     * invocations.  But they should be backed by the same job store, so it would
     * be transparent to the client.
     * 
     * @return the Scheduler to which to delegate
     */
    private IScheduler getScheduler()
    {
        IScheduler scheduler = SchedulerActivator.getScheduler();
        if (scheduler == null)
        {
            throw new RuntimeException("Scheduler service is currently unavailable");
        }

        return scheduler;
    }
}
