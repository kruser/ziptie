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
package org.ziptie.provider.telemetry;

import org.ziptie.addressing.NetworkAddressElf;

/**
 * Neighbor
 */
public class Neighbor
{
    private String protocol;
    private String ipAddress;
    private String localInterface;
    private String remoteInterface;
    private String otherId;
    /**
     * @return the protocol
     */
    public String getProtocol()
    {
        return protocol;
    }
    /**
     * @param protocol the protocol to set
     */
    public void setProtocol(String protocol)
    {
        this.protocol = protocol;
    }
    /**
     * @return the ipAddress
     */
    public String getIpAddress()
    {
        if (ipAddress != null)
        {
            return NetworkAddressElf.fromDatabaseString(ipAddress); 
        }
        else
        {
           return ""; 
        }
    }
    /**
     * @param ipAddress the ipAddress to set
     */
    public void setIpAddress(String ipAddress)
    {
        this.ipAddress = ipAddress;
    }
    /**
     * @return the localInterface
     */
    public String getLocalInterface()
    {
        return localInterface;
    }
    /**
     * @param localInterface the localInterface to set
     */
    public void setLocalInterface(String localInterface)
    {
        this.localInterface = localInterface;
    }
    /**
     * @return the remoteInterface
     */
    public String getRemoteInterface()
    {
        return remoteInterface;
    }
    /**
     * @param removeInterface the remoteInterface to set
     */
    public void setRemoteInterface(String remoteInterface)
    {
        this.remoteInterface = remoteInterface;
    }
    /**
     * @return the otherId
     */
    public String getOtherId()
    {
        return otherId;
    }
    /**
     * @param otherId the otherId to set
     */
    public void setOtherId(String otherId)
    {
        this.otherId = otherId;
    }

}
