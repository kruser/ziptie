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

import static org.apache.tools.ant.Project.MSG_INFO;
import static org.apache.tools.ant.Project.MSG_VERBOSE;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Javac;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;

/**
 * Helper for compiling bundles.
 */
@SuppressWarnings("nls")
public final class CompileElf
{
    private static final String TRUE = "true";

    /** hidden constructor */
    private CompileElf()
    {
        // do nothing
    }

    /**
     * Compiles the sources for the specified plugin.
     * <p>If no output directory is defined for a jar then the sources will be compiled into 'bin/'
     * 
     * @param task the calling ant task.
     * @param plugin The plugin to compile
     * @param allPlugins A map of all the plugins that are visible to this build.
     * @throws IOException on error
     */
    public static void compile(Task task, Plugin plugin, Map<String, Plugin> allPlugins) throws IOException
    {
        File pluginDir = plugin.getDir();

        task.log("Compiling: " + plugin.getId(), MSG_INFO);

        HashSet<File> classpathEntries = new HashSet<File>();
        computeClasspath(classpathEntries, allPlugins, plugin);
        classpathEntries.removeAll(plugin.getJars());

        Path classpath = new Path(task.getProject());
        for (File file : classpathEntries)
        {
            task.log("   + " + file.toString(), MSG_VERBOSE);
            classpath.add(new Path(task.getProject(), file.toString()));
        }

        for (Entry<File, List<File>> entry : plugin.getSources())
        {
            File jar = entry.getKey();
            List<File> srcDirs = entry.getValue();
            File destDir = plugin.getOutputs().get(jar);
            if (destDir == null)
            {
                destDir = new File(pluginDir, "bin");
            }
            if (!destDir.exists())
            {
                BuildElf.mkdir(task, destDir);
            }

            task.log("  jar: " + jar + " source: " + srcDirs, MSG_VERBOSE);

            Javac javac = new Javac();
            javac.setProject(task.getProject());

            for (File src : srcDirs)
            {
                javac.createSrc().setLocation(src);
            }

            //javac.setFork(true);
            javac.setDestdir(destDir);
            javac.setClasspath(classpath);
            javac.setFailonerror(true);
            javac.setDebug(isJavacDebug(task.getProject()));
            javac.setSource(property(task.getProject(), "javacSource", "1.5"));
            javac.setTarget(property(task.getProject(), "javacTarget", "1.5"));
            javac.setTaskName("javac");
            javac.execute();

            // copy non java files from source into the build output directory. (ie: properties files)
            for (File srcDir : srcDirs)
            {
                FileSet fileset = new FileSet();
                fileset.setDir(srcDir);
                fileset.setExcludes("**/*.java");

                Copy copy = new Copy();
                copy.setProject(task.getProject());
                copy.setTaskName(BuildElf.COPY_TASK);
                copy.setTodir(destDir);
                copy.addFileset(fileset);
                copy.execute();
            }
        }
    }

    private static boolean isJavacDebug(Project project)
    {
        String prop = property(project, "javacDebug", TRUE);
        return prop.equalsIgnoreCase(TRUE) || prop.equalsIgnoreCase("on") || prop.equalsIgnoreCase("yes");
    }

    /**
     * Null safe property getter.
     *
     * @param project the ant project.
     * @param name The property to get.
     * @param defualt The default value.
     * @return The value of the ant property, or <code>defualt</code> if that is <code>null</code>.
     */
    private static String property(Project project, String name, String defualt)
    {
        String val = project.getProperty(name);
        return val == null ? defualt : val;
    }

    /**
     * Recursively computes the classpath for the specified plugin.
     * 
     * @param result A set which the classpath entries will be added to.
     * @param plugin The plugin to compute.
     */
    private static void computeClasspath(Set<File> result, Map<String, Plugin> allPlugins, Plugin plugin)
    {
        computeClasspath(result, allPlugins, plugin, new HashSet<Plugin>());
    }

    private static void computeClasspath(Set<File> result, Map<String, Plugin> allPlugins, Plugin plugin, Set<Plugin> completed)
    {
        // we maintain a list of completed plugins so that we don't compute the classpath for the same plugin twice.
        if (completed.contains(plugin))
        {
            return;
        }
        completed.add(plugin);

        addToClasspath(result, plugin);

        Set<Plugin> fragments = BuildElf.findInjectedFragments(allPlugins.values(), plugin.getId());
        if (fragments != null)
        {
            for (Plugin child : fragments)
            {
                if (child.isEnabled())
                {
                    computeClasspath(result, allPlugins, child, completed);
                }
            }
        }

        for (String emport : plugin.getImports())
        {
            Plugin child = allPlugins.get(emport);
            if (child != null)
            {
                computeClasspath(result, allPlugins, child, completed);
            }
        }

        for (String packageImport : plugin.getImportPackage())
        {
            for (Plugin other : allPlugins.values())
            {
                if (other.getPackages().contains(packageImport))
                {
                    computeClasspath(result, allPlugins, other, completed);
                    break;
                }
            }
        }
    }

    private static void addToClasspath(Set<File> result, Plugin plugin)
    {
        Set<String> libs = plugin.getLibraries();
        if (libs.isEmpty())
        {
            result.add(plugin.getDir());
        }
        else
        {
            for (String lib : libs)
            {
                if (lib.equals("."))
                {
                    File dotDir = new File(plugin.getDir(), ".");
                    if (plugin.getJars().contains(dotDir))
                    {
                        File binDir = plugin.getOutputs().get(dotDir);

                        result.add(binDir == null ? new File(plugin.getDir(), "bin") : binDir);
                    }
                    else
                    {
                        result.add(plugin.getDir());
                    }
                }
                else
                {
                    result.add(new File(plugin.getDir(), lib));
                }
            }
        }

        for (File output : plugin.getOutputs().values())
        {
            result.add(output);
        }
    }
}
