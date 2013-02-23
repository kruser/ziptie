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

/**
 * The platform configuration to use for a build.
 */
public class PlatformConfig
{
    private String os;
    private String ws;
    private String arch;

    /**
     * Create the config.
     * @param os The OS
     * @param ws The window system
     * @param arch The architecture
     */
    public PlatformConfig(String os, String ws, String arch)
    {
        this.os = os;
        this.ws = ws;
        this.arch = arch;
    }

    /**
     * The target system architecture.
     * @return The architecture
     */
    public String getArch()
    {
        return arch;
    }

    /**
     * The target operating system.
     * @return The Operating system
     */
    public String getOs()
    {
        return os;
    }

    /**
     * The target window system
     * @return The window system.
     */
    public String getWs()
    {
        return ws;
    }

    /**
     * Determines if the given configuration is applicable for this one.
     * @param pos The other OS
     * @param pws The other window system
     * @param parch The other architecture.
     * @return <code>true</code> if the given parameters are a subset of this configuration.
     */
    public boolean isInConfig(String pos, String pws, String parch)
    {
        if (pos != null && !pos.equals(os))
        {
            return false;
        }
        else if (pws != null && !pws.equals(ws))
        {
            return false;
        }
        else if (parch != null && !parch.equals(arch))
        {
            return false;
        }
        return true;
    }
}
