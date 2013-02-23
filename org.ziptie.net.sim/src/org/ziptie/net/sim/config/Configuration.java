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

package org.ziptie.net.sim.config;

import java.io.OutputStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Map.Entry;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;

/**
 * Contains all the configuration details for a given session/client/global configuration.
 */
@SuppressWarnings("nls")
public class Configuration implements Cloneable
{
    public static final String CONFIGURATION_ROOT = "sim-config";
    public static final String NAME_ATTRIB = "name";
    public static final String DEFAULT_ATTRIB = "default";
    public static final String RATE_ATTRIB = "rate";
    public static final String MAX_BUFFER_LENGTH_ATTRIB = "maxBufferLength";
    public static final String OPERATION_TIMEOUT_ATTRIB = "operationTimeout";
    public static final String DEVICE_IP_ATTRIB = "deviceIp";
    public static final String DA_IP_ATTRIB = "daIp";
    public static final String RESPOND_ONLY_ON_NEWLINE_ATTRIB = "respondOnlyOnNewline";
    public static final String DO_ECHO_ATTRIB = "doEcho";

    public static final String SINGLE_TAG = "single";
    public static final String IP_ATTRIB = "ip";

    public static final String RANGE_TAG = "range";
    public static final String START_ATTRIB = "start";
    public static final String END_ATTRIB = "end";

    public static final String MASK_TAG = "mask";
    public static final String MASK_ATTRIB = "mask";

    public static final String RECORDING_ATTRIB = "session";

    private String filename;
    private String deviceIp;
    private String daIp;
    private String name;

    /**
     * List&lt;{@link Entry}&gt;
     */
    private List<IIpMapping> mappings;
    /**
     * Map&lt;{@link IpAddressMapping}, {@link WorkingConfig}&gt;
     */
    private Map<IpAddressMapping, WorkingConfig> operationMap;
    private URI defaultOperation;
    private float rateMultiplier;
    private long maxBufferLength;
    private int operationTimeout;
    private boolean respondOnlyOnNewline;
    private boolean doEcho;
    private boolean mapIp;

    public Configuration()
    {
        // List<Entry>
        mappings = Collections.synchronizedList(new ArrayList<IIpMapping>());

        // Map<IpAddressMapping, WorkingConfig>
        operationMap = Collections.synchronizedMap(new HashMap<IpAddressMapping, WorkingConfig>());
    }

    public void invalidateIp(String ip)
    {
        operationMap.remove(new IpAddressMapping(ip));
    }

    public void addMapping(IIpMapping mapping)
    {
        mappings.add(mapping);
    }

    public IIpMapping[] getMappings()
    {
        return mappings.toArray(new IIpMapping[mappings.size()]);
    }

    /**
     * @param filename The filename to set.
     */
    public void setFilename(String filename)
    {
        this.filename = filename;
    }

    /**
     * @return Returns the filename.
     */
    public String getFilename()
    {
        return filename;
    }

    /**
     * @param name The name to set.
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * @return Returns the name.
     */
    public String getName()
    {
        return name;
    }

    /**
     * @return Returns the deviceIp.
     */
    public String getDeviceIp()
    {
        return deviceIp;
    }

    /**
     * @param deviceIp The deviceIp to set.
     */
    public void setDeviceIp(String deviceIp)
    {
        this.deviceIp = deviceIp;
    }

    /**
     * @return Returns the daIp.
     */
    public String getDaIp()
    {
        return daIp;
    }

    /**
     * @param daIp The daIp to set.
     */
    public void setDaIp(String daIp)
    {
        this.daIp = daIp;
    }

    public WorkingConfig findOperation(String strLocalIp)
    {
        IpAddressMapping localIp = new IpAddressMapping(strLocalIp);

        WorkingConfig wc = operationMap.get(localIp);
        if (wc == null)
        {
            // Iterate backwards to ensure the most recently added mappings take priority
            ListIterator<IIpMapping> iter = mappings.listIterator(mappings.size());
            while (iter.hasPrevious())
            {
                IIpMapping next = iter.previous();
                if (next.contains(localIp))
                {
                    Boolean iroon = next.isRespondOnlyOnNewline();
                    Boolean doecho = next.isDoEcho();
                    wc = new WorkingConfig();
                    wc.setMaxBufferLength(getMaxBufferLength());
                    wc.setOperationTimeout(getOperationTimeout());
                    wc.setRateMultiplier(next.getRateMultiplier() * getRateMultiplier());
                    wc.setOperationUri(next.getOperation());
                    wc.setRespondOnlyOnNewline(iroon == null ? isRespondOnlyOnNewline() : iroon.booleanValue());
                    wc.setDoEcho(doecho == null ? isDoEcho() : doecho.booleanValue());

                    break;
                }
            }

            if (wc == null)
            {
                // use default
                wc = getDefaultOperationWorkingConfig();
            }
            operationMap.put(localIp, wc);
        }
        return wc;
    }

    public WorkingConfig getDefaultOperationWorkingConfig()
    {
        WorkingConfig wc = new WorkingConfig();
        wc.setMaxBufferLength(getMaxBufferLength());
        wc.setOperationTimeout(getOperationTimeout());
        wc.setRateMultiplier(getRateMultiplier());
        wc.setOperationUri(getDefaultOperation());
        wc.setRespondOnlyOnNewline(isRespondOnlyOnNewline());
        wc.setDoEcho(isDoEcho());
        return wc;
    }

    public URI getDefaultOperation()
    {
        return defaultOperation;
    }

    public void setDefaultOperation(URI defaultRecording)
    {
        this.defaultOperation = defaultRecording;
    }

    /**
     * @param rateMultiplier The rateMultiplier to set.
     */
    public void setRateMultiplier(float rateMultiplier)
    {
        this.rateMultiplier = rateMultiplier;
    }

    /**
     * @return Returns the rateMultiplier.
     */
    public float getRateMultiplier()
    {
        return rateMultiplier;
    }

    /**
     * @param maxBufferLength The maxBufferLength to set.
     */
    public void setMaxBufferLength(long maxBufferLength)
    {
        this.maxBufferLength = maxBufferLength;
    }

    /**
     * @return Returns the maxBufferLength.
     */
    public long getMaxBufferLength()
    {
        return maxBufferLength;
    }

    /**
     * The timeout time in minutes.
     */
    public int getOperationTimeout()
    {
        return operationTimeout;
    }

    public void setOperationTimeout(int operationTimeout)
    {
        this.operationTimeout = operationTimeout;
    }

    public boolean isRespondOnlyOnNewline()
    {
        return respondOnlyOnNewline;
    }

    public void setRespondOnlyOnNewline(boolean respondOnlyOnNewline)
    {
        this.respondOnlyOnNewline = respondOnlyOnNewline;
    }

    public boolean isDoEcho()
    {
        return doEcho;
    }

    public void setDoEcho(boolean doEcho)
    {
        this.doEcho = doEcho;
    }

    public void toXml(OutputStream os) throws Exception
    {
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();

        Document doc = builder.newDocument();

        Element root = doc.createElement(CONFIGURATION_ROOT);
        root.setAttribute(NAME_ATTRIB, getName());
        root.setAttribute(DEFAULT_ATTRIB, getDefaultOperation().toString());
        root.setAttribute(RATE_ATTRIB, String.valueOf(getRateMultiplier()));
        root.setAttribute(MAX_BUFFER_LENGTH_ATTRIB, String.valueOf(getMaxBufferLength()));
        root.setAttribute(OPERATION_TIMEOUT_ATTRIB, String.valueOf(getOperationTimeout()));
        root.setAttribute(DEVICE_IP_ATTRIB, getDeviceIp());
        root.setAttribute(DA_IP_ATTRIB, getDaIp());
        root.setAttribute(RESPOND_ONLY_ON_NEWLINE_ATTRIB, String.valueOf(isRespondOnlyOnNewline()));
        root.setAttribute(DO_ECHO_ATTRIB, String.valueOf(isDoEcho()));

        doc.appendChild(root);

        for (IIpMapping entry : mappings)
        {
            Element element = null;
            if (entry instanceof IpAddressMapping)
            {
                IpAddressMapping ip = (IpAddressMapping) entry;
                element = doc.createElement(SINGLE_TAG);
                element.setAttribute(IP_ATTRIB, ip.toString());
            }
            else if (entry instanceof IpSubnet)
            {
                IpSubnet subnet = (IpSubnet) entry;
                element = doc.createElement(MASK_TAG);
                element.setAttribute(MASK_ATTRIB, subnet.toString());
            }
            else if (entry instanceof IpRange)
            {
                IpRange range = (IpRange) entry;
                element = doc.createElement(RANGE_TAG);
                element.setAttribute(START_ATTRIB, range.getStart().toString());
                element.setAttribute(END_ATTRIB, range.getEnd().toString());
            }

            element.setAttribute(RECORDING_ATTRIB, entry.getOperation().toString());
            element.setAttribute(RATE_ATTRIB, String.valueOf(entry.getRateMultiplier()));
            element.setAttribute(RESPOND_ONLY_ON_NEWLINE_ATTRIB, String.valueOf(entry.isRespondOnlyOnNewline()));
            element.setAttribute(DO_ECHO_ATTRIB, String.valueOf(entry.isDoEcho()));

            root.appendChild(element);
        }

        DOMImplementationLS ls = (DOMImplementationLS) builder.getDOMImplementation();
        LSOutput out = ls.createLSOutput();
        out.setByteStream(os);

        ls.createLSSerializer().write(root, out);
    }

    public Configuration copy()
    {
        try
        {
            Configuration clone = (Configuration) clone();
            return clone;
        }
        catch (CloneNotSupportedException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * @return Returns the mapIp.
     */
    public boolean getMapIp()
    {
        return mapIp;
    }

    /**
     * @param mapIp The mapIp to set.
     */
    public void setMapIp(boolean mapIp)
    {
        this.mapIp = mapIp;
    }
}
