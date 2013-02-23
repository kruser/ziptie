/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/27 14:26:29 $
 * $Revision: 1.5 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/test/org/ziptie/discovery/UnitTestInventoryCallback.java,v $e
 */

package org.ziptie.discovery;

import java.net.UnknownHostException;

import org.ziptie.addressing.IPAddress;

/**
 * returns a simple <code>CredentialSet</code> for every
 * <code>IPAddress</code>.
 * 
 * @author rkruse
 */
public class UnitTestInventoryCallback implements IInventoryCallbacks
{

    /**
     * 
     *
     */
    public UnitTestInventoryCallback()
    {
    }

    /**
     * {@inheritDoc}
     */
    public IPAddress getPreferredIpAddress(IPAddress ipAddress) throws UnknownHostException
    {
        throw new UnknownHostException("UNIT TEST CALLBACK....NO INVENTORY SOURCE");
    }

    /**
     * {@inheritDoc}
     */
    public DiscoveryEvent discoveryMethod(DiscoveryHost discoveryHost, boolean runTelemetry)
    {
        return new DiscoveryEvent(discoveryHost.getIpAddress());
    }

}
