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
package org.ziptie.build;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * Defines a crate (set of bundles) that should be built.
 */
@SuppressWarnings("nls")
public final class Crate
{
    private Set<Plugin> plugins;
    private File file;
    private String version;

    private Crate(File file)
    {
        this.file = file;
        plugins = new HashSet<Plugin>();
    }

    /**
     * Gets the version number for this crate.
     * @return the raw version number
     */
    public String getVersion()
    {
        return version;
    }

    /**
     * Gets the file that this crate was loaded from.
     * @return The crate file.
     */
    public File getFile()
    {
        return file;
    }

    /**
     * Get the plugins this crate includes.
     * @return The plugins.
     */
    public Set<Plugin> getPlugins()
    {
        return plugins;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return file.hashCode();
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null)
        {
            return false;
        }

        if (!(obj instanceof Crate))
        {
            return false;
        }

        return ((Crate) obj).file.equals(file);
    }

    /**
     * Load a crate from a file.
     * @param task The ant project.
     * @param crateDir The directory.
     * @param name The filename
     * @param plugins All the available plugins.
     * @param failOnMissingBundle <code>true</code> if the build should fail if a bundle is missing. 
     * @return The crate.
     */
    public static Crate loadCrate(final Task task, File crateDir, String name, final Map<String, Plugin> plugins, final boolean failOnMissingBundle)
    {
        File file = new File(crateDir, name);
        if (!file.isFile())
        {
            file = new File(name);
            if (!file.isFile())
            {
                throw new BuildException("No crate found named " + name);
            }
        }

        final Crate crate = new Crate(file);

        try
        {
            SAXParserFactory.newInstance().newSAXParser().parse(file, new DefaultHandler()
            {
                @Override
                public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
                {
                    if (qName.equals("crate"))
                    {
                        crate.version = attributes.getValue("version");
                    }
                    else if (qName.equals("bundle"))
                    {
                        String id = attributes.getValue("id");
                        String location = attributes.getValue("location");
                        String version = attributes.getValue("version");

                        Plugin plugin = null;
                        if (location != null && !location.endsWith("/"))
                        {
                            String name = new File(location).getName();
                            for (Plugin p : plugins.values())
                            {
                                if (p.getDir().getName().equals(name))
                                {
                                    plugin = p;
                                    break;
                                }
                            }
                        }
                        else if (version != null && version.length() > 0)
                        {
                            plugin = plugins.get(id + '_' + version);
                        }
                        else
                        {
                            plugin = plugins.get(id);
                        }

                        if (plugin == null)
                        {
                            String msg = "No plugin found with id " + id;

                            if (failOnMissingBundle)
                            {
                                throw new BuildException(msg);
                            }

                            task.log(msg);
                            return;
                        }

                        plugin.setLocation(location);
                        crate.plugins.add(plugin);
                    }
                }
            });
        }
        catch (SAXException e)
        {
            throw new BuildException(e);
        }
        catch (IOException e)
        {
            throw new BuildException(e);
        }
        catch (ParserConfigurationException e)
        {
            throw new BuildException(e);
        }

        return crate;
    }
}
