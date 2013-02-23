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

import static org.apache.tools.ant.Project.MSG_VERBOSE;

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Ant;
import org.apache.tools.ant.taskdefs.Property;
import org.osgi.framework.Version;
import org.xml.sax.SAXException;
import org.ziptie.build.Crate;
import org.ziptie.build.Feature;
import org.ziptie.build.PlatformConfig;
import org.ziptie.build.Plugin;

/**
 * <ziptie-build
 *      eclipsehome="${eclipse.home}"
 *      versionQualifier="${version.qualifier}"
 *      dependencyOutputFile="${dist.dir}/dependencies.server-${ostype}.${osarch}.${winsystem}.xml"
 *      dist="${ziptie.dir}/${ostype}">
 *    <fileset dir="../" includes="${server.bundles}" />
 * </ziptie-build>
 */
@SuppressWarnings("nls")
public abstract class AbstractBuildTask extends Task
{
    public static final String FEATURE_DIR = "features";

    private String pluginDir = "plugins";

    private File eclipseHome;
    private File dist;
    private File root;
    private File crateDir;

    private HashMap<Plugin, Set<Plugin>> expandedDependencies;
    private Map<Plugin, String> expandedDependenciesAsCSV;
    private Map<String, Plugin> plugins;
    private Map<String, Feature> features;
    private Set<String> pluginsAndFeaturesToBuild;
    private Set<Plugin> pluginsToBuild;
    private Set<Feature> featuresToBuild;
    private Set<Crate> cratesToBuild;
    private String arch;
    private String ws;
    private String os;
    private boolean failOnMissingBundle;

    /**
     * Create the task.
     */
    public AbstractBuildTask()
    {
        pluginsAndFeaturesToBuild = new HashSet<String>();
        plugins = new HashMap<String, Plugin>();
        expandedDependencies = new HashMap<Plugin, Set<Plugin>>();
        expandedDependenciesAsCSV = new HashMap<Plugin, String>();
        features = new HashMap<String, Feature>();

        crateDir = new File(".");

        failOnMissingBundle = true;
    }

    protected Set<Plugin> getDependencies(Plugin plugin)
    {
        Set<Plugin> deps = expandedDependencies.get(plugin);
        if (deps == null)
        {
            deps = new HashSet<Plugin>();
            expandedDependencies.put(plugin, deps);

            for (String im : plugin.getImports())
            {
                Plugin p = plugins.get(im);
                if (p != null)
                {
                    deps.add(p);
                    deps.addAll(getDependencies(p));
                }
            }

            for (String pkg : plugin.getImportPackage())
            {
                Plugin p = findExportedPackage(pkg);
                if (p != null)
                {
                    deps.add(p);
                    deps.addAll(getDependencies(p));
                }
            }
        }
        return deps;
    }

    protected String getDependenciesAsCSV(Plugin plugin)
    {
        String rval = expandedDependenciesAsCSV.get(plugin);
        if (rval == null)
        {
            // build a comma separated list containing symbolic ids
            // or this plugin's dependencies
            StringBuilder dependencyList = new StringBuilder();
            for (Plugin upstream : getDependencies(plugin))
            {
                if (dependencyList.length() > 0)
                {
                    dependencyList.append(",");
                }
                dependencyList.append(upstream.getId());
            }

            rval = dependencyList.toString();
            expandedDependenciesAsCSV.put(plugin, rval);
        }

        return rval;
    }

    /**
     * Loads all the plugins which are contained within <code>root</code> and adds them to {@link #plugins}.
     */
    protected void readPluginsFromDir(File pluginRootDir) throws ParserConfigurationException, SAXException, IOException
    {
        log("readPluginsFromDir: " + pluginRootDir.getAbsolutePath(), Project.MSG_VERBOSE);

        File[] children = pluginRootDir.listFiles();
        if (children == null)
        {
        	return;
        }

        for (File dir : children)
        {
            Plugin plugin = Plugin.loadPlugin(getProject(), dir, getPlatformConfig());
            if (plugin != null)
            {
                log("Found plugin: " + plugin.getId(), MSG_VERBOSE);
                for (String emport : plugin.getImports())
                {
                    // log the imports if they are one of ours.
                    if (emport.contains("alterpoint") || emport.contains("ziptie"))
                    {
                        log("  + " + emport, MSG_VERBOSE);
                    }
                }

                // add the plug-in with it's version as a key so that it can be found explicitly if necessary.
                plugins.put(plugin.getId() + '_' + plugin.getVersion(), plugin);

                Plugin old = plugins.get(plugin.getId());
                if (old != null)
                {
                    Version oldVersion = new Version(old.getVersion());
                    Version version = new Version(plugin.getVersion());
                    if (version.compareTo(oldVersion) <= 0)
                    {
                        // don't add an older version
                        continue;
                    }
                }

                plugins.put(plugin.getId(), plugin);
                continue;
            }

            Feature feature = Feature.loadFeature(getProject(), dir, getPlatformConfig());
            if (feature != null)
            {
                log("Found feature: " + feature.getId(), MSG_VERBOSE);
                features.put(feature.getId(), feature);
            }
        }
    }

    public void maybeReadLinkedPlugins(File linksDir) throws Exception
    {
        if (!linksDir.exists())
        {
            return;
        }

        File[] linksFiles = linksDir.listFiles(new FilenameFilter()
        {
            public boolean accept(File dir, String name)
            {
                return name.endsWith(".links");
            }
        });

        for (File linkFile : linksFiles)
        {
            Properties props = new Properties();
            InputStream in = null;
            try
            {
                in = new FileInputStream(linkFile);
                props.load(in);
            }
            finally
            {
                in.close();
            }

            String path = props.getProperty("path");
            if (path != null && path.length() > 0)
            {
                File linkedEclipse = new File(path);
                readPluginsFromDir(new File(linkedEclipse, "eclipse/plugins"));
            }
        }
    }

    private PlatformConfig getPlatformConfig()
    {
        return new PlatformConfig(os, ws, arch);
    }

    protected Plugin findExportedPackage(String packageName)
    {
        for (Plugin plugin : getPlugins().values())
        {
            if (plugin.getPackages().contains(packageName))
            {
                return plugin;
            }
        }
        return null;
    }

    protected void callTarget(Plugin plugin, String target)
    {
        try
        {
            if (!new File(plugin.getDir(), "build.xml").isFile())
            {
                return;
            }

            Ant call = new Ant();
            call.setDir(plugin.getDir());
            call.setTarget(target);
            call.setProject(getProject());
            call.setInheritAll(true);
            call.setInheritRefs(true);
            call.setTaskName("ant");

            Property prop = call.createProperty();
            prop.setName("bundles.output.dir");
            prop.setLocation(new File(dist, pluginDir));

            prop = call.createProperty();
            prop.setName("bundle.id");
            prop.setValue(plugin.getId());

            prop = call.createProperty();
            prop.setName("bundle.version");
            prop.setValue(plugin.getVersion());

            prop = call.createProperty();
            prop.setName("bundle.dependencies");
            prop.setValue(getDependenciesAsCSV(plugin));

            call.execute();
        }
        catch (BuildException e)
        {
            if (e.getMessage().contains("does not exist"))
            {
                log(e.getMessage(), Project.MSG_VERBOSE);
                return;
            }
            throw e;
        }
    }

    /**
     * Sets a comma separated list of plugin ids that should be built.
     * @param pluginString The list of plugins to build.
     */
    public void setPluginsToBuild(String pluginString)
    {
        for (String id : pluginString.split(","))
        {
            id = id.trim();
            if (id.length() == 0)
            {
                continue;
            }

            pluginsAndFeaturesToBuild.add(id);
        }
    }

    /**
     * Sets whether to fail if a bundle in a crate is missing.
     * @param failOnMissingBundle <code>true</code> if the build should fail when a bundle is missing.
     */
    public void setFailOnMissingBundle(boolean failOnMissingBundle)
    {
        this.failOnMissingBundle = failOnMissingBundle;
    }

    /**
     * Gets whether to fail if a bundle in a crate is missing.
     * @return <code>true</code> if the build should fail when a bundle is missing.
     */
    public boolean getFailOnMissingBundle()
    {
        return failOnMissingBundle;
    }

    /**
     * The directory that the crate files reside in.
     * @param crateDir The crates directory.
     */
    public void setCrateDir(File crateDir)
    {
        this.crateDir = crateDir;
    }

    /**
     * The directory that the built product will be deployed to.
     * @param dist The target directory.
     */
    public void setDist(File dist)
    {
        this.dist = dist;
    }

    /**
     * Sets the target eclipse home directory.
     * @param eclipseHome The Target Platform directory.
     */
    public void setEclipseHome(File eclipseHome)
    {
        this.eclipseHome = eclipseHome;
    }

    /**
     * Sets the root directory that contains all the plugins and features to be built.
     * @param root The workspace directory
     */
    public void setRoot(File root)
    {
        this.root = root;
    }

    /**
     * The system architecture to build for
     * @param arch The architecture (ie: x86)
     */
    public void setArch(String arch)
    {
        this.arch = arch;
    }

    /**
     * The window system to build for.
     * @param ws The window system (ie: win32, carbon, gtk)
     */
    public void setWs(String ws)
    {
        this.ws = ws;
    }

    /**
     * The operating system to build for.
     * @param os The OS (ie: win32, macosx, linux)
     */
    public void setOs(String os)
    {
        this.os = os;
    }

    /**
     * The short name of the directory in the dist directory to place plugins.
     * @param pluginDir The plugins directory (default is "plugins")
     */
    public void setPluginDir(String pluginDir)
    {
        this.pluginDir = pluginDir;
    }

    protected Map<String, Plugin> getPlugins()
    {
        return plugins;
    }

    protected synchronized Set<Plugin> getPluginsToBuild()
    {
        if (pluginsToBuild == null)
        {
            pluginsToBuild = new HashSet<Plugin>();
            featuresToBuild = new HashSet<Feature>();
            cratesToBuild = new HashSet<Crate>();

            for (String id : pluginsAndFeaturesToBuild)
            {
                if (id.endsWith(".crate"))
                {
                    Crate crate = Crate.loadCrate(this, crateDir, id, getPlugins(), getFailOnMissingBundle());
                    cratesToBuild.add(crate);
                    addBundlesFromCrate(crate);
                }
                else
                {
                    addPluginToBuild(id);
                }
            }

            if (featuresToBuild.isEmpty())
            {
                // remove all plugins from the build that aren't added explicitly
                // but only if this build is not driven by features.
                plugins = new HashMap<String, Plugin>();
                for (Plugin p : pluginsToBuild)
                {
                    plugins.put(p.getId(), p);
                    log("Including: " + p.getId(), Project.MSG_VERBOSE);
                }
            }
        }
        return pluginsToBuild;
    }

    private void addPluginToBuild(String id)
    {
        Plugin plugin = plugins.get(id);
        if (plugin == null)
        {
            Feature feature = features.get(id);
            if (feature == null)
            {
                throw new BuildException("No plugin or feature found with id " + id);
            }

            featuresToBuild.add(feature);
            for (String pluginId : feature.getPlugins())
            {
                plugin = plugins.get(pluginId);
                if (plugin == null)
                {
                    throw new BuildException("No plugin found with id " + pluginId);
                }

                pluginsToBuild.add(plugin);
            }
        }
        else
        {
            pluginsToBuild.add(plugin);
        }
    }

    private void addBundlesFromCrate(Crate crate)
    {
        for (Plugin plugin : crate.getPlugins())
        {
            pluginsToBuild.add(plugin);
        }
    }

    protected Set<Crate> getCratesToBuild()
    {
        getPluginsToBuild();
        return cratesToBuild;
    }

    protected Set<Feature> getFeaturesToBuild()
    {
        getPluginsToBuild();
        return featuresToBuild;
    }

    protected File getRoot()
    {
        return root;
    }

    protected File getEclipseHome()
    {
        return eclipseHome;
    }

    protected File getDist()
    {
        return dist;
    }

    protected String getPluginDir()
    {
        return pluginDir;
    }
}
