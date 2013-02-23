package org.ziptie.credentials.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.util.LinkedList;
import java.util.List;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.ziptie.common.DomReaderElf;
import org.ziptie.credentials.CredentialKey;

/**
 * The <code>CredentialKeyElf</code> class provides various helper methods for loading a resource representing an XML
 * document that defines various credential key information.  The resource can either be specified as a <code>URI</code>
 * or as an <code>InputStream</code>.  The XML document that is referenced by the resource will then be parsed for any
 * credential key information and loaded into a <code>List</code> of <code>CredentialKey</code> objects.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public final class CredentialKeyElf
{
    private static final String STATIC_ATTR = "static";
    private static final String DISPLAY_PASSWORD_ATTR = "displayAsPassword";
    private static final String DISPLAY_NAME_ATTR = "displayName";
    private static final String NAME_ATTR = "name";
    private static final String CREDENTIAL_KEY_ELEM = "credentialKey";

    /**
     * Private default constructor to hide the ability to create instances of the <code>CredentialKeyElf</code> class.
     */
    private CredentialKeyElf()
    {
        // Do nothing.
    }

    /**
     * Loads a <code>List</code> of <code>CredentialKey</code> objects from a specified <code>URI</code> representing an
     * XML document that defines various credential key information.
     * 
     * @param resourceUri A <code>URI</code> representing an XML document that defines various credential key information.
     * @return A <code>List</code> of <code>CredentialKey</code> objects that was populated by parsing the XML document.
     * specified by the <code>URI</code>.
     * @throws IOException Thrown if there is an issue locating, opening, or closing the XML document specified by the
     * <code>URI</code>.
     * @throws SAXException Thrown if there is an issue parsing the XML document specified by the <code>URI</code>.
     */
    public static List<CredentialKey> loadCredentialKeys(URI resourceUri) throws IOException, SAXException
    {
        List<CredentialKey> credentialKeys = null;
        if (resourceUri != null)
        {
            InputStream is = new FileInputStream(new File(resourceUri));
            credentialKeys = loadCredentialKeys(is);
        }

        return credentialKeys;
    }

    /**
     * Loads a <code>List</code> of <code>CredentialKey</code> objects from a specified <code>InputStream</code> representing an
     * XML document that defines various credential key information.
     * 
     * @param resourceStream An <code>InputStream</code> representing an XML document that defines various credential key
     * information.
     * @return A <code>List</code> of <code>CredentialKey</code> objects that was populated by parsing the XML document.
     * @throws IOException Thrown if there is an issue reading from or closing the XML document specified by the
     * <code>InputStream</code>.
     * @throws SAXException Thrown if there is an issue parsing the XML document specified by the <code>InputStream</code>.
     */
    public static List<CredentialKey> loadCredentialKeys(InputStream resourceStream) throws IOException, SAXException
    {
        List<CredentialKey> credentialKeys = null;

        if (resourceStream != null)
        {
            credentialKeys = new LinkedList<CredentialKey>();
            try
            {
                Document document = DomReaderElf.xmlReaderToDocument(new InputStreamReader(resourceStream));
                Element docElement = document.getDocumentElement();
                NodeList nodeList = docElement.getElementsByTagName(CREDENTIAL_KEY_ELEM);
                for (int i = 0; i < nodeList.getLength(); i++)
                {
                    String keyName = "";
                    String displayName = "";
                    boolean displayAsPassword = false;
                    boolean staticCred = false;

                    Element element = (Element) nodeList.item(i);
                    if (element.hasAttribute(NAME_ATTR))
                    {
                        keyName = element.getAttribute(NAME_ATTR);
                    }
                    if (element.hasAttribute(DISPLAY_NAME_ATTR))
                    {
                        displayName = element.getAttribute(DISPLAY_NAME_ATTR);
                    }
                    if (element.hasAttribute(DISPLAY_PASSWORD_ATTR))
                    {
                        displayAsPassword = Boolean.parseBoolean(element.getAttribute(DISPLAY_PASSWORD_ATTR));
                    }
                    if (element.hasAttribute(STATIC_ATTR))
                    {
                        staticCred = Boolean.parseBoolean(element.getAttribute(STATIC_ATTR));
                    }
                    CredentialKey credKey = new CredentialKey(keyName, displayName, displayAsPassword, staticCred);
                    credentialKeys.add(credKey);
                }
            }
            catch (SAXException saxe)
            {
                throw new SAXException("SAXException while attempting to load credential keys from an input stream!", saxe);
            }
            catch (IOException ioe)
            {
                throw ioe;
            }
            finally
            {
                resourceStream.close();
            }
        }

        return credentialKeys;
    }
}
