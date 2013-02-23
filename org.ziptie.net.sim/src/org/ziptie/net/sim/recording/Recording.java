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

import java.util.ArrayList;
import java.util.List;

public class Recording
{
    private String ipAddress;
    private String tftpServerAddress;
    private String operationName;
    private String adapterId;
    private String devicePrompt;
    private List<Interaction> interactions;

    public Recording()
    {
        ipAddress = "";
        tftpServerAddress = "";
        operationName = "";
        adapterId = "";
        devicePrompt = "";
        interactions = new ArrayList<Interaction>();
    }

    public void addInteraction(Interaction ir)
    {
        interactions.add(ir);
    }

    public List<Interaction> getInteractions()
    {
        return interactions;
    }

    protected void deleteInteractions()
    {
        interactions.clear();
    }

    public String getAdapterId()
    {
        return adapterId;
    }

    protected void setAdapterId(String adapterId)
    {
        this.adapterId = adapterId;
    }
    
    public String getOperationName()
    {
        return operationName;
    }

    protected void setOperationName(String operation)
    {
        operationName = operation;
    }
    
    public String getDeviceIP()
    {
        return ipAddress;
    }

    protected void setDeviceIP(String deviceIP)
    {
        ipAddress = deviceIP;
    }
    
    public String getTftpServerIP()
    {
        return tftpServerAddress;
    }

    protected void setTftpServerIP(String tftpServerIP)
    {
        tftpServerAddress = tftpServerIP;
    }

    public String getDevicePrompt()
    {
        return devicePrompt;
    }
    
    protected void setDevicePrompt(String newDevicePrompt)
    {
        devicePrompt = newDevicePrompt;
    }

}
