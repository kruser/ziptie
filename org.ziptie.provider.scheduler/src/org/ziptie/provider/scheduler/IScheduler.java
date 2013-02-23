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

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * This interface described the public interface of the Scheduler component.  It
 * is used for both the internal scheduler implementation as well as the outbound
 * SOAP interface.  Due to the SOAP requirement, every attempt has been made to
 * use only simple types that are easily passed over SOAP.  The currently of this
 * interface includes several shallow objects that are themselves composed of only
 * simple SOAP types.
 */
@WebService(name = "Scheduler", targetNamespace = "http://www.ziptie.org/server/scheduler")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IScheduler
{
    /**
     * Get the enumeration Job types exposed by the ZipTie server.
     *
     * @return an array (enumeration) of Job types
     */
    List<JobType> getJobTypes();

    /**
     * Create a Job from the provided JobData.  Note that a Job is not the same
     * as a schedule (aka Trigger).
     *
     * @param jobData the Job definition
     * @param replace true if an existing job with the same name and group should be
     *    replaced, false otherwise
     */
    void addJob(@WebParam(name = "jobData") JobData jobData, @WebParam(name = "replace") boolean replace);

    /**
     * Delete the Job with the provided Job name and Job group.
     *
     * @param jobName the name of the Job to delete
     * @param jobGroup the name of the group the Job resides in
     * @return true if the Job was deleted, false otherwise
     */
    boolean deleteJob(@WebParam(name = "jobName") String jobName, @WebParam(name = "jobGroup") String jobGroup);

    /**
     * Get the JobData for the Job with specified name and group.
     *
     * @param jobName the name of the Job to delete
     * @param jobGroup the name of the group the Job resides in
     * @return a JobData object describing the Job
     */
    @WebMethod
    JobData getJob(@WebParam(name = "jobName") String jobName, @WebParam(name = "jobGroup") String jobGroup);

    /**
     * Get the list of all Job groups.
     * 
     * @return an array of names of the groups
     */
    String[] getJobGroupNames();

    /**
     * Get the metadata for the Jobs in the given group.  This method provides a
     * lighter weight method of obtaining metadata about a Job than retreiving
     * each Job individually.
     *
     * @param jobGroup a job group name
     * @return an array of JobMetadata
     */
    JobMetadata[] getJobMetadataByGroup(@WebParam(name = "jobGroup") String jobGroup);

    /**
     * Pause the Job or Job Group with the given name, by pausing all of it's current
     * Triggers.  If both <code>jobName</code> and <code>jobGroup</code> parameters are supplied
     * then a specific Job is paused.  If the <code>jobName</code> parameter is <code>null</code>
     * then all Jobs in the specified Job Group are paused. 
     *
     * @param jobName the name of a Job to pause, or <code>null</code> to pause an entire Job Group
     * @param jobGroup the name of the Job Group to pause, or the Job Group of the individiual Job to pause.
     */
    void pauseJob(@WebParam(name = "jobName") String jobName, @WebParam(name = "jobGroup") String jobGroup);

    /**
     * Resume the individual job or possibly set of jobs residing in the specified Job Group.  If both
     * <code>jobName</code> and <code>jobGroup</code> parameters are supplied then a specific Job is
     * unpaused.  If the <code>jobName</code> parameter is <code>null</code> then all Jobs in the specified
     * Job Group are resumed (un-paused).
     *
     * @param jobName the name of a Job to resume, or <code>null</code> to resume all the Jobs in the specified Job Group
     * @param jobGroup the name of the Job Group to resume, or the Job Group of the individiual Job to resume.
     */
    void resumeJob(@WebParam(name = "jobName") String jobName, @WebParam(name = "jobGroup") String jobGroup);

    /**
     * Add a job to the scheduler.
     *
     * @param triggerData the detailed information about the job and trigger, including all parameters necessary to execute
     *        the scheduler has had an internal error.
     */
    void scheduleJob(@WebParam(name = "triggerData") TriggerData triggerData);

    /**
     * Delete a job trigger from the scheduler by name.
     *
     * @param triggerName a unique trigger name
     * @param groupName a trigger group name
     * @return true if the trigger was found and deleted
     */
    boolean unscheduleJob(@WebParam(name = "triggerName") String triggerName, @WebParam(name = "groupName") String groupName);

    /**
     * Get the list of all Trigger group names.
     *
     * @return an array of unique names of all Trigger groups
     */
    String[] getTriggerGroupNames();

    /**
     * Get a collection of unique trigger names for the given trigger group (technically a Set, but an array here for SOAP purposes).
     *
     * @param groupName the name of the group to get trigger names from
     * @return an array of unique trigger names
     */
    String[] getTriggerNames(@WebParam(name = "groupName") String groupName);

    /**
     * Get the JobData for the job instance with the given name and group.
     *
     * @param triggerName a unique job name
     * @param groupName a job group name
     * @return the JobData, or null
     */
    TriggerData getTrigger(@WebParam(name = "triggerName") String triggerName, @WebParam(name = "groupName") String groupName);

    /**
     * Get the triggers that are scheduled for the given job.
     *
     * @param jobName The job name
     * @param jobGroup The job group
     * @return A list of triggers.
     */
    List<TriggerData> getTriggersOfJob(@WebParam(name = "jobName") String jobName, @WebParam(name = "jobGroup") String jobGroup);

    /**
     * Suspend the firing of the named trigger in the named group.  This does not affect currently executing jobs,
     * merely future jobs.  If <code>null</code> is passed for the trigger name, then the entire trigger group is
     * paused.
     *
     * @param triggerName a unique trigger name
     * @param groupName a trigger group name
     */
    void pauseTrigger(@WebParam(name = "triggerName") String triggerName, @WebParam(name = "groupName") String groupName);

    /**
     * Resume the firing of the named trigger in the named group.  If <code>null</code> is passed for the trigger
     * name, then the entire trigger group is resumed.
     *
     * @param triggerName a unique trigger name
     * @param groupName a trigger group name
     */
    void resumeTrigger(@WebParam(name = "triggerName") String triggerName, @WebParam(name = "groupName") String groupName);

    /**
     * Add a Filter that can be used by a Trigger to restrict when it fires.
     *
     * @param filterData the Filter definition
     * @param replace a flag indicating whether to replace an existing Filter definition that has the same name
     * @param updateTriggers a flag indicating whether to propagate the Filter change to Triggers that reference
     *     this Trigger
     */
    @ZInvocationSecurity(perm = "org.ziptie.filters.administer")
    void addFilter(@WebParam(name = "filterData") FilterData filterData,
                   @WebParam(name = "replace") boolean replace,
                   @WebParam(name = "updateTriggers") boolean updateTriggers);

    /**
     * Delete the Filter with the given name.
     *
     * @param filterName the name of the Filter
     * @return true if the filter was found and delete, false otherwise
     */
    @ZInvocationSecurity(perm = "org.ziptie.filters.administer")
    boolean deleteFilter(@WebParam(name = "filterName") String filterName);

    /**
     * Get the Filter with the specified name.
     *
     * @param filterName the name of the Filter
     * @return the FilterData object for the Filter, or null
     */
    FilterData getFilter(@WebParam(name = "filterName") String filterName);

    /**
     * Gets all the existing schedule filters.
     * @return An array of filters.
     */
    FilterData[] getAllFilters();

    /**
     * Get the list of unique Filter names.
     *
     * @return an array of filter names that are unique
     */
    String[] getFilterNames();

    /**
     * Interrupt a current running job with the given job identifier.  This job identifier comes from the map returned
     * by {@link #getExecutionData(PageData, String, boolean)}
     *
     * @param jobId a unique job identifier
     * @return true if at least one instance was found and interrupted.  false does not indicate an error.
     */
    boolean interruptJob(@WebParam(name = "jobId") int jobId);

    /**
     * Create a non-persistent Job and trigger it to run immediately.
     *
     * @param jobData the Job definition
     * @return The execution for the job.
     */
    ExecutionData runNow(@WebParam(name = "jobData") JobData jobData);

    /**
     * Schedule the existing job to run now.
     * @param jobName The name of the Job
     * @param jobGroup the group in which the Job resides
     * @return The execution for the job.
     */
    ExecutionData runExistingJobNow(@WebParam(name = "jobName") String jobName, @WebParam(name = "groupName") String jobGroup);

    /**
     * Gets the execution data with the given id.
     * @param executionId The ID of the execution.
     * @return The execution data.
     */
    ExecutionData getExecutionDataById(@WebParam(name = "executionId") int executionId);

    /**
     * Gets the execution data.
     * @param pageData a {@link PageData} object expressing which entries (page) to retrieve
     * @param sortColumn the name of a {@link ExecutionData} attribute to sort by, or null for default sort order
     * @param descending true if the sort should be descending, false if ascending
     * @return a {@link PageData} object with a possibly empty collection of {@link ExecutionData} objects
     */
    PageData getExecutionData(@WebParam(name = "pageData") PageData pageData,
                              @WebParam(name = "sortColumn") String sortColumn,
                              @WebParam(name = "descending") boolean descending);
}
