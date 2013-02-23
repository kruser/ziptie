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
import java.net.URL;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.log4j.Logger;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * Sax parser for Crate definition files.
 */
@SuppressWarnings("nls")
public class CrateSaxHandler extends DefaultHandler
{
    private static final String ATTR_NAME = "name";
    private static final String ATTR_VERSION = "version";
    private static final String CRATE = "crate";

    private Crate crate;
    private StringBuilder buffer;

    /**
     * Create the handler
     * @param crate The crate to populate.
     */
    public CrateSaxHandler(Crate crate)
    {
        this.crate = crate;
    }

    /** {@inheritDoc} */
    @Override
    public void startElement(String uri, String localName, String qName, Attributes attrs) throws SAXException
    {
        if (qName.equals(CRATE))
        {
            crate.setId(attrs.getValue("id"));
            crate.setName(attrs.getValue(ATTR_NAME));
            crate.setVersion(attrs.getValue(ATTR_VERSION));
            crate.setArtifact(attrs.getValue("artifact"));
        }
        else if (qName.equals("bundle"))
        {
            CrateBundle cb = new CrateBundle(attrs.getValue("id"), attrs.getValue(ATTR_VERSION), attrs.getValue("location"));
            cb.setOs(attrs.getValue("os"));
            cb.setWs(attrs.getValue("ws"));
            cb.setArch(attrs.getValue("arch"));
            cb.setStart(Boolean.parseBoolean(attrs.getValue("start")));
            String level = attrs.getValue("level");
            if (level != null)
            {
                try
                {
                    cb.setStartLevel(Integer.parseInt(level));
                }
                catch (NumberFormatException e)
                {
                    cb.setStartLevel(-1);
                }
            }

            String deployType = attrs.getValue("deploy");
            if (deployType != null && deployType.equals("dir"))
            {
                cb.setDeployedAsDirectory(true);
            }

            crate.addBundle(cb);
        }
        else if (qName.equals("dependency"))
        {
            crate.addDependency(attrs.getValue(CRATE));
        }
        else if (qName.equals("description"))
        {
            buffer = new StringBuilder();
        }
        else if (qName.equals("category"))
        {
            crate.addCategory(attrs.getValue(ATTR_NAME));
        }
        else if (qName.equals("include"))
        {
            crate.addInclude(attrs.getValue("category"));
        }
    }

    /** {@inheritDoc} */
    @Override
    public void characters(char[] ch, int start, int length) throws SAXException
    {
        if (buffer != null)
        {
            buffer.append(ch, start, length);
        }
    }

    /** {@inheritDoc} */
    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException
    {
        if (buffer != null)
        {
            crate.setDescription(buffer.toString());
            buffer = null;
        }
    }

    /**
     * Loads the create from the given URL.
     * @param url the location of the crate definition file.
     * @return The crate definition.
     * @throws CrateException on error.
     */
    public static Crate readCrate(URL url) throws CrateException
    {
        InputStream in = null;
        try
        {
            in = url.openStream();

            Crate crate = new Crate(url);

            SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
            parser.parse(in, new CrateSaxHandler(crate));

            return crate;
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e);
        }
        catch (SAXException e)
        {
            throw new CrateException(e.getMessage(), e);
        }
        catch (IOException e)
        {
            throw new CrateException(e.getMessage(), e);
        }
        finally
        {
            try
            {
                if (in != null)
                {
                    in.close();
                }
            }
            catch (IOException e)
            {
                Logger.getLogger(CrateSaxHandler.class).warn("Error closing stream.", e);
            }
        }

    }
}
