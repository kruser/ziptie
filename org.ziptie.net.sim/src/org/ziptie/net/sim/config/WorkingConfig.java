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

import java.net.URI;

/**
 * A working config contains configuration data that applies to a specific operation.
 * Operation may only interact with this class, the Configuration should be hidden to them.
 * The implementation of the operation is expected to honor all these values.
 */
public class WorkingConfig implements Cloneable
{
    private URI operationUri;
    private float rateMultiplier;
    private long maxBufferLength;
    /** The operation timeout in minutes */
    private int operationTimeout;
    private boolean respondOnlyOnNewline;
    private boolean doEcho;
    private boolean mapIp;

    public URI getOperationUri()
    {
        return operationUri;
    }

    public void setOperationUri(URI operationUri)
    {
        this.operationUri = operationUri;
    }

    public long getMaxBufferLength()
    {
        return maxBufferLength;
    }

    public void setMaxBufferLength(long maxBufferLength)
    {
        this.maxBufferLength = maxBufferLength;
    }

    /**
     * @return The operation timeout in minutes.
     */
    public int getOperationTimeout()
    {
        return operationTimeout;
    }

    /**
     * Sets the operation timeout in minutes.
     * @param operationTimeout Timeout in minutes.
     */
    public void setOperationTimeout(int operationTimeout)
    {
        this.operationTimeout = operationTimeout;
    }

    public float getRateMultiplier()
    {
        return rateMultiplier;
    }

    public void setRateMultiplier(float rateMultiplier)
    {
        this.rateMultiplier = rateMultiplier;
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

    public WorkingConfig copy()
    {
        try
        {
            return (WorkingConfig) clone();
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
