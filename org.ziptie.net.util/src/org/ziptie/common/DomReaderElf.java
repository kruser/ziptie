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

package org.ziptie.common;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * MiscUtils
 */
public final class DomReaderElf
{
    // Array of all the characters that should be escaped when calculating a regex
    static final String[] META_CHARS = { "\\", "^", ".", "$", "|", "(", ")", "[", "]", "*", "+", "?", "/", "'" };

    private static final DocumentBuilderFactory DOC_FACTORY;
    private static final DocumentBuilder PARSER;

    static
    {
        try
        {
            DOC_FACTORY = DocumentBuilderFactory.newInstance();
            DOC_FACTORY.setNamespaceAware(true);
            // not for jaxp: docFactory.setFeature("http://xml.org/sax/features/namespaces", true);
            PARSER = DOC_FACTORY.newDocumentBuilder();
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Hidden constructor
     *
     */
    private DomReaderElf()
    {
    }

    /**
     * @param file the file to read
     * @return the resulting doc
     * @throws SAXException if the XML is malformed
     * @throws IOException if the file can't be read
     */
    public static Document xmlFileToDoc(File file) throws SAXException, IOException
    {
        return xmlReaderToDocument(new FileReader(file));
    }

    /**
     * @param reader the incoming text
     * @return the resulting doc
     * @throws SAXException if the XML is malformed
     * @throws IOException if the file can't be read
     */
    public static synchronized Document xmlReaderToDocument(Reader reader) throws SAXException, IOException
    {
        InputSource is = new InputSource(reader);
        try
        {
            PARSER.reset();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }

        return PARSER.parse(is);
    }

    /**
     * @param inputStream the incoming text
     * @return the resulting doc
     * @throws SAXException if the XML is malformed
     * @throws IOException if the file can't be read
     */
    public static Document inputStreamToDom(InputStream inputStream) throws SAXException, IOException
    {
        try
        {
            PARSER.reset();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return PARSER.parse(inputStream);
    }
}
