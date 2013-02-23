package org.ziptie.provider.scheduler;

import java.util.Date;

import org.hibernate.Session;
import org.quartz.JobExecutionContext;
import org.quartz.Trigger;
import org.quartz.listeners.TriggerListenerSupport;
import org.ziptie.provider.scheduler.internal.SchedulerActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Listens to the scheduler.
 */
public class ExecutionTriggerListener extends TriggerListenerSupport
{
    /**
     * Constructor.
     */
    public ExecutionTriggerListener()
    {
        getLog().info(this.getClass().getSimpleName() + " registered with scheduler.");
    }

    /** {@inheritDoc} */
    @Override
    public void triggerComplete(Trigger trigger, JobExecutionContext context, int triggerInstructionCode)
    {
        ExecutionData execution = (ExecutionData) context.get(ExecutionData.class);

        execution.setEndTime(new Date(context.getFireTime().getTime() + context.getJobRunTime()));

        Scheduler scheduler = SchedulerActivator.getScheduler();
        if (scheduler != null)
        {
            scheduler.save(execution);
        }
    }

    /** {@inheritDoc} */
    @Override
    public void triggerFired(Trigger trigger, JobExecutionContext context)
    {
        TransactionElf.beginOrJoinTransaction();

        boolean success = false;
        try
        {
            Scheduler scheduler = SchedulerActivator.getScheduler();

            ExecutionData execution = (ExecutionData) context.get(ExecutionData.class);
            if (execution == null)
            {
                Integer id = (Integer) context.getMergedJobDataMap().get("executionId");
                if (id == null || id == -1)
                {
                    execution = scheduler.createExecution(trigger, context.getJobDetail().getJobClass());
                    execution.setStartTime(context.getFireTime());
                    scheduler.save(execution);
                }
                else
                {
                    if (!SchedulerActivator.isRAMStore())
                    {
                        Session session = SchedulerActivator.getSessionFactory().getCurrentSession();

                        execution = (ExecutionData) session.get(ExecutionData.class, id);
                        execution.setStartTime(context.getFireTime());
                        session.update(execution);
                    }
                }

                context.put(ExecutionData.class, execution);
            }
            else
            {
                execution.setStartTime(context.getFireTime());
                scheduler.save(execution);
            }

            success = true;
        }
        finally
        {
            if (success)
            {
                TransactionElf.commit();
            }
            else
            {
                TransactionElf.rollback();
            }
        }
    }

    /** {@inheritDoc} */
    public String getName()
    {
        return this.getClass().getSimpleName();
    }
}
