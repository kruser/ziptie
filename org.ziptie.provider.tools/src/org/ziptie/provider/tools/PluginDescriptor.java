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
package org.ziptie.provider.tools;

import javax.xml.bind.annotation.XmlTransient;

import org.osgi.framework.Bundle;

/**
 * ScriptToolDescriptor
 */
public class PluginDescriptor
{
    private String toolName;
    private String propertyText;
    private String pluginType;
    private ZToolProperties properties;

    private Bundle bundle;
    private String bundlePath;

    /**
     * Default constructor.
     */
    public PluginDescriptor()
    {
        // default constructor
    }

    // ------------------------------------------------------------
    //                    Server-side Attributes
    // ------------------------------------------------------------

    /**
     * Construct a descriptor with a bundle and a path indicating
     * the script location within the bundle.
     *
     * @param bundle an OSGi bundle
     * @param path a path relative to the bundle
     */
    public PluginDescriptor(Bundle bundle, String path)
    {
        this.bundle = bundle;
        this.bundlePath = path;
    }

    /**
     * Get the properties associated with this tool.
     *
     * @return the properties
     */
    @XmlTransient
    public ZToolProperties getProperties()
    {
        return properties;
    }

    /**
     * Set the properties associated with this tool.
     *
     * @param properties the properties to set
     */
    public void setProperties(ZToolProperties properties)
    {
        this.properties = properties;
    }

    /**
     * Get the path for the script within the Bundle.
     *
     * @return the bundlePath
     */
    @XmlTransient
    public String getBundlePath()
    {
        return bundlePath;
    }

    /**
     * Get a reference to the Bundle that contains the script.
     *
     * @return the scriptBundle
     */
    @XmlTransient
    public Bundle getBundle()
    {
        return bundle;
    }

    // ------------------------------------------------------------
    //                    SOAPable Attributes
    // ------------------------------------------------------------

    /**
     * Get the text of the properties for this script tool.
     *
     * @return the text of the properties for this script tool
     */
    public String getPropertyText()
    {
        return propertyText;
    }

    /**
     * Set the text of the properties for this script tool.
     *
     * @param propertyText the text of the properties to set
     */
    public void setPropertyText(String propertyText)
    {
        this.propertyText = propertyText;
    }

    /**
     * Get the display name of the tool.
     *
     * @return the toolName
     */
    public String getToolName()
    {
        return toolName;
    }

    /**
     * Set the display name of the tool.
     *
     * @param toolName the toolName to set
     */
    public void setToolName(String toolName)
    {
        this.toolName = toolName;
    }

    /**
     * Set the plugin type to one of the supported types.
     *
     * @param pluginType the plugin type
     */
    public void setPluginType(String pluginType)
    {
        this.pluginType = pluginType;
    }

    /**
     * Get the plugin type.
     *
     * @return the plugin type
     */
    public String getPluginType()
    {
        return pluginType;
    }
}
