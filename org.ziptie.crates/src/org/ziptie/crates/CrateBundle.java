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
package org.ziptie.crates;

/**
 * A OSGi bundle defined by a crate.
 */
public class CrateBundle
{
    private String id;
    private String version;
    private String location;
    private boolean deployedAsDirectory;
    private int startLevel;
    private boolean start;
    private String arch;
    private String ws;
    private String os;

    /**
     * Create the definition.
     * @param id The bundle id.
     * @param version The bundle version.
     * @param location The OSGi container relative path to the bundle.
     */
    public CrateBundle(String id, String version, String location)
    {
        this.id = id;
        this.version = version;
        this.location = location;
    }

    /**
     * Gets the bundle id.
     * @return the bundle id.
     */
    public String getId()
    {
        return id;
    }

    /**
     * The bundle version.
     * @return the version.
     */
    public String getVersion()
    {
        return version;
    }

    /**
     * The install relative location that this bundle would be placed. (eg: "plugins/" or "plugins/org.example_blah.jar")
     * @return The install location for this bundle.
     */
    public String getLocation()
    {
        return location;
    }

    /**
     * Gets the OSGi start level.  This is only applicable if {@link #isStart()} returns <code>true</code>.
     * @return The start level to apply to the bundle
     */
    public int getStartLevel()
    {
        return startLevel;
    }

    /**
     * Gets whether this bundle should be automatically started when the crate is activated.
     * @return <code>true</code> if this bundle should be started automatically.
     */
    public boolean isStart()
    {
        return start;
    }

    /**
     * The operating system filter.
     * @return the filter or <code>null</code> if no filter.
     */
    public String getOs()
    {
        return os;
    }

    /**
     * The window system filter.
     * @return the filter or <code>null</code> if no filter.
     */
    public String getWs()
    {
        return ws;
    }

    /**
     * The os architecture filter.
     * @return the filter or <code>null</code> if no filter.
     */
    public String getArch()
    {
        return arch;
    }

    void setOs(String os)
    {
        this.os = os;
    }

    void setWs(String ws)
    {
        this.ws = ws;
    }

    void setArch(String arch)
    {
        this.arch = arch;
    }

    void setStart(boolean start)
    {
        this.start = start;
    }

    void setStartLevel(int startLevel)
    {
        this.startLevel = startLevel;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null)
        {
            return false;
        }
        if (!(obj instanceof CrateBundle))
        {
            return false;
        }

        return ((CrateBundle) obj).getId().equals(getId());
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return getId().hashCode();
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return String.format("cratebundle: %s_%s", getId(), getVersion()); //$NON-NLS-1$
    }

    /**
     * @return true if this bundle should be deployed in directory form.
     */
    public boolean isDeployedAsDirectory()
    {
        return deployedAsDirectory;
    }

    /**
     * Should this bundle be deployed in directory form?
     * 
     * @param deployedAsDirectory true if this bundle should be deployed as a directory.
     */
    public void setDeployedAsDirectory(boolean deployedAsDirectory)
    {
        this.deployedAsDirectory = deployedAsDirectory;
    }
}
