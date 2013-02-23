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
package org.ziptie.build;

import static org.apache.tools.ant.Project.MSG_VERBOSE;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashSet;
import java.util.Properties;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.tools.ant.Project;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * Describes a feature definition.
 */
@SuppressWarnings("nls")
public class Feature
{
    public static final String FEATURE_XML = "feature.xml";
    private static final String ATTR_FEATURE = "feature";
    private static final String ATTR_VERSION = "version";
    private static final String ATTR_PLUGIN = "plugin";
    private static final String BUILD_PROPERTIES = "build.properties";
    private static final String BIN_INCLUDES = "bin.includes";

    private String id;
    private File dir;
    private String version;
    private Set<String> plugins = new HashSet<String>();
    private String binIncludes;

    /**
     * Sets the feature's id
     * @param id The feature id.
     */
    public void setId(String id)
    {
        this.id = id;
    }

    /**
     * Sets the feature's version number
     * @param version the version. ie: 3.2.1
     */
    public void setVersion(String version)
    {
        this.version = version;
    }

    /**
     * The feature's directory.
     * @return The directory.
     */
    public File getDir()
    {
        return dir;
    }

    /**
     * The feature's ID.
     * @return the id.
     */
    public String getId()
    {
        return id;
    }

    /**
     * The feature's version.
     * @return The version.
     */
    public String getVersion()
    {
        return version;
    }

    /**
     * Adds a plugin to the feature.
     * @param plugin The plugin id.
     */
    public void addPlugin(String plugin)
    {
        plugins.add(plugin);
    }

    /**
     * The plugins that this feature contains.
     * @return The plugin ids.
     */
    public Set<String> getPlugins()
    {
        return plugins;
    }

    /**
     * Set's the feature's directory. 
     * @param dir The directory.
     */
    public void setDir(File dir)
    {
        this.dir = dir;
    }

    /**
     * The binary include property.  As in 'bin.includes' in 'build.properties'.
     * @return A comma seperated list of files and folders. 
     */
    public String getBinIncludes()
    {
        return binIncludes;
    }

    /**
     * Sets the bin.includes for this feature.
     * @param binIncludes The bin.includes string
     */
    public void setBinIncludes(String binIncludes)
    {
        this.binIncludes = binIncludes;
    }


    /**
     * Loads the feature from the specified directory.
     * @param project the ant project.
     * @param dir The feature directory.
     * @param config the platform configuration of this build.
     * @return The newly created {@link Feature} instance.
     * @throws ParserConfigurationException on error.
     * @throws SAXException on error.
     * @throws IOException on error.
     */
    public static Feature loadFeature(final Project project, File dir, final PlatformConfig config) throws ParserConfigurationException, SAXException,
            IOException
    {
        File featureXml = new File(dir, FEATURE_XML);
        if (!featureXml.isFile())
        {
            return null;
        }

        final Feature feature = new Feature();
        feature.setDir(dir);

        SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
        parser.parse(featureXml, new DefaultHandler()
        {
            @Override
            public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
            {
                if (qName.equals(ATTR_FEATURE))
                {
                    feature.setId(attributes.getValue("id"));
                    feature.setVersion(attributes.getValue(ATTR_VERSION));
                }
                else if (qName.equals(ATTR_PLUGIN))
                {
                    String pluginId = attributes.getValue("id");

                    String pos = attributes.getValue("os");
                    String pws = attributes.getValue("ws");
                    String parch = attributes.getValue("arch");
                    if (!config.isInConfig(pos, pws, parch))
                    {
                        project.log("Plugin not included, it is not needed for configured system: " + pluginId, MSG_VERBOSE);
                        return;
                    }

                    feature.addPlugin(pluginId);
                }
            }
        });

        File propFile = new File(dir, BUILD_PROPERTIES);
        if (propFile.isFile())
        {
            FileInputStream in = new FileInputStream(propFile);
            try
            {
                Properties buildProps = new Properties();
                buildProps.load(in);
                feature.setBinIncludes(buildProps.getProperty(BIN_INCLUDES));
            }
            finally
            {
                in.close();
            }
        }
        return feature;
    }
}
