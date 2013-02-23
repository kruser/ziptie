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

import static org.ziptie.build.BuildElf.mkdir;

import java.io.File;
import java.io.IOException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.PatternSet.NameEntry;
import org.ziptie.build.BuildElf;

/**
 * @author lbayer
 *
 */
@SuppressWarnings("nls")
public class DistLauncherTask extends Task
{
    private static final String ECLIPSE_EXE = "eclipse.exe";
    private static final String ECLIPSE_BIN = "eclipse";

    private File dist;
    private File eclipseHome;
    private File configIni;
    private String os;
    private String executableName = ECLIPSE_BIN;

    /** {@inheritDoc} */
    @Override
    public void execute()
    {
        if (dist == null)
        {
            throw new BuildException("dist directory must be specified");
        }

        File distConfigDir = new File(dist, "configuration");

        mkdir(this, distConfigDir);

        try
        {
            distOsSpecificFiles();
        }
        catch (IOException e)
        {
            throw new BuildException(e);
        }

        BuildElf.copy(this, new File(eclipseHome, "startup.jar"), dist);
        BuildElf.copy(this, configIni, distConfigDir);
    }

    private void distOsSpecificFiles() throws IOException
    {
        if (os.equals("macosx"))
        {
            FileSet fileset = new FileSet();
            fileset.setProject(getProject());
            fileset.setDir(eclipseHome);
            NameEntry include = fileset.createInclude();
            include.setName("Eclipse.app/**");

            Copy copy = new Copy();
            copy.setProject(getProject());
            copy.setTaskName("copy");
            copy.setTodir(dist);
            copy.addFileset(fileset);
            copy.execute();
        }
        else if (os.equals("win32"))
        {
            BuildElf.copy(this, new File(eclipseHome, ECLIPSE_EXE), new File(dist, executableName + ".exe"));
        }
        else if (os.equals("linux"))
        {
            File from = new File(eclipseHome, ECLIPSE_BIN);
            File to = new File(dist, executableName);

            //if running linux build on windows
            if (System.getProperty("os.name").toLowerCase().startsWith("windows"))
            {
                BuildElf.copy(this, new File(eclipseHome, ECLIPSE_BIN), new File(dist, executableName));
            }
            else
            {
                // use system's copy command to maintain this file's execute permission.
                Runtime.getRuntime().exec(new String[]{"cp", from.getAbsolutePath(), to.getAbsolutePath()});
            }
        }
    }

    /**
     * The operating system of the target platform.
     * @param os The operating system. (ie: win32, macosx, linux, etc)
     */
    public void setOs(String os)
    {
        this.os = os;
    }

    /**
     * The name of the executable. (eg: "eclipse.exe" will be renamed to this with "exe" appended.
     * @param executableName The new executable name. (default is "eclipse")
     */
    public void setExecutableName(String executableName)
    {
        this.executableName = executableName;
    }

    /**
     * The config.ini file that will be copied to dist.
     * @param configIni The config.ini file.
     */
    public void setConfigIni(File configIni)
    {
        this.configIni = configIni;
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
     * The directory that the built product will be deployed to.
     * @param dist The target directory.
     */
    public void setDist(File dist)
    {
        this.dist = dist;
    }
}
