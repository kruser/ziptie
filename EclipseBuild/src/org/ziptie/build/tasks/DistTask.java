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

import static org.apache.tools.ant.Project.MSG_INFO;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.tools.ant.BuildException;
import org.xml.sax.SAXException;
import org.ziptie.build.BuildElf;
import org.ziptie.build.CompileElf;
import org.ziptie.build.Crate;
import org.ziptie.build.DistElf;
import org.ziptie.build.Feature;
import org.ziptie.build.JarElf;
import org.ziptie.build.Plugin;

/**
 * Compiles and distributes a set of bundles.
 */
@SuppressWarnings("nls")
public class DistTask extends AbstractBuildTask
{
    private String versionQualifier;
    private String crateOuputDir;
    private boolean dontDist;

    /**
     * Create the task.
     */
    public DistTask()
    {
        crateOuputDir = "crates";
    }

    /** {@inheritDoc} */
    @Override
    public void execute()
    {
        try
        {
            readPluginsFromDir(getRoot());
            readPluginsFromDir(new File(getEclipseHome(), "plugins"));
            readPluginsFromDir(new File(getEclipseHome(), FEATURE_DIR));
            maybeReadLinkedPlugins(new File(getEclipseHome(), "links"));

            File pluginDir = new File(getDist(), getPluginDir());

            List<Plugin> order = getOrderedPlugins();
            if (!order.isEmpty())
            {
                for (Plugin plugin : order)
                {
                    callTarget(plugin, "preall");
                }

                for (Plugin plugin : order)
                {
                    callTarget(plugin, "pre_build");
                    CompileElf.compile(this, plugin, getPlugins());

                    callTarget(plugin, "pre_jar");
                    JarElf.jar(this, plugin);

                    if (!dontDist)
                    {
                        callTarget(plugin, "pre_dist");
                        String loc = plugin.getLocation();
                        DistElf.dist(this, plugin, loc == null ? pluginDir : new File(getDist(), loc), versionQualifier);
                    }

                    callTarget(plugin, "post_build");
                }

                for (Plugin plugin : order)
                {
                    callTarget(plugin, "postall");
                }
            }

            copyFeatures();
            copyCrates();
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
        catch (Exception ex)
        {
            // EdG:  I don't understand this pattern of multiple catches that rewrap an
            // exception and add no additional error handling behavior.
            throw new BuildException(ex);
        }
    }

    private void copyFeatures()
    {
        File featureDir = new File(getDist(), FEATURE_DIR);

        Set<Feature> features = getFeaturesToBuild();
        if (!features.isEmpty())
        {
            BuildElf.mkdir(this, featureDir);

            for (Feature feature : features)
            {
                DistElf.dist(this, feature, featureDir, versionQualifier, getPlugins());
            }
        }
    }

    private void copyCrates()
    {
        Set<Crate> crates = getCratesToBuild();
        if (!crates.isEmpty())
        {
            File crateDir = new File(getDist(), crateOuputDir);

            BuildElf.mkdir(this, crateDir);

            for (Crate crate : crates)
            {
                DistElf.dist(this, crate, crateDir, versionQualifier);
            }
        }
    }

    private List<Plugin> getOrderedPlugins()
    {
        List<Plugin> order = new LinkedList<Plugin>();

        for (Plugin p : getPluginsToBuild())
        {
            // only build plugins within the root.
            if (!p.getDir().getParentFile().equals(getRoot()))
            {
                continue;
            }

            Set<Plugin> deps = getDependencies(p);

            int index = 0;
            for (; index < order.size(); index++)
            {
                Plugin other = order.get(index);
                if (deps.contains(other))
                {
                    continue;
                }

                Set<Plugin> odeps = getDependencies(other);
                if (odeps.contains(p))
                {
                    break;
                }
            }
            order.add(index, p);
        }

        log("Build Order:", MSG_INFO);
        for (Plugin plugin : order)
        {
            log("   " + plugin.getId(), MSG_INFO);
        }

        return order;
    }

    /**
     * The version qualifier for the result plugins.
     * @param qualifier The qualifier
     */
    public void setVersionQualifier(String qualifier)
    {
        this.versionQualifier = qualifier;
    }

    /**
     * Sets the name of the directory relative to the dist dir.
     * @param crateOuputDir The crate output dir.  Defaults to "crates".
     */
    public void setCrateOuputDir(String crateOuputDir)
    {
        this.crateOuputDir = crateOuputDir;
    }

    /**
     * Tells the build not to distribute the bundles to a dist directory.  Only perform the compile and jar.
     * @param dontDist <code>true</code> to not perform a copy to the dist dir.
     */
    public void setDontDist(boolean dontDist)
    {
        this.dontDist = dontDist;
    }
}
