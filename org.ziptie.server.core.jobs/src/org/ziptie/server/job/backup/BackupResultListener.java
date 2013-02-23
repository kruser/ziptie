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
package org.ziptie.server.job.backup;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.Properties;

import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.hibernate.classic.Session;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.provider.devices.ZDeviceStatus;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.job.PerlErrorParserElf;
import org.ziptie.server.job.AdapterException.ErrorCode;
import org.ziptie.server.job.internal.CoreJobsActivator;
import org.ziptie.zap.jms.EventElf;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Backup completion listener that persists the status of the latest backup for a device.
 */
public class BackupResultListener implements IBackupCompletionListener
{
    private static final String BACKUP_QUEUE = "backup"; //$NON-NLS-1$
    private static final String UTF_8_ENCODING = "UTF-8"; //$NON-NLS-1$
    private static final String UNABLE_TO_SEND_JMS_EVENT = "Unable to send JMS event"; //$NON-NLS-1$

    private static final String EVENT_BACKUP_COMPLETE = "complete"; //$NON-NLS-1$

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public void complete(int executionId, ZDeviceCore device, Throwable throwable, String outcome)
    {
        if (outcome.equals(Outcome.CANCELLED.name()))
        {
            return;
        }

        TransactionElf.beginOrJoinTransaction();

        Session session = CoreJobsActivator.getSessionFactory().getCurrentSession();
        ZDeviceStatus result = (ZDeviceStatus) session.get(ZDeviceStatus.class, device.getDeviceId());

        boolean success = false;
        try
        {
            result.setLastBackupAttempt(new Date());

            if (throwable != null)
            {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                throwable.printStackTrace(new PrintStream(baos));
                result.setBackupStatusMessage(cleanupStatusMessage(baos.toString("UTF-8")));

                // Parse the throwable for an error code
                ErrorCode errorResult = PerlErrorParserElf.getErrorCodeFromException(throwable);
                result.setBackupStatus(errorResult.name());
            }
            else
            {
                // Set the result as the specified outcome
                result.setBackupStatus(outcome);
                result.setBackupStatusMessage(null);
            }

            sendEvent(executionId, result);

            session.saveOrUpdate(result);
            success = true;
        }
        catch (UnsupportedEncodingException e)
        {
            Logger.getLogger(BackupResultListener.class).error("Unable to encode status message.", e);
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

    @SuppressWarnings("nls")
    private void sendEvent(int executionId, ZDeviceStatus device)
    {
        try
        {
            Properties properties = new Properties();
            properties.setProperty("IpAddress", device.getIpAddress());
            properties.setProperty("ManagedNetwork", device.getManagedNetwork());
            properties.setProperty("Result", device.getBackupStatus());
            properties.setProperty("ExecutionId", String.valueOf(executionId));
            if (device.getBackupStatusMessage() != null)
            {
                properties.setProperty("Message", device.getBackupStatusMessage());
            }

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            properties.storeToXML(baos, "", UTF_8_ENCODING); //$NON-NLS-1$

            // Tell the producer to send the message
            TextMessage message = EventElf.createTextMessage(BACKUP_QUEUE, baos.toString(UTF_8_ENCODING));
            message.setJMSType(EVENT_BACKUP_COMPLETE);
            EventElf.sendMessage(BACKUP_QUEUE, message);
        }
        catch (Exception e)
        {
            Logger.getLogger(BackupResultListener.class).error(UNABLE_TO_SEND_JMS_EVENT, e);
        }
    }

    // CHECKSTYLE:OFF
    private String cleanupStatusMessage(String message)
    {
        StringBuilder out = new StringBuilder();

        char[] chars = message.toCharArray();
        for (char c : chars)
        {
            // These are valid or escapable XML characters.  Everything else we'll just replace with its value in hex.
            if ((c == 0x9) || (c == 0xA) || (c == 0xD) || ((c >= 0x20) && (c <= 0xD7FF)) || ((c >= 0xE000) && (c <= 0xFFFD))
                    || ((c >= 0x10000) && (c <= 0x10FFFF)))
            {
                out.append(c);
            }
            else
            {
                out.append("0x").append(Integer.toHexString(c)); //$NON-NLS-1$
            }
        }

        return out.toString();
    }
    // CHECKSTYLE:ON
}
