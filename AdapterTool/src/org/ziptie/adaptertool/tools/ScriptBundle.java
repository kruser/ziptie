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
 */
package org.ziptie.adaptertool.tools;

import java.io.File;

/**
 * ScriptBundle
 */
public class ScriptBundle
{
    private File bundle;
    private String scriptsFolderName;

    /**
     * New {@link ScriptBundle}
     * @param bundle the bundle folder
     * @param scriptsFolderName the name of the "ZTool-Directory"
     */
    public ScriptBundle(File bundle, String scriptsFolderName)
    {
        this.bundle = bundle;
        this.scriptsFolderName = scriptsFolderName;
    }

    /**
     * @return the bundle
     */
    public File getBundle()
    {
        return bundle;
    }

    /**
     * @param bundle the bundle to set
     */
    public void setBundle(File bundle)
    {
        this.bundle = bundle;
    }

    /**
     * @return the scriptsFolderName
     */
    public String getScriptsFolderName()
    {
        return scriptsFolderName;
    }

    /**
     * @param scriptsFolderName the scriptsFolderName to set
     */
    public void setScriptsFolderName(String scriptsFolderName)
    {
        this.scriptsFolderName = scriptsFolderName;
    }

}
