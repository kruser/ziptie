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

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashSet;
import java.util.Set;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;

import org.apache.log4j.Logger;
import org.xml.sax.SAXException;

/**
 * Represents a crate site.
 */
public class SiteCrateLocation extends CrateLocation
{
    private URL url;
    private String siteCrateFileName;
    private Set<CrateRef> refs;

    /**
     * Create the site location.
     * @param url The site url.  (ie: "http://www.ziptie.org/site")
     */
    public SiteCrateLocation(URL url)
    {
        this(url, "site.xml");
    }

    /**
     * Create the site location, specifying the crate list file name ("site.xml" by default)
     * @param url The site url.  (ie: "http://www.ziptie.org/site")
     */
    public SiteCrateLocation(URL url, String siteCrateFileName)
    {
        this.url = url;
        this.siteCrateFileName = siteCrateFileName;
    }

    /**
     * The base url for the site.
     * @return The base url.
     */
    public URL getUrl()
    {
        return url;
    }

    /**
     * Get the crate for the given crate reference.
     * @param ref The crate to load.
     * @return The crate.
     * @throws CrateException On read error.
     */
    public Crate getCrate(CrateRef ref) throws CrateException
    {
        return getCrate(ref.getId(), ref.getVersion());
    }

    /** {@inheritDoc} */
    @Override
    public Crate getCrate(String id, String strVersion) throws CrateException
    {
        if (strVersion != null)
        {
            return getCrate(getCrateUrl(id, strVersion));
        }

        CrateRef result = null;
        for (CrateRef ref : getCrateRefs())
        {
            if (ref.getId().equals(id))
            {
                if (result == null || isLessThan(result.getVersion(), ref.getVersion()))
                {
                    result = ref;
                }
            }
        }

        return result == null ? null : getCrate(getCrateUrl(result));
    }

    /**
     * Gets the latest version of each crate reference for this location.
     * @return All the latest crate refs.
     * @throws CrateException on error.
     */
    public Set<CrateRef> getLatestCrateRefs() throws CrateException
    {
        return getLatest(getCrateRefs());
    }

    /**
     * Get all available crates.
     * @return A list of crate references.
     * @throws CrateException On read error.
     */
    @SuppressWarnings("nls")
    public synchronized Set<CrateRef> getCrateRefs() throws CrateException
    {
        if (refs != null)
        {
            return refs;
        }

        refs = new HashSet<CrateRef>();
        InputStream in = null;
        try
        {
            URL siteXml = new URL(url.toString() + "/" + siteCrateFileName); //$NON-NLS-1$
            in = siteXml.openStream();
            SAXParserFactory.newInstance().newSAXParser().parse(in , new SiteSaxHandler(refs));

            return refs;
        }
        catch (SAXException e)
        {
            throw new CrateException(e.getMessage(), e);
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e);
        }
        catch (IOException e)
        {
            throw new CrateException(e.getMessage(), e);
        }
        finally
        {
            if (in != null)
            {
                try
                {
                    in.close();
                }
                catch (IOException e)
                {
                    Logger.getLogger(getClass()).warn("Error closing stream.", e); //$NON-NLS-1$
                }
            }
        }
    }

    @Override
    protected URL[] getCrateUrls() throws CrateException
    {
        Set<CrateRef> crates = getCrateRefs();
        URL[] urls = new URL[crates.size()];

        int i = 0;
        for (CrateRef ref : crates)
        {
            urls[i++] = getCrateUrl(ref);
        }

        return urls;
    }

    private URL getCrateUrl(String id, String version) throws CrateException
    {
        try
        {
            return new URL(String.format("%s/crates/%s_%s.crate", url.toString(), id, version)); //$NON-NLS-1$
        }
        catch (MalformedURLException e)
        {
            throw new CrateException(e.getMessage(), e);
        }
    }

    private URL getCrateUrl(CrateRef ref) throws CrateException
    {
        return getCrateUrl(ref.getId(), ref.getVersion());
    }
}
