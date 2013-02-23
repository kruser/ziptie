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

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.operations.StateEvent;
import org.ziptie.net.sim.operations.TrivialRequestResponseOperation;
import org.ziptie.net.sim.telnet.TelnetResponse;
import org.ziptie.net.sim.tftp.TftpInterface;
import org.ziptie.net.sim.util.CharSequenceBuffer;
import org.ziptie.net.sim.util.IpAddress;
import org.ziptie.net.sim.util.Util;

/**
 * An operation implementation that supports basic Telnet-Tftp recordings.
 */
public class RecordingOperation extends TrivialRequestResponseOperation
{
    private Interaction[] interactions;
    private int count = 0;
    boolean first = true;
    private int nextTelnetRecord = -1;

    private boolean sendError = false;
    private String[] errors;
    private int errorIndex = 0;

    /** {@link Map}&lt;{@link CharSequence}, {@link RecordEntry}&gt; */
    public Map<CharSequence, InteractionEntry> commandMap;

    /**
     * 
     * @param remoteIp The remote host IP address
     * @param ip The local IP address
     * @param recording The InteractionRecordingSession
     */
    public RecordingOperation(WorkingConfig config, IpAddress remoteIp, IpAddress ip, Recording recording)
    {
        super(config, ip, remoteIp);

        List<Interaction> listOfInteractions = recording.getInteractions();
        interactions = listOfInteractions.toArray(new Interaction[listOfInteractions.size()]);

        commandMap = new HashMap<CharSequence, InteractionEntry>(interactions.length);

        // Replace ips with those for this connection
        for (int i = 0; i < interactions.length; i++)
        {
            interactions[i] = (Interaction) listOfInteractions.get(i).clone();

            // Replace the original device IP in any CLI response with the simulated IP
            CharSequence strCliResponse = interactions[i].getCliResponse();
            strCliResponse = Util.replaceLiteral(strCliResponse, recording.getDeviceIP(), getLocalIp().getIp());

            // Replace the original TFTP server IP in any CLI response with the remote IP, assuming the TFTP server
            // is located on it
            String recordedTftpServerIp = recording.getTftpServerIP();
            if (recordedTftpServerIp != null && !recording.getTftpServerIP().equals(""))
            {
                strCliResponse = Util.replaceLiteral(strCliResponse, recording.getTftpServerIP(), getRemoteIp().getIp());
            }

            // Save the modified response
            interactions[i].setCliResponse((CharSequenceBuffer) strCliResponse);

            // Replace the original IP in any CLI command to be the simulated IP
            CharSequence strCliCommand = interactions[i].getCliCommand();
            strCliCommand = Util.replaceLiteral(strCliCommand, recording.getDeviceIP(), getLocalIp().getIp());

            // Replace the original TFTP server IP in any CLI command with the remote IP, assuming the TFTP server
            // is located on it
            if (recordedTftpServerIp != null && !recording.getTftpServerIP().equals(""))
            {
                strCliCommand = Util.replaceLiteral(strCliCommand, recording.getTftpServerIP(), getRemoteIp().getIp());
            }
            
            // Save the modified command
            interactions[i].setCliCommand((CharSequenceBuffer) strCliCommand);

            // Replace the original device IP with the simulated IP for the file name of any file that was transfered
            String xferFilename = interactions[i].getXferFilename();
            CharSequenceBuffer csFilename = new CharSequenceBuffer();
            csFilename.append(xferFilename);
            csFilename = (CharSequenceBuffer) Util.replaceLiteral(csFilename, recording.getDeviceIP(), getLocalIp().getIp());
            interactions[i].setXferFilename(csFilename.toString());

            commandMap.put(interactions[i].getCliCommand(), new InteractionEntry(i, interactions[i]));
        }

        // TODO dwhite: The recording does not store the error forms
        //errors = recording.getErrorRegExs();
        if (errors == null || errors.length == 0)
        {
            errors = new String[] { ">>>>>>> ERROR: UNRECOGNIZED COMMAND!" };
        }
        for (int i = 0; i < errors.length; i++)
        {
            errors[i] = errors[i] + "\r\n" + recording.getDevicePrompt();
        }
    }

    public TelnetResponse connect()
    {
        for (int i = count; i < interactions.length; i++)
        {
            String cliProtocol = interactions[i].getCliProtocol();
            if (cliProtocol != null && cliProtocol.length() > 0)
            {
                CharSequence strResponse = interactions[i].getCliResponse();
                Long interactionTime = interactions[i].getEndTime() - interactions[i].getStartTime();
                long time = (long) ((double) interactionTime * (double) getWorkingConfig().getRateMultiplier());
                count = i + 1;
                nextTelnetRecord = -1;
                return new TelnetResponse(strResponse, time);
            }

        }
        sendEvent(new StateEvent(this, StateEvent.INFO, "No response for connect!"));
        return null;
    }

    public boolean shouldProcess(CharSequence input)
    {
        if (nextTelnetRecord < 0)
        {
            if (nextTelnetRecord == -2)
            {
                return false;
            }

            for (int i = count; i < interactions.length; i++)
            {
                if (interactions[i].getCliProtocol().equalsIgnoreCase("telnet"))
                {
                    nextTelnetRecord = i;
                    break;
                }
            }

            if (nextTelnetRecord == -1)
            {
                nextTelnetRecord = -2;
                sendEvent(new StateEvent(this, StateEvent.INFO, "No more telnet records available."));
                return false;
            }
        }

        // if respondOnlyOnNewline is set then cut out if the input does not end in an <LF>
        if (getWorkingConfig().isRespondOnlyOnNewline() && !Util.reverseEndsWith(input, "\n"))
        {
            return false;
        }

        InteractionEntry entry = null;
        CharSequence recordInput = interactions[nextTelnetRecord].getCliCommand();

        // Handle input sent as bytes and check to see if it matches a particular response
        if (interactions[nextTelnetRecord].getAsBytesFlag())
        {
            // Retrieve the first byte in the input character sequence.  This is assumed to
            // the byte that was sent
            char retrievedChar = input.charAt(0);

            // Get the ASCII value of the recorded input.  This should be the hexadecimal value
            // of the byte the was sent
            int recordInputASCIIValue = Integer.parseInt(recordInput.toString(), 16);

            // Check to see if the received input and the recorded input are the same.
            if (retrievedChar == recordInputASCIIValue)
            {
                return true;
            }
        }

        if (Util.indexOf(input, recordInput) != -1)
        {
            return true;
        }

        if (Util.reverseEndsWith(input, "\n"))
        {
            if (Util.reverseEndsWith(input, "\r\n"))
            {
                if (input.length() == 2)
                {
                    sendError = true;
                    return true;
                }
                input = input.subSequence(0, input.length() - 2);
            }
            else
            {
                if (input.length() == 1)
                {
                    return false;
                }
                input = input.subSequence(0, input.length() - 1);
            }

            if ((entry = commandMap.get(input)) != null)
            {
                count = entry.index;
                return true;
            }
            sendError = true;
            return true;
        }
        return false;
    }

    public TelnetResponse processInput(CharSequence input)
    {
        TelnetResponse response = null;

        sendEvent(new StateEvent(this, StateEvent.INPUT, input));
        if (sendError)
        {
            sendError = false;
            if (errorIndex < errors.length)
            {
                response = new TelnetResponse(errors[errorIndex], 250);
                errorIndex++;
            }
            else
            {
                response = new TelnetResponse(errors[0], 250);
                errorIndex = 1;
            }

            sendEvent(new StateEvent(this, StateEvent.OUTPUT, response.getSequence()));
            return response;
        }

        nextTelnetRecord = -1;

        while (count < interactions.length)
        {
            Interaction interaction = interactions[count];
            count++;
            if (count < interactions.length)
            {
                // Look ahead one interaction and see if it is a TFTP file transfer interaction
                Interaction nextInteraction = interactions[count];
                CharSequenceBuffer xferResponse = nextInteraction.getXferResponse();
                String xferProtocol = nextInteraction.getXferProtocol();
                String xferFilename = nextInteraction.getXferFilename();
                if ((xferResponse != null && xferResponse.length() > 0)
                        && (xferProtocol != null && xferProtocol.length() > 0 && xferProtocol.equalsIgnoreCase("TFTP"))
                        && (xferFilename != null && xferFilename.length() > 0))
                {
                    if (nextInteraction.getXferAsServer())
                    {
                        InputStream tftpFile = null;
                        try
                        {
                            sendEvent(new StateEvent(this, StateEvent.INFO, "Puting the file " + xferFilename + " to tftp server at " + getRemoteIp()));
                            tftpFile = new ByteArrayInputStream(xferResponse.toString().getBytes());
                            TftpInterface.getInstance().sendFile(getLocalIp(), getRemoteIp(), xferFilename, tftpFile);
                        }
                        catch (Throwable e)
                        {
                            sendEvent(new StateEvent(this, StateEvent.ERROR, "Could not TFTP file: " + xferFilename, e));
                        }
                        finally
                        {
                            if (tftpFile != null)
                            {
                                try
                                {
                                    tftpFile.close();
                                }
                                catch (IOException e)
                                {
                                    // who cares
                                }
                                tftpFile = null;
                            }
                        }
                    }
                }
            }

            // Handle input sent as bytes and check to see if it matches a particular response
            boolean doBytesMatch = false;
            if (interaction.getAsBytesFlag())
            {
                // Retrieve the first byte in the input character sequence.  This is assumed to
                // the byte that was sent
                char retrievedChar = input.charAt(0);

                // Get the ASCII value of the recorded input.  This should be the hexadecimal value
                // of the byte the was sent
                int recordInputASCIIValue = Integer.parseInt(interaction.getCliCommand().toString(), 16);

                // Check to see if the received input and the recorded input are the same.
                if (retrievedChar == recordInputASCIIValue)
                {
                    doBytesMatch = true;
                }
            }

            if (first || Util.indexOf(input, interaction.getCliCommand()) != -1 || doBytesMatch)
            {
                CharSequenceBuffer strResponse = interaction.getCliResponse();
                sendEvent(new StateEvent(this, StateEvent.INFO, "Interaction : '" + interaction.getCliCommand() + "'"));
                long responseTime = interaction.getEndTime() - interaction.getStartTime();

                // Continue to send empty interactions that proceed this interaction.  An interaction is only empty if there is an empty
                // CLI command AND response.
                while (count < interactions.length
                        && ((interactions[count].getCliCommand().equals("No input sent") || interactions[count].getCliCommand().equals("")))
                        && (interactions[count].getCliResponse().equals("")))
                {
                    sendEvent(new StateEvent(this, StateEvent.INFO, "Interaction : '" + interactions[count].getCliCommand() + "'"));
                    strResponse.append(interactions[count].getCliResponse());
                    count++;
                    long elapsedTime = interactions[count].getEndTime() - interactions[count].getStartTime();
                    responseTime += elapsedTime;
                }
                responseTime *= getWorkingConfig().getRateMultiplier();

                response = new TelnetResponse(strResponse, responseTime);

                break;
            }
            sendEvent(new StateEvent(this, StateEvent.INFO, "Skipping interaction : '" + interaction.getCliCommand() + "'"));
        }

        first = false;

        if (response == null)
        {
            sendEvent(new StateEvent(this, StateEvent.INFO, "No response for given input!"));
            return null;
        }

        sendEvent(new StateEvent(this, StateEvent.OUTPUT, response.getSequence()));

        return response;
    }

    /**
     * Returns the array of records. This should only be used for testing purposes.
     * These records are different that that of the recording file because these have had the ips replaced.
     */
    public Interaction[] getInteractions()
    {
        return interactions;
    }

    private class InteractionEntry
    {
        int index;
        Interaction interaction;

        InteractionEntry(int index, Interaction interaction)
        {
            this.index = index;
            this.interaction = interaction;
        }
    }
}
