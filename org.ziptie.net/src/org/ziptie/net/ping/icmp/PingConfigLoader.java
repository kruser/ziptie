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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.ping.icmp;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.ziptie.common.DomReaderElf;
import org.ziptie.common.OsTypes;


/**
 * Loads up the <code>PingConfig</code> from an XML file on the system.
 * 
 * @author rkruse
 */
@SuppressWarnings("nls")
public class PingConfigLoader
{
    private static final String MAC = "Mac";
    private static final String LINUX = "Linux";
    private static final String WINDOWS = "Windows";
    private static final String PING_CONFIG_FILE = "pingConfig.xml";
    private PingConfig pingConfig;

    /**
     * Loads up a PingConfig from the default XML file
     * 
     * @throws PingException if the XML is malformed
     */
    public PingConfigLoader() throws PingException
    {
        pingConfig = new PingConfig();
        loadPingXmlConfig(PING_CONFIG_FILE);
    }

    /**
     * Initializes the pingConfig
     * 
     * @param configFilename
     * @throws PingException
     */
    private void loadPingXmlConfig(String configFilename) throws PingException
    {
        InputStream input = null;
        try
        {
            URL url = PingConfigLoader.class.getResource("/nil/" + configFilename);

            if (url == null)
            {
                throw new RuntimeException("Could not find file in classpath. Filename: " + configFilename);
            }

            NodeList nodeList;
            input = url.openStream();
            Document doc = DomReaderElf.xmlReaderToDocument(new InputStreamReader(input));
            Element docElement = doc.getDocumentElement();

            String os = System.getProperty("os.name");
            if (os.startsWith(WINDOWS))
            {
                os = WINDOWS;
                pingConfig.setOs(OsTypes.Windows);
            }
            else if (os.startsWith(LINUX))
            {
                os = LINUX;
                pingConfig.setOs(OsTypes.Linux);
            }
            else if (os.startsWith(MAC))
            {
                os = MAC;
                pingConfig.setOs(OsTypes.Mac);
            }
            else
            {
                os = "Solaris";
                pingConfig.setOs(OsTypes.Solaris);
            }
            nodeList = docElement.getElementsByTagName(os);
            getPingAttributes((Element) nodeList.item(0));
        }
        catch (IOException i)
        {
            throw new PingException(i);
        }
        catch (SAXException s)
        {
            throw new PingException(s);
        }
        finally
        {
            if (input != null)
            {
                try
                {
                    input.close();
                }
                catch (IOException e)
                {
                    // eat
                    return;
                }
            }
        }
    }

    /**
     * Given one of the OS specific elements, parse out the specifics and put them in the <code>PingConfig</code>
     * 
     * @param element
     */
    private void getPingAttributes(Element element)
    {
        String pingCommand = element.getAttribute("command");
        String count = element.getAttribute("countFlag");
        String timeout = element.getAttribute("timeoutFlag");
        String size = element.getAttribute("sizeFlag");

        pingConfig.setCommand(pingCommand);
        pingConfig.setCountFlag(count);
        pingConfig.setTimeoutFlag(timeout);
        pingConfig.setSizeFlag(size);
    }

    /**
     * 
     * @return the {@link PingConfig}
     */
    public PingConfig getPingConfig()
    {
        return pingConfig;
    }
}
