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
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.log4j.Logger;


/**
 * Easy little functions for updating crates.
 */
@SuppressWarnings("nls")
public final class CrateUpdateElf
{
    private CrateUpdateElf()
    {
    }


    /**
     * Brings the given local install up to date.
     * @param siteLoc The site to update from.
     * @param install The install to update.
     * @param callback callback for messages
     * @return <code>true</code> if an install was performed or <code>false</code> if there was nothing to do.
     * @throws CrateException on read error.
     */
    public static boolean update(SiteCrateLocation siteLoc, InstallLocation install, IProgressCallback callback) throws CrateException
    {
        Set<Crate> toUpdate = CrateUpdateElf.findCratesToUpdate(siteLoc, install);
        return install(siteLoc, install, toUpdate, callback);
    }

    /**
     * Finds that crates that need to be installed for the dest to be fully updated.
     * @param source The source crate location
     * @param dest The destination location
     * @return The set of new crates to install.
     * @throws CrateException On read error.
     */
    public static Set<Crate> findCratesToUpdate(CrateLocation source, CrateLocation dest) throws CrateException
    {
        Set<Crate> toInstall = new HashSet<Crate>();

        Set<Crate> installed = dest.getLatestCrates();
        for (Crate crate : installed)
        {
            Crate newer = source.getCrate(crate.getId(), null);
            if (newer == null)
            {
                continue;
            }

            if (newer.isNewerThan(crate))
            {
                toInstall.add(newer);
            }
        }

        LinkedList<Crate> queue = new LinkedList<Crate>();
        queue.addAll(toInstall);

        while (!queue.isEmpty())
        {
            Crate crate = queue.poll();
            for (String id : crate.getDependencies())
            {
                Crate dependency = source.getCrate(id, null);

                if (toInstall.add(dependency))
                {
                    queue.add(dependency);
                }
            }
        }

        return toInstall;
    }

    /**
     * Installs the given crate.
     * @param site The source location
     * @param install The destination install.
     * @param newCrates The crates to install
     * @param progress Progress callback, called with messages indicating progress.
     * @return <code>true</code> if an install was performed or <code>false</code> if there was nothing to do.
     * @throws CrateException On error.
     */
    public static synchronized boolean install(SiteCrateLocation site, InstallLocation install, Collection<Crate> newCrates, IProgressCallback progress)
        throws CrateException
    {
        if (newCrates.isEmpty())
        {
            return false;
        }

        try
        {
            File crateDir = install.getCrateDir();

            HashSet<CrateBundle> bundles = new HashSet<CrateBundle>();
            HashSet<File> artifactDirs = new HashSet<File>();

            for (Crate newCrate : newCrates)
            {
                if (isAlreadyInstalled(install, newCrate))
                {
                    progress(progress, String.format("Skipping crate %s, a newer version is already installed.", newCrate.getId()));
                    continue;
                }

                // download crate file
                if (!copy(progress, newCrate.getUrl(), new File(crateDir, String.format("%s_%s.crate", newCrate.getId(), newCrate.getVersion()))))
                {
                    throw new CrateException(String.format("Crate %s not found on server.", newCrate.getUrl()));
                }

                File dir = downloadArtifact(progress, site, crateDir, newCrate);
                if (dir != null)
                {
                    artifactDirs.add(dir);
                }

                List<CrateBundle> more = newCrate.getBundles();
                for (CrateBundle cb : more)
                {
                    if (install.isApplicable(cb))
                    {
                        bundles.add(cb);
                    }
                }
            }

            installBundles(site, install, progress, bundles);

            /*
            for (File dir : artifactDirs)
            {
                // execute artifact
                executeArtifact(progress, dir);
            }
            */

            return true;
        }
        catch (IOException e)
        {
            throw new CrateException(e.getMessage(), e);
        }
    }

    private static boolean isAlreadyInstalled(InstallLocation install, Crate newCrate) throws CrateException
    {
        Crate old = install.getCrate(newCrate.getId(), null);
        return old != null && old.isNewerThan(newCrate);
    }

    private static File downloadArtifact(IProgressCallback progress, SiteCrateLocation site, File crateDir, Crate newCrate) throws IOException, CrateException
    {
        String artifactName = newCrate.getArtifact();
        if (artifactName != null)
        {
            URL artifact = new URL(site.getUrl().toString() + "/artifacts/" + artifactName);
            File artifactZip = new File(crateDir, String.format("artifacts/%s_%s/%s", newCrate.getId(), newCrate.getVersion(), artifactName));

            File dir = stripZipExtension(artifactZip);
            if (!dir.exists())
            {
                // download artifact
                if (!copy(progress, artifact, artifactZip))
                {
                    throw new CrateException(String.format("Artifact %s not found on server.", artifact));
                }

                // extract artifact
                extract(progress, artifactZip, dir, true);

                return dir;
            }
        }
        return null;
    }

    private static void installBundles(SiteCrateLocation site, InstallLocation install, IProgressCallback progress, HashSet<CrateBundle> bundles)
        throws IOException, CrateException
    {
        File installRoot = install.getRoot();

        for (CrateBundle bundle : bundles)
        {
            String skipMessage = String.format("Skipping bundle %s, it is already up to date.", bundle.getId());

            String location = bundle.getLocation();
            if (!location.endsWith("/"))
            {
                File dest = new File(installRoot, location);
                if (dest.exists())
                {
                    progress(progress, skipMessage);
                    continue;
                }

                if (!copy(progress, new URL(site.getUrl().toString() + "/" + location), dest))
                {
                    throw new CrateException(String.format("Bundle %s not found on server.", location));
                }
            }
            else
            {
                String filename = String.format("%s_%s.jar", bundle.getId(), bundle.getVersion());
                File dest = new File(installRoot, location + filename);
                if (dest.exists())
                {
                    progress(progress, skipMessage);
                    continue;
                }

                if (!copy(progress, new URL(site.getUrl() + "/" + location + filename), dest))
                {
                    // if it's not a jar try a zip...

                    filename = String.format("%s_%s.zip", bundle.getId(), bundle.getVersion());
                    File zip = new File(installRoot, location + filename);
                    File dir = stripZipExtension(zip);
                    if (dir.exists())
                    {
                        progress(progress, skipMessage);
                        continue;
                    }

                    if (copy(progress, new URL(site.getUrl() + "/" + location + filename), zip))
                    {
                        extract(progress, zip, dir, true);
                    }
                    else
                    {
                        throw new CrateException(String.format("%s_%s not found on server.", bundle.getId(), bundle.getVersion()));
                    }
                }
            }
        }
    }

    private static void progress(IProgressCallback progress, String message)
    {
        if (progress != null)
        {
            progress.progress(message);
        }
    }

    /*
    private static void executeArtifact(IProgressCallback progress, File artifactDir) throws IOException
    {
        File file = new File(artifactDir, "install.js"); //$NON-NLS-1$
        if (file.isFile())
        {
            progress.progress("Running install script " + file);

            Context ctxt = Context.enter();
            try
            {
                FileReader reader = new FileReader(file);
                try
                {
                    Scriptable scope = ctxt.initStandardObjects(null);
                    ctxt.evaluateReader(scope, reader, file.getAbsolutePath(), 0, null);
                }
                catch (JavaScriptException e)
                {
                    e.printStackTrace();
                }
                finally
                {
                    reader.close();
                }
            }
            finally
            {
                Context.exit();
            }
        }
    }
    */

    private static File stripZipExtension(File zip)
    {
        String name = zip.getName();
        name = name.substring(0, name.length() - 4);

        return new File(zip.getParent(), name);
    }

    private static File extract(IProgressCallback progress, File artifactZip, File target, boolean deleteOriginal) throws IOException
    {
        progress(progress, "Unziping " + target);

        target.mkdir();

        ZipInputStream in = null;
        OutputStream out = null;
        try
        {
            in = new ZipInputStream(new FileInputStream(artifactZip));

            byte[] buf = new byte[4096];
            while (true)
            {
                ZipEntry entry = in.getNextEntry();
                if (entry == null)
                {
                    break;
                }

                out = new FileOutputStream(new File(target, entry.getName()));
                int len;
                while ((len = in.read(buf)) > 0)
                {
                    out.write(buf, 0, len);
                }
                out.close();
                out = null;

                in.closeEntry();
            }
        }
        finally
        {
            if (out != null)
            {
                try
                {
                    out.close();
                }
                catch (IOException e)
                {
                    Logger.getLogger(CrateUpdateElf.class).warn(e.getMessage(), e);
                }
            }

            if (in != null)
            {
                try
                {
                    in.close();
                }
                catch (IOException e)
                {
                    Logger.getLogger(CrateUpdateElf.class).warn(e.getMessage(), e);
                }
            }

        }

        if (deleteOriginal)
        {
            artifactZip.delete();
        }

        return target;
    }

    private static boolean copy(IProgressCallback progress, URL url, File dest) throws IOException
    {
        dest.getParentFile().mkdirs();

        if (dest.exists())
        {
            progress(progress, String.format("%s already exists", dest.getAbsolutePath()));

            // nothing to do.
            return true;
        }

        URLConnection conn = url.openConnection();
        long modified = conn.getLastModified();

        OutputStream fos = null;
        InputStream in = null;
        try
        {
            try
            {
                in = conn.getInputStream();
            }
            catch (FileNotFoundException e)
            {
                return false;
            }

            progress(progress, String.format("Downloading %s to %s.", url.toString(), dest.getParentFile().getAbsolutePath()));

            fos = new FileOutputStream(dest);

            byte[] buf = new byte[2048];
            int len = 0;
            while ((len = in.read(buf)) > 0)
            {
                fos.write(buf, 0, len);
            }

            fos.close();
            fos = null;

            dest.setLastModified(modified);

            return true;
        }
        finally
        {
            if (in != null)
            {
                in.close();
            }
            if (fos != null)
            {
                fos.close();
            }
        }
    }
}
