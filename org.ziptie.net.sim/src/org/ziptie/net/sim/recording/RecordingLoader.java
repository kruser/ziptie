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

package org.ziptie.net.sim.recording;

import java.io.BufferedInputStream;
import java.io.CharArrayWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.log4j.Logger;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.encoding.Base64;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.operations.IOperation;
import org.ziptie.net.sim.operations.IOperationFactory;
import org.ziptie.net.sim.util.CharSequenceBuffer;
import org.ziptie.net.sim.util.IpAddress;
import org.ziptie.net.sim.util.Util;

/**
 * Loads interaction record files.
 * <p>{@link IOperationFactory} implementation for recordings on the filesystem.
 * <p>Sessions for these recordings follow the pattern "<i>recording://&lt;filename&gt;</i>"
 */
@SuppressWarnings("nls")
public class RecordingLoader implements IOperationFactory
{
    private static final Logger LOG = Logger.getLogger(RecordingLoader.class);

    private static final String PREFIX = "recording";
    private static final String DIR = "recordings";
    private static final String EXTENSION = ".record";

    ///////////////////////////////////////////////////
    // XML tags/attribute names
    ///////////////////////////////////////////////////

    private static final String ROOT_RECORDING_NODE = "recording";
    private static final String ADAPTER_ID_ATTRIBUTE = "adapterId";
    private static final String DEVICE_PROMPT_ATTRIBUTE = "devicePrompt";
    private static final String OPERATION_NAME_ATTRIBUTE = "operationName";

    private static final String CONNECTION_PATH_NODE = "connectionPath";
    private static final String HOST_ATTRIBUTE = "host";
    
    private static final String FILESERVERS_NODE = "fileServers";
    private static final String PROTOCOL_ATTRIBUTE = "protocol";
    private static final String IP_ATTRIBUTE = "ip";
    
    private static final String TFTP_STRING = "TFTP";

    private static final String INTERACTION_NODE = "interaction";
    private static final String AS_BYTES_ATTRIBUTE = "asBytes";
    private static final String CLI_COMMAND_ATTRIBUTE = "cliCommand";
    private static final String CLI_PROTOCOL_ATTRIBUTE = "cliProtocol";
    private static final String CLI_RESPONSE_NODE = "cliResponse";
    private static final String START_TIME_ATTRIBUTE = "startTime";
    private static final String END_TIME_ATTRIBUTE = "endTime";
    private static final String TIMEOUT_ATTRIBUTE = "timeout";
    private static final String WAIT_FOR_ATTRIBUTE = "waitFor";
    private static final String XFER_PROTOCOL_ATTRIBUTE = "xferProtocol";
    private static final String XFER_FILENAME_ATTRIBUTE = "xferFilename";
    private static final String XFER_AS_SERVER_ATTRIBUTE = "xferAsServer";
    private static final String XFER_RESPONSE_NODE = "xferResponse";

    /**
     * A cache of recordings which have already been loaded
     */
    private Map<String, RecordingEntry> recordingMap;
    private Lock mainLock;

    /**
     * Hidden constructor
     * @see RecordingLoader#getInstance()
     */
    private RecordingLoader()
    {
        recordingMap = new WeakHashMap<String, RecordingEntry>();
        mainLock = new ReentrantLock();
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.interactions.IOperationFactory#createOperation(org.ziptie.net.sim.config.Configuration, org.ziptie.net.sim.IpAddress, org.ziptie.net.sim.IpAddress, java.net.URI)
     */
    public IOperation createOperation(WorkingConfig config, IpAddress remoteIp, IpAddress localIp) throws NoSuchOperationException
    {
        Recording recording = findRecording(config.getOperationUri().getSchemeSpecificPart());

        return new RecordingOperation(config, remoteIp, localIp, recording);
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.interactions.ISessionFactory#enumerateSessions()
     */
    public Collection<URI> enumerateSessions()
    {
        File recordingDir = new File(DIR);
        String[] list = recordingDir.list(new FilenameFilter()
        {
            public boolean accept(File dir, String name)
            {
                return name.endsWith(EXTENSION);
            }
        });

        // List<java.net.URI>;
        List<URI> uris = new ArrayList<URI>(list.length);
        for (int i = 0; i < list.length; i++)
        {
            try
            {
                uris.add(new URI(PREFIX + ":" + list[i]));
            }
            catch (URISyntaxException e)
            {
                LOG.error("Invalid recording URI: " + list[i], e);
            }
        }
        return uris;
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.interactions.ISessionFactory#getPathPrefix()
     */
    public String getPathPrefix()
    {
        return PREFIX;
    }

    /**
     * Returns the session from the cache or loads it from the filesystem if it hasn't been already.
     * @param name The filename of the recording
     * @throws NoSuchOperationException when no recording exists for <code>name</code>
     */
    public Recording findRecording(String name) throws NoSuchOperationException
    {
        RecordingEntry entry;
        mainLock.lock();
        try
        {
            entry = recordingMap.get(name);
            if (entry == null)
            {
                entry = new RecordingEntry();
                recordingMap.put(name, entry);
            }
        }
        finally
        {
            mainLock.unlock();
        }

        entry.lock.lock();
        try
        {
            if (entry.recording == null)
            {
                try
                {
                    entry.recording = loadRecordFile(name);
                }
                catch (Exception e)
                {
                    throw new NoSuchOperationException("No such recording: " + name, e);
                }
            }
            return entry.recording;
        }
        finally
        {
            entry.lock.unlock();
        }
    }

    private Recording loadRecordFile(String strFilename) throws FileNotFoundException, SAXException, IOException
    {
        try
        {
            RecordSaxHandler handler = new RecordSaxHandler();

            SAXParser sparser = SAXParserFactory.newInstance().newSAXParser();
            sparser.parse(new BufferedInputStream(new FileInputStream(getFileForRecording(strFilename))), handler);

            LOG.info("Loaded recording from " + strFilename);

            return handler.getRecording();
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e);
        }
    }

    public void printRecordingFile(OutputStream out, String filename) throws IOException
    {
        InputStream is = new BufferedInputStream(new FileInputStream(getFileForRecording(filename)));

        byte[] buf = new byte[1024];
        while (true)
        {
            int len = is.read(buf);
            if (len < 0)
            {
                break;
            }
            out.write(buf, 0, len);
        }
        is.close();
    }

    private File getFileForRecording(String filename)
    {
        File file = new File(filename);
        if (!file.isAbsolute())
        {
            file = new File(DIR, filename);
        }
        return file;
    }

    /**
     * SAX Handler for parsing a recording file (We use SAX because it is crazy fast)
     */
    private class RecordSaxHandler extends DefaultHandler
    {
        private Recording recording;
        private Interaction currentInteraction;
        private boolean rearrangeInteractions = false;
        private CharArrayWriter response = new CharArrayWriter();

        /* (non-Javadoc)
         * @see org.xml.sax.helpers.DefaultHandler#startElement(java.lang.String, java.lang.String, java.lang.String, org.xml.sax.Attributes)
         */
        public void startElement(String uri, String localName, String qName, Attributes attribs) throws SAXException
        {
            if (qName.equals(INTERACTION_NODE))
            {
                // Add any previously existing interaction and reset the state
                if (currentInteraction != null)
                {
                    recording.addInteraction(currentInteraction);
                    response.reset();
                    currentInteraction = null;
                }
                
                currentInteraction = new Interaction();

                // Parse the "asBytes" attribute
                String asBytesFlagString = attribs.getValue(AS_BYTES_ATTRIBUTE);
                boolean asBytesFlag = (asBytesFlagString != null && asBytesFlagString.length() > 0) ? (Integer.parseInt(asBytesFlagString) == 1) : false;
                currentInteraction.setAsBytesFlag(asBytesFlag);

                // Parse the "cliProtocol" attribute
                String cliProtocolString = attribs.getValue(CLI_PROTOCOL_ATTRIBUTE);
                currentInteraction.setCliProtocol((cliProtocolString != null && cliProtocolString.length() > 0) ? cliProtocolString : "");

                // Parse the "startTime" attribute
                String startTimeString = attribs.getValue(START_TIME_ATTRIBUTE);
                currentInteraction.setStartTime(Long.parseLong((startTimeString != null && startTimeString.length() > 0) ? startTimeString : "0"));

                // Parse the "endTime" attribute
                String endTimeString = attribs.getValue(END_TIME_ATTRIBUTE);
                currentInteraction.setEndTime(Long.parseLong((endTimeString != null && endTimeString.length() > 0) ? endTimeString : "0"));

                // Parse the "timeout" attribute
                String timeoutString = attribs.getValue(TIMEOUT_ATTRIBUTE);
                currentInteraction.setTimeout(Integer.parseInt((timeoutString != null && timeoutString.length() > 0) ? timeoutString : "0"));

                // Parse the "waitFor" attribute
                String waitForString = attribs.getValue(WAIT_FOR_ATTRIBUTE);
                currentInteraction.setWaitFor((waitForString != null && waitForString.length() > 0) ? Base64.decodeToString(waitForString) : "");

                // Parse the "xferProtocol" attribute
                String xferProtocolString = attribs.getValue(XFER_PROTOCOL_ATTRIBUTE);
                currentInteraction.setXferProtocol((xferProtocolString != null && xferProtocolString.length() > 0) ? xferProtocolString : "");

                // Parse the "xferFilename" attribute
                String xferFilenameString = attribs.getValue(XFER_FILENAME_ATTRIBUTE);
                currentInteraction.setXferFilename((xferFilenameString != null && xferFilenameString.length() > 0) ? xferFilenameString : "");
                
                // Parse the "xferAsServer" attribute
                String xferAsServerString = attribs.getValue(XFER_AS_SERVER_ATTRIBUTE);
                boolean xferAsServerFlag = (xferAsServerString != null && xferAsServerString.length() > 0) ? (Integer.parseInt(xferAsServerString) == 1)
                        : false;
                currentInteraction.setXferAsServer(xferAsServerFlag);

                // Parse the "cliCommand" attribute and decode it using the Base64 algorithm
                String strInput = attribs.getValue(CLI_COMMAND_ATTRIBUTE);

                // input is encoded to support menu devices
                if (strInput != null)
                {
                    strInput = Base64.decodeToString(strInput);
                    currentInteraction.setCliCommand(new CharSequenceBuffer(strInput.toCharArray()));
                }
                else
                {
                    currentInteraction.setCliCommand(new CharSequenceBuffer());
                }
            }
            else if (qName.equals(ROOT_RECORDING_NODE))
            {
                /* <recording 
                 *         operationName="backup"
                 *         adapterId="ZipTie::Adapters::Cisco::IOS"
                 *         devicePrompt="#">
                 */
                if (recording == null)
                {
                    recording = new Recording();
                }
                recording.setOperationName(attribs.getValue(OPERATION_NAME_ATTRIBUTE));
                recording.setAdapterId(attribs.getValue(ADAPTER_ID_ATTRIBUTE));
                recording.setDevicePrompt(attribs.getValue(DEVICE_PROMPT_ATTRIBUTE));
            }
            else if (qName.equals(CONNECTION_PATH_NODE))
            {
                if (recording == null)
                {
                    recording = new Recording();
                }
                recording.setDeviceIP(attribs.getValue(HOST_ATTRIBUTE));
            }
            else if (qName.equals(FILESERVERS_NODE))
            {
                String protocolName = attribs.getValue(PROTOCOL_ATTRIBUTE);
                if (protocolName != null && protocolName.equalsIgnoreCase(TFTP_STRING))
                {
                    if (recording == null)
                    {
                        recording = new Recording();
                    }
                    
                    recording.setTftpServerIP(attribs.getValue(IP_ATTRIBUTE));
                }
            }
        }

        /* (non-Javadoc)
         * @see org.xml.sax.helpers.DefaultHandler#endElement(java.lang.String, java.lang.String, java.lang.String)
         */
        public void endElement(String uri, String localName, String qName) throws SAXException
        {
            if (currentInteraction != null)
            {
                String decodedString = Base64.decodeToString(response.toString());
                CharSequence cs = new CharSequenceBuffer(decodedString.toCharArray());
                if (!currentInteraction.getAsBytesFlag())
                {
                    // normalize newlines to <CR.LF>
                    // This is two pass to prevent any <CR.CR.LF> 
                    cs = Util.replaceLiteral(cs, "\r\n", "\n");

                    // TODO dwhite:  Is this needed?  This seems to just add an extra newline between every line
                    //cs = Util.replaceLiteral(cs, "\n", "\r\n");
                }
                if (qName.equals(XFER_RESPONSE_NODE))
                {
                    CharSequenceBuffer csb = (CharSequenceBuffer) cs;

                    // Handle a possible empty XFER response
                    if (csb.length() == 0)
                    {
                        csb.reset();
                    }

                    currentInteraction.setXferResponse(csb);
                }
                else if (qName.equals(CLI_RESPONSE_NODE))
                {
                    CharSequenceBuffer csb = (CharSequenceBuffer) cs;

                    // Handle a possible empty CLI response
                    if (csb.length() == 0)
                    {
                        csb.reset();
                    }

                    currentInteraction.setCliResponse(csb);
                }

                response.reset();
            }
        }

        /* (non-Javadoc)
         * @see org.xml.sax.helpers.DefaultHandler#characters(char[], int, int)
         */
        public void characters(char[] ch, int start, int length) throws SAXException
        {
            if (currentInteraction != null)
            {
                response.write(ch, start, length);
            }
        }

        public Recording getRecording()
        {
            // Check to see if we have rearranged file transfer interactions.
            // The reason this needs to happen is for the fact that a file transfer to our TFTP server
            // needs to happen before any CLI interactions that would have done a file transfer from the
            // real devices.  By rearranging the file transfer interaction to come before the CLI interaction,
            // the file will be properly transfered to the TFTP server.
            if (!rearrangeInteractions)
            {
                List<Interaction> interactions = recording.getInteractions();
                
                for (int i = 0; i < interactions.size(); i++)
                {
                    int oneAhead = i + 1;
                    if (oneAhead < interactions.size())
                    {
                        Interaction nextInteraction = interactions.get(oneAhead);
                        CharSequenceBuffer xferResponse = nextInteraction.getXferResponse();
                        String xferProtocol = nextInteraction.getXferProtocol();
                        String xferFilename = nextInteraction.getXferFilename();
                        if ((xferResponse != null && xferResponse.length() > 0)
                                && (xferProtocol != null && xferProtocol.length() > 0)
                                && (xferFilename != null && xferFilename.length() > 0))
                        {
                            // Swap the next interaction and current one
                            Collections.swap(interactions, i, oneAhead);
                        }
                    }
                }
                
                // Mark that the interactions have been rearranged
                rearrangeInteractions = true;
            }
            
            return recording;
        }
    }

    private static class RecordingEntry
    {
        Lock lock = new ReentrantLock();
        Recording recording;
    }

    //////////////////////////////////////////////////////////
    // Factory method...
    //////////////////////////////////////////////////////////
    private static RecordingLoader instance;

    public synchronized static RecordingLoader getInstance()
    {
        if (instance == null)
        {
            instance = new RecordingLoader();
        }
        return instance;
    }
}
