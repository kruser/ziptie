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

import java.io.FileNotFoundException;
import java.net.URISyntaxException;

import junit.framework.TestCase;

import org.ziptie.net.sim.DeviceSimulator;
import org.ziptie.net.sim.config.Configuration;
import org.ziptie.net.sim.config.ConfigurationService;
import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.telnet.TelnetResponse;
import org.ziptie.net.sim.util.IpAddress;
import org.ziptie.net.sim.util.Util;

/**
 * Tests the basic functionality of Recordings
 */
public class RecordingTest extends TestCase
{
    static
    {
        DeviceSimulator.initLogger();
    }

    public void testFindDefaultRecording() throws FileNotFoundException, NoSuchOperationException
    {
        RecordingLoader factory = RecordingLoader.getInstance();
        Configuration config = ConfigurationService.getInstance().findConfigurationFile(ConfigurationService.DEFAULT_CONFIG);

        Recording recording = factory.findRecording(config.getDefaultOperation().getSchemeSpecificPart());
        assertNotNull(recording);
    }

    public void testFindBadRecording()
    {
        RecordingLoader factory = RecordingLoader.getInstance();
        try
        {
            factory.findRecording("blahblahblah.bad.record");
            fail("Should not be able to find this bad recording.");
        }
        catch (NoSuchOperationException e)
        {
        }
    }

    public void testWriteRecording() throws NoSuchOperationException, FileNotFoundException, URISyntaxException
    {
        RecordingLoader factory = RecordingLoader.getInstance();
        Configuration config = ConfigurationService.getInstance().findConfigurationFile(ConfigurationService.DEFAULT_CONFIG);

        Recording recording = factory.findRecording(config.getDefaultOperation().getSchemeSpecificPart());
        assertNotNull(recording);
    }

    public void testRunRecording() throws FileNotFoundException, NoSuchOperationException
    {
        RecordingLoader factory = RecordingLoader.getInstance();
        Configuration config = ConfigurationService.getInstance().findConfigurationFile(ConfigurationService.DEFAULT_CONFIG);
        IpAddress local = IpAddress.getIpAddress(Util.getLocalHost(), "127.0.0.1");

        WorkingConfig wc = config.getDefaultOperationWorkingConfig();

        RecordingOperation operation = (RecordingOperation) factory.createOperation(wc, local, local);

        TelnetResponse tresp = null;//operation.connect();

        Interaction[] interactions = operation.getInteractions();
        for (int i = 0; i < interactions.length; i++)
        {
            Interaction interaction = interactions[i];
            String proto = interaction.getCliProtocol();
            if (!proto.equals("Telnet"))
            {
                continue;
            }

            CharSequence input = interaction.getCliCommand() + "\r\n";
            CharSequence response = interaction.getCliResponse();
            if (operation.shouldProcess(input))
            {
                tresp = operation.processInput(input);
                assertCompare(tresp.getSequence(), response);
            }
        }
    }

    private void assertCompare(CharSequence one, CharSequence two)
    {
        int len = one.length();
        assertEquals("Different lengths", len, two.length());
        for (int i = 0; i < len; i++)
        {
            assertEquals("Different character at index " + i, one.charAt(i), two.charAt(i));
        }
    }
}
