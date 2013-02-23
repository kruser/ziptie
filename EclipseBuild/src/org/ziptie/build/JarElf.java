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
import java.util.List;
import java.util.Map;

import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Jar;

/**
 * Helper for jarring bundles.
 */
@SuppressWarnings("nls")
public final class JarElf
{
    /** Hidden constructor */
    private JarElf()
    {
        // do nothing
    }

    /**
     * Jars the class files for the specified plugin.
     * @param task the calling ant task
     * @param plugin The plugin
     */
    public static void jar(Task task, Plugin plugin)
    {
        task.log("Jaring plugin: " + plugin.getId());

        List<File> sources = plugin.getJars();
        Map<File, File> outputs = plugin.getOutputs();
        for (File jar : sources)
        {
            if (jar.getName().equals("."))
            {
                // don't jar this one yet, dist will jar it.
                continue;
            }

            File bin = outputs.get(jar);
            if (bin == null)
            {
                bin = new File(plugin.getDir(), "bin");
            }

            Jar jarTask = new Jar();
            jarTask.setProject(task.getProject());
            jarTask.setTaskName("jar");
            jarTask.setBasedir(bin);
            jarTask.setDestFile(jar);
            jarTask.execute();
        }
    }
}
