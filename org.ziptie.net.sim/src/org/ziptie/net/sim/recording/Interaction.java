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

import org.ziptie.net.sim.util.CharSequenceBuffer;

public class Interaction implements Cloneable
{
    private boolean asBytes;
    private CharSequenceBuffer cliCommand;
    private String cliProtocol;
    private CharSequenceBuffer cliResponse;
    private Long startTime;
    private Long endTime;
    private int timeout;
    private String waitFor;
    private String xferProtocol;
    private String xferFilename;
    private CharSequenceBuffer xferResponse;
    private boolean  xferAsServer;

    protected Interaction()
    {
        asBytes = false;
        cliProtocol = "";
        waitFor = "";
        xferProtocol = "";
        xferAsServer = false;
    }

    public boolean getAsBytesFlag()
    {
        return asBytes;
    }

    protected void setAsBytesFlag(boolean asBytesFlag)
    {
        asBytes = asBytesFlag;
    }

    public CharSequenceBuffer getCliCommand()
    {
        return cliCommand;
    }

    protected void setCliCommand(CharSequenceBuffer input)
    {
        cliCommand = input;
    }

    public String getCliProtocol()
    {
        return cliProtocol;
    }

    protected void setCliProtocol(String protocolName)
    {
        cliProtocol = protocolName;
    }

    public CharSequenceBuffer getCliResponse()
    {
        return cliResponse;
    }

    protected void setCliResponse(CharSequenceBuffer response)
    {
        cliResponse = response;
    }

    public Long getStartTime()
    {
        return startTime;
    }

    protected void setStartTime(Long start)
    {
        startTime = start;
    }

    public Long getEndTime()
    {
        return endTime;
    }

    protected void setEndTime(Long end)
    {
        endTime = end;
    }

    public int getTimeout()
    {
        return timeout;
    }

    protected void setTimeout(int newTimeout)
    {
        timeout = newTimeout;
    }

    public String getWaitFor()
    {
        return waitFor;
    }

    protected void setWaitFor(String waitForRegEx)
    {
        waitFor = waitForRegEx;
    }

    public String getXferProtocol()
    {
        return xferProtocol;
    }

    protected void setXferProtocol(String protocolName)
    {
        xferProtocol = protocolName;
    }

    public CharSequenceBuffer getXferResponse()
    {
        return xferResponse;
    }

    protected void setXferResponse(CharSequenceBuffer response)
    {
        xferResponse = response;
    }
    
    public boolean getXferAsServer()
    {
        return xferAsServer;
    }
    
    protected void setXferAsServer(boolean xferAsServerFlag)
    {
        xferAsServer = xferAsServerFlag;
    }

    /**
     *  Returns a new Object by making a shallow copy of this one.
     */
    public Object clone()
    {
        try
        {
            return super.clone();
        }
        catch (CloneNotSupportedException e)
        {
            // This should not happen since this Class implements Cloneable.
            throw (new RuntimeException(e.toString()));
        }
    }

    public String toString()
    {
        return "input='" + getCliCommand() + "'";
    }

    public String getXferFilename()
    {
        return xferFilename;
    }

    protected void setXferFilename(String xferFilename)
    {
        this.xferFilename = xferFilename;
    }
}
