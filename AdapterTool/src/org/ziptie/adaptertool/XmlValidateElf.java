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
import java.io.IOException;
import java.io.PrintStream;
import java.io.Reader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;

import javax.xml.namespace.NamespaceContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;
import org.ziptie.adaptertool.art.Results;
import org.ziptie.adaptertool.art.Results.Type;

/**
 * Helper for validating XML.
 */
public final class XmlValidateElf
{
    private static final String HANDLED = "Handled"; //$NON-NLS-1$

    private XmlValidateElf()
    {
    }

    /**
     * Validate the XML from <code>in</code>.  Print messages to <code>out</code>
     * @param in The XML input.
     * @param out The status output stream.
     * @return <code>true</code> if there were no errors.
     */
    @SuppressWarnings("nls")
    public static boolean validate(Reader in, PrintStream out)
    {
        try
        {
            SAXParserFactory factory = SAXParserFactory.newInstance();

            factory.setValidating(true);
            factory.setNamespaceAware(true);
            factory.setFeature("http://xml.org/sax/features/validation", true);
            factory.setFeature("http://xml.org/sax/features/namespace-prefixes", true);
            factory.setFeature("http://xml.org/sax/features/namespaces", true);

            SAXParser parser = factory.newSAXParser();
            parser.setProperty("http://java.sun.com/xml/jaxp/properties/schemaLanguage", "http://www.w3.org/2001/XMLSchema");

            SaxHandler handler = new SaxHandler(out, null, 0);
            parser.parse(new InputSource(in), handler);

            return handler.errorCount == 0;
        }
        catch (SAXException e)
        {
            if (!e.getMessage().equals(HANDLED))
            {
                e.printStackTrace(out);
            }
        }
        catch (Throwable e)
        {
            e.printStackTrace(out);
        }
        return false;
    }

    /**
     * Validate the document read from <code>in</code> and verify that all expressions in <code>xpaths</code> evaluate to true.
     * @param results The result object to write to.
     * @param testId The current test's result id.
     * @param in The document.
     * @param xpaths a list of XPath expressions.
     * @return <code>true</code> iff the document is valid and there were no failed xpath expressions.
     */
    public static boolean validate(Results results, int testId, Reader in, Iterable<String> xpaths)
    {
        boolean valid = true;

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setValidating(true);
        factory.setNamespaceAware(true);
        factory.setAttribute("http://java.sun.com/xml/jaxp/properties/schemaLanguage", "http://www.w3.org/2001/XMLSchema"); //$NON-NLS-1$ //$NON-NLS-2$

        try
        {
            DocumentBuilder db = factory.newDocumentBuilder();
            SaxHandler eh = new SaxHandler(System.err, results, testId);
            db.setErrorHandler(eh);
            db.setEntityResolver(eh);

            Document doc = db.parse(new InputSource(in));
            if (eh.errorCount > 0)
            {
                return false;
            }

            NamespaceContext context = new NsContext(doc);
            Element elem = doc.getDocumentElement();

            XPathFactory xpf = XPathFactory.newInstance();
            for (String xpath : xpaths)
            {
                try
                {
                    XPath xp = xpf.newXPath();
                    xp.setNamespaceContext(context);
                    XPathExpression expression = xp.compile(xpath);
                    Boolean b = (Boolean) expression.evaluate(elem, XPathConstants.BOOLEAN);
                    if (b == null || !b)
                    {
                        results.addError(testId, Type.XPATH, "Failed to match expresion: " + xpath); //$NON-NLS-1$
                        valid = false;
                    }
                }
                catch (XPathExpressionException e)
                {
                    results.addError(testId, Type.XPATH, e);
                    valid = false;
                }
            }
        }
        catch (Throwable e)
        {
            results.addError(testId, Type.VALIDATION, e);
            valid = false;
        }

        return valid;
    }

    /**
     * Handles the parsing for the xml.
     */
    private static class SaxHandler extends DefaultHandler
    {
        private PrintStream out;
        private int errorCount;
        private int testId;
        private Results result;

        public SaxHandler(PrintStream out, Results results, int testId)
        {
            this.out = out;
            this.result = results;
            this.testId = testId;
        }

        @Override
        public InputSource resolveEntity(String publicId, String systemId) throws IOException, SAXException
        {
            try
            {
                URL url = new URL(systemId);
                if (url.getProtocol().equals("file")) //$NON-NLS-1$
                {
                    File file = new File(url.getFile());
                    if (file.exists())
                    {
                        return new InputSource(systemId);
                    }

                    String root = new File(".").getCanonicalPath(); //$NON-NLS-1$
                    // URL may come in with spaces escaped.  Let's de-escape them.
                    String canonicalPath = file.getCanonicalPath().replaceAll("%20", " "); //$NON-NLS-1$ //$NON-NLS-2$
                    if (canonicalPath.startsWith(root))
                    {
                        file = new File("schema/model", canonicalPath.substring(root.length())); //$NON-NLS-1$
                        if (file.exists())
                        {
                            return new InputSource(new FileInputStream(file));
                        }
                    }
                }
            }
            catch (MalformedURLException e)
            {
                return null;
            }
            return null;
        }

        @Override
        public void error(SAXParseException e) throws SAXException
        {
            createError(e);
        }

        private void createError(SAXParseException e)
        {
            errorCount++;
            String msg = String.format("Error: L:%d C:%d - %s", e.getLineNumber(), e.getColumnNumber(), e.getMessage()); //$NON-NLS-1$
            out.println(msg);
            if (result != null)
            {
                result.addError(testId, Type.VALIDATION, msg);
            }
        }

        @Override
        public void fatalError(SAXParseException e) throws SAXException
        {
            createError(e);

            throw e;
        }
    }

    /**
     * Namespace context from a document
     */
    private static class NsContext implements NamespaceContext
    {
        private Document doc;

        NsContext(Document doc)
        {
            this.doc = doc;
        }

        public String getNamespaceURI(String prefix)
        {
            return doc.lookupNamespaceURI(prefix);
        }

        public String getPrefix(String namespaceURI)
        {
            throw new UnsupportedOperationException();
        }

        public Iterator<?> getPrefixes(String namespaceURI)
        {
            throw new UnsupportedOperationException();
        }
    }
}
