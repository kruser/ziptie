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

import org.osgi.framework.Version;

/**
 * Defines the version interface for the crates.
 */
public abstract class AbstractVersioned
{
    private String version;
    private String id;

    /**
     * The crate version.
     * @return the version.
     */
    public String getVersion()
    {
        return version;
    }

    /**
     * The crate's id.
     * @return the id.
     */
    public String getId()
    {
        return id;
    }

    /**
     * Determines if this crate is newer than the given one.
     * @param other The other crate.
     * @return <code>true</code> if this is newer than <code>other</code>, false otherwise.
     */
    public boolean isNewerThan(AbstractVersioned other)
    {
        return new Version(getVersion()).compareTo(new Version(other.getVersion())) > 0;
    }

    /**
     * @param version the crate's version string
     */
    public void setVersion(String version)
    {
        this.version = version;
    }

    /**
     * @param id the crates' ID
     */
    public void setId(String id)
    {
        this.id = id;
    }
}
