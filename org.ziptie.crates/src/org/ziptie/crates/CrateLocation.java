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
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import org.osgi.framework.Version;

/**
 * Defines a location which contains Bundle Crates.
 */
public abstract class CrateLocation
{
    private Set<Crate> crates;

    /**
     * Get all the crates found in this location.
     * @return The crates.
     * @throws CrateException On error.
     */
    public synchronized Set<Crate> getAllCrates() throws CrateException
    {
        if (crates == null)
        {
            loadCrates();
        }
        return crates;
    }

    /**
     * Gets the latest version of each crate for this location.
     * @return All the latest crates.
     * @throws CrateException on error.
     */
    public Set<Crate> getLatestCrates() throws CrateException
    {
        return getLatest(getAllCrates());
    }

    /**
     * @param categoryName the name of a crate category
     * @return a subset of the latest versions of crates that are tagged with the specified category
     * @throws CrateException on error
     */
    public Set<Crate> getLatestCratesOfCategory(String categoryName) throws CrateException
    {
        Set<Crate> latestOfCategory = new HashSet<Crate>();
        Set<Crate> latest = getLatestCrates();
        for (Crate c : latest)
        {
            if (c.getCategories().contains(categoryName))
            {
                latestOfCategory.add(c);
            }
        }

        return latestOfCategory;
    }

    /**
     * Return the latest versioned 'thing' (typically Crate) for each unique 'thing' ID in a supplied set.
     * 
     * @param <T> the type of AbstractVersioned object; typically a Crate
     * @param all the set of things (Crates) under examination
     * @return the subset of 'all' containing the latest things
     */
    public <T extends AbstractVersioned> Set<T> getLatest(Set<T> all)
    {
        Map<String, T> crateById = new HashMap<String, T>();
        for (T crate : all)
        {
            T c = crateById.get(crate.getId());
            if (c == null || crate.isNewerThan(c))
            {
                crateById.put(crate.getId(), crate);
            }
        }

        return new HashSet<T>(crateById.values());
    }

    /**
     * Get the crate for the given id and version.  If version is null the latest version for the given id is returned.
     * @param id the crate id.
     * @param strVersion The version or <code>null</code> for the latest.
     * @return the newest crate identified by id and strVersion, or <code>null</code> if none is found.
     * @throws CrateException on read error.
     */
    public Crate getCrate(String id, String strVersion) throws CrateException
    {
        Crate result = null;
        for (Crate crate : getAllCrates())
        {
            if (!crate.getId().equals(id))
            {
                continue;
            }

            if (strVersion == null)
            {
                if (result == null || isLessThan(result.getVersion(), crate.getVersion()))
                {
                    result = crate;
                }
            }
            else if (crate.getVersion().equals(strVersion))
            {
                return crate;
            }
        }
        return result;
    }

    protected boolean isLessThan(String a, String b)
    {
        return new Version(a).compareTo(new Version(b)) < 0;
    }

    protected Crate getCrate(URL url) throws CrateException
    {
        return CrateSaxHandler.readCrate(url);
    }

    protected synchronized void addCrate(Crate crate) throws CrateException
    {
        if (crates == null)
        {
            loadCrates();
        }
        crates.add(crate);
    }

    private void loadCrates() throws CrateException
    {
        crates = new LinkedHashSet<Crate>();

        for (URL url : getCrateUrls())
        {
            crates.add(getCrate(url));
        }
    }

    protected abstract URL[] getCrateUrls() throws CrateException;
}
