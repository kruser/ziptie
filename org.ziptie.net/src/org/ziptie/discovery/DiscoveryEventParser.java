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
 */
package org.ziptie.discovery;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.List;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.MACAddress;
import org.ziptie.addressing.Subnet;
import org.ziptie.discovery.RoutingNeighbor.RoutingProtocol;
import org.ziptie.discovery.XdpEntry.XdpTypes;

/**
 * DiscoveryEventParser
 */
public class DiscoveryEventParser
{
    private FileInputStream discoveryEventXml;
    private DiscoveryEvent discoveryEvent;

    /**
     * @param fis the inbound XML document
     */
    public DiscoveryEventParser(FileInputStream fis)
    {
        this.discoveryEventXml = fis;
        this.discoveryEvent = new DiscoveryEvent();
    }

    /**
     * Turn an XML doc from the input stream into a {@link DiscoveryEvent} object.
     * @return the translated event
     */
    public DiscoveryEvent parseEvent()
    {
        SAXParserFactory parserFactory = SAXParserFactory.newInstance();
        try
        {
            SAXParser parser = parserFactory.newSAXParser();
            TelemetryHandler handler = new TelemetryHandler();
            parser.reset();
            parser.parse(discoveryEventXml, handler);
            return discoveryEvent;
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e.getMessage());
        }
        catch (SAXException e)
        {
            throw new RuntimeException(e.getMessage());
        }
        catch (IOException e)
        {
            throw new RuntimeException(e.getMessage());
        }
    }

    /**
     * TelemetryHandler
     */
    private class TelemetryHandler extends DefaultHandler
    {

        private static final String MAC_ADDRESS = "macAddress";
        private static final String INTERFACE = "interface";
        private static final String PROTOCOL = "protocol";
        private static final String IP_ADDRESS = "ipAddress";
        /**
         * Holds the contents of each element
         */
        private StringBuffer elementChars;

        /** {@inheritDoc} */
        @Override
        public void endDocument() throws SAXException
        {
            discoveryEvent.setGoodEvent(true);
        }

        /** {@inheritDoc} */
        @Override
        public void characters(char[] ch, int start, int length) throws SAXException
        {
            elementChars.append(ch, start, length);
        }

        /** {@inheritDoc} */
        @Override
        public void startElement(String uri, String localName, String name, Attributes attributes) throws SAXException
        {
            elementChars = new StringBuffer();
            if (name.equals(INTERFACE))
            {
                DeviceInterface deviceInterface = new DeviceInterface();

                String operStatus = attributes.getValue("operStatus");
                deviceInterface.setIfOperStatus((operStatus == null) ? "" : operStatus);

                String intName = attributes.getValue("name");
                deviceInterface.setName((intName == null) ? "" : intName);

                String type = attributes.getValue("type");
                deviceInterface.setIfType((type == null) ? "other" : type);

                String inputBytes = attributes.getValue("inputBytes");
                deviceInterface.setInOctets((inputBytes == null) ? 0 : Long.parseLong(inputBytes));

                discoveryEvent.getInterfaces().add(deviceInterface);
            }
            else if (name.equals("ipEntry"))
            {
                String ipAddress = attributes.getValue(IP_ADDRESS);
                if (ipAddress != null)
                {
                    List<DeviceInterface> interfaces = discoveryEvent.getInterfaces();
                    DeviceInterface lastInterface = interfaces.get(interfaces.size() - 1);

                    IPAddress ip = new IPAddress(ipAddress);
                    lastInterface.addIPAddress(ip);
                    String mask = attributes.getValue("mask");
                    if (mask != null)
                    {
                        lastInterface.addSubnet(new Subnet(ip, new Short(mask)));
                    }
                }
            }
            else if (name.equals("routingNeighbor"))
            {
                String ipAddress = attributes.getValue(IP_ADDRESS);
                String protocol = attributes.getValue(PROTOCOL);
                RoutingNeighbor rn = new RoutingNeighbor(new IPAddress(ipAddress), RoutingProtocol.valueOf(protocol));
                rn.setDeviceId(discoveryEvent.getDeviceId());

                String interfaceName = attributes.getValue(INTERFACE);
                if (interfaceName != null)
                {
                    rn.setIfName(interfaceName);
                }
                String routerId = attributes.getValue("routerId");
                if (routerId != null)
                {
                    rn.setRouterId(new IPAddress(routerId));
                }
                discoveryEvent.addRoutingNeighbor(rn);
            }
            else if (name.equals("discoveryProtocolNeighbor"))
            {
                String protocol = attributes.getValue(PROTOCOL);
                XdpEntry xdp = new XdpEntry(XdpTypes.valueOf(protocol));
                xdp.setDeviceId(discoveryEvent.getDeviceId());

                String ipAddress = attributes.getValue(IP_ADDRESS);
                if (ipAddress != null)
                {
                    xdp.setIpAddress(new IPAddress(ipAddress));
                }
                else
                {
                    xdp.setIpAddress(new IPAddress("0.0.0.0"));
                }

                String mac = attributes.getValue(MAC_ADDRESS);
                if (mac != null)
                {
                    xdp.setMacAddress(new MACAddress(mac));
                }

                String sysDescr = attributes.getValue("sysDescr");
                xdp.setSysDescr((sysDescr != null) ? sysDescr : "");

                String localInterface = attributes.getValue("localInterface");
                xdp.setLocalIfName((localInterface != null) ? localInterface : "");

                String remoteInterface = attributes.getValue("remoteInterface");
                xdp.setInterfaceName((remoteInterface != null) ? remoteInterface : "");

                String platform = attributes.getValue("platform");
                xdp.setPlatform((platform != null) ? platform : "");

                String sysName = attributes.getValue("sysName");
                xdp.setSysName((sysName != null) ? sysName : "");

                discoveryEvent.addXdpNeighbor(xdp);
            }
            else if (name.equals("arpEntry"))
            {
                String ip = attributes.getValue("ipAddress");
                String mac = attributes.getValue(MAC_ADDRESS);
                if (ip != null && mac != null)
                {
                    ArpEntry arpEntry = new ArpEntry(new IPAddress(ip), new MACAddress(mac));
                    arpEntry.setDeviceId(discoveryEvent.getDeviceId());
                    String arpInterface = attributes.getValue(INTERFACE);
                    arpEntry.setInterfaceName((arpInterface != null) ? arpInterface : "");
                    discoveryEvent.addArpEntry(arpEntry);
                }
            }
            else if (name.equals("macEntry"))
            {
                String interfaceName = attributes.getValue(INTERFACE);
                String mac = attributes.getValue(MAC_ADDRESS);
                if (interfaceName != null && mac != null)
                {
                    MacTableEntry macEntry = new MacTableEntry(new MACAddress(mac));
                    macEntry.setDeviceId(discoveryEvent.getDeviceId());
                    macEntry.setInterfaceName(interfaceName);
                    String vlan = attributes.getValue("vlan");
                    macEntry.setVlan((vlan != null) ? vlan : "");
                    discoveryEvent.addMacTableEntry(macEntry);
                }
            }
        }

        /** {@inheritDoc} */
        @Override
        public void endElement(String uri, String localName, String name) throws SAXException
        {
            if (name.equals("adminIp"))
            {
                discoveryEvent.setAddress(new IPAddress(elementChars.toString()));
            }
            else if (name.equals("sysObjectId"))
            {
                discoveryEvent.setSysOID(elementChars.toString());
            }
            else if (name.equals("sysDescr"))
            {
                discoveryEvent.setSysDescr(elementChars.toString());
            }
            else if (name.equals("sysName"))
            {
                discoveryEvent.setSysName(elementChars.toString());
            }
        }
    }

    /**
     * Set the event, but do this before parsing occurs so that telemetry parsing can write to this event.
     * @param event
     */
    public void setDiscoveryEvent(DiscoveryEvent event)
    {
        this.discoveryEvent = event;
    }
}
