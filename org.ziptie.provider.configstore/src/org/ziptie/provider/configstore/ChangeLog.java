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
package org.ziptie.provider.configstore;

import java.util.Date;
import java.util.List;

/**
 * ChangeLog
 */
public class ChangeLog
{
    private List<Change> changes;
    private Date timestamp;

    /**
     * Default constructor.
     */
    public ChangeLog()
    {
        // default constructor
    }

    /**
     * Get the collection of changes that make up this revision.
     *
     * @return a list of changes
     */
    public List<Change> getChanges()
    {
        return changes;
    }

    /**
     * Set the list of changed changes.
     *
     * @param newPaths a <code>List</code> of changed changes
     */
    public void setChanges(List<Change> newPaths)
    {
        changes = newPaths;
    }

    /**
     * A timestamp representing the time the configuration was captured.  Accuracy is
     * to the millisecond level to serve as a unique identifier of the revision for the
     * given device.  It provides approximate indication as to when the configuration was
     * captured (probably within several seconds) but the specific instant in time
     * reflected by this timestamp only guaranteed to be between the time the configuration
     * was captured from the device and when the configuration was versioned in the
     * Configuration Store.
     *
     * @return the timestamp that serves as a unique identifier for a revision of
     *    configuration for the given device
     */
    public Date getTimestamp()
    {
        return timestamp;
    }

    /**
     * @param timestamp the timestamp to set
     */
    public void setTimestamp(Date timestamp)
    {
        this.timestamp = timestamp;
    }
}
