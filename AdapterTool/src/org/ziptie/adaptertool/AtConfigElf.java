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
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.Properties;
import java.util.Set;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

import org.ziptie.net.adapters.AdapterService;
import org.ziptie.net.adapters.IAdapterService;

/**
 * Handles the persistent configuration of the adapter tool
 */
public final class AtConfigElf
{
    public static final String MANIFEST = "META-INF/MANIFEST.MF"; //$NON-NLS-1$

    private static final String ADAPTER_DIR_PROPERTY = "adapter.dir"; //$NON-NLS-1$
    private static final String TOOLS_DIR_PROPERTY = "tools.dir"; //$NON-NLS-1$
    private static final String PERL_INC = "PERL_INC"; //$NON-NLS-1$
    private static File adapterDir;
    private static File toolsDir;
    private static AdapterService adapterService;

    static
    {
        adapterService = new AdapterService();

        try
        {
            adapterService.addSchemaLocation(new File("schema/adapters").toURI().toURL()); //$NON-NLS-1$
        }
        catch (MalformedURLException e)
        {
            throw new RuntimeException(e);
        }
    }

    private AtConfigElf()
    {
    }

    /**
     * Run the user through the setup.
     * @throws IOException on error.
     */
    public static void runSetup() throws IOException
    {
        while (true)
        {
            String dir = CliElf.get(Messages.getString("AtConfigElf.specifyAdapterDirectory")); //$NON-NLS-1$
            File file = new File(dir);
            if (file.isDirectory())
            {
                setAdapterDir(file);
                break;
            }

            System.err.println(Messages.getString("AtConfigElf.directoryDoesNotExist")); //$NON-NLS-1$
        }
        while (true)
        {
            String dir = CliElf.get(Messages.getString("AtConfigElf.specifyToolsDirectory")); //$NON-NLS-1$
            File file = new File(dir);
            if (file.isDirectory())
            {
                setToolsDir(file);
                break;
            }

            System.err.println(Messages.getString("AtConfigElf.directoryDoesNotExist")); //$NON-NLS-1$
        }
        saveSetup();
    }

    /**
     * Load the setup from the file, if it doesn't exist run the setup.
     * @throws IOException on error.
     */
    public static void loadSetup() throws IOException
    {
        File file = new File("conf", "adapterTool.properties"); //$NON-NLS-1$//$NON-NLS-2$
        if (!file.exists())
        {
            System.err.println(Messages.getString("AtConfigElf.firstRun")); //$NON-NLS-1$
            runSetup();
            return;
        }

        Properties props = new Properties();
        props.load(new FileInputStream(file));

        String dir = props.getProperty(ADAPTER_DIR_PROPERTY);
        if (dir == null)
        {
            System.err.println(Messages.getString("AtConfigElf.noAdaptersConfigured")); //$NON-NLS-1$
            runSetup();
        }
        else if (!new File(dir).isDirectory())
        {
            System.err.printf(Messages.getString("AtConfigElf.oldDirDoesNotExist"), dir); //$NON-NLS-1$
            runSetup();
        }
        else
        {
            setAdapterDir(new File(dir));
        }

        String toolDir = props.getProperty(TOOLS_DIR_PROPERTY);
        if (toolDir == null)
        {
            System.err.println(Messages.getString("AtConfigElf.noToolsConfigured")); //$NON-NLS-1$
            runSetup();
        }
        else if (!new File(toolDir).isDirectory())
        {
            System.err.printf(Messages.getString("AtConfigElf.oldDirDoesNotExist"), toolDir); //$NON-NLS-1$
            runSetup();
        }
        else
        {
            setToolsDir(new File(toolDir));
        }
    }

    /**
     * Save the config file.
     * @throws IOException on error.
     */
    private static void saveSetup() throws IOException
    {
        Properties props = new Properties();
        props.setProperty(ADAPTER_DIR_PROPERTY, adapterDir.getAbsolutePath());
        props.setProperty(TOOLS_DIR_PROPERTY, toolsDir.getAbsolutePath());

        props.store(new FileOutputStream("conf/adapterTool.properties"), Messages.getString("AtConfigElf.configHeader")); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Add all the adapters in the given directory.
     * @param directory The adapter bundle directory, or a parent of adapter bundles.
     * @throws IOException on read error.
     */
    public static void setAdapterDir(File directory) throws IOException
    {
        adapterDir = directory;
        for (File dir : directory.listFiles())
        {
            if (new File(dir, MANIFEST).isFile())
            {
                addAdapterBundle(dir);
            }
        }
    }

    /**
     * Add all tools in the given directory
     * 
     * @param directory the directory where the tools live
     * @throws IOException 
     */
    private static void setToolsDir(File directory) throws IOException
    {
        toolsDir = directory;
        for (File dir : directory.listFiles())
        {
            if (new File(dir, MANIFEST).isFile())
            {
                addAdapterBundle(dir);
            }
        }
    }

    /**
     * Get the directory that contains the adapters.
     * @return the adapters directory
     */
    public static File getAdapterDir()
    {
        return adapterDir;
    }

    /**
     * Add the given adapter bundle.
     * @param adapterBundle The adapter bundle directory
     * @throws IOException on read error.
     */
    public static void addAdapterBundle(File adapterBundle) throws IOException
    {
        adapterService.registerAdapters(adapterBundle);

        File file = new File(adapterBundle, MANIFEST);
        FileInputStream in = new FileInputStream(file);
        try
        {
            Manifest mf = new Manifest(in);
            Attributes attrs = mf.getMainAttributes();
            String inc = attrs.getValue("Perl-Include"); //$NON-NLS-1$
            if (inc == null || inc.length() == 0)
            {
                return;
            }

            for (String path : inc.split(",")) //$NON-NLS-1$
            {
                File include = new File(adapterBundle, path);
                addToIncludePath(include);
            }
        }
        finally
        {
            in.close();
        }
    }

    /**
     * Add the directory to the perl include path.
     * @param dir The directory
     */
    public static void addToIncludePath(File dir)
    {
        String inc = System.getProperty(PERL_INC);
        System.setProperty(PERL_INC, dir.toString() + File.pathSeparator + inc);
    }

    /**
     * Get the adapter service.
     * @return The adapter service singleton
     */
    public static IAdapterService getAdapterService()
    {
        return adapterService;
    }

    /**
     * Choose an adapter from a list
     * @return an adapter ID
     */
    public static String chooseAdapter()
    {
        Set<String> set = getAdapterService().getAllAdapterIDs();
        String[] ids = set.toArray(new String[set.size()]);
        Arrays.sort(ids, String.CASE_INSENSITIVE_ORDER);
        if (ids.length == 0)
        {
            System.err.println(Messages.getString("AdapterCli.noAdapters")); //$NON-NLS-1$
            return ""; //$NON-NLS-1$
        }
        else
        {
            while (true)
            {
                System.err.println(Messages.getString("AdapterCli.availableAdapters")); //$NON-NLS-1$
                for (int i = 0; i < ids.length; i++)
                {
                    System.err.printf(" %2d: %s\n", i, ids[i]); //$NON-NLS-1$
                }
                String selection = CliElf.get(Messages.getString("AdapterCli.selectAdapter")); //$NON-NLS-1$
                if (set.contains(selection))
                {
                    return selection;
                }

                try
                {
                    return ids[Integer.parseInt(selection)];
                }
                catch (NumberFormatException nfe)
                {
                    System.err.println(Messages.getString("AdapterCli.unknownAdapterId")); //$NON-NLS-1$
                    continue;
                }
            }
        }
    }

    /**
     * Return the tools directory
     * @return the tools dir
     */
    public static File getToolsDir()
    {
        return toolsDir;
    }
}
