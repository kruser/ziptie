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
 */
package org.ziptie.server.job.backup;

import org.ziptie.adapters.Operation;
import org.ziptie.net.snmp.TrapSender;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.job.internal.CoreJobsActivator;

/**
 * Sends an SNMP trap on a failed backup
 */
public class BackupResultsTrapSender implements IBackupCompletionListener
{
    /** {@inheritDoc} */
    public void complete(int executionId, ZDeviceCore device, Throwable throwable, String outcome)
    {
        if (outcome.equals(Outcome.FAILURE.name()) || outcome.equals(Outcome.WARNING.name()) || outcome.equals(Outcome.EXCEPTION.name()))
        {
            TrapSender trapSender = CoreJobsActivator.getTrapSender();

            String hostname = device.getHostname() == null ? "" : device.getHostname(); //$NON-NLS-1$
            trapSender.sendFailedOperationTrap(hostname, device.getIpAddress(), device.getManagedNetwork(), Operation.backup.name(), throwable.getMessage());
        }
    }
}
