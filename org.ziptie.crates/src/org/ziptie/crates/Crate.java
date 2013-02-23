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

import java.net.URL;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * Defines a set of OSGi bundles that encompas a logical feature set.
 */
public class Crate extends AbstractVersioned
{
    private List<CrateBundle> bundles;
    private Set<String> dependencies;
    private Set<String> categories;
    private Set<String> includes;

    private String name;
    private String artifact;
    private String description;
    private URL url;

    /**
     * Create a new crate.
     * 
     * @param url reference to a crate XML file
     */
    public Crate(URL url)
    {
        this.url = url;
        bundles = new LinkedList<CrateBundle>();
        dependencies = new HashSet<String>();
        categories = new HashSet<String>();
        includes = new HashSet<String>();
    }

    /**
     * Get the set of crate id's that this crate depends on.
     * @return This crate's dependencies.
     */
    public Set<String> getDependencies()
    {
        return dependencies;
    }

    /**
     * Get the set of category tags this crate belongs to.
     * 
     * @return this crate's categories.
     */
    public Set<String> getCategories()
    {
        return categories;
    }

    /**
     * Add a new category tag to this crate.
     * 
     * @param category the name of a category tag.
     */
    public void addCategory(String category)
    {
        this.categories.add(category);
    }

    /**
     * The location of this crate.
     * @return The crate's url.
     */
    public URL getUrl()
    {
        return url;
    }

    /**
     * The ordered list of bundles this crate includes.
     * @return The bundles.
     */
    public List<CrateBundle> getBundles()
    {
        return bundles;
    }

    /**
     * Gets a user friendly name for this bundle
     * @return The user friendly name.
     */
    public String getName()
    {
        return name;
    }

    /**
     * Gets this crate's install artifact.
     * @return the artifact name or <code>null</code>
     */
    public String getArtifact()
    {
        return artifact;
    }

    /**
     * Gets the description for this bundle.
     * @return A user friendly description.
     */
    public String getDescription()
    {
        return description;
    }

    /**
     * Add a bundle to this this crate
     * 
     * @param bundle the bundle to be added
     */
    public void addBundle(CrateBundle bundle)
    {
        bundles.add(bundle);
    }

    /**
     * Set this crate's name
     * 
     * @param name the new name
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * @param artifact the artifact for this crate
     */
    public void setArtifact(String artifact)
    {
        this.artifact = artifact;
    }

    /**
     * Add a dependency to this crate
     * 
     * @param crate the crate we depend on
     */
    public void addDependency(String crate)
    {
        dependencies.add(crate);
    }

    /**
     * @param description the new crate description
     */
    public void setDescription(String description)
    {
        this.description = description;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return String.format("crate:%s_%s", getId(), getVersion()); //$NON-NLS-1$
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        if (obj == null || !(obj instanceof Crate))
        {
            return false;
        }

        Crate other = (Crate) obj;
        return other.getUrl().equals(getUrl());
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return getUrl().hashCode();
    }

    /**
     * @param includeCategory the name of a crate category included by startup of this crate
     */
    public void addInclude(String includeCategory)
    {
        includes.add(includeCategory);
    }

    /**
     * @return the set of categories included by this category
     */
    public Set<String> getIncludes()
    {
        return includes;
    }
}
