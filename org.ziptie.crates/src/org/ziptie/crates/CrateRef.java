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

import java.util.HashSet;
import java.util.Set;


/**
 * Describes a crate reference on a site.
 */
public class CrateRef extends AbstractVersioned
{
    private String name;
    private Set<String> categories;

    // instance init
    {
        categories = new HashSet<String>();
    }

    /**
     * Get the crate's user friendly name.
     * @return The crate's name
     */
    public String getName()
    {
        return name;
    }

    /**
     * The categories this crate belongs to.
     * @return The categories.
     */
    public Set<String> getCategories()
    {
        return categories;
    }

    void setName(String name)
    {
        this.name = name;
    }

    void addCategory(String category)
    {
        categories.add(category);
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return String.format("crateref:%s_%s", getId(), getVersion()); //$NON-NLS-1$
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null || !(obj instanceof CrateRef))
        {
            return false;
        }

        CrateRef other = (CrateRef) obj;
        if (!other.getId().equals(getId()))
        {
            return false;
        }

        return getVersion().equals(other.getVersion());
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return getId().hashCode() ^ getVersion().hashCode();
    }
}
