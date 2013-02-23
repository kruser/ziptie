/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/08/27 14:26:29 $
 * $Revision: 1.5 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/IInventoryCallbacks.java,v $e
 */

package org.ziptie.discovery;

import java.net.UnknownHostException;

import org.ziptie.addressing.IPAddress;

/**
 * Allows for the customization of the credentials used by the
 * {@link DiscoveryEngine}. <br>
 * <br>
 * The credential names used are:<br>
 * <li>username - the username to login to a device (ssh or telnet)
 * <li>password - the password to login to a device (ssh or telnet)
 * <li>getCommunity - the SNMP community string used for SNMP gets or walks
 * 
 * @author rkruse
 */
public interface IInventoryCallbacks
{
    /**
     * The implementor of this method should return the preferred
     * {@link IPAddress} of the given IP. This will cause the
     * <code>DiscoverDevice</code> process to not use its own algorithm to
     * determine the administrative IP of the device just learned about. <br>
     * <br>
     * 
     * @param ipAddress an IP address
     * @return never should return null. Throw the exception if it isn't in the
     *         inventory
     * @throws UnknownHostException - if the host isn't known to the inventory
     *             source
     */
    IPAddress getPreferredIpAddress(IPAddress ipAddress) throws UnknownHostException;

    /**
     * Tells the DiscoveryEngine how it should get a {@link DiscoveryEvent} from a host.
     * An implementation of this method should communicate with the device via any desired means
     * to create the necessary {@link DiscoveryEvent}.
     * 
     * @param discoveryHost the host to target
     * @param runTelemetry if set to true, the implementation should run the extended telemetry operation.  If false,
     *  the implementation is only responsible for retrieving top level system information.
     * @return the filled out DiscoveryEvent
     */
    public DiscoveryEvent discoveryMethod(DiscoveryHost discoveryHost, boolean runTelemetry);
}
