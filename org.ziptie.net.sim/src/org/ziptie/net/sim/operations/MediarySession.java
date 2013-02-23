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

package org.ziptie.net.sim.operations;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;

import org.ziptie.net.sim.config.Configuration;
import org.ziptie.net.sim.config.ConfigurationService;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.util.CharSequenceBuffer;
import org.ziptie.net.sim.util.CharSequenceInputStream;
import org.ziptie.net.sim.util.IpAddress;
import org.ziptie.net.sim.util.Util;

/**
 * Delegates the creation of an IOperation to after the first input.
 */
public class MediarySession
{
    private IpAddress remoteIp;
    private IpAddress localIp;
    private CharSequenceBuffer inputBuffer;
    private InputStream configStream;

    /**
     * @param localIp
     * @param remoteIp
     */
    public MediarySession(IpAddress localIp, IpAddress remoteIp)
    {
        this.localIp = localIp;
        this.remoteIp = remoteIp;
        this.inputBuffer = new CharSequenceBuffer();
    }

    public boolean append(byte[] data) throws IOException
    {
        inputBuffer.write(data);

        int index = Util.indexOf(inputBuffer, "</sim-config>");
        if (index < 0)
        {
            return false;
        }

        configStream = new CharSequenceInputStream(inputBuffer, 0, index + "</sim-config>".length());

        return true;
    }

    public IOperation getOperation() throws NoSuchOperationException, IOException
    {
        if (configStream == null)
        {
            throw new NoSuchOperationException("Config string not yet met.");
        }

        ConfigurationService service = ConfigurationService.getInstance();

        Configuration parent = service.findConfiguration(remoteIp.getIp());
        Configuration config = service.loadConfiguration(parent, configStream);

        String deviceIp = config.getDeviceIp();
        String daIp = config.getDaIp();

        if (daIp != null)
        {
            remoteIp = new IpAddress(InetAddress.getByName(daIp));
        }
        else if (remoteIp.getIp().startsWith("127."))
        {
            remoteIp = new IpAddress(Util.getLocalHost());
        }

        if (deviceIp != null)
        {
            localIp = new IpAddress(Util.getLocalHost(), deviceIp);
        }
        else
        {
            localIp = new IpAddress(Util.getLocalHost(), localIp.getIp());
        }
        return OperationManager.getInstance().getCurrentOperation(config, localIp, remoteIp);
    }
}
