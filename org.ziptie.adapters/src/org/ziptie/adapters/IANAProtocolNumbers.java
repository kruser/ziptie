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

package org.ziptie.adapters;

import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.log4j.Logger;
import org.osgi.framework.Bundle;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * Maintain the mapping of IANA Protocol Numbers to Names based on the contents
 * of the ZipTie Core schema.
 */
@SuppressWarnings("nls")
public final class IANAProtocolNumbers
{
    private static Logger logger = Logger.getLogger(IANAProtocolNumbers.class);
    private static Map<String, Short> nameToNumberMap;
    private static Map<Short, String> numberToNameMap;
    private static List<Protocol> protocolList;

    /**
     * One IANA protocol.
     */
    public static class Protocol
    {
        private short number;
        private String name;

        Protocol(short num, String nam)
        {
            this.number = num;
            this.name = nam;
        }

        /**
         * @return the name of this protocol
         */
        public String getName()
        {
            return name;
        }

        /**
         * @return the number (8 bits) of this protocol
         */
        public short getNumber()
        {
            return number;
        }
    }

    /**
     * Make CheckStyle happy - private constructor for utility class.
     */
    private IANAProtocolNumbers()
    {
    }

    static void load(Bundle orgZiptieAdapters)
    {
        nameToNumberMap = new HashMap<String, Short>();
        numberToNameMap = new HashMap<Short, String>();
        protocolList = new ArrayList<Protocol>();

        try
        {
            URL ziptieCore = orgZiptieAdapters.getEntry("schema/model/ziptie-core.xsd");
            InputStream stream = ziptieCore.openStream();
            SAXParserFactory factory = SAXParserFactory.newInstance();
            factory.setNamespaceAware(true);
            SAXParser parser = factory.newSAXParser();
            parser.parse(stream, new XSDProtocolHandler());

            protocolList = Collections.unmodifiableList(protocolList);
        }
        catch (Exception ex)
        {
            logger.error("Unable to parse Protocl numbers from ziptie-core.xsd", ex);
        }
    }

    /**
     * Return the IANA protocol name given a protocol number.
     * @param name the name of a protocol as it appears in ziptie-core "Protocols"
     * @return the protocol number, or -1 if no such protocol is known
     */
    public static short getNumberForName(String name)
    {
        Short sh = nameToNumberMap.get(name);
        if (sh != null)
        {
            return sh.shortValue();
        }
        else
        {
            return -1;
        }
    }

    /**
     * Look up the name of an IANA protocol given the 8-bit protocol number
     * @param number the protocol number
     * @return the corresponding protocol name, or null if the number is unknown
     */
    public static String getNameForNumber(short number)
    {
        return numberToNameMap.get(number);
    }

    /**
     * Return a list of all Protocols known by the ZipTie core schema.
     * 
     * @return an unmodifiable list of protocols.
     */
    public static List<Protocol> getProtocols()
    {
        return protocolList;
    }

    /**
     * Parse the Protocol simpleType out of ziptie-core.
     */
    private static class XSDProtocolHandler extends DefaultHandler
    {
        private boolean inProtocolSimpleType;
        private int depth;
        private String coreNS;
        private String protocolName;
        private Short protocolNumber;

        @Override
        public void endElement(String uri, String localName, String qName) throws SAXException
        {
            depth--;

            if (inProtocolSimpleType)
            {
                if (localName.equals("simpleType"))
                {
                    inProtocolSimpleType = false;
                }
                else if (localName.equals("enumeration"))
                {
                    if (protocolName != null)
                    {
                        if (protocolNumber == null)
                        {
                            logger.warn("ZipTie-core schema Protocols malformed mapping.  name=" + protocolName + " number=" + protocolNumber);
                        }
                        nameToNumberMap.put(protocolName, protocolNumber);
                        numberToNameMap.put(protocolNumber, protocolName);
                        protocolList.add(new Protocol(protocolNumber, protocolName));
                    }
                }
            }
        }

        @Override
        public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
        {
            if (depth == 1 && localName.equals("simpleType"))
            {
                String nameAttr = attributes.getValue("", "name");
                if (nameAttr.equals("Protocol"))
                {
                    inProtocolSimpleType = true;
                }
            }
            else if (inProtocolSimpleType)
            {
                if (localName.equals("enumeration"))
                {
                    protocolName = attributes.getValue("", "value");
                    protocolNumber = null;
                }
                else if (localName.equals("annotation"))
                {
                    String attr = attributes.getValue(coreNS, "protocolNumber");
                    if (attr != null)
                    {
                        protocolNumber = Short.parseShort(attr);
                    }
                }
            }

            depth++;
        }

        @Override
        public void startPrefixMapping(String prefix, String uri) throws SAXException
        {
            if (uri.contains("www.ziptie.org/model/core"))
            {
                coreNS = uri;
            }
        }
    }
}
