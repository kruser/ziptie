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
 * Implements the basic functionality of an IIpMapping.
 */
public abstract class AbstractIpMapping implements IIpMapping
{
    private URI operation;
    private float rate;
    private Boolean respondOnlyOnNewline;
    private Boolean doEcho;

    /**
     * @param operation The operation to set.
     */
    public void setOperation(URI operation)
    {
        this.operation = operation;
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.config.IIpMapping#getOperation()
     */
    public URI getOperation()
    {
        return operation;
    }

    /**
     * 
     */
    public void setRateMultiplier(float rate)
    {
        this.rate = rate;
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.config.IIpMapping#getRateMultiplier()
     */
    public float getRateMultiplier()
    {
        return rate;
    }

    public Boolean isRespondOnlyOnNewline()
    {
        return respondOnlyOnNewline;
    }

    public void setRespondOnlyOnNewline(Boolean respondOnlyOnNewline)
    {
        this.respondOnlyOnNewline = respondOnlyOnNewline;
    }

    public Boolean isDoEcho()
    {
        return doEcho;
    }

    public void setDoEcho(Boolean doEcho)
    {
        this.doEcho = doEcho;
    }
}
