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

import org.ziptie.credentials.CredentialSet;
import org.ziptie.net.client.ConnectionPath;
import org.ziptie.net.client.Restore;
import org.ziptie.net.client.RestoreFileInfo;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.configstore.Revision;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.job.AbstractAdapterTask;
import org.ziptie.server.job.AdapterEndpointElf;

/**
 * The {@link RestoreTask} class provides functionality for restoring a device configuration to a particular device.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public class RestoreTask extends AbstractAdapterTask
{
    private Revision revision;

    /**
     * Creates a new {@link RestoreTask} instance and associates the specified {@link ZDeviceCore} object with it.
     * 
     * @param device The device to be associated with this {@link RestoreTask} instance.
     * @param revision The revision of the configuration to be promoted.
     */
    RestoreTask(ZDeviceCore device, Revision revision)
    {
        super("restore", device); //$NON-NLS-1$
        this.revision = revision;
    }

    /**
     * Get the revision of the configuration that is being promoted.
     * 
     * @return The revision.
     */
    public Revision getRevision()
    {
        return revision;
    }

    /** {@inheritDoc} */
    @Override
    protected Outcome performTask(CredentialSet credentialSet, ProtocolSet protocolSet, ConnectionPath connectionPath) throws Exception
    {
        String adapterId = getDevice().getAdapterId();

        // Construct the SOAP-compatible restore file info object to store all the information about
        // the device configuration file that is being restored to the device
        RestoreFileInfo restoreFileInfo = new RestoreFileInfo();
        restoreFileInfo.setFullPathOnDevice(revision.getPath());
        restoreFileInfo.setBase64EncodedFileBlob(revision.getContent());

        // Execute the restore operation
        AdapterEndpointElf.getEndpoint(Restore.class, adapterId).restore(connectionPath, restoreFileInfo);
        return Outcome.SUCCESS;
    }
}
