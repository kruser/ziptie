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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.osgi.framework.BundleException;
import org.osgi.framework.ServiceReference;
import org.osgi.service.packageadmin.PackageAdmin;
import org.osgi.service.startlevel.StartLevel;

/**
 * Helper for activating the bundles within crates.
 */
@SuppressWarnings("nls")
public final class CrateStarterElf
{
    private CrateStarterElf()
    {
    }

    /**
     * Activates all the bundles contained in the specified crates in the given crate location.
     * @param context The bundle context to use for interacting with OSGi.
     * @param location The location containing the crates.
     * @param crateIds The set of crates to activate.
     * @return The number of bundles that failed to start.
     * @throws CrateException On read error.
     */
    public static int activateBundles(BundleContext context, InstallLocation location, String... crateIds) throws CrateException
    {
        ArrayList<Crate> crates = new ArrayList<Crate>(crateIds.length);
        for (String id : crateIds)
        {
            Crate c = location.getCrate(id, null);
            if (c == null)
            {
                throw new CrateException("No crate with given id found. " + id);
            }

            crates.add(c);
        }

        return activateBundles(context, location, crates.toArray(new Crate[crates.size()]));
    }

    /**
     * Install all bundles contained in the specified crates from the given crate location.
     * @param context The bundle context to use for interacting with OSGi.
     * @param location The location containing the crates.
     * @param crates The set of crates to activate.
     * @return an ordered list of bundles whose 'start' flag is set to true in their containing crate
     * @throws CrateException on read error.
     */
    public static List<Bundle> installBundles(BundleContext context, InstallLocation location, Crate... crates) throws CrateException
    {
        Logger logger = Logger.getLogger(CrateStarterElf.class);

        List<Crate> toLoad = expandDependencies(location, crates);

        Map<String, Bundle> installed = new HashMap<String, Bundle>();
        for (Bundle bundle : context.getBundles())
        {
            installed.put(bundle.getSymbolicName(), bundle);
        }

        // prevent osgi from trying to be installed.
        installed.put("org.eclipse.osgi", null);

        ServiceReference reference = context.getServiceReference(StartLevel.class.getName());
        StartLevel start = (StartLevel) context.getService(reference);

        List<Bundle> bundles = new ArrayList<Bundle>();
        List<Bundle> toStart = new LinkedList<Bundle>();

        for (Crate crate : toLoad)
        {
            for (CrateBundle bundle : crate.getBundles())
            {
                if (installed.containsKey(bundle.getId()))
                {
                    if (bundle.isStart())
                    {
                        Bundle alreadyInstalledBundle = installed.get(bundle.getId());
                        if (alreadyInstalledBundle != null)
                        {
                            int state = alreadyInstalledBundle.getState();
                            if (state != Bundle.ACTIVE && state != Bundle.STARTING)
                            {
                                toStart.add(alreadyInstalledBundle);
                            }
                        }
                    }

                    continue;
                }

                installed.put(bundle.getId(), null);

                // exclude fragments not applicable for the platform.
                if (!location.isApplicable(bundle))
                {
                    continue;
                }

                File file = getFileForBundle(location.getRoot(), bundle);

                try
                {
                    Bundle b = context.installBundle("reference:file:" + file.toString());
                    bundles.add(b);

                    if (bundle.getStartLevel() > 0)
                    {
                        start.setBundleStartLevel(b, bundle.getStartLevel());
                    }

                    if (bundle.isStart())
                    {
                        toStart.add(b);
                    }

                    logger.debug("Installed bundle: " + bundle.getId());
                }
                catch (BundleException e)
                {
                    logger.warn("Error installing bundle: " + bundle.getId(), e);
                }
            }
        }
        context.ungetService(reference);

        reference = context.getServiceReference(PackageAdmin.class.getName());

        PackageAdmin packageAdmin = (PackageAdmin) context.getService(reference);
        packageAdmin.resolveBundles(bundles.toArray(new Bundle[bundles.size()]));

        context.ungetService(reference);

        return toStart;
    }

    /**
     * Activates all the bundles contained in the specified crates in the given crate location.
     * @param context The bundle context to use for interacting with OSGi.
     * @param location The location containing the crates.
     * @param crates The set of crates to activate.
     * @return The number of bundles that failed to start.
     * @throws CrateException on read error.
     */
    public static int activateBundles(BundleContext context, InstallLocation location, Crate... crates) throws CrateException
    {
        List<Bundle> toStart = installBundles(context, location, crates);
        return start(context, toStart);
    }

    /**
     * Activates all the bundles contained in the specified crates in the given crate location.
     * @param context The bundle context to use for interacting with OSGi.
     * @param location The location containing the crates.
     * @param crates The set of crates to activate.
     * @return The number of bundles that failed to start.
     * @throws CrateException on read error.
     */
    public static int activateBundles(BundleContext context, InstallLocation location, Set<Crate> crates) throws CrateException
    {
        List<Bundle> toStart = installBundles(context, location, crates.toArray(new Crate[crates.size()]));
        return start(context, toStart);
    }

    /**
     * Activates all the bundles defined by the crates in the given crate location.
     * @param context A bundle context to use for interacting with OSGi.
     * @param location The location containing the crates.
     * @return The number of bundles that failed to start.
     * @throws CrateException on crate read error.
     */
    public static int activateBundles(BundleContext context, InstallLocation location) throws CrateException
    {
        return activateBundles(context, location, location.getLatestCrates().toArray(new Crate[0]));
    }

    /**
     * @param location The location containing the crates.
     * @param crates The list of crates to start
     * @return An expanded set of crate dependencies in dependency order
     * @throws CrateException on crate read error
     */
    public static List<Crate> expandDependencies(CrateLocation location, Crate[] crates) throws CrateException
    {
        List<Crate> result = new ArrayList<Crate>();

        for (Crate crate : crates)
        {
            recurseDependenciesAndIncludes(location, result, crate);
        }

        return result;
    }

    private static void recurseDependenciesAndIncludes(CrateLocation location, List<Crate> accumulator, Crate toAdd) throws CrateException
    {
        // all dependencies of this crate get added first
        Set<String> depends = toAdd.getDependencies();
        for (String id : depends)
        {
            Crate c = location.getCrate(id, null);
            if (c == null)
            {
                throw new CrateException("Could not find crate. " + id);
            }

            recurseDependenciesAndIncludes(location, accumulator, c);
        }

        // this crate can be started after all of it's dependencies
        if (!accumulator.contains(toAdd))
        {
            accumulator.add(toAdd);
        }

        // finally any included crates can be started after this one is
        for (String cat : toAdd.getIncludes())
        {
            Set<Crate> includedCrates = location.getLatestCratesOfCategory(cat);
            for (Crate c : includedCrates)
            {
                recurseDependenciesAndIncludes(location, accumulator, c);
            }
        }
    }

    private static int start(BundleContext context, List<Bundle> toStart)
    {
        Logger logger = Logger.getLogger(CrateStarterElf.class);

        int errorCount = 0;
        for (Bundle bundle : toStart)
        {
            try
            {
                logger.debug("start bundle: " + bundle.getSymbolicName());
                bundle.start();
            }
            catch (BundleException e)
            {
                Logger.getLogger(CrateStarterElf.class).warn("Error starting bundle: " + bundle.getSymbolicName(), e);
                errorCount++;
            }
        }
        return errorCount;
    }

    /**
     * Return the file (or directory) for the plugin identified by the supplied CrateBundle.
     * @param installRoot the plugin directory
     * @param bundle a CrateBundle that you wish to find among all plugins
     * @return a File pointing to the plugin (JAR or directory)
     * @throws CrateException if something goes wrong in the underlying crate system
     */
    public static File getFileForBundle(File installRoot, CrateBundle bundle) throws CrateException
    {
        String guess = bundle.getLocation();
        File location = new File(installRoot, guess);
        if (!guess.endsWith("/"))
        {
            return location;
        }

        File jar = new File(location, String.format("%s_%s.jar", bundle.getId(), bundle.getVersion()));
        if (jar.isFile())
        {
            return jar;
        }

        File dir = new File(location, String.format("%s_%s", bundle.getId(), bundle.getVersion()));
        if (dir.isDirectory())
        {
            return dir;
        }

        throw new CrateException("Could not find bundle: " + bundle.toString());
    }

    /**
     * Stop the bundles in the supplied crates.  Inter-crate dependencies are NOT expanded.
     * 
     * @param context a bundle context
     * @param crates the list of crates to be stopped
     * @return the list of stopped Bundles
     * @throws CrateException wrapping any other exceptions that happen
     */
    public static List<Bundle> stopBundles(BundleContext context, Crate... crates) throws CrateException
    {
        Logger logger = Logger.getLogger(CrateStarterElf.class);

        // get the set of currently installed bundles...
        Map<String, Bundle> installed = new HashMap<String, Bundle>();
        for (Bundle bundle : context.getBundles())
        {
            installed.put(bundle.getSymbolicName(), bundle);
        }

        ServiceReference reference = context.getServiceReference(PackageAdmin.class.getName());
        PackageAdmin packageAdmin = (PackageAdmin) context.getService(reference);

        List<Bundle> stoppedBundles = new ArrayList<Bundle>();

        // Shutdown in reverse order...
        List<Crate> cratesReversed = Arrays.asList(crates);
        Collections.reverse(cratesReversed);

        for (Crate crate : cratesReversed)
        {
            // Shutdown in reverse order...
            List<CrateBundle> bundles = crate.getBundles();
            Collections.reverse(bundles);

            for (CrateBundle cb : bundles)
            {
                Bundle bundle = installed.get(cb.getId());
                if (bundle != null && !bundle.getSymbolicName().startsWith("org.eclipse"))
                {
                    try
                    {
                        Dictionary<?, ?> dict = bundle.getHeaders();
                        String bundleVersion = (String) dict.get("Bundle-Version");
                        if (bundleVersion != null && bundleVersion.equals(cb.getVersion()))
                        {
                            if (packageAdmin.getBundleType(bundle) != PackageAdmin.BUNDLE_TYPE_FRAGMENT)
                            {
                                logger.debug("Stopping bundle " + bundle.getSymbolicName() + " " + bundleVersion);
                                bundle.stop();
                            }
                        }
                    }
                    catch (BundleException be)
                    {
                        logger.warn("Error stopping bundle " + cb.getId(), be);
                    }
                }
            }
        }

        return stoppedBundles;
    }

    /**
     * Un-install the bundles in the supplied crates.  Inter-crate dependencies are NOT expanded.
     * 
     * @param context a bundle context
     * @param crates the list of crates to be un-installed
     * @return the list of un-installed Bundles
     * @throws CrateException wrapping any other exceptions that happen
     */
    public static List<Bundle> stopAndUninstallBundles(BundleContext context, Crate... crates) throws CrateException
    {
        Logger logger = Logger.getLogger(CrateStarterElf.class);

        // get the set of currently installed bundles...
        Map<String, Bundle> installed = new HashMap<String, Bundle>();
        for (Bundle bundle : context.getBundles())
        {
            installed.put(bundle.getSymbolicName(), bundle);
        }

        List<Bundle> uninstalledBundles = new ArrayList<Bundle>();

        // Shutdown in reverse order...
        List<Crate> cratesReversed = Arrays.asList(crates);
        Collections.reverse(cratesReversed);

        for (Crate crate : cratesReversed)
        {
            // Shutdown in reverse order...
            List<CrateBundle> bundles = crate.getBundles();
            Collections.reverse(bundles);

            for (CrateBundle cb : bundles)
            {
                Bundle bundle = installed.get(cb.getId());
                if (bundle != null && !bundle.getSymbolicName().startsWith("org.eclipse"))
                {
                    try
                    {
                        Dictionary<?, ?> dict = bundle.getHeaders();
                        String bundleVersion = (String) dict.get("Bundle-Version");
                        if (bundleVersion != null && bundleVersion.equals(cb.getVersion()))
                        {
                            int state = bundle.getState();
                            if (state != Bundle.UNINSTALLED)
                            {
                                logger.debug("Un-installing bundle " + bundle.getSymbolicName() + " " + bundleVersion);
                                bundle.uninstall();
                            }

                            uninstalledBundles.add(bundle);
                        }
                    }
                    catch (BundleException be)
                    {
                        logger.warn("Error stopping bundle " + cb.getId(), be);
                    }
                }
            }
        }

        return uninstalledBundles;
    }
}
