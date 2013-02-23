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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

/**
 * TODO lbayer: Add class description here
 */
public class SimTask extends Task
{
    private String dir;

    public void execute() throws BuildException
    {
        try
        {
            File simDir = new File(dir);
            Runtime.getRuntime().exec("cmd /c run.bat", null, simDir);
            Thread.sleep(5000);
        }
        catch (Throwable e)
        {
            throw new BuildException("Error spawning simulator!", e);
        }
    }

    public void setDir(String dir)
    {
        this.dir = dir;
    }
}
