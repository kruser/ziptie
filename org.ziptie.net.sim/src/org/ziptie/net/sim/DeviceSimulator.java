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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Properties;

import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;
import org.ziptie.net.sim.http.HttpServer;
import org.ziptie.net.sim.telnet.TelnetServer;

/**
 * Main class for the DeviceSimulator
 */
@SuppressWarnings("nls")
public class DeviceSimulator
{
    private static final Logger LOG = Logger.getLogger(DeviceSimulator.class);

    public static final String HTTP_PORT = "http.port";
    public static final String TELNET_PORT = "telnet.port";
    public static final String TELNET_HANDSHAKE_PORT = "telnet.handshake.port";
    public static final String TELNET_POOL_COUNT = "telnet.pool.count";

    public static final String LOG_STORE_STATE = "logging.storeState";

    public static final String LOCKFILE = "sim.lock";

    private static Properties props;

    private HttpServer httpServer;
    private TelnetServer telnetServer;

    public DeviceSimulator()
    {
        Properties initial = new Properties();

        InputStream is = null;
        try
        {
            File file = new File("simulator.properties");
            is = new FileInputStream(file);
            if (is != null)
            {
                initial.load(is);
            }
            else
            {
                LOG.info("Could not find properties file.");
            }
        }
        catch (IOException e)
        {
            LOG.warn("Could not load properties file.", e);
        }
        finally
        {
            if (is != null)
            {
                try
                {
                    is.close();
                }
                catch (IOException e1)
                {
                    LOG.warn("Error closing stream.", e1);
                }
            }
        }
        init(initial);
    }

    public DeviceSimulator(Properties initial)
    {
        init(initial);
    }

    private void init(Properties initial)
    {
        props = initial;

        // Load system properties into sim properties map.
        Properties sysProps = System.getProperties();
        Enumeration<?> en = sysProps.keys();
        while (en.hasMoreElements())
        {
            String next = (String) en.nextElement();

            props.setProperty(next, sysProps.getProperty(next));
        }
    }

    public void start()
    {
        try
        {
            telnetServer = new TelnetServer();
            telnetServer.start();

            httpServer = new HttpServer();
            httpServer.start();

            LOG.info("DeviceSimulator started");
        }
        catch (Throwable t)
        {
            LOG.error("Unable to start simulator!", t);
        }
    }

    public static String getProperty(String key)
    {
        return props.getProperty(key);
    }

    public static void main(String[] args)
    {
        for (int i = 0; i < args.length; i++)
        {
            if (args[i].equals("--stop"))
            {
                File lock = new File(LOCKFILE);
                lock.delete();
                return;
            }
        }
        initLogger();

        DeviceSimulator sim = new DeviceSimulator();
        sim.start();

        try
        {
            File lock = new File(LOCKFILE);
            lock.createNewFile();
            lock.deleteOnExit();

            while (lock.exists())
            {
                try
                {
                    Thread.sleep(5000);
                }
                catch (InterruptedException e1)
                {

                }
            }

            System.exit(0);
        }
        catch (IOException e)
        {
            LOG.error("Unable to watch lockfile", e);
        }
    }

    /////////////////////////////////////////////////////
    // Logging...
    /////////////////////////////////////////////////////
    private static boolean loggingInitialized;

    public static synchronized void initLogger()
    {
        if (loggingInitialized)
        {
            return;
        }
        loggingInitialized = true;

        DOMConfigurator.configureAndWatch("log4j.xml");
        //        Logger.getRootLogger().addAppender(new ConsoleAppender(new PatternLayout("%d %-5p [%c] %m%n")));
    }
}
