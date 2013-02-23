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

package org.ziptie.net.sim.telnet;

import java.io.BufferedInputStream;
import java.io.PrintStream;

import junit.framework.TestCase;

import org.apache.commons.net.telnet.TelnetClient;
import org.ziptie.net.sim.DeviceSimulator;
import org.ziptie.net.sim.config.Configuration;
import org.ziptie.net.sim.config.ConfigurationService;
import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.recording.Interaction;
import org.ziptie.net.sim.recording.RecordingLoader;
import org.ziptie.net.sim.recording.RecordingOperation;
import org.ziptie.net.sim.util.CharSequenceBuffer;
import org.ziptie.net.sim.util.IpAddress;
import org.ziptie.net.sim.util.Util;

/**
 * Tests the Simulator's Telnet server
 */
public class TelnetTest extends TestCase
{
    /**
     * Static initializer
     */
    static
    {
        DeviceSimulator.initLogger();
        // Start the telnet server only once

        TelnetServer ts = new TelnetServer();
        ts.start();
    }

    /**
     * 
     * @throws Exception
     */
    public void testTelnet() throws Exception
    {
        /*     Start:
         *   +------------+
         * ,-! Send Input !
         * ! +------------+
         * !     | 
         * ! +------------+
         * ! ! Read Input !------. no
         * ! +------------+       \
         * !yes   |                |
         * ! +------------+ no +------------+ yes +------+
         * `-! IsCorrect? !----! IsTooLong? !-----! FAIL !
         *   +------------+    +------------+     +------+
         * 
         */
        IpAddress local = IpAddress.getIpAddress(Util.getLocalHost(), null);

        TelnetClient client = new TelnetClient();
        client.connect(local.getRealAddress());

        RecordingLoader recordingLoader = RecordingLoader.getInstance();
        Configuration config = ConfigurationService.getInstance().findConfigurationFile(ConfigurationService.DEFAULT_CONFIG);

        WorkingConfig wc = config.getDefaultOperationWorkingConfig();

        // create the operation manually first so that we can easily get the records
        RecordingOperation operation = (RecordingOperation) recordingLoader.createOperation(wc, local, local);
        Interaction[] interactions = operation.getInteractions();
        operation.tearDown();

        BufferedInputStream in = new BufferedInputStream(client.getInputStream());
        PrintStream out = new PrintStream(client.getOutputStream(), true);

        byte[] bbuf = new byte[2048];

        CharSequenceBuffer cbuf = new CharSequenceBuffer();
        for (int i = 0; i < interactions.length; i++)
        {
            Interaction currInteraction = interactions[i];
            
            String proto = currInteraction.getCliProtocol();
            if (!proto.equals("Telnet"))
            {
                /*
                 * Because the recording might have other protocols we should stop when we encounter one.
                 * The recording may not behave properly if we continue as we are.
                 * If we got through at least 10 interactions then this test is probably still valid.
                 */
                assertTrue("At least 10 telnet interction should have been handled.  Maybe this test should be run with another recording.", i > 10);
                System.err.println("Continueing could disrupt the validity of this test.  This test will only support Telnet operations.");
                break;
            }

            // The timeout will be four times the expected time or 4 seconds, whichever is longer.
            Long interactionTime = currInteraction.getEndTime() - currInteraction.getStartTime();
            long time = Math.max((long) (interactionTime * wc.getRateMultiplier()) * 4, 4000);
            long start = System.currentTimeMillis();

            CharSequence input = currInteraction.getCliCommand();
            CharSequence response = currInteraction.getCliResponse();
            if (!input.equals("No input sent") && !input.equals(""))
            {
                out.println(input);
            }

            cbuf.reset();
            while (true)
            {
                int len = 0;
                if (in.available() <= 0)
                {
                    try
                    {
                        Thread.sleep(250);
                    }
                    catch (InterruptedException e)
                    {
                        e.printStackTrace();
                    }
                    if (in.available() <= 0)
                    {
                        if (System.currentTimeMillis() - start > time)
                        {
                            // isTooLong
                            fail("Timeout reached waiting for response for interaction '" + currInteraction.getCliCommand() + "'");
                        }
                        continue;
                    }
                }
                len = in.read(bbuf);
                cbuf.write(bbuf, 0, len);

                // isCorrect?
                if (compare(cbuf, response))
                {
                    break;
                }
                else if (System.currentTimeMillis() - start > time)
                {
                    // isTooLong
                    fail("Timeout reached waiting for response for interaction '" + currInteraction.getCliCommand() + "'");
                }
            }
        }
    }

    private boolean compare(CharSequence one, CharSequence two)
    {
        int len = one.length();
        if (len != two.length())
        {
            return false;
        }

        for (int i = 0; i < len; i++)
        {
            if (one.charAt(i) != two.charAt(i))
            {
                return false;
            }
        }
        return true;
    }
}
