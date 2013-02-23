package org.ziptie.provider.scheduler;

import java.io.ByteArrayOutputStream;
import java.util.Properties;

import javax.jms.TextMessage;

import org.quartz.JobDetail;
import org.quartz.Trigger;
import org.quartz.listeners.SchedulerListenerSupport;
import org.ziptie.provider.scheduler.internal.SchedulerActivator;
import org.ziptie.zap.jms.EventElf;

/**
 * SchedulerEventProducer
 */
public class SchedulerEventProducer extends SchedulerListenerSupport
{
    private static final String UTF_8_ENCODING = "UTF-8";
    private static final String UNABLE_TO_SEND_JMS_EVENT = "Unable to send JMS event";
    private static final String SCHEDULER_QUEUE = "scheduler";
    private static final String JOB_TYPE = "job.type";
    private static final String JOB_NAME = "job.name";
    private static final String JOB_GROUP = "job.group";
    private static final String TRIGGER_NAME = "trigger.name";
    private static final String TRIGGER_GROUP = "trigger.group";
    private static final String EVENT_JOB_ADDED = "job.added";
    private static final String EVENT_JOB_DELETED = "job.deleted";
    private static final String EVENT_JOB_SCHEDULED = "job.scheduled";
    private static final String EVENT_JOB_UNSCHEDULED = "job.unscheduled";

    /**
     * Constructor.
     */
    public SchedulerEventProducer()
    {
    }

    /** {@inheritDoc} */
    @Override
    public void schedulerShutdown()
    {
    }

    /**
     * Generate a "job added" event.
     *
     * @param jobDetail the jobDetail object that was added
     */
    public void jobAdded(JobDetail jobDetail)
    {
        Properties properties = new Properties();
        properties.setProperty(JOB_GROUP, jobDetail.getGroup());
        properties.setProperty(JOB_NAME, jobDetail.getName());
        Scheduler scheduler = SchedulerActivator.getScheduler();
        properties.setProperty(JOB_TYPE, scheduler.getJobClassMapping().get(jobDetail.getJobClass()));

        sendEvent(EVENT_JOB_ADDED, properties);
    }

    /**
     * Generate a "job deleted" event.
     *
     * @param jobName the job name that was deleted
     * @param jobGroup the job group in which the job was deleted
     */
    public void jobDeleted(String jobName, String jobGroup)
    {
        Properties properties = new Properties();
        properties.setProperty(JOB_GROUP, jobGroup);
        properties.setProperty(JOB_NAME, jobName);

        sendEvent(EVENT_JOB_DELETED, properties);
    }

    /** {@inheritDoc} */
    public void jobUnscheduled(String triggerName, String triggerGroup)
    {
        Properties properties = new Properties();
        properties.setProperty(TRIGGER_GROUP, triggerGroup);
        properties.setProperty(TRIGGER_NAME, triggerName);

        sendEvent(EVENT_JOB_UNSCHEDULED, properties);
    }

    /** {@inheritDoc} */
    @Override
    public void jobScheduled(Trigger trigger)
    {
        Properties properties = new Properties();
        properties.setProperty(TRIGGER_GROUP, trigger.getGroup());
        properties.setProperty(TRIGGER_NAME, trigger.getName());

        sendEvent(EVENT_JOB_SCHEDULED, properties);
    }

    /** {@inheritDoc} */
    @Override
    public void jobsPaused(String jobName, String jobGroup)
    {
        super.jobsPaused(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    @Override
    public void jobsResumed(String jobName, String jobGroup)
    {
        super.jobsResumed(jobName, jobGroup);
    }

    /** {@inheritDoc} */
    @Override
    public void triggersPaused(String triggerName, String triggerGroup)
    {
        super.triggersPaused(triggerName, triggerGroup);
    }

    /** {@inheritDoc} */
    @Override
    public void triggersResumed(String triggerName, String triggerGroup)
    {
        super.triggersResumed(triggerName, triggerGroup);
    }

    private void sendEvent(String type, Properties properties)
    {
        try
        {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            properties.storeToXML(baos, "", UTF_8_ENCODING); //$NON-NLS-1$

            // Tell the producer to send the message
            TextMessage message = EventElf.createTextMessage(SCHEDULER_QUEUE, baos.toString(UTF_8_ENCODING));
            message.setJMSType(type);
            EventElf.sendMessage(SCHEDULER_QUEUE, message);
        }
        catch (Exception e)
        {
            getLog().error(UNABLE_TO_SEND_JMS_EVENT, e);
        }
    }
}
