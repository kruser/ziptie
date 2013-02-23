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

import static org.ziptie.build.BuildElf.COPY_TASK;

import java.io.File;
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.filters.TokenFilter;
import org.apache.tools.ant.filters.TokenFilter.ReplaceRegex;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Jar;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.FilterChain;
import org.apache.tools.ant.types.PatternSet.NameEntry;
import org.ziptie.build.tasks.DistTask;

/**
 * Helper for distributing bundles.
 */
@SuppressWarnings("nls")
public final class DistElf
{
    private static final String CRATE_EXTENSION = ".crate";

    /** Hidden constructor */
    private DistElf()
    {
        // do nothing
    }

    /**
     * Copies the build results of <code>feature</code> to {@link #distFeatureDir}
     * @param task the calling ant task
     * @param feature The feature to dist.
     * @param distFeatureDir The destination directory.
     * @param versionQualifier The version qualifier.
     * @param allPlugins all the plugins.
     */
    public static void dist(Task task, Feature feature, File distFeatureDir, String versionQualifier, Map<String, Plugin> allPlugins)
    {
        String includes = feature.getBinIncludes();
        if (includes != null)
        {
            task.log("Distributing feature: " + feature.getId());

            File featureDir = feature.getDir();
            File resultDir = new File(distFeatureDir, feature.getId() + '_' + version(feature, versionQualifier));

            File featXml = new File(featureDir, Feature.FEATURE_XML);
            if (featXml.isFile())
            {
                Copy featCopy = new Copy();
                featCopy.setProject(task.getProject());
                featCopy.setTaskName(COPY_TASK);
                featCopy.setTodir(resultDir);
                featCopy.setFailOnError(true);
                featCopy.setFile(featXml);
                featCopy.setFiltering(true);

                FilterChain fc = featCopy.createFilterChain();

                String featurePattern = "(\\<feature.+?version\\s*=)\\\".+?(\\\")";
                ReplaceRegex featureRr = new TokenFilter.ReplaceRegex();
                featureRr.setProject(task.getProject());
                featureRr.setPattern(featurePattern);
                featureRr.setFlags("s"); // singline
                featureRr.setByLine(false);
                featureRr.setReplace("\\1\"" + version(feature, versionQualifier) + "\\2");
                fc.addReplaceRegex(featureRr);

                for (String string : feature.getPlugins())
                {
                    Plugin p = allPlugins.get(string);

                    // TODO lbayer: escape the id to be good within a regex
                    String pattern = "(id\\s*=\\s*\\\"" + p.getId() + "\\\".+?version\\s*=)\\\"0\\.0\\.0(\\\")";
                    ReplaceRegex rr = new TokenFilter.ReplaceRegex();
                    rr.setProject(task.getProject());
                    rr.setPattern(pattern);
                    rr.setFlags("s"); // singline
                    rr.setByLine(false);
                    rr.setReplace("\\1\"" + p.version(versionQualifier) + "\\2");
                    fc.addReplaceRegex(rr);
                }

                featCopy.execute();
            }

            dist(task, featureDir, includes, resultDir);
        }
        else
        {
            BuildElf.copy(task, feature.getDir(), distFeatureDir);
        }
    }

    /**
     * Distributes the given plugin.
     * @param task The calling ant task
     * @param plugin The plugin to dist.
     * @param dest The destination plugins directory.
     * @param versionQualifier The version qualifier to append to the plugin's version.
     */
    public static void dist(Task task, Plugin plugin, File dest, String versionQualifier)
    {
        task.log("Distributing plugin: " + plugin.getId());

        String qualifiedVersion = plugin.version(versionQualifier);

        File pluginDir = plugin.getDir();
        File resultDir = new File(dest, plugin.getId() + '_' + qualifiedVersion);

        BuildElf.mkdir(task, dest);

        File mfFile = new File(pluginDir, Plugin.MANIFEST_MF);
        if (mfFile.isFile())
        {
            boolean jarPlugin = plugin.getJars().contains(new File(plugin.getDir(), ".")) || plugin.getOutputs().containsKey(new File(pluginDir, "."));

            boolean noJarBundles = Boolean.getBoolean("no.jar.bundles");
            if (jarPlugin && !noJarBundles)
            {
                File filteredManifest = new File(pluginDir, "MANIFEST.MF");

                replaceVersionInManifest(task, qualifiedVersion, filteredManifest.getParentFile(), mfFile);

                File binDir = plugin.getOutputs().get(new File(pluginDir, "."));
                if (binDir == null)
                {
                    binDir = new File(pluginDir, "bin");
                }

                Jar jarTask = new Jar();
                jarTask.setProject(task.getProject());
                jarTask.setTaskName("jar");
                jarTask.setManifest(filteredManifest);
                jarTask.setDestFile(new File(dest, plugin.getId() + '_' + qualifiedVersion + ".jar"));
                jarTask.setUpdate(true);
                jarTask.setDefaultexcludes(true);

                FileSet fileset = getDistFileset(task, pluginDir, plugin.getBinIncludes());
                jarTask.addFileset(fileset);

                if (binDir.isDirectory())
                {
                    fileset = new FileSet();
                    fileset.setProject(task.getProject());
                    fileset.setDir(binDir);
                    jarTask.addFileset(fileset);
                }

                jarTask.execute();

                filteredManifest.delete();

                return;
            }
            else
            {
                replaceVersionInManifest(task, qualifiedVersion, new File(resultDir, Plugin.META_INF), mfFile);
            }
        }
        else
        {
            File pFile = new File(pluginDir, Plugin.PLUGIN_XML);

            if (pFile.isFile())
            {
                Copy pCopy = new Copy();
                pCopy.setProject(task.getProject());
                pCopy.setTaskName(COPY_TASK);
                pCopy.setTodir(resultDir);
                pCopy.setFailOnError(true);
                pCopy.setFile(pFile);
                pCopy.setFiltering(true);

                FilterChain fc = pCopy.createFilterChain();
                ReplaceRegex rr = new TokenFilter.ReplaceRegex();
                rr.setProject(task.getProject());
                rr.setPattern("version\\s*=\\s*\"" + plugin.getVersion());
                rr.setByLine(true);
                rr.setReplace("version=\"" + qualifiedVersion);
                fc.addReplaceRegex(rr);

                pCopy.execute();
            }
        }

        dist(task, pluginDir, plugin.getBinIncludes(), resultDir);
    }

    /**
     * Distribute the given crate.
     * @param task The calling task.
     * @param crate The crate to distribute
     * @param crateDir The destination crate directory.
     * @param versionQualifier The version qualifier
     */
    public static void dist(DistTask task, Crate crate, File crateDir, String versionQualifier)
    {
        task.log("Distributing crate: " + crate.getFile().getName());

        File file = crate.getFile();

        String name = file.getName();
        name = name.substring(0, name.length() - CRATE_EXTENSION.length());
        name = name + '_' + version(crate, versionQualifier) + CRATE_EXTENSION;
        File dest = new File(crateDir, name);

        Copy copy = new Copy();
        copy.setProject(task.getProject());
        copy.setTaskName(COPY_TASK);
        copy.setTofile(dest);
        copy.setFile(file);
        copy.setFailOnError(true);
        copy.setFiltering(true);

        FilterChain fc = copy.createFilterChain();

        String cratePattern = "(\\<crate[^>]+?version\\s*=)\\\"[^\\\"]+?(\\\")";
        ReplaceRegex featureRr = new TokenFilter.ReplaceRegex();
        featureRr.setProject(task.getProject());
        featureRr.setPattern(cratePattern);
        featureRr.setFlags("s"); // singline
        featureRr.setByLine(false);
        featureRr.setReplace("\\1\"" + version(crate, versionQualifier) + "\\2");
        fc.addReplaceRegex(featureRr);

        for (Plugin p : crate.getPlugins())
        {
            // TODO lbayer: escape the id to be good within a regex
            String pattern = "(id\\s*=\\s*\\\"" + p.getId() + "\\\"[^>]+?version\\s*=)\\\"(\\\")";
            ReplaceRegex rr = new TokenFilter.ReplaceRegex();
            rr.setProject(task.getProject());
            rr.setPattern(pattern);
            rr.setFlags("s"); // singline
            rr.setByLine(false);
            rr.setReplace("\\1\"" + p.version(versionQualifier) + "\\2");
            fc.addReplaceRegex(rr);
        }

        copy.execute();
    }

    private static void replaceVersionInManifest(Task task, String qualifiedVersion, File resultDir, File mfFile)
    {
        Copy mfCopy = new Copy();
        mfCopy.setProject(task.getProject());
        mfCopy.setTaskName(COPY_TASK);
        mfCopy.setTodir(resultDir);
        mfCopy.setFailOnError(true);
        mfCopy.setFile(mfFile);
        mfCopy.setFiltering(true);

        FilterChain fc = mfCopy.createFilterChain();
        ReplaceRegex rr = new TokenFilter.ReplaceRegex();
        rr.setProject(task.getProject());
        rr.setPattern("Bundle-Version:.+$");
        rr.setByLine(true);
        rr.setReplace("Bundle-Version: " + qualifiedVersion);
        fc.addReplaceRegex(rr);

        mfCopy.execute();
    }

    private static FileSet getDistFileset(Task task, File sourceDir, String includes)
    {
        FileSet fileset = new FileSet();
        fileset.setProject(task.getProject());
        fileset.setDir(sourceDir);

        String[] files = includes.split(",");
        for (String file : files)
        {
            NameEntry include = fileset.createInclude();
            include.setName(file.trim());
        }

        return fileset;
    }

    /**
     * Copies the files specified by <code>includes</code> from <code>sourceDir</code> to <code>resultDir</code>
     * @param task the calling ant task.
     * @param sourceDir The directory of the desired plugin or feature.
     * @param includes This should be the value of 'bin.includes' from the build.properties file for the plugin or feature.
     * @param resultDir The destination eclipse directory.  (ei: eclipse/plugins or eclipse/features)
     */
    private static void dist(Task task, File sourceDir, String includes, File resultDir)
    {
        if (includes == null)
        {
            throw new BuildException("Missing build.properties for plugin " + (sourceDir != null ? sourceDir.getName() : "[unknown]"));
        }

        BuildElf.mkdir(task, resultDir);

        FileSet fileset = getDistFileset(task, sourceDir, includes);

        Copy copy = new Copy();
        copy.setProject(task.getProject());
        copy.setTaskName("copy");
        copy.setTodir(resultDir);
        copy.setFailOnError(true);
        copy.addFileset(fileset);
        copy.execute();
    }

    private static String version(Crate crate, String qualifier)
    {
        return isQualifierSet(qualifier) ? crate.getVersion() + "." + qualifier : crate.getVersion();
    }

    private static String version(Feature feature, String qualifier)
    {
        return isQualifierSet(qualifier) ? feature.getVersion() + "." + qualifier : feature.getVersion();
    }

    private static boolean isQualifierSet(String qualifier)
    {
        return qualifier != null && qualifier.length() > 0;
    }
}
