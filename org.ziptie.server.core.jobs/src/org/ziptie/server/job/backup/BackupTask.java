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

import java.io.File;

import javax.xml.stream.XMLStreamException;

import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;
import org.ziptie.common.StringElf;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.net.client.Backup;
import org.ziptie.net.client.ConnectionPath;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.credentials.CredentialsProvider;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.job.AbstractAdapterTask;
import org.ziptie.server.job.AdapterEndpointElf;
import org.ziptie.server.job.internal.CoreJobsActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * The {@link BackupTask} class provides functionality for backing up all of device's configuration files and parsing various
 * device response to build a normalized data set about that device.
 */
public class BackupTask extends AbstractAdapterTask
{
    /**
     * Creates a new {@link BackupTask} instance and associates the specified {@link ZDeviceCore} object with it.
     * 
     * @param device The device to be associated with this {@link BackupTask} instance.
     */
    BackupTask(ZDeviceCore device)
    {
        super("backup", device); //$NON-NLS-1$
    }

    /** {@inheritDoc} */
    @Override
    protected Outcome performTask(CredentialSet credentialSet, ProtocolSet protocolSet, ConnectionPath connectionPath) throws Exception
    {
        ZDeviceCore device = getDevice();
        String ipAddress = device.getIpAddress();
        String adapterId = device.getAdapterId();
        String deviceId = Integer.toString(device.getDeviceId());
        SessionFactory sessionFactory = CoreJobsActivator.getSessionFactory();

        String backupOutput = null;
        File modelXmlFile = null;

        boolean success = false;
        TransactionElf.beginOrJoinTransaction();  // This thread OWNS this transaction

        try
        {
            // Execute the backup
            backupOutput = AdapterEndpointElf.getEndpoint(Backup.class, adapterId).backup(connectionPath);
            String filename = (ipAddress + "_backup.xml").replaceAll(":+", "."); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            modelXmlFile = StringElf.stringToTempFile(filename, backupOutput);
            backupOutput = null;

            Session currentSession = sessionFactory.getCurrentSession();
            StaxProcessor processor = new StaxProcessor();
            processor.process(device, modelXmlFile);

            currentSession.flush();

            // Save the protocol set and credential set that were both successfully used to backup the device
            // and map this information to the device itself.
            CredentialsProvider credProvider = CoreJobsActivator.getCredentialsProvider();
            credProvider.mapDeviceToProtocolSet(deviceId, protocolSet);
            credProvider.mapDeviceToCredentialSet(deviceId, credentialSet);

            success = true;

            return Outcome.SUCCESS;

        }
        // TODO dwhite: This is for checking to see the contents of a problematic XML related to
        // bug #635 (http://bugs.ziptie.org/show_bug.cgi?id=635)
        catch (XMLStreamException xse)
        {
            throw new XMLStreamException(xse.getMessage() + "\nProblematic XML:\n" + (backupOutput != null ? backupOutput : "null"), xse);
        }
        finally
        {
            if (modelXmlFile != null && modelXmlFile.exists())
            {
                modelXmlFile.delete();
            }

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

}
