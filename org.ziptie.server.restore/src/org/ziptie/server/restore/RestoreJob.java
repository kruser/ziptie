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
package org.ziptie.server.restore;

import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.Semaphore;

import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.quartz.InterruptableJob;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.ziptie.provider.configstore.IConfigStore;
import org.ziptie.provider.configstore.Revision;
import org.ziptie.provider.devices.DeviceResolutionElf;
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
import org.ziptie.server.restore.internal.RestoreActivator;
import org.ziptie.zap.jms.EventElf;
import org.ziptie.zap.jta.TransactionElf;

/**
 * The {@link RestoreJob} class provides the ability to execute a task to restore a configuration file to a device,
 * within the job/operation framework laid down by ZipTie.
 * 
 * @author Dylan White (dylamite@zipie.org)
 */
public class RestoreJob implements InterruptableJob, ITaskListener
{
    private static final transient Logger LOGGER = Logger.getLogger(RestoreJob.class);

    private static final String RESTORE_QUEUE = "restore"; //$NON-NLS-1$
    private static final String UTF_8_ENCODING = "UTF-8"; //$NON-NLS-1$

    // W3C DTF sans the timezone (assume GMT because the java simpe date format doesn't support the colon in the timezone offset.)
    private static final String TIMESTAMP_FORMAT = "yyyy-MM-dd'T'HH:mm:ss"; //$NON-NLS-1$


    private OperationManager operationManager;
    private ExecutionData execution;
    private Integer batchID;
    private Semaphore semaphore;
    private String jobName;

    /** {@inheritDoc} */
    public void interrupt()
    {
        if (operationManager == null || batchID == null)
        {
            return;
        }

        operationManager.cancelJobs(batchID);
        semaphore.release(Integer.MAX_VALUE);
    }

    /** {@inheritDoc} */
    public void execute(JobExecutionContext executionContext) throws JobExecutionException
    {
        operationManager = RestoreActivator.getOperationManager();
        if (operationManager == null)
        {
            throw new JobExecutionException(Messages.RestoreJob_noOpManager);
        }

        execution = (ExecutionData) executionContext.get(ExecutionData.class);

        jobName = executionContext.getJobDetail().getName();

        JobDetail jobDetail = executionContext.getJobDetail();
        LOGGER.info(Messages.bind(Messages.RestoreJob_starting, jobDetail.getGroup(), jobDetail.getName()));

        JobDataMap jobDataMap = executionContext.getMergedJobDataMap();
        String ipData = jobDataMap.getString("ipResolutionData"); //$NON-NLS-1$
        String ipScheme = jobDataMap.getString("ipResolutionScheme"); //$NON-NLS-1$
        String configPath = jobDataMap.getString("configPath"); //$NON-NLS-1$
        String configTimestamp = jobDataMap.getString("configTimestamp"); //$NON-NLS-1$;

        List<ITask> tasks = new LinkedList<ITask>();
        List<ZDeviceLite> devices = DeviceResolutionElf.resolveDevices(ipScheme, ipData);

        // A restore operation only supports one device and one configuration of that device
        if (!devices.isEmpty())
        {
            ZDeviceLite device = devices.get(0);

            Date date = null;
            try
            {
                SimpleDateFormat format = new SimpleDateFormat(TIMESTAMP_FORMAT);
                date = format.parse(configTimestamp);
            }
            catch (ParseException e)
            {
                String[] errorMessageInput = new String[] { configPath, device.getIpAddress(), device.getManagedNetwork(), jobName };
                throw new JobExecutionException(Messages.bind(Messages.RestoreJob_exception, errorMessageInput), e);
            }

            // Attempt to retrieve the revision specified by all the job parameters
            //
            // NOTE: We must begin or join a transaction because we can not assume that other providers
            // properly handle their own transactions
            Revision revision = null;
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            try
            {
                IConfigStore cs = RestoreActivator.getConfigStoreService();
                revision = cs.retrieveRevision(device.getIpAddress(), device.getManagedNetwork(), configPath, date);
            }
            finally
            {
                if (ownTransaction)
                {
                    TransactionElf.commit();
                }
            }

            // Ensure the the revision that was retrieved is valid
            if (revision == null)
            {
                String[] errorMessageInput = new String[] { configPath, device.getIpAddress(), device.getManagedNetwork(), jobName };
                throw new JobExecutionException(Messages.bind(Messages.RestoreJob_noRevision, errorMessageInput));
            }

            ITask task = new RestoreTask(ServerDeviceElf.convertLiteToCore(device), revision);
            tasks.add(task);
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
            Logger.getLogger(getClass()).warn(e.getMessage(), e);
        }
    }

    /** {@inheritDoc} */
    public void eventOccurred(TaskEvent taskEvent)
    {
        if (taskEvent instanceof TaskCompleteEvent)
        {
            TaskCompleteEvent completeEvent = (TaskCompleteEvent) taskEvent;
            RestoreTask task = (RestoreTask) taskEvent.getTask();

            ZDeviceCore device = task.getDevice();
            Revision revision = task.getRevision();

            Outcome outcome = completeEvent.getOutcome();
            try
            {
                String[] errorMessageInput = new String[] { revision.getPath(), device.getIpAddress(), device.getManagedNetwork(), jobName };

                if (outcome == Outcome.SUCCESS)
                {
                    LOGGER.info(Messages.bind(Messages.RestoreJob_success, errorMessageInput));

                    // Add a restore event
                    sendEvent(device, revision, outcome, null);

                }
                else if (outcome == Outcome.EXCEPTION)
                {
                    String errorMessage = Messages.bind(Messages.RestoreJob_exception, errorMessageInput);
                    LOGGER.warn(errorMessage);

                    // Write the exception associated with the restore job to a string
                    StringWriter writer = new StringWriter();
                    completeEvent.getThrowable().printStackTrace(new PrintWriter(writer));

                    // Add a restore event
                    sendEvent(device, revision, outcome, String.format("%s\n\n%s", errorMessage, writer.toString())); //$NON-NLS-1$
                }
                else if (outcome == Outcome.CANCELLED)
                {
                    LOGGER.info(Messages.bind(Messages.RestoreJob_cancelled, errorMessageInput));
                }
            }
            finally
            {
                semaphore.release();
            }
        }
    }

    /**
     * Creates an adds restore event to the {@link RestoreEventList} object that maintains all restore events.
     * 
     * @param device The {@link ZDeviceCore} object representing the device that was used in the restore task.
     * @param revision The {@link Revision} object representing the configuration file that was used in the restore task.
     * @param outcome The outcome of the restore task.
     * @param errorMessage The exception that may have been generated from the restore task.
     */
    @SuppressWarnings("nls")
    private void sendEvent(ZDeviceCore device, Revision revision, Outcome outcome, String errorMessage)
    {
        String ip = device.getIpAddress();
        String net = device.getManagedNetwork();
        String configPath = revision.getPath();

        // Create a properties object defining this restore job
        Properties restoreProperties = new Properties();
        restoreProperties.setProperty("IpAddress", ip);
        restoreProperties.setProperty("ManagedNetwork", net);
        restoreProperties.setProperty("ConfigPath", configPath);
        restoreProperties.setProperty("ConfigDate", revision.getLastChanged().toString());
        restoreProperties.setProperty("Error", (errorMessage != null ? errorMessage : ""));
        restoreProperties.setProperty("ExecutionId", String.valueOf(execution.getId()));
        restoreProperties.setProperty("Outcome", outcome.name());

        try
        {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            restoreProperties.storeToXML(baos, "", UTF_8_ENCODING); //$NON-NLS-1$

            // Tell the producer to send the message
            TextMessage message = EventElf.createTextMessage(RESTORE_QUEUE, baos.toString(UTF_8_ENCODING));
            message.setJMSType("complete");
            EventElf.sendMessage(RESTORE_QUEUE, message);
        }
        catch (Exception e)
        {
            LOGGER.error("Unable to send JMS message.", e);
        }
    }

}
