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

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;

import org.apache.log4j.Logger;

/**
 * Defines a crate location that exists on the local file system.
 */
public class InstallLocation extends CrateLocation
{
    private File crateDir;
    private File root;
    private String os;
    private String ws;
    private String arch;

    private File enabledApplicationProperties;

    /**
     * Create a crate location.
     * @param root The root install directory.
     * @param crateDir The directory containing the crate definition files.
     * @param os The operating system of the install or <code>null</code> if not applicable.
     * @param ws The window system of the install or <code>null</code> if not applicable.
     * @param arch The architecture of the install or <code>null</code> if not applicable.
     */
    public InstallLocation(File root, File crateDir, String os, String ws, String arch)
    {
        this.crateDir = crateDir;
        this.root = root;
        this.os = os;
        this.ws = ws;
        this.arch = arch;
    }

    /**
     * (Re)set the property file for enabled applications.  This file should contain
     * properties of the form:
     * 
     *  <verbatim>
     *      fully.qualified.crate.name=[true|false]
     *  </verbatim>
     * 
     * Where the named crate is tagged with the "application" category, and the property
     * value indicates whether that application should be started.
     * 
     * @param propertiesFile a standard java.util.Properties file
     */
    public void setEnabledApplicationProperties(File propertiesFile) throws CrateException
    {
        this.enabledApplicationProperties = propertiesFile;
    }

    /**
     * The operating system (eg: linux, win32, macosx, ...)
     * @return The operating system of the install or <code>null</code> if not applicable.
     */
    public String getOs()
    {
        return os;
    }

    /**
     * The window system (eg: win32, carbon, gtk, ...)
     * @return The window system of the install or <code>null</code> if not applicable.
     */
    public String getWs()
    {
        return ws;
    }

    /**
     * The architecture (eg: x86, x86_64, ppc, ...)
     * @return The architecture of the install or <code>null</code> if not applicable.
     */
    public String getArch()
    {
        return arch;
    }

    /**
     * Gets the install root.
     * @return The root of this install.
     */
    public File getRoot()
    {
        return root;
    }

    /**
     * The directory containing crates.
     * @return The directory containing the crate definition files.
     */
    public File getCrateDir()
    {
        return crateDir;
    }

    protected URL[] getCrateUrls()
    {
        File[] files = crateDir.listFiles(new FilenameFilter()
        {
            public boolean accept(File dir, String name)
            {
                return name.endsWith(".crate"); //$NON-NLS-1$
            }
        });
        if (files == null)
        {
            return new URL[0];
        }

        ArrayList<URL> urls = new ArrayList<URL>(files.length);

        for (File file : files)
        {
            try
            {
                urls.add(file.toURL());
            }
            catch (MalformedURLException e)
            {
                Logger.getLogger(getClass()).error("Bad file for URL: " + file, e); //$NON-NLS-1$
            }
        }

        return urls.toArray(new URL[urls.size()]);
    }

    /**
     * Determines if the given bundle is applicable for the install.
     * @param bundle The bundle
     * @return <code>true</code> if the os, ws, and arch all suit the install's platform.
     */
    public boolean isApplicable(CrateBundle bundle)
    {
        if (bundle.getOs() != null && (getOs() == null || !bundle.getOs().equals(getOs())))
        {
            return false;
        }

        if (bundle.getWs() != null && (getWs() == null || !bundle.getWs().equals(getWs())))
        {
            return false;
        }

        if (bundle.getArch() != null && (getArch() == null || !bundle.getArch().equals(getArch())))
        {
            return false;
        }

        return true;
    }

    /**
     * Read the crate file and add it as an available crate.
     * @param id The crate ID.
     * @param version The crate version.
     * @return The crate description.
     * @throws CrateException on error.
     */
    public Crate addCrate(String id, String version) throws CrateException
    {
        try
        {
            String crateUrl = crateDir.toString().replace(" ", "%20"); //$NON-NLS-1$//$NON-NLS-2$
            URL url = new URL("file", "", crateUrl + '/' + id + '_' + version + ".crate"); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$

            Crate crate = CrateSaxHandler.readCrate(url);

            addCrate(crate);

            return crate;
        }
        catch (MalformedURLException e)
        {
            throw new CrateException(e.getMessage(), e);
        }
    }

    /**
     * Return the set of enabled application crates:
     * <ol>
     * <li> start with the latest version of all crates
     * <li> remove crates not tagged with the "application" category
     * <li> (optionally) remove crates that aren't enabled via setEnabledApplicationProperties.
     * </ol>

     * @return the set of enabled application crates
     * @throws CrateException on error
     */
    public Set<Crate> getEnabledApplicationCrates() throws CrateException
    {
        Set<Crate> rval = getLatestCratesOfCategory("application");

        Properties applicationCrates = null;
        try
        {
            if (enabledApplicationProperties != null && enabledApplicationProperties.exists())
            {
                applicationCrates = new Properties();
                applicationCrates.load(new FileInputStream(enabledApplicationProperties));
            }
        }
        catch (Exception ex)
        {
            applicationCrates = null;
        }

        
        if (applicationCrates != null)
        {
            for (Iterator<Crate> it = rval.iterator(); it.hasNext();)
            {
                Crate crate = it.next();

                if (!Boolean.valueOf(applicationCrates.getProperty(crate.getId())))
                {
                    it.remove();
                }
            }
        }

        return rval;
    }
}
