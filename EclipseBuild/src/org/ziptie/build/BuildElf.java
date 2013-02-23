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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.apache.tools.ant.types.FileSet;

/**
 * Helper methods for the build.
 */
@SuppressWarnings("nls")
public final class BuildElf
{
    public static final String COPY_TASK = "copy";

    /** Hidden constructor */
    private BuildElf()
    {
        // do nothing
    }

    /**
     * Creates the specified directory using the {@link Mkdir} ant task.
     * @param task the calling ant task.
     * @param dir the Directory to create.
     */
    public static void mkdir(Task task, File dir)
    {
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(task.getProject());
        mkdir.setTaskName("mkdir");
        mkdir.setDir(dir);
        mkdir.execute();
    }

    /**
     * Deletes the specified file or directory using the {@link Delete} ant task.
     * @param task The calling ant task.
     * @param file the file to delete.
     */
    public static void delete(Task task, File file)
    {
        task.log(" deleting " + file);
        Delete delete = new Delete();
        delete.setProject(task.getProject());
        delete.setTaskName("delete");
        if (file.isFile())
        {
            delete.setFile(file);
        }
        else if (file.isDirectory())
        {
            delete.setDir(file);
        }
        else
        {
            return;
        }

        delete.execute();
    }

    /**
     * Copies a file using the ant copy task.
     * @param task the calling ant task.
     * @param from The file to copy.
     * @param to The destination.  If this is not a directory it will considered to be a file. 
     */
    public static void copy(Task task, File from, File to)
    {
        Copy copy = new Copy();
        copy.setProject(task.getProject());
        copy.setTaskName(COPY_TASK);

        if (from.isDirectory())
        {
            FileSet fileset = new FileSet();
            fileset.setProject(task.getProject());
            fileset.setDir(from.getParentFile());
            fileset.setIncludes(from.getName() + "/**");

            copy.addFileset(fileset);
        }
        else
        {
            copy.setFile(from);
        }

        if (to.isDirectory())
        {
            copy.setTodir(to);
        }
        else
        {
            copy.setTofile(to);
        }
        copy.execute();
    }

    /**
     * Gets all the fragments that have been injected into the given plugin.
     * @param allPlugins The set of all plugins.
     * @param pluginId The id of the host plugin.
     * @return The injected fragments.
     */
    public static Set<Plugin> findInjectedFragments(Collection<Plugin> allPlugins, String pluginId)
    {
        Set<Plugin> result = new HashSet<Plugin>();
        for (Plugin plugin : allPlugins)
        {
            String host = plugin.getFragmentHost();
            if (host != null && host.equals(pluginId))
            {
                result.add(plugin);
            }
        }
        return result;
    }

    /**
     * Creates an input stream that ends in exactly one CRLF ("\r\n") and no other whitespace.
     *
     * @param input The input stream
     * @return a new input stream.
     * @throws IOException on error
     */
    public static ByteArrayInputStream normalizeLastNewlinesEOF(InputStream input) throws IOException
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buf = new byte[2048];
        int len = 0;
        while ((len = input.read(buf)) >= 0)
        {
            baos.write(buf, 0, len);
        }

        byte[] contents = baos.toByteArray();
        len = contents.length;
        while (len > 1 && Character.isWhitespace(contents[len - 1]))
        {
            len--;
        }

        buf = new byte[len + 2];
        System.arraycopy(contents, 0, buf, 0, len);
        buf[len] = '\r';
        buf[len + 1] = '\n';
        // both CR and LF are required to comply with the MANIFEST's expected input

        return new ByteArrayInputStream(buf);
    }
}
