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

import static org.ziptie.build.BuildElf.delete;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import javax.xml.parsers.ParserConfigurationException;

import org.apache.tools.ant.BuildException;
import org.xml.sax.SAXException;
import org.ziptie.build.Plugin;

/**
 * Task that cleans a set of plugins.
 */
@SuppressWarnings("nls")
public class CleanTask extends AbstractBuildTask
{
    /**
     * Create the task.
     */
    public CleanTask()
    {
        setFailOnMissingBundle(false);
    }

    /** {@inheritDoc} */
    @Override
    public void execute()
    {
        try
        {
            readPluginsFromDir(getRoot());

            Set<Plugin> plugins = getPluginsToBuild();
            for (Plugin plugin : plugins)
            {
                // only clean plugins in our root
                if (plugin.getDir().getParentFile().equals(getRoot()))
                {
                    callTarget(plugin, "pre_clean");

                    clean(plugin);
                }
            }
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

    /**
     * Cleans up the build artifacts for <code>plugin</code>
     * @param plugin The plugin to clean.
     */
    private void clean(Plugin plugin)
    {
        log("cleaning " + plugin.getId());

        Map<File, File> outputs = plugin.getOutputs();

        for (File file : plugin.getJars())
        {
            if (file.isFile()) // jar file
            {
                delete(this, file);
            }
        }

        for (Entry<File, List<File>> entry : plugin.getSources())
        {
            File file = entry.getKey();
            if (file.isFile()) // jar file
            {
                delete(this, file);
            }

            file = outputs.get(file);
            if (file == null)
            {
                file = new File(plugin.getDir(), "bin");
            }
            if (file.isDirectory()) // bin dir
            {
                delete(this, file);
            }
        }
    }
}
