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

package org.ziptie.server.job.backup;

import java.io.ByteArrayOutputStream;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.Semaphore;

import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.quartz.InterruptableJob;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.UnableToInterruptJobException;
import org.ziptie.provider.devices.DeviceResolutionElf;
import org.ziptie.provider.devices.IDeviceProvider;
import org.ziptie.provider.devices.ServerDeviceElf;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.provider.scheduler.ExecutionData;
import org.ziptie.server.dispatcher.ITask;
import org.ziptie.server.dispatcher.ITaskListener;
import org.ziptie.server.dispatcher.OperationManager;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.dispatcher.TaskCompleteEvent;
import org.ziptie.server.dispatcher.TaskEvent;
import org.ziptie.server.dns.IDnsResolveListener;
import org.ziptie.server.job.internal.CoreJobsActivator;
import org.ziptie.zap.jms.EventElf;
import org.ziptie.zap.jta.TransactionElf;

/**
 * BackupJob
 */
public class BackupJob implements InterruptableJob, ITaskListener
{
    private static final transient Logger LOGGER = Logger.getLogger(BackupJob.class);

    private static final String BACKUP_QUEUE = "backup"; //$NON-NLS-1$
    private static final String EVENT_BACKUP_START = "started"; //$NON-NLS-1$
    private static final String UTF_8_ENCODING = "UTF-8"; //$NON-NLS-1$
    private static final String UNABLE_TO_SEND_JMS_EVENT = "Unable to send JMS event"; //$NON-NLS-1$

    private OperationManager operationManager;
    private Integer batchID;
    private Semaphore semaphore;

    private String jobName;

    private ExecutionData execution;

    /** {@inheritDoc} */
    public void interrupt() throws UnableToInterruptJobException
    {
        if (operationManager == null || batchID == null)
        {
            return;
        }

        operationManager.cancelJobs(batchID);
        semaphore.release(Integer.MAX_VALUE);
    }

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public void execute(JobExecutionContext executionContext) throws JobExecutionException
    {
        operationManager = CoreJobsActivator.getOperationManager();
        if (operationManager == null)
        {
            throw new JobExecutionException("Unable to obtain Operation Dispatcher service."); //$NON-NLS-1$
        }

        jobName = executionContext.getJobDetail().getFullName();

        JobDetail jobDetail = executionContext.getJobDetail();
        LOGGER.info(String.format("Starting Backup Job '%s.%s'", jobDetail.getGroup(), jobDetail.getName()));

        try
        {
            JobDataMap jobDataMap = executionContext.getMergedJobDataMap();
            String ipData = jobDataMap.getString("ipResolutionData"); //$NON-NLS-1$
            String ipScheme = jobDataMap.getString("ipResolutionScheme"); //$NON-NLS-1$

            List<ITask> tasks = new LinkedList<ITask>();

            List<ZDeviceLite> devices = DeviceResolutionElf.resolveDevices(ipScheme, ipData);

            for (ZDeviceLite device : devices)
            {
                ITask task = new BackupTask(ServerDeviceElf.convertLiteToCore(device));
                tasks.add(task);
            }

            execution = (ExecutionData) executionContext.get(ExecutionData.class);
            sendEvent(execution, devices.size());

            if (devices.isEmpty())
            {
                LOGGER.info(String.format("No devices to backup in job '%s.%s'.", jobDetail.getGroup(), jobDetail.getName()));
                return;
            }

            try
            {
                semaphore = new Semaphore(tasks.size());
                semaphore.acquire(tasks.size());
                batchID = operationManager.submitJobs(tasks, false, this);
                semaphore.acquire(tasks.size());
            }
            catch (InterruptedException e)
            {
                e.printStackTrace();
            }
        }
        finally
        {
            LOGGER.info(String.format("Completed Backup Job '%s.%s'", jobDetail.getGroup(), jobDetail.getName()));
        }
    }

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public void eventOccurred(TaskEvent taskEvent)
    {
        ITask task = taskEvent.getTask();
        if (taskEvent instanceof TaskCompleteEvent)
        {
            TaskCompleteEvent completeEvent = (TaskCompleteEvent) taskEvent;

            // If the backup task has completed successfully, kick off a task to resolve the hostname
            if (completeEvent.getOutcome() == Outcome.SUCCESS)
            {
                semaphore.release();

                LOGGER.info(String.format("Backup %s in Job '%s' completed successfully.", task, jobName));
            }
            else
            {
                semaphore.release();

                if (completeEvent.getOutcome() == Outcome.CANCELLED)
                {
                    LOGGER.info(String.format("Backup %s cancelled for Job '%s'", task, jobName));
                }
                else if (completeEvent.getOutcome() == Outcome.EXCEPTION)
                {
                    LOGGER.warn(String.format("Backup %s in Job '%s' completed with exception", task, jobName));
                }
            }

            if (completeEvent.getOutcome() == Outcome.SUCCESS && Boolean.getBoolean("org.ziptie.useDnsForHostname")) //$NON-NLS-1$
            {
                ZDeviceCore device = ((BackupTask) task).getDevice();
                CoreJobsActivator.getDnsService().resolveHost(device.getIpAddress(), new DnsCallback(device, completeEvent));
            }
            else
            {
                notifyCompletionListeners(completeEvent, ((BackupTask) task).getDevice());
            }
        }
    }

    @SuppressWarnings("nls")
    private void sendEvent(ExecutionData executionData, int deviceCount)
    {
        try
        {
            Properties properties = new Properties();
            properties.setProperty("ExecutionId", String.valueOf(executionData.getId()));
            properties.setProperty("TotalDevices", String.valueOf(deviceCount));

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            properties.storeToXML(baos, "", UTF_8_ENCODING); //$NON-NLS-1$

            TextMessage message = EventElf.createTextMessage(BACKUP_QUEUE, baos.toString(UTF_8_ENCODING));
            message.setJMSType(EVENT_BACKUP_START);
            EventElf.sendMessage(BACKUP_QUEUE, message);
        }
        catch (Exception e)
        {
            Logger.getLogger(BackupResultListener.class).error(UNABLE_TO_SEND_JMS_EVENT, e);
        }
    }

    private void notifyCompletionListeners(TaskCompleteEvent event, ZDeviceCore device)
    {
        if (event.getTask() instanceof BackupTask)
        {
            IExtensionRegistry reg = Platform.getExtensionRegistry();
            IConfigurationElement[] configs = reg.getConfigurationElementsFor("org.ziptie.server.core.jobs.backupComplete"); //$NON-NLS-1$
            for (IConfigurationElement config : configs)
            {
                try
                {
                    IBackupCompletionListener listener = (IBackupCompletionListener) config.createExecutableExtension("class"); //$NON-NLS-1$
                    listener.complete(execution.getId(), device, event.getThrowable(), event.getOutcome().toString());
                }
                catch (CoreException e)
                {
                    LOGGER.error("Invalid listener contribution", e); //$NON-NLS-1$
                }
            }
        }
    }

    /**
     * DnsCallback
     */
    private class DnsCallback implements IDnsResolveListener
    {
        private ZDeviceCore device;
        private TaskCompleteEvent completeEvent;

        DnsCallback(ZDeviceCore device, TaskCompleteEvent completeEvent)
        {
            this.device = device;
            this.completeEvent = completeEvent;
        }

        public void resolvedName(String name)
        {
            try
            {
                if (name == null)
                {
                    return;
                }

                TransactionElf.beginOrJoinTransaction();

                try
                {
                    device.setHostname(name);

                    IDeviceProvider deviceProvider = CoreJobsActivator.getDeviceProvider();
                    deviceProvider.updateDevice(device.getIpAddress(), device.getManagedNetwork(), device);
                }
                finally
                {
                    TransactionElf.commit();
                }
            }
            finally
            {
                notifyCompletionListeners(completeEvent, device);
            }
        }
    }
}
