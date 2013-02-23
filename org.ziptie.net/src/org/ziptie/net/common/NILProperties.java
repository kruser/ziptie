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

package org.ziptie.net.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.Serializable;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Properties;

/**
 * The <code>NILProperties</code> provides functionality for reading in the "nil.properties" file found on the file system and providing
 * access to the properties stored within it.
 */
@SuppressWarnings("nls")
public final class NILProperties
{
    // discovery
    public static final String DISCOVERY_PING_PROTOCOL = "nil.discovery.ping.protocol";
    public static final String DISCOVERY_TCPPING_PORTS = "nil.discovery.ping.tcpPorts";
    public static final String DISCOVERY_TCPPING_CONNECTIONS = "nil.discovery.ping.tcpConnections";
    public static final String DISCOVERY_PING_SEMAPHORES = "nil.discovery.ping.semaphores";

    // trap sender
    public static final String SNMP_TRAP_RECEIVERS = "nil.snmp.trap.receivers";
    public static final String SNMP_TRAP_TIMEOUT = "nil.snmp.trap.timeout";
    public static final String SNMP_TRAP_RETRIES = "nil.snmp.trap.retries";

    // system
    public static final String NIL_PROPERTIES = "nil.properties";

    private static NILProperties instance;
    private static NILPropertiesMutex staticMutex = new NILPropertiesMutex();

    // -- Members
    private Properties properties;

    /**
     * Hidden constructor 
     *
     */
    private NILProperties()
    {
    }

    /**
     * NILPropertiesMutex
     */
    private static class NILPropertiesMutex implements Serializable
    {
        static final long serialVersionUID = 4120225075183264343L;
    }

    /**
     * 
     * @return a list of all properties
     */
    public List<String> getPropertyNames()
    {
        Enumeration enumeration = properties.propertyNames();
        ArrayList<String> propertyList = new ArrayList<String>();
        while (enumeration.hasMoreElements())
        {
            propertyList.add((String) enumeration.nextElement());
        }
        return propertyList;
    }

    /**
     * Parse out the Boolean value of a property
     * @param key the key
     * @return the parsed out boolean
     */
    public Boolean getBoolean(String key)
    {
        String s = properties.getProperty(key);

        if (s != null)
        {
            return Boolean.valueOf(s);
        }
        return null;
    }

    /**
     * 
     * @param key the key
     * @return the parsed out Integer
     */
    public Integer getInt(String key)
    {
        String s = properties.getProperty(key);

        if (s != null)
        {
            return Integer.valueOf(s);
        }
        return null;
    }

    /**
     * 
     * @param key the key
     * @param defaultValue what to return if the key doesn't exist
     * @return the parsed out int
     */
    public Integer getInt(String key, int defaultValue)
    {
        String s = properties.getProperty(key);

        if (s != null)
        {
            return Integer.valueOf(s);
        }
        return defaultValue;
    }

    /**
     * 
     * @param key the key
     * @return the parsed out long
     */
    public Long getLong(String key)
    {
        String s = properties.getProperty(key);

        if (s != null)
        {
            return Long.valueOf(s);
        }
        return null;
    }

    /**
     * 
     * @param key the key
     * @param defaultValue the value to return if the key doesn't exist
     * @return the parsed out long
     */
    public Long getLong(String key, long defaultValue)
    {
        String s = properties.getProperty(key);

        if (s != null)
        {
            return Long.valueOf(s);
        }
        return defaultValue;
    }

    /**
     * 
     * @param key the key
     * @return the value
     */
    public String getString(String key)
    {
        return properties.getProperty(key);
    }

    /**
     * Reads in a property and splits it by commas into a String array
     * 
     * @param key the key
     * @return returns an empty array if nothing found
     */
    public String[] getStringArray(String key)
    {
        String value = properties.getProperty(key);
        if (value != null)
        {
            String[] splitter = value.split(",");
            return splitter;
        }
        return new String[0];
    }

    /**
     * Reads in a property and splits it by commas into an int array
     *
     * throws ClassCastException if the string can't be parsed into integers
     * 
     * @param key the key
     * @return the int array
     */
    public int[] getIntArray(String key)
    {
        String value = properties.getProperty(key);
        if (value != null)
        {
            String[] splitter = value.split(",");
            int[] newArray = new int[splitter.length];
            for (int i = 0; i < splitter.length; i++)
            {
                newArray[i] = Integer.parseInt(splitter[i]);
            }
            return newArray;
        }
        return new int[0];
    }

    /**
     * Sets property
     * 
     * @param key
     *            The name of the property be set
     * @param value
     *            The string value of the property to set
     * @return
     */

    public void setProperty(String key, String value)
    {
        properties.setProperty(key, value);
    }

    /**
     * 
     * @return an instance of <code>NILProperties</code>
     */
    public static NILProperties getInstance()
    {
        synchronized (staticMutex)
        {
            if (instance == null)
            {
                instance = new NILProperties();
                instance.defaultInit();
            }
            return instance;
        }
    }

    /**
     * Setup this instance using the specified file rather than 
     * loading up with the default properties file.
     * 
     * @param file the properties file
     */
    public static void setup(File file)
    {
        synchronized (staticMutex)
        {
            reset();
            instance = new NILProperties();
            instance.init(file);
        }
    }

    /**
     * 
     * sets the instance of <code>NILProperties</code> to null.  This should
     * be used in a shutdown or in conjunction with {@link #init()} to 
     * reinitialize the service.
     */
    public static void reset()
    {
        synchronized (staticMutex)
        {
            if (instance != null)
            {
                instance.shutdown();
                instance = null;
            }
        }
    }

    /**
     * load up with the specified file 
     * 
     * @param file
     */
    private void init(File file)
    {
        try
        {
            properties = new Properties();
            properties.load(new FileInputStream(file));
        }
        catch (FileNotFoundException e)
        {
            throw new RuntimeException("Unable to find the nil.properties file '" + file.getAbsolutePath() + "'.");
        }
        catch (IOException e)
        {
            throw new RuntimeException("Unable to load the nil.properties file '" + file.getAbsolutePath() + "'.");
        }
    }

    /**
     * Load up the properties from the default file on the classpath
     */
    private void defaultInit()
    {
        properties = new Properties();
        try
        {
            URL nilFolder = NILProperties.class.getResource("/" + "nil");
            properties.load(new FileInputStream(nilFolder.getPath() + File.separator + NIL_PROPERTIES));
        }
        catch (IOException e)
        {
            throw new RuntimeException("Unable to load the nil.properties file '" + NIL_PROPERTIES + "'.");
        }
    }

    private void shutdown()
    {
        if (properties != null)
        {
            properties.clear();
            properties = null;
        }
    }

    /**
     * <b>DO NOT USE!</b>
     * <p>
     * Direct access to properties.  This is for support of the FTP server only.
     * Users should call the individual getters directly.
     * </p>
     * @return The properties backing this instance.
     */
    public Properties getProperties()
    {
        return properties;
    }

}
