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
package org.ziptie.provider.update.internal;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.StringWriter;
import java.net.URL;
import java.net.URLConnection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Platform;
import org.ziptie.crates.Crate;
import org.ziptie.crates.CrateException;
import org.ziptie.crates.CrateStarterElf;
import org.ziptie.crates.InstallLocation;
import org.ziptie.provider.update.ISummaryBuilder;
import org.ziptie.provider.update.IUpdateProvider;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Provides a means to update the server.
 */
class UpdateProvider implements IUpdateProvider
{
    private static final Logger LOGGER = Logger.getLogger(UpdateProvider.class);
    private Set<Crate> notInstalled;

    public UpdateProvider()
    {
        notInstalled = new HashSet<Crate>();
    }

    /** {@inheritDoc} */
    public boolean download(String crateId, String version, String forgeHost)
    {
        try
        {
            String forge = forgeHost;
            if (forge == null)
            {
                forge = "forge.ziptie.org"; //$NON-NLS-1$
            }

            InstallLocation install = UpdateActivator.getInstallLocation();

            LinkedList<ToDownload> queue = new LinkedList<ToDownload>();
            queue.addFirst(new ToDownload(crateId, version));

            while (!queue.isEmpty())
            {
                ToDownload toDownload = queue.poll();

                String ver = toDownload.version == null ? "" : toDownload.version; //$NON-NLS-1$
                URL url = new URL(String.format("http://%s/download.php?crateId=%s&version=%s", forge, toDownload.id, ver)); //$NON-NLS-1$
                URLConnection conn = url.openConnection();
                String type = conn.getHeaderField("Content-Type"); //$NON-NLS-1$
                if (!type.equals("application/zip")) //$NON-NLS-1$
                {
                    Logger.getLogger(getClass()).warn("Crate is not a zip: " + url); //$NON-NLS-1$
                    return false;
                }
                download(conn.getInputStream());

                Crate crate = install.addCrate(crateId, version);
                for (String dep : crate.getDependencies())
                {
                    if (install.getCrate(dep, null) == null)
                    {
                        queue.add(new ToDownload(dep, null));
                    }
                }
            }

            install(crateId, version);

            return true;
        }
        catch (FileNotFoundException e)
        {
            // expected, in case there is not access to the file.
            return false;
        }
        catch (Exception e)
        {
            Logger.getLogger(getClass()).error(e.getMessage(), e);
            return false;
        }
    }

    public boolean upload(OutputStream response, String crateId, String version, InputStream zipfile) throws IOException, CrateException, XMLStreamException
    {
        XMLOutputFactory factory = XMLOutputFactory.newInstance();
        XMLStreamWriter writer = factory.createXMLStreamWriter(response);
        writer.writeStartDocument();
        writer.writeStartElement("dependencies"); //$NON-NLS-1$

        download(zipfile);

        InstallLocation install = UpdateActivator.getInstallLocation();
        Crate crate = install.addCrate(crateId, version);

        boolean installable = true;
        for (String dep : crate.getDependencies())
        {
            if (install.getCrate(dep, null) == null)
            {
                writer.writeStartElement("bundle"); //$NON-NLS-1$
                writer.writeAttribute("id", dep); //$NON-NLS-1$
                writer.writeEndElement();

                installable = false;
            }
        }

        writer.writeEndElement();
        writer.writeEndDocument();

        if (installable)
        {
            install(crateId, version);
        }
        else
        {
            notInstalled.add(crate);
        }

        return true;
    }

    private void install(String crateId, String version) throws CrateException, IOException
    {
        InstallLocation install = UpdateActivator.getInstallLocation();
        Crate crate = install.getCrate(crateId, version);

        HashSet<Crate> toInstall = new HashSet<Crate>();
        toInstall.add(crate);

        for (Crate c : notInstalled)
        {
            try
            {
                CrateStarterElf.expandDependencies(install, new Crate[]{c});
                toInstall.add(c);
            }
            catch (CrateException e)
            {
                continue;
            }
        }

        Logger logger = Logger.getLogger(getClass());
        CrateStarterElf.activateBundles(UpdateActivator.getContext(), install, toInstall);
        for (Crate installed : toInstall)
        {
            notInstalled.remove(installed);
            logger.info(String.format("Installed crate: %s (%s)", installed.getId(), installed.getVersion())); //$NON-NLS-1$
        }
    }

    private void download(InputStream in) throws IOException
    {
        File root = UpdateActivator.getInstallLocation().getRoot();

        ZipInputStream zis = new ZipInputStream(in);
        byte[] buf = new byte[4096];
        while (true)
        {
            ZipEntry entry = zis.getNextEntry();
            if (entry == null)
            {
                break;
            }

            File file = new File(root, entry.getName().replace('\\', File.separatorChar));
            file.getParentFile().mkdirs();
            if (!entry.isDirectory())
            {
                FileOutputStream out = new FileOutputStream(file);
                int len;
                while ((len = zis.read(buf)) > 0)
                {
                    out.write(buf, 0, len);
                }
                out.close();
                out = null;
            }

            zis.closeEntry();
        }

        zis.close();
    }

    /** {@inheritDoc} */
    public String getSummaryXml()
    {
        XMLOutputFactory factory = XMLOutputFactory.newInstance();

        boolean success = false;
        boolean own = TransactionElf.beginOrJoinTransaction();

        try
        {
            StringWriter result = new StringWriter();
            XMLStreamWriter writer = factory.createXMLStreamWriter(result);
            writer.writeStartDocument();
            writer.writeStartElement("summary"); //$NON-NLS-1$

            IConfigurationElement[] configs = Platform.getExtensionRegistry().getConfigurationElementsFor("org.ziptie.provider.update.summary"); //$NON-NLS-1$
            for (IConfigurationElement config : configs)
            {
                try
                {
                    ISummaryBuilder builder = (ISummaryBuilder) config.createExecutableExtension("class"); //$NON-NLS-1$
                    builder.buildSummary(writer);
                }
                catch (CoreException e)
                {
                    LOGGER.error("Error loading summary builder extension.", e); //$NON-NLS-1$
                }
            }

            writer.writeEndElement();
            writer.writeEndDocument();

            success = true;

            return result.toString();
        }
        catch (XMLStreamException e)
        {
            LOGGER.error(e.getMessage(), e);
            return null;
        }
        finally
        {
            if (own)
            {
                if (success)
                {
                    TransactionElf.commit();
                }
                else
                {
                    TransactionElf.rollback();
                }
            }
        }
    }

    /**
     * A download dependency
     */
    private static class ToDownload
    {
        private String id;
        private String version;

        public ToDownload(String id, String version)
        {
            this.id = id;
            this.version = version;
        }
    }
}
