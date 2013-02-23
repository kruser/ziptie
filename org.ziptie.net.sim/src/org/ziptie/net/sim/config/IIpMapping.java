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
import java.util.Iterator;

/**
 * Interface which defines a set of IP addresses.
 */
public interface IIpMapping
{
    /**
     * @param ip The IpAddress
     * @return <code>true</code> if this mapping includes <code>ip</code>, <code>false</code> otherwise.
     */
    public boolean contains(IpAddressMapping ip);

    /**
     * @return An iterator which iterates over all IPs in this mapping
     */
    public Iterator iterator();

    /**
     * Returns the URI to use for the operation associated with this mapping.
     */
    public URI getOperation();

    /**
     * Returns the rate multiplier to use for operations associated with this mapping.
     */
    public float getRateMultiplier();

    /**
     * Returns whether or not operations using this mapping should only respond after newlines.
     */
    public Boolean isRespondOnlyOnNewline();

    /**
     * Returns whether or not operations using this mapping should echo input.  (ie: Telnet WILL ECHO)
     */
    public Boolean isDoEcho();
}
