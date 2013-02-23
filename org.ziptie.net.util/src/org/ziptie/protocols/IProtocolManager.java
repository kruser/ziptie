/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/04/11 19:13:45 $
 * $Revision: 1.5 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net.util/src/org/ziptie/protocols/IProtocolManager.java,v $e
 */

package org.ziptie.protocols;

import java.util.List;
import java.util.Set;

import org.ziptie.addressing.AddressSet;
import org.ziptie.addressing.IPAddress;
import org.ziptie.security.PermissionDeniedException;

/**
 * Keeps track of <code>ProtocolConfig</code> for specific devices, for devices as members of an
 * <code>AddressSet</code> or simply the default <code>ProtocolConfig</code>
 * 
 * @author rkruse
 */
public interface IProtocolManager
{
    public static final String SERVICE_NAME = "ProtocolManager";

    /**
     * Returns the default <code>ProtocolConfigTO</code>. The default is the last one checked if there is no device
     * specific config or any config that matches the <code>IPAddress</code>
     * 
     * @return
     * @throws PermissionDeniedException 
     */
    public ProtocolConfig getDefaultProtocolConfig() throws PermissionDeniedException;

    /**
     * Set the default config
     * 
     * @param protocolConfigTO
     * @throws PermissionDeniedException 
     */
    public void saveDefaultProtocolConfig(ProtocolConfig protocolConfigTO) throws PermissionDeniedException;

    /**
     * Returns an ordered Set of all <code>ProtocolConfig</code>
     * 
     * @return
     * @throws PermissionDeniedException 
     */
    public Set<ProtocolConfig> getAllProtocolConfig() throws PermissionDeniedException;

    /**
     * Returns the protocol details for the given address. It will try to determine if the address is already in the
     * inventory, if not it will simply look up the protocol details by the address alone.
     * 
     * @param deviceIPAddress
     * @return
     * @throws PermissionDeniedException 
     */
    public ProtocolConfig getProtocolConfig(IPAddress deviceIPAddress) throws PermissionDeniedException;

    /**
     * Returns a full protocol set with all protocols but in the default order of preference. This can be useful for a
     * UI to create a screen of all the protocol sets.
     * 
     * @return
     */
    public ProtocolConfig getNewFullProtocolConfig();

    /**
     * Defines a ProcotolConfig by a set of IP addresses.
     * 
     * @param configByAddr
     * @param addrSet
     * @throws PermissionDeniedException 
     */
    public void saveProtocolConfig(ProtocolConfig configByAddr, AddressSet addrSet) throws PermissionDeniedException;

    /**
     * Returns a <code>ProtocolConfig</code> with the same content as the default but resets the ID so it can be saved
     * as a new config. A UI should offer this copy up when a user wants to create a new <code>ProtocolConfig</code>
     * based on their preferences.
     * 
     * @return
     * @throws PermissionDeniedException 
     */
    public ProtocolConfig getCopyOfDefaultProtocolConfig() throws PermissionDeniedException;

    /**
     * Given an array of allowed protocol names from an adapter, this method will use the stored ProtocolConfigs to
     * return a list of the peferred protocol sets. If there isn't already a known working set of protocols for the
     * given IP address then the ProtocolManager will do a quick port scan of the possible TCP ports listed in order to
     * only return the working possibilities.
     * 
     * @param protocolSetNames - these should be the names as listed in the adapter. e.g 'Telnet-TFTP'.
     * @param address
     * @return
     * @throws PermissionDeniedException 
     */
    public ProtocolSet[] calculateProtocolSets(List<String> protocolSetNames, IPAddress address) throws PermissionDeniedException;

    /**
     * If a user realizes a certain ProtocolSet is working for a particular device it should be reported here along with
     * the ID of the ProtocolConfig. This will ensure maximum efficiency in that the ProtocolManager will use this data
     * the next time it is asked for a protocol set.
     * 
     * For example, if the ProtocolManager is being used in conjunction with backups, after a successful backup of a
     * device, the backup process should report the working protocol set here.
     * 
     * @param ip
     * @param protocols
     * @throws PermissionDeniedException 
     */
    public void saveWorkingProtocols(IPAddress ip, ProtocolSet protocols) throws PermissionDeniedException;

    /**
     * Clear out any working protocols for a given IPAddress.
     * 
     * @param address
     * @throws PermissionDeniedException 
     */
    public void clearWorkingProtocols(IPAddress address) throws PermissionDeniedException;

    /**
     * Clear out any saved working protocols based on the ID of the parent ProtocolConfig. This can be used to clear out
     * any saved protocols in the event that the parent ProtocolConfig has been updated or removed.
     * 
     * @param protocolConfigID
     * @throws PermissionDeniedException 
     */
    public void clearWorkingProtocols(long protocolConfigID) throws PermissionDeniedException;

    /**
     * If true, the ProtocolManager will do open up a TCP port before deciding if it is allowed for a given IP address.
     * 
     * @return the doTCPScan
     */
    public boolean isDoTCPScan();

    /**
     * If true, the ProtocolManager will do open up a TCP port before deciding if it is allowed for a given IP address.
     * 
     * @param doTCPScan the doTCPScan to set
     */
    public void setDoTCPScan(boolean doTCPScan);
}
