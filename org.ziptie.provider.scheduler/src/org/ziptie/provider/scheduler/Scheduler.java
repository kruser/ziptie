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

import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TimeZone;

import javax.transaction.Transaction;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.ScrollMode;
import org.hibernate.ScrollableResults;
import org.hibernate.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.quartz.CronTrigger;
import org.quartz.InterruptableJob;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.SimpleTrigger;
import org.quartz.Trigger;
import org.quartz.UnableToInterruptJobException;
import org.quartz.impl.StdSchedulerFactory;
import org.quartz.impl.calendar.CronCalendar;
import org.ziptie.provider.scheduler.internal.SchedulerActivator;
import org.ziptie.zap.jta.TransactionElf;
import org.ziptie.zap.security.ISecurityService;
import org.ziptie.zap.security.IUserSession;

/**
 * Scheduler
 */
public class Scheduler implements IScheduler
{
    private static final Logger LOGGER = Logger.getLogger(Scheduler.class);
    private static final String JOB_NAME_GROUP_OR_TYPE_IS_INVALID = "Job name, group, or type is invalid.";
    private static final String MSG_EXECUTION_NOT_ALLOWED = "Execution of job type %s not allowed for user '%s'";
    private static final String MSG_MODIFICATION_NOT_ALLOWED = "Modification of job type %s not allowed for user '%s'";
    private static final String USERNAME = "username";

    private org.quartz.Scheduler scheduler;
    private SchedulerEventProducer schedEventProducer;
    private Map<String, JobType> jobTypeByName;
    private Map<Class, String> jobNameByType;

    /**
     * Default constructor.
     *
     * @param props the configuration to use.
     * @throws SchedulerException thrown if the scheduler cannot be obtained from the factory and started
     */
    public Scheduler(Properties props) throws SchedulerException
    {
        jobTypeByName = new HashMap<String, JobType>();
        jobNameByType = new HashMap<Class, String>();

        try
        {
            StdSchedulerFactory factory = new StdSchedulerFactory(props);
            scheduler = factory.getScheduler();

            schedEventProducer = new SchedulerEventProducer();
            scheduler.addSchedulerListener(schedEventProducer);

            scheduler.addGlobalTriggerListener(new ExecutionTriggerListener());
            scheduler.addGlobalTriggerListener(new TriggerEventProducer());
        }
        catch (org.quartz.SchedulerException se)
        {
            se.printStackTrace();
            throw new SchedulerException(se.getMessage(), se);
        }
    }

    /** {@inheritDoc} */
    public List<JobType> getJobTypes()
    {
        ArrayList<JobType> list = new ArrayList<JobType>();
        list.addAll(jobTypeByName.values());
        return list;
    }

    /**
     * Return the Job type name to job class mapping that is maintained
     * by registerJobType and unregisterJobType.
     * 
     * @return an unmodifiable map of job type names to classes.
     */
    public Map<String, JobType> getJobTypeMapping()
    {
        return Collections.unmodifiableMap(jobTypeByName);
    }

    /**
     * Return the Job class to job type name mapping that is maintained
     * by registerJobType and unregisterJobType.
     *
     * @return an unmodifiable map of job class to job names.
     */
    public Map<Class, String> getJobClassMapping()
    {
        return Collections.unmodifiableMap(jobNameByType);
    }

    /** {@inheritDoc} */
    public void addJob(JobData jobData, boolean replace)
    {
        try
        {
            checkCudPermission(jobData);

            String jobName = jobData.getJobName();
            String jobGroup = jobData.getJobGroup();
            String jobDescription = jobData.getDescription();
            Map<String, String> jobParameters = jobData.getJobParameters();
            String jobTypeName = jobData.getJobType();
            boolean persistent = jobData.isPersistent();
            JobType jobType = jobTypeByName.get(jobTypeName);
            Class jobClass = jobType.getJobClass();

            if (jobName == null || jobGroup == null || jobClass == null)
            {
                throw new RuntimeException(JOB_NAME_GROUP_OR_TYPE_IS_INVALID);
            }

            JobDetail detail = new JobDetail(jobName, jobGroup, jobClass);
            detail.setDescription(jobDescription);
            detail.setVolatility(!persistent); // in the DB?
            detail.setDurability(persistent); // keep after orphaned (by triggers)

            JobDataMap dataMap = new JobDataMap(jobParameters != null ? jobParameters : new HashMap<String, String>());

            // all triggers must be associated with the user that scheduled them.
            ISecurityService ss = SchedulerActivator.getSecurityService();
            if (ss != null && ss.getUserSession() != null && ss.getUserSession().getPrincipal() != null)
            {
                dataMap.put("job.creator", ss.getUserSession().getPrincipal().getName());
            }

            detail.setJobDataMap(dataMap);

            scheduler.addJob(detail, replace);

            schedEventProducer.jobAdded(detail);
        }
        catch (Exception e)
        {
            LOGGER.error(e.getMessage(), e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public boolean deleteJob(String jobName, String jobGroup)
    {
        try
        {
            JobData jobData = getJob(jobName, jobGroup);
            checkCudPermission(jobData);

            boolean result = scheduler.deleteJob(jobName, jobGroup);

            if (result)
            {
                schedEventProducer.jobDeleted(jobName, jobGroup);
            }

            return result;
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public JobData getJob(String jobName, String jobGroup)
    {
        try
        {
            JobDetail jobDetail = scheduler.getJobDetail(jobName, jobGroup);
            if (jobDetail == null)
            {
                return null;
            }

            JobData jobData = new JobData(jobName, jobGroup);
            jobData.setJobType(jobNameByType.get(jobDetail.getJobClass()));
            jobData.setJobParameters(jobDetail.getJobDataMap());
            jobData.setDescription(jobDetail.getDescription());
            jobData.setPersistent(jobDetail.isDurable());

            return jobData;
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public JobMetadata[] getJobMetadataByGroup(String jobGroup)
    {
        try
        {
            ArrayList<JobMetadata> metadata = new ArrayList<JobMetadata>();

            String[] jobNames = scheduler.getJobNames(jobGroup);
            for (String jobName : jobNames)
            {
                JobDetail jobDetail = scheduler.getJobDetail(jobName, jobGroup);
                JobMetadata meta = new JobMetadata();
                meta.setJobGroup(jobGroup);
                meta.setJobName(jobName);
                meta.setJobType(jobNameByType.get(jobDetail.getJobClass()));
                meta.setJobDescription(jobDetail.getDescription());
                metadata.add(meta);
            }

            return metadata.toArray(new JobMetadata[0]);
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    // CHECKSTYLE:OFF
    public void scheduleJob(TriggerData triggerData)
    {
        try
        {
            String triggerName = triggerData.getTriggerName();
            String triggerGroup = triggerData.getTriggerGroup();
            String jobName = triggerData.getJobName();
            String jobGroup = triggerData.getJobGroup();
            String cronExpression = triggerData.getCronExpression();
            Date startTime = triggerData.getStartTime();
            Date endTime = triggerData.getEndTime();
            String timeZone = triggerData.getTimeZone();
            String filterName = triggerData.getFilterName();

            JobDetail jobDetail = scheduler.getJobDetail(jobName, jobGroup);

            CronTrigger trigger = new CronTrigger();
            trigger.setName(triggerName);
            trigger.setGroup(triggerGroup);
            trigger.setJobName(jobName);
            trigger.setJobGroup(jobGroup);
            trigger.setCronExpression(cronExpression);
            trigger.setCalendarName("".equals(filterName) ? null : filterName);
            trigger.setVolatility(jobDetail.isVolatile());

            Map<String, String> params = triggerData.getJobParameters();

            // NOTE: Do not create an empty map. There is a bug related to empty JobDataMaps and Derby for quartz 1.6.0.
            JobDataMap map = new JobDataMap(params == null ? new HashMap<String, String>() : params);

            // all triggers must be associated with the user that scheduled them.
            ISecurityService ss = SchedulerActivator.getSecurityService();
            if (ss != null && ss.getUserSession() != null && ss.getUserSession().getPrincipal() != null)
            {
                map.put(USERNAME, ss.getUserSession().getPrincipal().getName());
            }
            trigger.setJobDataMap(map);

            if (startTime != null)
            {
                trigger.setStartTime(startTime);
            }

            if (endTime != null)
            {
                trigger.setEndTime(endTime);
            }

            if (timeZone != null)
            {
                trigger.setTimeZone(TimeZone.getTimeZone(timeZone));
            }

            // Check if it already exists
            if (scheduler.getTrigger(triggerName, triggerGroup) == null)
            {
                scheduler.scheduleJob(trigger);
            }
            else
            {
                scheduler.rescheduleJob(triggerName, triggerGroup, trigger);
            }

            schedEventProducer.jobScheduled(trigger);
        }
        catch (ParseException e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
        catch (org.quartz.SchedulerException e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    // CHECKSTYLE:ON

    /** {@inheritDoc} */
    public boolean unscheduleJob(String triggerName, String groupName)
    {
        try
        {
            boolean result = scheduler.unscheduleJob(triggerName, groupName);
            if (result)
            {
                schedEventProducer.jobUnscheduled(triggerName, groupName);
            }
            return result;
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public String[] getJobGroupNames()
    {
        try
        {
            return scheduler.getJobGroupNames();
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public TriggerData getTrigger(String triggerName, String groupName)
    {
        try
        {
            TriggerData data = null;
            Trigger qtzTrigger = scheduler.getTrigger(triggerName, groupName);
            if (qtzTrigger instanceof CronTrigger)
            {
                CronTrigger cronTrigger = (CronTrigger) qtzTrigger;
                data = new TriggerData();
                data.setJobName(cronTrigger.getJobName());
                data.setJobGroup(cronTrigger.getJobGroup());
                data.setTriggerName(cronTrigger.getName());
                data.setTriggerGroup(cronTrigger.getGroup());
                data.setFilterName(cronTrigger.getCalendarName());
                data.setTimeZone(cronTrigger.getTimeZone().getID());
                data.setStartTime(cronTrigger.getStartTime());
                data.setEndTime(cronTrigger.getEndTime());
                data.setCronExpression(cronTrigger.getCronExpression());
                data.setPreviousFireTime(cronTrigger.getPreviousFireTime());
                data.setNextFireTime(cronTrigger.getNextFireTime());
                data.setFinalFireTime(cronTrigger.getFinalFireTime());
                data.setJobParameters(cronTrigger.getJobDataMap());

                int triggerState = scheduler.getTriggerState(triggerName, groupName);
                data.setPaused((triggerState & CronTrigger.STATE_PAUSED) != 0);
            }

            return data;
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public boolean interruptJob(String jobName, String groupName)
    {
        try
        {
            return scheduler.interrupt(jobName, groupName);
        }
        catch (UnableToInterruptJobException e)
        {
            LOGGER.warn(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public boolean interruptJob(int jobId)
    {
        try
        {
            boolean foundAndKilled = false;

            List currentlyExecutingJobs = scheduler.getCurrentlyExecutingJobs();
            for (Iterator iter = currentlyExecutingJobs.iterator(); iter.hasNext();)
            {
                JobExecutionContext currentJob = (JobExecutionContext) iter.next();
                Job jobInstance = currentJob.getJobInstance();
                ExecutionData data = (ExecutionData) currentJob.get(ExecutionData.class);
                data.setCanceled(true);
                save(data);

                if (jobId == data.getId() && jobInstance instanceof InterruptableJob)
                {
                    InterruptableJob job = (InterruptableJob) jobInstance;
                    foundAndKilled = true;
                    job.interrupt();

                    break;
                }
            }

            return foundAndKilled;
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public void pauseTrigger(String triggerName, String groupName)
    {
        try
        {
            if (triggerName == null)
            {
                scheduler.pauseTriggerGroup(groupName);
            }
            else if (groupName != null)
            {
                scheduler.pauseTrigger(triggerName, groupName);
            }
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public void resumeTrigger(String triggerName, String groupName)
    {
        try
        {
            if (triggerName == null)
            {
                scheduler.pauseTriggerGroup(groupName);
            }
            else if (groupName != null)
            {
                scheduler.resumeTrigger(triggerName, groupName);
            }
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public String[] getTriggerGroupNames()
    {
        try
        {
            return scheduler.getTriggerGroupNames();
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public String[] getTriggerNames(String groupName)
    {
        try
        {
            return scheduler.getTriggerNames(groupName);
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public List<TriggerData> getTriggersOfJob(String jobName, String jobGroup)
    {
        try
        {
            Trigger[] triggers = scheduler.getTriggersOfJob(jobName, jobGroup);

            List<TriggerData> result = new LinkedList<TriggerData>();
            for (Trigger trigger : triggers)
            {
                if (trigger instanceof CronTrigger)
                {
                    result.add(convertTrigger((CronTrigger) trigger));
                }
            }

            return result;
        }
        catch (org.quartz.SchedulerException e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public void pauseJob(String jobName, String jobGroup)
    {
        try
        {
            if (jobName == null)
            {
                scheduler.pauseJobGroup(jobGroup);
            }
            else if (jobGroup != null)
            {
                scheduler.pauseTrigger(jobName, jobGroup);
            }
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public void resumeJob(String jobName, String jobGroup)
    {
        try
        {
            if (jobName == null)
            {
                scheduler.resumeJobGroup(jobGroup);
            }
            else if (jobGroup != null)
            {
                scheduler.resumeTrigger(jobName, jobGroup);
            }
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public void addFilter(FilterData filterData, boolean replace, boolean updateTriggers)
    {
        try
        {
            String cronExpression = filterData.getCronExpression();
            String timeZone = filterData.getTimeZone();

            CronCalendar calendar = new CronCalendar(cronExpression);
            if (timeZone != null)
            {
                calendar.setTimeZone(TimeZone.getTimeZone(timeZone));
            }

            scheduler.addCalendar(filterData.getFilterName(), calendar, replace, updateTriggers);
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public boolean deleteFilter(String filterName)
    {
        try
        {
            return scheduler.deleteCalendar(filterName);
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public FilterData getFilter(String filterName)
    {
        try
        {
            CronCalendar calendar = (CronCalendar) scheduler.getCalendar(filterName);
            if (calendar != null)
            {
                FilterData filterData = new FilterData();
                filterData.setFilterName(filterName);
                filterData.setCronExpression(calendar.getCronExpression().getCronExpression());
                filterData.setTimeZone(calendar.getTimeZone().getID());
                return filterData;
            }
            else
            {
                return null;
            }
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public FilterData[] getAllFilters()
    {
        String[] names = getFilterNames();
        FilterData[] filters = new FilterData[names.length];
        for (int i = 0; i < names.length; i++)
        {
            filters[i] = getFilter(names[i]);
        }
        return filters;
    }

    /** {@inheritDoc} */
    public String[] getFilterNames()
    {
        try
        {
            return scheduler.getCalendarNames();
        }
        catch (Exception e)
        {
            LOGGER.error(e.getMessage(), e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public ExecutionData runExistingJobNow(String jobName, String jobGroup)
    {
        try
        {
            JobDetail detail = scheduler.getJobDetail(jobName, jobGroup);
            if (detail == null)
            {
                return null;
            }

            return runNow(detail, false);
        }
        catch (Exception e)
        {
            LOGGER.error(e.getMessage(), e);
            throw new RuntimeException(e);
        }
    }

    /** {@inheritDoc} */
    public ExecutionData runNow(JobData jobData)
    {
        String jobName = jobData.getJobName();
        String jobGroup = jobData.getJobGroup();
        String jobDescription = jobData.getDescription();
        Map<String, String> jobParameters = jobData.getJobParameters();
        String jobTypeName = jobData.getJobType();
        JobType jobType = jobTypeByName.get(jobTypeName);
        Class jobClass = jobType.getJobClass();

        if (jobData.getJobName() == null || jobGroup == null || jobClass == null)
        {
            throw new RuntimeException(JOB_NAME_GROUP_OR_TYPE_IS_INVALID);
        }

        JobDetail detail = new JobDetail(jobName, jobGroup, jobClass);
        detail.setDurability(false);
        detail.setVolatility(true);
        detail.setDescription(jobDescription);
        JobDataMap dataMap = new JobDataMap(jobParameters != null ? jobParameters : new HashMap<String, String>());
        detail.setJobDataMap(dataMap);

        try
        {
            return runNow(detail, true);
        }
        catch (Exception e)
        {
            LOGGER.error(e.getMessage(), e);
            throw new RuntimeException(e);
        }
    }

    // CHECKSTYLE:OFF
    private ExecutionData runNow(JobDetail detail, boolean isUnsavedJob) throws org.quartz.SchedulerException
    {
        checkRunPermission(detail);

        int uniqueId;
        try
        {
            uniqueId = RunNowIdElf.getExecutionId();
        }
        catch (SQLException e)
        {
            throw new org.quartz.SchedulerException("Unable to obtain RunNow ID", e);
        }

        if (isUnsavedJob)
        {
            detail.setName(String.format("%s (Run now ID%d)", detail.getName(), uniqueId));
        }

        String jobName = detail.getName();

        SimpleTrigger trigger = new SimpleTrigger(jobName, String.format("%s : ID%d", detail.getGroup(), uniqueId));
        trigger.setJobName(jobName);
        trigger.setJobGroup(detail.getGroup());
        trigger.setVolatility(true);

        JobDataMap map = new JobDataMap();
        // NOTE: Do not create an empty map. There is a bug related to empty JobDataMaps and Derby for quartz 1.6.0.
        trigger.setJobDataMap(map);

        ISecurityService ss = SchedulerActivator.getSecurityService();
        if (ss != null && ss.getUserSession() != null && ss.getUserSession().getPrincipal() != null)
        {
            map.put(USERNAME, ss.getUserSession().getPrincipal().getName());
        }

        Transaction suspended = TransactionElf.suspend();
        TransactionElf.beginOrJoinTransaction();
        ExecutionData execution = createExecution(trigger, detail.getJobClass());
        save(execution);
        TransactionElf.commit();
        TransactionElf.resume(suspended);

        map.put("executionId", execution.getId());

        if (isUnsavedJob)
        {
            scheduler.scheduleJob(detail, trigger);
        }
        else
        {
            scheduler.scheduleJob(trigger);
        }

        return execution;
    }

    // CHECKSTYLE:ON

    /** {@inheritDoc} */
    public ExecutionData getExecutionDataById(int executionId)
    {
        Session session = SchedulerActivator.getSessionFactory().getCurrentSession();
        return (ExecutionData) session.get(ExecutionData.class, executionId);
    }

    /** {@inheritDoc} */
    public PageData getExecutionData(PageData pageData, String sortColumn, boolean descending)
    {
        Session session = SchedulerActivator.getSessionFactory().getCurrentSession();

        Criteria criteria = session.createCriteria(ExecutionData.class).add(Restrictions.isNotNull("startTime")).setFirstResult(pageData.getOffset())
                                   .setMaxResults(pageData.getPageSize());

        if (pageData.getOffset() == 0)
        {
            // Set the total result size into the page data.
            criteria.setProjection(Projections.count("id"));

            Integer total = (Integer) criteria.uniqueResult();
            pageData.setTotal(total);

            criteria.setProjection(null);
        }

        if (sortColumn != null)
        {
            criteria.addOrder((descending ? Order.desc(sortColumn.trim()) : Order.asc(sortColumn.trim())));
        }

        List<ExecutionData> list = new ArrayList<ExecutionData>();
        ScrollableResults scroll = criteria.scroll(ScrollMode.SCROLL_INSENSITIVE);
        while (scroll.next())
        {
            list.add((ExecutionData) scroll.get(0));
        }
        scroll.close();

        pageData.setExecutionData(list);

        return pageData;
    }

    /**
     * Start the Quartz Scheduler.
     *
     * @throws SchedulerException thrown if the Scheduler can't start.
     */
    public void start() throws SchedulerException
    {
        try
        {
            scheduler.start();
            LOGGER.debug("Scheduler Summary:\n" + scheduler.getMetaData().getSummary());
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /**
     * Shutdown the Quartz Scheduler.
     *
     * @throws SchedulerException thrown if there was an error shutting down the Quartz Scheduler
     */
    public void shutdown() throws SchedulerException
    {
        try
        {
            if (!scheduler.isShutdown())
            {
                scheduler.shutdown();
            }
        }
        catch (Exception e)
        {
            LOGGER.error(e);
            throw new RuntimeException(e);
        }
    }

    /**
     * Get a reference to the 'raw' underlying Quartz scheduler.  This
     * is for ZipTie internal server use only.
     *
     * @return a reference to the Quartz scheduler
     */
    public org.quartz.Scheduler getQuartzScheduler()
    {
        return scheduler;
    }

    /**
     * Register a new job type.
     *
     * @param name common name of the job type
     * @param clazz the job class
     * @param cudPermission the permission string for create/update/delete, or null
     * @param runPermission the permission string for run, or null
     */
    public void registerJobType(String name, Class<?> clazz, String cudPermission, String runPermission)
    {
        try
        {
            JobType jobType = new JobType();
            jobType.setTypeName(name);
            jobType.setJobClass(clazz);
            jobType.setCudPermission(cudPermission);
            jobType.setRunPermission(runPermission);

            jobTypeByName.put(name, jobType);
            jobNameByType.put(clazz, name);
        }
        catch (Exception e)
        {
            LOGGER.error("Unable to register job " + name + " of type " + clazz.getName());
        }
    }

    /**
     * Unregister a previously registered job type.
     * @param name the name of the job type
     * @param clazz the class of the job type
     * @throws SchedulerException if the supplied class does not match the class
     * previously registered for the supplied name.
     */
    public void unregisterJobType(String name, Class clazz) throws SchedulerException
    {
        JobType jobType = jobTypeByName.get(name);
        if (clazz.equals(jobType.getJobClass()))
        {
            jobTypeByName.remove(name);
            jobNameByType.remove(clazz);
        }
        else
        {
            throw new SchedulerException("unmatched job registration: " + name + " to " + clazz);
        }
    }

    private TriggerData convertTrigger(CronTrigger cronTrigger) throws org.quartz.SchedulerException
    {
        TriggerData data = new TriggerData();
        data.setJobName(cronTrigger.getJobName());
        data.setJobGroup(cronTrigger.getJobGroup());
        data.setTriggerName(cronTrigger.getName());
        data.setTriggerGroup(cronTrigger.getGroup());
        data.setFilterName(cronTrigger.getCalendarName());
        data.setTimeZone(cronTrigger.getTimeZone().getID());
        data.setStartTime(cronTrigger.getStartTime());
        data.setEndTime(cronTrigger.getEndTime());
        data.setCronExpression(cronTrigger.getCronExpression());
        data.setPreviousFireTime(cronTrigger.getPreviousFireTime());
        data.setNextFireTime(cronTrigger.getNextFireTime());
        data.setFinalFireTime(cronTrigger.getFinalFireTime());

        int triggerState = scheduler.getTriggerState(cronTrigger.getName(), cronTrigger.getGroup());
        data.setPaused((triggerState & CronTrigger.STATE_PAUSED) != 0);

        return data;
    }

    protected void save(ExecutionData execution)
    {
        if (!SchedulerActivator.isRAMStore())
        {
            boolean success = false;
            boolean own = TransactionElf.beginOrJoinTransaction();
            try
            {
                Session session = SchedulerActivator.getSessionFactory().getCurrentSession();

                session.saveOrUpdate(execution);
                session.flush();

                success = true;
            }
            finally
            {
                if (success)
                {
                    if (own)
                    {
                        TransactionElf.commit();
                    }
                }
                else
                {
                    TransactionElf.rollback();
                }
            }
        }
    }

    protected ExecutionData createExecution(Trigger trigger, Class<?> jobClass)
    {
        ExecutionData execution = new ExecutionData();
        execution.setJobGroup(trigger.getJobGroup());
        execution.setJobName(trigger.getJobName());
        execution.setJobClass(jobClass.getName());
        execution.setJobType(jobNameByType.get(jobClass));
        execution.setTriggerGroup(trigger.getGroup());
        execution.setTriggerName(trigger.getName());
        execution.setExecutor(trigger.getJobDataMap().getString(USERNAME));
        return execution;
    }

    private void checkRunPermission(JobDetail detail) throws org.quartz.SchedulerException
    {
        ISecurityService ss = SchedulerActivator.getSecurityService();
        if (ss != null && ISecureJob.class.isAssignableFrom(detail.getJobClass()))
        {
            try
            {
                ISecureJob secureJob = (ISecureJob) detail.getJobClass().newInstance();
                if (!secureJob.validateRunOperation(detail))
                {
                    String jobType = jobNameByType.get(detail.getJobClass());
                    IUserSession userSession = ss.getUserSession();
                    throw new org.quartz.SchedulerException(String.format(MSG_EXECUTION_NOT_ALLOWED, jobType, userSession.getPrincipal()));
                }
            }
            catch (Exception e)
            {
                throw new RuntimeException(e);
            }
        }
    }

    private void checkCudPermission(JobData jobData) throws org.quartz.SchedulerException
    {
        String jobTypeName = jobData.getJobType();
        JobType jobType = jobTypeByName.get(jobTypeName);
        Class jobClass = jobType.getJobClass();

        String cudPermission = jobType.getCudPermission();
        ISecurityService ss = SchedulerActivator.getSecurityService();

        // only acquire the ZPrincipal if there are permissions to be checked.  there
        // are instances where a server-side component will call addJob(...) and not
        // require permission checks, and in such cases there is no ZPrincipal...
        if (ss != null && (cudPermission != null || ISecureJob.class.isAssignableFrom(jobClass)))
        {
            IUserSession userSession = ss.getUserSession();

            if (cudPermission != null && !userSession.checkHasPermission(cudPermission))
            {
                throw new org.quartz.SchedulerException(String.format(MSG_MODIFICATION_NOT_ALLOWED, jobType, userSession.getPrincipal()));
            }

            if (ISecureJob.class.isAssignableFrom(jobClass))
            {
                try
                {
                    ISecureJob secureJob = (ISecureJob) jobClass.newInstance();
                    if (!secureJob.validateCudOperation(jobData))
                    {
                        throw new org.quartz.SchedulerException(String.format(MSG_MODIFICATION_NOT_ALLOWED, jobType, userSession.getPrincipal()));
                    }
                }
                catch (Exception e)
                {
                    throw new RuntimeException(e);
                }
            }
        }
    }
}
