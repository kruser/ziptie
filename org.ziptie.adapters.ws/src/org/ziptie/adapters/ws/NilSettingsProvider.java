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
package org.ziptie.adapters.ws;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.util.Properties;

import org.apache.log4j.Logger;
import org.ziptie.net.servers.FileServerInfoElf;

/**
 * The {@link NilSettingsProvider} provides the ability to modify the settings for the Network Interface Layer (NIL).
 * 
 * @author Leo Bayer (lbayer@ziptie.org)
 * @author Dylan White (dylamite@ziptie.org)
 */
public class NilSettingsProvider implements INilSettingsProvider
{
    public static final int DEBUG_LOGGING_LEVEL = 0;
    public static final int FATAL_LOGGING_LEVEL = 1;
    public static final String LOGS_DIR = "scratch/logs"; //$NON-NLS-1$
    public static final String RECORDINGS_DIR = "scratch/recordings"; //$NON-NLS-1$
    public static final String TFTP_NAME = "TFTP"; //$NON-NLS-1$
    public static final String FTP_NAME = "FTP"; //$NON-NLS-1$
    public static final String NIL_SETTINGS_PROP_FILE = "network/nilSettings.properties"; //$NON-NLS-1$

    public static final String ENABLE_RECORDINGS_PROP = "adapters.enableRecordings"; //$NON-NLS-1$
    public static final String ENABLE_LOGGING_TO_FILE_PROP = "adapters.enableLoggingToFile"; //$NON-NLS-1$
    public static final String LOGGING_LEVEL_PROP = "adapters.loggingLevel"; //$NON-NLS-1$

    private static final Logger LOGGER = Logger.getLogger(NilSettingsProvider.class);

    private Properties nilSettingsProperties;
    private File adapterRecordingsDir;
    private File adapterLogsDir;
    private File nilSettingsPropFile;
    private String osgiConfigArea;
    private boolean enableRecordings;
    private boolean enableLoggingToFile;
    private int loggingLevel = FATAL_LOGGING_LEVEL;

    /**
     * Default constructor for the {@link NilSettingsProvider} class.
     */
    public NilSettingsProvider()
    {
        // Retrieve the base OSGI configuration area URI string
        osgiConfigArea = System.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

        // Create a URI that represents the location for storing recordings for adapter operations
        URI recordingDirURI = URI.create(osgiConfigArea + "/" + RECORDINGS_DIR); //$NON-NLS-1$

        // Create a URI that represents the location for storing logs for adapter operations
        URI logsDirURI = URI.create(osgiConfigArea + "/" + LOGS_DIR); //$NON-NLS-1$

        // Create the recording directory if it doesn't exist
        adapterRecordingsDir = new File(recordingDirURI);
        if (!adapterRecordingsDir.exists())
        {
            LOGGER.info("Directory to store recordings '" + adapterRecordingsDir.getAbsolutePath() + "' doesn't exist ... creating it.");
            adapterRecordingsDir.mkdirs();
        }

        // Create the logs directory if it doesn't exist
        adapterLogsDir = new File(logsDirURI);
        if (!adapterLogsDir.exists())
        {
            LOGGER.info("Directory to store adapter logs '" + adapterLogsDir.getAbsolutePath() + "' doesn't exist ... creating it.");
            adapterLogsDir.mkdirs();
        }

        // Grab the location of the NIL settings properties file
        URI nilSettingsPropURI = URI.create(osgiConfigArea + "/" + NIL_SETTINGS_PROP_FILE);
        nilSettingsPropFile = new File(nilSettingsPropURI);
        if (!nilSettingsPropFile.exists())
        {
            LOGGER.debug("Properties file for storing NIL-specific settings '" + nilSettingsPropFile.getAbsolutePath() + "' does not exist ... creating it.");
            try
            {
                nilSettingsPropFile.createNewFile();
            }
            catch (IOException e)
            {
                LOGGER.debug("IOException while attempting to create the NIL-specific properties file located at'" + nilSettingsPropFile.getAbsolutePath()
                        + "'!", e);
            }
        }

        // Create a new Properties object to store the properties about to be loaded
        nilSettingsProperties = new Properties();

        // Load the properties file
        InputStream in = null;
        try
        {
            LOGGER.debug("Loading NIL-specific properties file located at '" + nilSettingsPropFile.getAbsolutePath() + "'...");
            in = new BufferedInputStream(new FileInputStream(nilSettingsPropFile));
            nilSettingsProperties.load(in);
        }
        catch (FileNotFoundException e)
        {
            LOGGER.debug("Could not find NIL-specific properties file located at '" + nilSettingsPropFile.getAbsolutePath() + "'!");
        }
        catch (IOException e)
        {
            LOGGER.debug("IOException while attempting to load the NIL-specific properties file located at'" + nilSettingsPropFile.getAbsolutePath() + "'!", e);
        }

        // Initialize preferences based on the properties loaded
        enableLoggingToFile = Boolean.parseBoolean(nilSettingsProperties.getProperty(ENABLE_LOGGING_TO_FILE_PROP, "false"));
        enableRecordings = Boolean.parseBoolean(nilSettingsProperties.getProperty(ENABLE_RECORDINGS_PROP, "false"));
        loggingLevel = Integer.parseInt(nilSettingsProperties.getProperty(LOGGING_LEVEL_PROP, Integer.toString(FATAL_LOGGING_LEVEL)));
    }

    /** {@inheritDoc} */
    public FileServerInfo getFileServerInfo(String name)
    {
        return getFileServerInfoForIPv6(name, false);
    }

    /** {@inheritDoc} */
    public FileServerInfo getFileServerInfoForIPv6(String protocolName, boolean useIPv6)
    {
        FileServerInfo fsInfo = null;

        if (protocolName != null)
        {
            // Handle TFTP Server request
            if (protocolName.equalsIgnoreCase(TFTP_NAME))
            {
                String ipAddress = useIPv6 ? FileServerInfoElf.getTFTPServerIpV6Address() : FileServerInfoElf.getTFTPServerIpAddress();
                int port = FileServerInfoElf.getTFTPServerPort();
                String rootDir = FileServerInfoElf.getTFTPServerRootDir();

                fsInfo = new FileServerInfo(TFTP_NAME, ipAddress, port, rootDir);
            }
            // Handle FTP Server request
            else if (protocolName.equalsIgnoreCase(FTP_NAME))
            {
                String ipAddress = useIPv6 ? FileServerInfoElf.getFTPServerIpV6Address() : FileServerInfoElf.getFTPServerIpAddress();
                int port = FileServerInfoElf.getFTPServerPort();
                String rootDir = FileServerInfoElf.getFTPServerRootDir();

                fsInfo = new FileServerInfo(FTP_NAME, ipAddress, port, rootDir);
            }
        }

        return fsInfo;
    }

    /** {@inheritDoc} */
    public void enableLoggingAdapterOperationsToFile(boolean enable)
    {
        enableLoggingToFile = enable;

        // Save to properties file
        nilSettingsProperties.setProperty(ENABLE_LOGGING_TO_FILE_PROP, Boolean.toString(enableLoggingToFile));
        saveProperties();
    }

    /**
     * Determines whether or not logging of adapter operations to a file is enabled.
     * 
     * @return <code>true</code> if enabled, <code>false</code> if disabled.
     */
    public boolean isLoggingAdapterOperationsToFileEnabled()
    {
        return enableLoggingToFile;
    }

    /**
     * Retrieves the absolute path to where logs of adapter operations are stored.
     * 
     * @return The absolute path to where logs are stored.
     */
    public String getAdapterLogsDir()
    {
        return adapterLogsDir.getAbsolutePath();
    }

    /** {@inheritDoc} */
    public void setAdapterLoggingLevel(int level)
    {
        loggingLevel = level;

        // Save to properties file
        nilSettingsProperties.setProperty(LOGGING_LEVEL_PROP, Integer.toString(loggingLevel));
        saveProperties();
    }

    /**
     * Retrieves the logging level for adapter operations.
     * 
     * @return The logging level for adapter operations.
     */
    public int getAdapterLoggingLevel()
    {
        return loggingLevel;
    }

    /** {@inheritDoc} */
    public void enableRecordingAdapterOperations(boolean enable)
    {
        enableRecordings = enable;

        // Save to properties file
        nilSettingsProperties.setProperty(ENABLE_RECORDINGS_PROP, Boolean.toString(enableRecordings));
        saveProperties();
    }

    /**
     * Determines whether or not recording of adapter operations is enabled.
     * 
     * @return <code>true</code> if enabled, <code>false</code> if disabled.
     */
    public boolean isRecordingAdapterOperationsEnabled()
    {
        return enableRecordings;
    }

    /**
     * Retrieves the absolute path to where recordings of adapter operations are stored.
     * 
     * @return The absolute path to where recordings are stored.
     */
    public String getAdapterRecordingsDir()
    {
        return adapterRecordingsDir.getAbsolutePath();
    }

    /**
     * Saves the NIL-specific properties out to a file.
     */
    private void saveProperties()
    {
        OutputStream out = null;
        try
        {
            out = new BufferedOutputStream(new FileOutputStream(nilSettingsPropFile));
            nilSettingsProperties.store(out, "Generated by ZipTie - DO NOT DELETE!!!"); //$NON-NLS-1$
        }
        catch (FileNotFoundException e)
        {
            LOGGER.debug("Could not find NIL-specific properties file located at '" + nilSettingsPropFile.getAbsolutePath() + "'!");
        }
        catch (IOException e)
        {
            LOGGER.debug("IOException while attempting to save the NIL-specific properties file located at'" + nilSettingsPropFile.getAbsolutePath() + "'!", e);
        }
    }
}
