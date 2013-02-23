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
package org.ziptie.adaptertool;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.jar.Attributes;
import java.util.jar.Manifest;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * Class for crating adapter bundles into a zip.
 */
public class CrateAdapters
{
    private static final String VERSION_REGEX = "\\d+\\.\\d+\\.\\d+(\\.[a-zA-Z0-9]+)?"; //$NON-NLS-1$
    private static final String ID_REGEX = "([a-z][a-zA-Z0-9]\\.)+[a-z][a-zA-Z0-9]"; //$NON-NLS-1$
    private String name;
    private String crateId;
    private String version;
    private List<Bundle> bundles;

    // instance initializer.
    {
        bundles = new LinkedList<Bundle>();
    }

    /**
     * Add the given bundle to the list of bundles to crate.
     * @param bundle the bundle to add.
     */
    public void addBundle(Bundle bundle)
    {
        bundles.add(bundle);
    }

    /**
     * Set the ID to use for the crate.
     * @param crateId the crate ID
     */
    public void setCrateId(String crateId)
    {
        if (name == null)
        {
            setName(crateId);
        }
        this.crateId = crateId;
    }

    /**
     * Set the name of the crate.
     * @param name the crate name
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * Set the version to use for the crate.
     * @param version the crate version number.
     */
    public void setVersion(String version)
    {
        this.version = version;
    }

    /**
     * Crate the adapters.
     * @throws IOException on write error.
     */
    public void run() throws IOException
    {
        String zipFile = String.format("%s.crate_%s.zip", crateId, version); //$NON-NLS-1$
        System.err.println(Messages.getString("CrateAdapters.creatingZip") + zipFile); //$NON-NLS-1$
        ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zipFile));

        String crateFile = String.format("crates/%s_%s.crate", crateId, version); //$NON-NLS-1$
        System.err.println(Messages.getString("CrateAdapters.addingZipEntry") + crateFile); //$NON-NLS-1$

        zos.putNextEntry(new ZipEntry(crateFile));
        writeCrateFile(zos);
        zos.closeEntry();

        for (Bundle bundle : bundles)
        {
            File root = bundle.location;
            int rootPathOffset = root.getPath().length() + 1;

            LinkedList<File> files = new LinkedList<File>();
            files.add(root);
            while (!files.isEmpty())
            {
                File file = files.poll();
                if (file.isDirectory())
                {
                    if (file.getName().equals("CVS")) //$NON-NLS-1$
                    {
                        continue;
                    }

                    File[] childs = file.listFiles();
                    if (childs != null)
                    {
                        for (File child : childs)
                        {
                            files.addFirst(child);
                        }
                    }
                }
                else
                {
                    String path = file.getPath().substring(rootPathOffset);
                    path = path.replaceAll("\\\\", "/");  //$NON-NLS-1$//$NON-NLS-2$

                    String filename = String.format("%s%s_%s/%s", bundle.targetLocation, bundle.id, bundle.version, path); //$NON-NLS-1$
                    System.err.println(Messages.getString("CrateAdapters.addingZipEntry") + filename); //$NON-NLS-1$
                    ZipEntry entry = new ZipEntry(filename);
                    entry.setTime(file.lastModified());
                    zos.putNextEntry(entry);
                    copy(file, zos);
                    zos.closeEntry();
                }
            }
        }

        zos.close();
    }

    @SuppressWarnings("nls")
    private void writeCrateFile(OutputStream out)
    {
        PrintStream ps = new PrintStream(out);
        ps.println("<crate");
        ps.printf("     id=\"%s\"\n", crateId);
        ps.printf("     name=\"%s\"\n", name);
        ps.printf("     version=\"%s\" >\n", version);
        ps.println();

        for (Bundle bundle : bundles)
        {
            ps.printf("   <bundle id=\"%s\" location=\"%s\" version=\"%s\" />\n", bundle.id, bundle.targetLocation, bundle.version);
        }

        ps.println("</crate>");
        ps.flush();
    }

    private void copy(File file, OutputStream zos) throws IOException
    {
        FileInputStream fis = new FileInputStream(file);
        byte[] buf = new byte[2048];
        int len = 0;
        while ((len = fis.read(buf)) > 0)
        {
            zos.write(buf, 0, len);
        }
        fis.close();
    }

    /**
     * The main.
     * @param args the CLI arguments.
     */
    public static void main(String[] args)
    {
        try
        {
            CliElf.setupLog4j();

            CrateAdapters ca = new CrateAdapters();
            parseArgs(ca, args);

            if (ca.bundles.isEmpty())
            {
                AtConfigElf.loadSetup();

                while (ca.bundles.isEmpty())
                {
                    promptForBundles(ca);
                }
            }

            Bundle b = ca.bundles.get(0);

            if (ca.crateId == null)
            {
                ca.setCrateId(get(Messages.getString("CrateAdapters.specifyCrateID"), b.id, ID_REGEX)); //$NON-NLS-1$
            }

            if (ca.version == null)
            {
                ca.setVersion(get(Messages.getString("CrateAdapters.specifyVersion"), b.version, VERSION_REGEX)); //$NON-NLS-1$
            }

            if (ca.name == null)
            {
                ca.setName(get(Messages.getString("CrateAdapters.specifyName"), b.id, null)); //$NON-NLS-1$
            }

            ca.run();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
    }

    private static void promptForBundles(CrateAdapters ca) throws IOException
    {
        System.err.println(Messages.getString("CrateAdapters.availableBundles")); //$NON-NLS-1$

        List<Bundle> bundles = getAvailableBundles();

        int i = 0;
        for (Bundle b : bundles)
        {
            System.err.printf(" %2d: %s\n", i, b.id); //$NON-NLS-1$
            i++;
        }

        String selection = CliElf.get(Messages.getString("CrateAdapters.selectBundle")); //$NON-NLS-1$
        for (String index : selection.split("\\s")) //$NON-NLS-1$
        {
            try
            {
                int n = Integer.parseInt(index);
                if (n < 0 || n >= bundles.size())
                {
                    System.err.println(Messages.getString("CrateAdapters.invalidInput")); //$NON-NLS-1$
                    break;
                }
                else
                {
                    ca.addBundle(bundles.get(n));
                }
            }
            catch (NumberFormatException e)
            {
                System.err.println(Messages.getString("CrateAdapters.unknownBundle")); //$NON-NLS-1$
                break;
            }
        }
    }

    // CHECKSTYLE:OFF
    private static void parseArgs(CrateAdapters ca, String[] args) throws IOException
    {
        // CHECKSTYLE:ON
        for (int i = 0; i < args.length; i++)
        {
            if (args[i].equals("-d") || args[i].equals("--dir")) //$NON-NLS-1$ //$NON-NLS-2$
            {
                String adapter = CliElf.next(args, ++i);
                Bundle bundle = getBundle(new File(adapter));
                if (bundle == null)
                {
                    CliElf.die(adapter + Messages.getString("CrateAdapters.invalidAdapterBundle")); //$NON-NLS-1$
                }
                ca.addBundle(bundle);

                if (ca.crateId == null)
                {
                    ca.setCrateId(bundle.id);
                }

                if (ca.version == null)
                {
                    ca.setVersion(bundle.version);
                }
            }
            else if (args[i].equals("-v") || args[i].equals("--version")) //$NON-NLS-1$ //$NON-NLS-2$
            {
                String version = CliElf.next(args, ++i);
                if (!version.matches(VERSION_REGEX))
                {
                    CliElf.die(Messages.getString("CrateAdapters.invalidVersion")); //$NON-NLS-1$
                }
                ca.setVersion(version);
            }
            else if (args[i].equals("-i") || args[i].equals("--id")) //$NON-NLS-1$ //$NON-NLS-2$
            {
                String id = CliElf.next(args, ++i);
                if (!id.matches(ID_REGEX))
                {
                    CliElf.die(Messages.getString("CrateAdapters.invalidID")); //$NON-NLS-1$
                }
                ca.setCrateId(id);
            }
            else if (args[i].equals("-n") || args[i].equals("--name")) //$NON-NLS-1$ //$NON-NLS-2$
            {
                ca.setName(CliElf.next(args, ++i));
            }
        }
    }

    private static List<Bundle> getAvailableBundles() throws IOException
    {
        List<Bundle> bundles = new ArrayList<Bundle>();
        addBundlesFromDirectory(bundles, AtConfigElf.getAdapterDir());
        addBundlesFromDirectory(bundles, AtConfigElf.getToolsDir());
        return bundles;
    }

    private static void addBundlesFromDirectory(List<Bundle> bundles, File dir) throws IOException
    {
        File[] files = dir.listFiles();
        if (files != null)
        {
            for (File file : files)
            {
                Bundle bundle = getBundle(file);
                if (bundle != null)
                {
                    bundles.add(bundle);
                }
            }
        }
    }

    private static String get(String prompt, String defualt, String regex)
    {
        while (true)
        {
            String ret = CliElf.get(String.format("%s [%s]: ", prompt, defualt)); //$NON-NLS-1$
            ret = ret.trim();
            if (ret.length() == 0)
            {
                return defualt;
            }

            if (regex == null || ret.matches(regex))
            {
                return ret;
            }

            System.err.println(Messages.getString("CrateAdapters.invalidInput")); //$NON-NLS-1$
        }
    }

    /**
     * @param file
     * @return <code>null</code> if the given file is not an adapter bundle.
     */
    private static Bundle getBundle(File file) throws IOException
    {
        try
        {
            if (!file.isDirectory())
            {
                return null;
            }

            Manifest mf = new Manifest(new FileInputStream(new File(file, "META-INF/MANIFEST.MF"))); //$NON-NLS-1$
            Attributes attrs = mf.getMainAttributes();

            String version = attrs.getValue("Bundle-Version"); //$NON-NLS-1$
            String id = attrs.getValue("Bundle-SymbolicName"); //$NON-NLS-1$
            String bundleType = attrs.getValue("Bundle-Type"); //$NON-NLS-1$

            String resultLocation = "core/"; //$NON-NLS-1$
            if (attrs.getValue("ZTool-Directory") != null) //$NON-NLS-1$
            {
                resultLocation = "tools/"; //$NON-NLS-1$
            }
            else if (bundleType != null && bundleType.equals("adapter")) //$NON-NLS-1$
            {
                resultLocation = "adapters/"; //$NON-NLS-1$
            }

            return new Bundle(id.toString(), file, version, resultLocation);
        }
        catch (FileNotFoundException e)
        {
            return null;
        }
    }

    /**
     * Represents a bundle.
     */
    public static class Bundle
    {
        private String id;
        private File location;
        private String version;
        private String targetLocation;

        /**
         * Create the bundle reference
         * @param id The bundle ID
         * @param location The location of the bundle
         * @param version The bundle version
         * @param targetLocation The server relative location of the bundle (ie: "core/" or "adapters/" etc)
         */
        public Bundle(String id, File location, String version, String targetLocation)
        {
            this.id = id;
            this.location = location;
            this.version = version;
            this.targetLocation = targetLocation;
        }
    }
}
