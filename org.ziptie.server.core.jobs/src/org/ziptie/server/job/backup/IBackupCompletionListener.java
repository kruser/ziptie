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

import org.ziptie.provider.devices.ZDeviceCore;


/**
 * Listener that will be called back on backup completion.  
 * Instances can be contributed using the 'backupComplete' extension point.
 */
public interface IBackupCompletionListener
{
    /**
     * Called when a backup has completed.  This is for both failures and successes.
     * @param executionId the execution id of the parent backup job
     * @param device The device
     * @param throwable An exception if one occurred or <code>null</code>
     * @param outcome A string the defining the outcome of the backup.  The possible outcome messages are:
     * "SUCCESS", "FAILURE", "WARNING", "EXCEPTION", and "CANCELLED".
     */
    void complete(int executionId, ZDeviceCore device, Throwable throwable, String outcome);
}
