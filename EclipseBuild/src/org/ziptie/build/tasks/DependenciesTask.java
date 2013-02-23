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
package org.ziptie.build.tasks;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.types.FileSet;
import org.xml.sax.SAXException;
import org.ziptie.build.BuildElf;
import org.ziptie.build.Plugin;

/**
 * Copies the dependencies for a set of plugins to a distribution directory.
 */
@SuppressWarnings("nls")
public class DependenciesTask extends AbstractBuildTask
{
    private File dependencyOutputFile;
    private File distPluginDir;

    /** {@inheritDoc} */
    @Override
    public void execute()
    {
        try
        {
            readPluginsFromDir(getRoot());
            readPluginsFromDir(new File(getEclipseHome(), "plugins"));
            readPluginsFromDir(new File(getEclipseHome(), FEATURE_DIR));

            distPluginDir = new File(getDist(), getPluginDir());
            BuildElf.mkdir(this, distPluginDir);

            distDependencies();
        }
        catch (ParserConfigurationException e)
        {
            throw new BuildException(e);
        }
        catch (SAXException e)
        {
            throw new BuildException(e);
        }
        catch (IOException e)
        {
            throw new BuildException(e);
        }
    }

    private void distDependencies()
    {
        Queue<Plugin> dependencyPlugins = new LinkedList<Plugin>();

        dependencyPlugins.addAll(getPluginsToBuild());

        Set<Plugin> finished = new HashSet<Plugin>();
        while (!dependencyPlugins.isEmpty())
        {
            Plugin plugin = dependencyPlugins.poll();
            if (finished.contains(plugin))
            {
                continue;
            }
            finished.add(plugin);

            dependencyPlugins.addAll(getDependencies(plugin));

            Set<Plugin> fragments = BuildElf.findInjectedFragments(getPlugins().values(), plugin.getId());
            if (fragments != null)
            {
                fragments.removeAll(finished);
                dependencyPlugins.addAll(fragments);
            }

            // ignore fragments that aren't needed on this platform
            if (plugin.isEnabled())
            {
                log("Copying plugin " + plugin.getId(), Project.MSG_VERBOSE);
                for (String packge : plugin.getImportPackage())
                {
                    Plugin emport = findExportedPackage(packge);
                    if (emport != null)
                    {
                        if (!finished.contains(emport))
                        {
                            log("Package " + packge + " imported from " + emport.getId(), Project.MSG_VERBOSE);
                            dependencyPlugins.add(emport);
                        }
                    }
                    else
                    {
                        log("No plugin exports " + packge, Project.MSG_WARN);
                    }
                }

                if (plugin.getDir().getParentFile().equals(getRoot()))
                {
                    // don't copy our buildable plugins as dependencies
                    continue;
                }

                copy(plugin);
            }
        }

        saveDependenciesToFile(dependencyOutputFile, finished);
    }

    private void saveDependenciesToFile(File outputFile, Set<Plugin> dependencies)
    {
        if (outputFile != null)
        {
            PrintStream out = null;
            try
            {
                out = new PrintStream(new FileOutputStream(outputFile));
                out.println("<dependencies>");
                for (Plugin plugin : dependencies)
                {
                    out.printf("   <plugin id=\"%s\" version=\"%s\" ", plugin.getId(), plugin.getVersion());

                    if (plugin.getOsFilter() != null)
                    {
                        out.printf("os=\"%s\" ", plugin.getOsFilter());
                    }

                    if (plugin.getWsFilter() != null)
                    {
                        out.printf("ws=\"%s\" ", plugin.getWsFilter());
                    }

                    if (plugin.getArchFilter() != null)
                    {
                        out.printf("arch=\"%s\" ", plugin.getArchFilter());
                    }

                    out.println("/>");
                }
                out.println("</dependencies>");
            }
            catch (FileNotFoundException e)
            {
                throw new BuildException("Cannot find dependency file: " + outputFile, e);
            }
            finally
            {
                if (out != null)
                {
                    out.close();
                }
            }
        }
    }

    /**
     * Copies the given plugin to the dist directory.
     *
     * @param plugin The plugin to copy.
     */
    private void copy(Plugin plugin)
    {
        Copy copy = new Copy();
        copy.setProject(getProject());
        copy.setTaskName(BuildElf.COPY_TASK);

        File dir = plugin.getDir();

        File toFile;

        String loc = plugin.getLocation();
        if (loc == null)
        {
            toFile = new File(distPluginDir, dir.getName());
        }
        else if (loc.endsWith("/"))
        {
            toFile = new File(new File(getDist(), loc), dir.getName());
        }
        else
        {
            toFile = new File(getDist(), loc);
        }

        if (dir.isDirectory())
        {
            copy.setTodir(toFile);
            FileSet set = new FileSet();
            set.setProject(getProject());
            set.setDir(plugin.getDir());
            copy.addFileset(set);
        }
        else if (dir.isFile())
        {
            copy.setTofile(toFile);
            copy.setFile(dir);
        }
        else
        {
            throw new BuildException("Cannot copy plugin: " + dir);
        }
        copy.execute();
    }

    /**
     * The file to write the list of external plugin dependencies to.
     *
     * @param dependencyOutputFile The output file.
     */
    public void setDependencyOutputFile(File dependencyOutputFile)
    {
        this.dependencyOutputFile = dependencyOutputFile;
    }
}
