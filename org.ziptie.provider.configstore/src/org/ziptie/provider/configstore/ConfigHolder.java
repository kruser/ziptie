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
package org.ziptie.provider.configstore;

import java.io.File;
import java.util.Date;
import java.util.zip.CRC32;
import java.util.zip.Checksum;

/**
 * Holds an unsaved configuration.
 */
public class ConfigHolder
{
    private File configFile;
    private String fullName;
    private String mediaType;
    private File lastRevisionFile;
    private Checksum checksum;
    private String type;
    private Date timestamp;
    private Date previousChange;

    /**
     * Constructor that takes the name of a configuration, it's contents,
     * and a flag indicating whether it is binary or not.
     *
     * @param configFile a handle to a configuration file
     * @param fullName the full name of the configuration file on the device 
     * @param mediaType the media type of the configuration file as reported by
     *    the adapter
     */
    public ConfigHolder(File configFile, String fullName, String mediaType)
    {
        this.configFile = configFile;
        this.setFullName(fullName);
        this.mediaType = mediaType;
        this.checksum = new CRC32();
    }

    /**
     * Get the full name of the configuration file including it's path on
     * the device.
     *
     * @return the full name of the configuration file
     */
    public String getFullName()
    {
        return fullName;
    }

    /**
     * Set the full name of the configuration file including it's path on
     * the device.
     *
     * @param fullName the full name
     */
    public void setFullName(String fullName)
    {
        this.fullName = fullName;
    }

    /**
     * Get the configuration file.
     *
     * @return a File object for the configuration file
     */
    public File getConfigFile()
    {
        return configFile;
    }

    /**
     * Get the media type as reported by the adapter.
     *
     * @return the media type of the configuration file
     */
    public String getMediaType()
    {
        return mediaType;
    }

    /**
     * Get the last revision file.
     *
     * @return the last revision file
     */
    public File getLastRevisionFile()
    {
        return lastRevisionFile;
    }

    /**
     * Set the last revision file.
     *
     * @param lastRevisionFile the last revision file
     */
    public void setLastRevisionFile(File lastRevisionFile)
    {
        this.lastRevisionFile = lastRevisionFile;
    }

    /**
     * Get the Checksum of this configuration.
     *
     * @return the Checksum object
     */
    public Checksum getChecksum()
    {
        return checksum;
    }

    /**
     * Get the type of change.  This is set by the IConfigStore after a change
     * has been recorded.
     *
     * @return the type of change.  'M'odification, 'A'ddition,'D'eletion.
     */
    public String getType()
    {
        return type;
    }

    /**
     * Get the type of change.  This is set by the IConfigStore after a change
     * has been recorded.
     *
     * @param type the type of change.  'M'odification, 'A'ddition,'D'eletion.
     */
    public void setType(String type)
    {
        this.type = type;
    }

    /**
     * Get the timestamp of change.  This is set by the IConfigStore after a change
     * has been recorded.
     *
     * @param timestamp the timestamp of change.
     */
    public void setTimestamp(Date timestamp)
    {
        this.timestamp = timestamp;
    }

    /**
     * Get the timestamp of change.  This is set by the IConfigStore after a change
     * has been recorded.
     *
     * @return the timestamp of change.
     */
    public Date getTimestamp()
    {
        return timestamp;
    }

    /**
     * Get the timestamp of the previous change for this configuration.
     *
     * @return the timestamp of the previous change, or null
     */
    public Date getPreviousChange()
    {
        return previousChange;
    }

    /**
     * Set the timestamp of the previous change for this configuration.
     *
     * @param previousChange the timestamp of the previous change, or null
     */
    public void setPreviousChange(Date previousChange)
    {
        this.previousChange = previousChange;
    }
}
