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
import java.io.InputStream;

import org.ziptie.net.adapters.IAdapterService;

/**
 * Class for creating new adapters.
 */
public class CreateAdapter
{
    private static final String SKELETON = "Skeleton"; //$NON-NLS-1$
    private static final String FULL_SKELETON_NAME = "FullSkeletonName"; //$NON-NLS-1$
    private static final String DESCRIPTION = "ADAPTER_DESCRIPTION"; //$NON-NLS-1$

    private String adapterId;
    private String shortName;
    private String bundle;
    private File parentDir;
    private String description;
    private String adapterIdDirName;

    /**
     * Perform the create.
     * @throws IOException on error.
     */
    public void create() throws IOException
    {
        File bundleDir = new File(parentDir, bundle);

        if (!bundleDir.isDirectory())
        {
            bundleDir.mkdir();

            copy(new File(AdapterConstants.TEMPLATE_BUNDLE), bundleDir);
        }

        copy(new File("templates/newadapter"), bundleDir); //$NON-NLS-1$
    }

    private void copy(File from, File to) throws IOException
    {
        File[] files = from.listFiles();
        if (files == null)
        {
            System.err.println(Messages.getString("CreateAdapter.noFilesToCopy") + from); //$NON-NLS-1$
            return;
        }

        for (File file : files)
        {
            if (file.isDirectory())
            {
                String name = file.getName();
                if (name.equals(SKELETON))
                {
                    name = adapterIdDirName;
                }

                File dir = new File(to, name);

                System.err.printf(Messages.getString("CreateAdapter.creatingDirectory"), dir.toString()); //$NON-NLS-1$
                dir.mkdirs();

                copy(file, dir);
            }
            else if (file.isFile())
            {

                // copy 'file' to directory 'to'
                String name = file.getName().replace(SKELETON, adapterIdDirName);

                System.err.printf(Messages.getString("CreateAdapter.copyingFile"), file.toString(), name); //$NON-NLS-1$

                File target = new File(to, name);
                target.getParentFile().mkdirs();

                InputStream input = new FileInputStream(file);
                input = new StringReplaceInputStream(FULL_SKELETON_NAME, adapterId, input);
                input = new StringReplaceInputStream(SKELETON, shortName, input);
                input = new StringReplaceInputStream(AdapterConstants.PROJECT_NAME, bundle, input);
                input = new StringReplaceInputStream(AdapterConstants.BUNDLE_TYPE, "Bundle-Type: adapter", input); //$NON-NLS-1$
                input = new StringReplaceInputStream(DESCRIPTION, description, input);

                FileOutputStream out = new FileOutputStream(target);
                byte[] buf = new byte[2048];
                int len;
                while ((len = input.read(buf)) > 0)
                {
                    out.write(buf, 0, len);
                }

                input.close();
                out.close();
            }
        }
    }

    /**
     * Set the adapter short name.
     * @param shortName The short name
     */
    public void setShortName(String shortName)
    {
        this.shortName = shortName;
    }

    /**
     * Set the adapter ID.
     * @param adapterId The new ID.
     */
    public void setAdapterId(String adapterId)
    {
        this.adapterId = adapterId;
        adapterIdDirName = adapterId.replace("::", "/"); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Set the bundle project name.
     * @param bundle The project name
     */
    public void setBundle(String bundle)
    {
        this.bundle = bundle;
    }

    /**
     * Set the parent dir of the bundle.
     * @param parentDir The parent dir.
     */
    public void setParentDir(File parentDir)
    {
        this.parentDir = parentDir;
    }

    /**
     * Set the adapter description
     * @param description the description.
     */
    public void setDescription(String description)
    {
        this.description = description;
    }

    /**
     * Main
     * @param args the command line arguments
     */
    public static void main(String[] args)
    {
        try
        {
            CliElf.setupLog4j();
            AtConfigElf.loadSetup();
            IAdapterService adapterService = AtConfigElf.getAdapterService();

            CreateAdapter ca = new CreateAdapter();
            ca.setParentDir(AtConfigElf.getAdapterDir());

            while (true)
            {
                String id = CliElf.get(Messages.getString("CreateAdapter.adapterId")); //$NON-NLS-1$
                id = id.trim();

                if (adapterService.getAdapterMetadata(id) != null)
                {
                    System.err.println(Messages.getString("CreateAdapter.adapterAlreadyExists")); //$NON-NLS-1$
                }
                else if (!id.matches("[A-Z][A-Za-z0-9]*(::[A-Z][A-Za-z0-9]*)*")) //$NON-NLS-1$
                {
                    System.err.println(Messages.getString("CreateAdapter.adapterMustBeValidPerlModule")); //$NON-NLS-1$
                }
                else
                {
                    ca.setAdapterId(id);
                    break;
                }
            }

            String bundle = ca.adapterId.toLowerCase().replace("::", ".");  //$NON-NLS-1$//$NON-NLS-2$
            String projectName = CliElf.get(String.format(Messages.getString("CreateAdapter.adapterBundle"), bundle)); //$NON-NLS-1$
            projectName = projectName.trim();
            ca.setBundle(projectName.length() == 0 ? bundle : projectName);

            ca.setShortName(CliElf.get(Messages.getString("CreateAdapter.shortName"))); //$NON-NLS-1$
            ca.setDescription(CliElf.get(Messages.getString("CreateAdapter.description"))); //$NON-NLS-1$

            ca.create();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
    }
}
