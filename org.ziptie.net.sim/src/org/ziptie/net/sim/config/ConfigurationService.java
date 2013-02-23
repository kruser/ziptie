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

package org.ziptie.net.sim.config;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.log4j.Logger;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.multiop.MultiOperationFactory;
import org.ziptie.net.sim.operations.OperationManager;
import org.ziptie.net.sim.recording.Recording;
import org.ziptie.net.sim.recording.RecordingLoader;
import org.ziptie.net.sim.util.Util;

/**
 * Manages the association of hosts to configurations.
 */
@SuppressWarnings("nls")
public class ConfigurationService
{
    private static final Logger LOG = Logger.getLogger(ConfigurationService.class);

    private static final String CONFIG_DIR = "configs/";
    public static final String DEFAULT_CONFIG = "default-config.xml";

    /** Map&lt;{@link String} (filename), {@link Configuration}&gt;*/
    private Map<String, Configuration> configMap;
    /** Map&lt;{@link String} (remoteIp), {@link String} (filename)&gt;*/
    private Map<String, String> configForHostMap;

    /**
     * Hidden constructor
     * @see ConfigurationService#getInstance()
     */
    private ConfigurationService()
    {
        // Map<String (filename), Configuration>
        configMap = new HashMap<String, Configuration>();
        // Map<String (remoteIp), String (filename)>
        configForHostMap = Collections.synchronizedMap(new HashMap<String, String>());
    }

    /**
     * @param remoteIp
     * @return The Configuration associated with <code>remoteIp</code>.
     */
    public Configuration findConfiguration(String remoteIp)
    {
        String config = configForHostMap.get(remoteIp);
        try
        {
            return findConfigurationFile(config == null ? DEFAULT_CONFIG : config);
        }
        catch (FileNotFoundException e)
        {
            LOG.error("Could not load config file for " + remoteIp, e);
            return null;
        }
    }

    public Configuration generateEpitomizingConfiguration(IpSubnet subnet) throws FileNotFoundException
    {
        Configuration defaultConfig = ConfigurationService.getInstance().findConfigurationFile(ConfigurationService.DEFAULT_CONFIG);
        Configuration config = new Configuration();

        config.setName("Epitomizing Configuration");
        config.setMaxBufferLength(defaultConfig.getMaxBufferLength());
        config.setRateMultiplier(defaultConfig.getRateMultiplier());
        config.setOperationTimeout(defaultConfig.getOperationTimeout());

        Collection<?> sessions = OperationManager.getInstance().enumerateSessions();

        URI session = null;

        Iterator<?> sessionIter = sessions.iterator();
        Iterator<?> subnetIter = subnet.iterator();
        while (sessionIter.hasNext() && subnetIter.hasNext())
        {
            IpAddressMapping ip = (IpAddressMapping) subnetIter.next();
            session = (URI) sessionIter.next();

            ip = new IpAddressMapping(ip.getIntValue());
            ip.setOperation(session);
            ip.setRateMultiplier(1.0f);
            config.addMapping(ip);
        }
        config.setDefaultOperation(session);

        return config;
    }

    public void setConfigurationForIp(String remoteIp, String config)
    {
        configForHostMap.put(remoteIp, config);
        if (remoteIp.startsWith("127."))
        {
            configForHostMap.put(Util.getLocalHost().getHostAddress(), config);
        }
    }

    /**
     * @return A list of all available config files.
     */
    public String[] enumerateConfigs()
    {
        File configDir = new File(CONFIG_DIR);
        String[] files = configDir.list(new FilenameFilter()
        {
            public boolean accept(File dir, String name)
            {
                return name.endsWith(".xml");
            }
        });
        return files == null ? new String[0] : files;
    }

    public Map<String, String> enumerateMappedHosts()
    {
        return configForHostMap;
    }

    public void serializeImport(OutputStream out, Configuration config) throws IOException
    {
        String recordingPrefix = RecordingLoader.getInstance().getPathPrefix();
        String multiPrefix = MultiOperationFactory.getInstance().getPathPrefix();

        ObjectOutputStream oos = new ObjectOutputStream(out);
        IIpMapping[] mappings = config.getMappings();
        for (int i = 0; i < mappings.length; i++)
        {
            IIpMapping mapping = mappings[i];
            URI session = mapping.getOperation();

            Recording recording = null;
            try
            {
                if (session.getScheme().equals(multiPrefix))
                {
                    session = MultiOperationFactory.getInstance().findFirstUri(session);
                }

                if (session.getScheme().equals(recordingPrefix))
                {
                    recording = RecordingLoader.getInstance().findRecording(session.getSchemeSpecificPart());
                }
                else
                {
                    continue;
                }
            }
            catch (NoSuchOperationException e)
            {
                LOG.warn("No such recording: " + session, e);
                continue;
            }

            String adapterId = recording.getAdapterId();

            Iterator<?> ipIter = mapping.iterator();
            while (ipIter.hasNext())
            {
                IpAddressMapping ip = (IpAddressMapping) ipIter.next();
                Map<String, String> map = new HashMap<String, String>();
                map.put("Name", session.toString());
                map.put("IpAddress", ip.toString());
                map.put("AdapterId", adapterId);

                oos.writeObject(map);
            }
        }
        oos.writeObject(null);
    }

    public void createImport(PrintStream ps, Configuration config)
    {
        String recordingPrefix = RecordingLoader.getInstance().getPathPrefix();
        String multiPrefix = MultiOperationFactory.getInstance().getPathPrefix();

        ps
          .println("IP Address,Hostname (optional),Adapter ID,Folder");
        IIpMapping[] mappings = config.getMappings();
        for (IIpMapping mapping : mappings)
        {
            URI session = mapping.getOperation();

            Recording recording = null;
            try
            {
                if (session.getScheme().equals(multiPrefix))
                {
                    session = MultiOperationFactory.getInstance().findFirstUri(session);
                }

                if (session.getScheme().equals(recordingPrefix))
                {
                    recording = RecordingLoader.getInstance().findRecording(session.getSchemeSpecificPart());
                }
                else
                {
                    continue;
                }
            }
            catch (NoSuchOperationException e)
            {
                LOG.warn("No such recording: " + session, e);
                continue;
            }

            Iterator<?> ipIter = mapping.iterator();
            while (ipIter.hasNext())
            {
                IpAddressMapping ip = (IpAddressMapping) ipIter.next();
                ps.print(ip);
                ps.print(",");
                ps.print("Sim Device,");
                ps.print(recording.getAdapterId());
                ps.print(",");
                ps.print("sim");
                ps.println();
            }
        }
    }

    /**
     * Retrieves the configuration with the given name.  If the configuration has yet to be loaded it will be loaded.
     * @param configFile The filename
     * @return The Configuration
     * @throws FileNotFoundException
     */
    public Configuration findConfigurationFile(String configFile) throws FileNotFoundException
    {
        synchronized (configMap)
        {
            Configuration config = configMap.get(configFile);
            if (config == null)
            {
                if (!configMap.containsKey(configFile))
                {
                    config = loadConfiguration(configFile);
                    configMap.put(configFile, config);
                }
            }
            return config;
        }
    }

    /**
     * Resets the cache of configuration so that the subsequent loads will have to reload from the filesystem. 
     */
    public void resetAll()
    {
        synchronized (configMap)
        {
            configMap.clear();
        }
    }

    //////////////////////////////////////////////////////////////
    // Configuration Persist...
    //////////////////////////////////////////////////////////////

    public void saveConfiguration(String file, String config) throws Exception
    {

        try
        {
            FileOutputStream fos = new FileOutputStream(new File(CONFIG_DIR, file));
            PrintStream ps = new PrintStream(new BufferedOutputStream(fos));
            ps.print(config);
            ps.close();
        }
        catch (Exception e)
        {
            LOG.error("Error saving configuration!", e);
            throw e;
        }
    }

    private Configuration loadConfiguration(String file) throws FileNotFoundException
    {
        return loadConfiguration(null, new FileInputStream(CONFIG_DIR + file));
    }

    /**
     * Load a configuration from the given input stream.  If <code>parent</code> is non-null inherit everything from it. 
     * @param parent
     * @param input
     * @return
     */
    public Configuration loadConfiguration(Configuration parent, InputStream input)
    {
        try
        {
            ConfigSaxHandler handler = new ConfigSaxHandler(parent);

            SAXParser sparser = SAXParserFactory.newInstance().newSAXParser();
            sparser.parse(new BufferedInputStream(input), handler);

            Configuration config = handler.getConfig();
            LOG.info("Loaded config: " + config.getName());

            return config;
        }
        catch (SAXException e)
        {
            LOG.error("Error loading config.", e);
        }
        catch (IOException e)
        {
            LOG.error("Error loading config.", e);
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e);
        }
        return null;
    }

    private class ConfigSaxHandler extends DefaultHandler
    {
        private Configuration config;

        ConfigSaxHandler(Configuration parent)
        {
            config = parent == null ? new Configuration() : parent.copy();
        }

        /**
         * @return Returns the config.
         */
        public Configuration getConfig()
        {
            return config;
        }

        /* (non-Javadoc)
         * @see org.xml.sax.helpers.DefaultHandler#startElement(java.lang.String, java.lang.String, java.lang.String, org.xml.sax.Attributes)
         */
        public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
        {
            if (qName.equals(Configuration.CONFIGURATION_ROOT))
            {
                String name = attributes.getValue(Configuration.NAME_ATTRIB);
                String defaultRecording = attributes.getValue(Configuration.DEFAULT_ATTRIB);
                String rate = attributes.getValue(Configuration.RATE_ATTRIB);
                String maxBufferLength = attributes.getValue(Configuration.MAX_BUFFER_LENGTH_ATTRIB);
                String operationTimeout = attributes.getValue(Configuration.OPERATION_TIMEOUT_ATTRIB);
                String deviceIp = attributes.getValue(Configuration.DEVICE_IP_ATTRIB);
                String daIp = attributes.getValue(Configuration.DA_IP_ATTRIB);
                String respondOnlyOnNewline = attributes.getValue(Configuration.RESPOND_ONLY_ON_NEWLINE_ATTRIB);
                String doEcho = attributes.getValue(Configuration.DO_ECHO_ATTRIB);

                if (rate != null && rate.length() > 0)
                {
                    try
                    {
                        config.setRateMultiplier(Float.parseFloat(rate));
                    }
                    catch (NumberFormatException e1)
                    {
                        LOG.warn("Invalid rate attribute: " + rate);
                    }
                }
                if (maxBufferLength != null && maxBufferLength.length() > 0)
                {
                    try
                    {
                        config.setMaxBufferLength(Long.parseLong(maxBufferLength));
                    }
                    catch (NumberFormatException e1)
                    {
                        LOG.warn("Invalid maxBufferLength attribute: " + maxBufferLength);
                    }
                }
                if (operationTimeout != null && operationTimeout.length() > 0)
                {
                    try
                    {
                        config.setOperationTimeout(Integer.parseInt(operationTimeout));
                    }
                    catch (NumberFormatException e1)
                    {
                        LOG.warn("Invalid operationTimeout attribute: " + operationTimeout);
                    }
                }
                if (name != null && name.length() > 0)
                {
                    config.setName(name);
                }
                if (defaultRecording != null && defaultRecording.length() > 0)
                {
                    try
                    {
                        config.setDefaultOperation(new URI(defaultRecording));
                    }
                    catch (URISyntaxException e)
                    {
                        LOG.warn("Invalid default URI: " + defaultRecording, e);
                    }
                }
                if (daIp != null && daIp.length() > 0)
                {
                    config.setDaIp(daIp);
                }
                if (deviceIp != null && deviceIp.length() > 0)
                {
                    config.setDeviceIp(deviceIp);
                }
                if (respondOnlyOnNewline != null)
                {
                    config.setRespondOnlyOnNewline(respondOnlyOnNewline.equalsIgnoreCase("true"));
                }
                if (doEcho != null)
                {
                    config.setDoEcho(doEcho.equalsIgnoreCase("true"));
                }
            }
            else
            {
                try
                {
                    if (qName.equals(Configuration.SINGLE_TAG))
                    {
                        IpAddressMapping ip = new IpAddressMapping(attributes.getValue(Configuration.IP_ATTRIB));
                        populateMapping(ip, attributes);
                        config.addMapping(ip);
                    }
                    else if (qName.equals(Configuration.RANGE_TAG))
                    {
                        IpAddressMapping start = new IpAddressMapping(attributes.getValue(Configuration.START_ATTRIB));
                        IpAddressMapping end = new IpAddressMapping(attributes.getValue(Configuration.END_ATTRIB));

                        IpRange range = new IpRange(start, end);
                        populateMapping(range, attributes);
                        config.addMapping(range);
                    }
                    else if (qName.equals(Configuration.MASK_TAG))
                    {
                        IpSubnet subnet = new IpSubnet(attributes.getValue(Configuration.MASK_ATTRIB));
                        populateMapping(subnet, attributes);
                        config.addMapping(subnet);
                    }
                }
                catch (URISyntaxException e)
                {
                    LOG.warn("Invalid session attribute.", e);
                }
            }
        }

        private void populateMapping(AbstractIpMapping mapping, Attributes attributes) throws URISyntaxException
        {
            String uri = attributes.getValue(Configuration.RECORDING_ATTRIB);
            mapping.setOperation(new URI(uri));
            String rate = attributes.getValue(Configuration.RATE_ATTRIB);
            if (rate != null)
            {
                mapping.setRateMultiplier(Float.parseFloat(rate));
            }
            String respond = attributes.getValue(Configuration.RESPOND_ONLY_ON_NEWLINE_ATTRIB);
            mapping.setRespondOnlyOnNewline(respond == null ? null : Boolean.valueOf(respond.equalsIgnoreCase("true")));
            String doEcho = attributes.getValue(Configuration.DO_ECHO_ATTRIB);
            mapping.setRespondOnlyOnNewline(doEcho == null ? null : Boolean.valueOf(doEcho.equalsIgnoreCase("true")));
        }
    }

    //////////////////////////////////////////////////////////////////////
    // Factory method...
    //////////////////////////////////////////////////////////////////////
    private static ConfigurationService instance;

    public static synchronized ConfigurationService getInstance()
    {
        if (instance == null)
        {
            instance = new ConfigurationService();
        }
        return instance;
    }
}
