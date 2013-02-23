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

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 * XPathElf
 */
public final class XPathElf
{
    private static final XPathFactory XPATH_FACTORY;
    private static final DocumentBuilderFactory DOC_BUILDER_FACTORY;
    private static final DocumentBuilder DOC_BUILDER;

    static
    {
        try
        {
            XPATH_FACTORY = XPathFactory.newInstance();

            DOC_BUILDER_FACTORY = DocumentBuilderFactory.newInstance();
            DOC_BUILDER = DOC_BUILDER_FACTORY.newDocumentBuilder();
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e);
        }
    }

    private XPathElf()
    {
        // private constructor
    }

    /**
     * Create an empty DOM document.
     *
     * @return a DOM Document instance
     */
    public static synchronized Document newDocument()
    {
        return DOC_BUILDER.newDocument();
    }

    /**
     * Easy Little Funtion to get a child node from a parent node given the provided
     * XPath expression.
     *
     * @param parent parent node
     * @param path XPath expression
     * @return the child node, or null
     * @throws XPathExpressionException thown if the XPath expression is invalid
     */
    public static Node selectSingleNode(Node parent, String path) throws XPathExpressionException
    {
        return (Node) getCachedXPathExpression(path).evaluate(parent, XPathConstants.NODE);
    }

    /**
     * Execute the given xpath expression against the provided node object and return the matching
     * node list.
     *
     * @param node a DOM node
     * @param path an xpath expression
     * @return the matching NodeList of nodes matching the expression
     * @throws XPathExpressionException thrown if the expression is invalid
     */
    public static NodeList selectNodeList(Node node, String path) throws XPathExpressionException
    {
        return (NodeList) getCachedXPathExpression(path).evaluate(node, XPathConstants.NODESET);
    }

    /**
     * Return an XPathExpression instance for the given xpath expression string.
     *
     * @param path an xpath expression
     * @return an XPathExpression instance
     * @throws XPathExpressionException thrown if the expression is invalid
     */
    public static XPathExpression getCachedXPathExpression(String path) throws XPathExpressionException
    {
        XPath xPath;
        synchronized (XPATH_FACTORY)
        {
            xPath = XPATH_FACTORY.newXPath();
        }
        return new ThreadSafeXPathExpression(xPath.compile(path));
    }

    /**
     * Create an empty XPath object.
     *
     * @return an XPath instance
     */
    public static XPath getXPath()
    {
        return XPATH_FACTORY.newXPath();
    }


    // ----------------------------------------------------------------------
    //                         I N N E R   C L A S S E S
    // ----------------------------------------------------------------------

    /**
     * ThreadSafeXPathExpression
     */
    private static class ThreadSafeXPathExpression implements XPathExpression
    {
        private XPathExpression delegate;

        ThreadSafeXPathExpression(XPathExpression delegate)
        {
            this.delegate = delegate;
        }

        public synchronized Object evaluate(InputSource source, QName returnType) throws XPathExpressionException
        {
            return delegate.evaluate(source, returnType);
        }

        public synchronized String evaluate(InputSource source) throws XPathExpressionException
        {
            return delegate.evaluate(source);
        }

        public synchronized Object evaluate(Object item, QName returnType) throws XPathExpressionException
        {
            return delegate.evaluate(item, returnType);
        }

        public synchronized String evaluate(Object item) throws XPathExpressionException
        {
            return delegate.evaluate(item);
        }
    }
}
