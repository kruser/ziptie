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
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.provider.credentials;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import org.ziptie.addressing.IPAddress;
import org.ziptie.exception.PersistenceException;
import org.ziptie.net.utils.PortScan;
import org.ziptie.protocols.AbstractProtocolManager;
import org.ziptie.protocols.IProtocolPersister;
import org.ziptie.protocols.NoEnabledProtocolsException;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolConfig;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.credentials.internal.CredentialsProviderActivator;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.security.ISecurityCheck;
import org.ziptie.security.NoSecurityCheck;
import org.ziptie.security.PermissionDeniedException;

/**
 * The {@link ZipTieProtocolManager} class extends the functionality laid down by the {@link ZipTieProtocolManager} class and provides
 * it as a singleton instance.  It also leverages the Device provider to provide device ID to device resolution so that an IP address and
 * managed network associated with the device can be retrieved and used to determine which protocols should be used.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 * @author rkruse
 */
public class ZipTieProtocolManager extends AbstractProtocolManager
{
    private static final String ERROR_NOT_INITIALIZED = "The ZipTieProtocolManager has not yet been initialized!"; //$NON-NLS-1$

    private static ZipTieProtocolManager instance;
    private static Object staticMutex = new Object();

    /**
     * Private default constructor for the {@link ZipTieProtocolManager} class to ensure that there is no way to create an instance externally.
     */
    private ZipTieProtocolManager()
    {
        // Do nothing.
    }

    /**
     * Retrieves a singleton instance of the {@link ZipTieProtocolManager} class.  The {@link ZipTieProtocolManager} must be initialized first
     * by using one of the {@link startup} methods.  A {@link RuntimeException} is thrown if the ZipTieProtocolManager singleton hasn't been initialized
     * yet.
     *
     * @return The singleton instance of the {@link ZipTieProtocolManager} class.
     */
    public static ZipTieProtocolManager getInstance()
    {
        synchronized (staticMutex)
        {
            if (instance == null)
            {
                throw new RuntimeException(ERROR_NOT_INITIALIZED);
            }
            return instance;
        }
    }

    /**
     * Creates an instance of the {@link ZipTieProtocolManager} class but allows you to set some
     * of the other services that require persistence. This allows for easy stub work while testing.
     * 
     * @param persister An implementation of the {@link IProtocolPersister} interface.
     * @return The singleton instance of the {@link ZipTieProtocolManager} class.
     */
    public static ZipTieProtocolManager startup(IProtocolPersister persister)
    {
        return startup(persister, new NoSecurityCheck());
    }

    /**
     * Creates an instance of the {@link ZipTieProtocolManager} class but allows you to set some
     * of the other services that require persistence. This allows for easy stub work while testing.
     * 
     * @param persister An implementation of the {@link IProtocolPersister} interface.
     * @param securityCheck An implementation of the {@link ISecurityCheck} interface.
     * @return The singleton instance of the {@link ZipTieProtocolManager} class.
     */
    public static ZipTieProtocolManager startup(IProtocolPersister persister, ISecurityCheck securityCheck)
    {
        instance = new ZipTieProtocolManager();
        instance.init(persister, securityCheck);
        return instance;
    }

    /**
     * Initializes the {@link ZipTieProtocolManager} class by ensuring that a default {@link ProtocolConfig} object is setup and
     * persisted.
     * 
     * @param persister The implementation of the {@link IProtocolPersister} interface to use for persistence.
     * @param securityCheck The implementation of the {@link ISecurityCheck} interface to use for security checks.
     */
    private void init(IProtocolPersister persister, ISecurityCheck securityCheck)
    {
        String errorMessage = "Error setting the ProtocolManager's default protocols during startup.";
        synchronized (staticMutex)
        {
            setPersister(persister);
            setSecurityCheck(securityCheck);

            // Load up the default config if there isn't one set
            try
            {
                if (persister.getDefaultProtocolConfig() == null)
                {
                    ProtocolConfig newDefault = getNewFullProtocolConfig();
                    newDefault.setName("Default");
                    saveDefaultProtocolConfig(newDefault);
                }
            }
            catch (PersistenceException e)
            {
                throw new RuntimeException(errorMessage, e);
            }
            catch (PermissionDeniedException e)
            {
                throw new RuntimeException(errorMessage, e);
            }
        }
    }

    /** {@inheritDoc} */
    @Override
    public List<ProtocolSet> calculateSupportedProtocolSets(List<ProtocolSet> protocolSetsFromAdapter, String deviceID, boolean includeStaleProtocols)
            throws PersistenceException, NoEnabledProtocolsException
    {
        List<String> protocolNames = new LinkedList<String>();
        for (ProtocolSet ps : protocolSetsFromAdapter)
        {
            protocolNames.add(ps.getName());
        }
        return calculateProtocolSets(protocolNames, deviceID, includeStaleProtocols);
    }

    /**
     * Calculates which protocol sets are actually supported for use against a device associated with the specified
     * device ID.  This is achieved by checking if the ports for all the protocols from a protocol set are open and ready for use on the device
     * specified by the ID.  This method is most commonly used when checking to see which of the protocol sets that have been specified
     * on a device adapter is the preferred set.  If a single protocol set have already been mapped for use with the device associated with the
     * specified ID, then this method will not check any open ports and will return a {@link List} containing the single protocol set.
     * 
     * @param protocolSets A {@link List} of strings that represent the various protocol sets to test to see if they are supported for use with the
     * device that is associated with the specified device ID.
     * @param deviceID The ID of the device to use when testing to see which protocol sets are supported.
     * @param includeStaleProtocols Flag to determine whether or not to include protocols that have been marked stale.
     * @return A {@link List} of all {@link ProtocolSet} objects that have been determined to be supported against the device associated with the
     * specified device ID.
     * @throws PersistenceException if the data store throws an error.
     * @throws NoEnabledProtocolsException if there are no protocols enable on the device.
     */
    List<ProtocolSet> calculateProtocolSets(List<String> protocolSets, String deviceID, boolean includeStaleProtocols) throws PersistenceException,
            NoEnabledProtocolsException
    {
        ProtocolSet workingProtocolSet = getPersister().getProtocolSetByDeviceID(deviceID, includeStaleProtocols);
        if (workingProtocolSet != null)
        {
            List<ProtocolSet> toReturn = new ArrayList<ProtocolSet>(1);
            toReturn.add(0, workingProtocolSet);
            return toReturn;
        }
        else
        {
            // Use the device provider to retrieve the device and to retrieve the IP address of the device.
            ZDeviceCore device = CredentialsProviderActivator.getDeviceProvider().getDevice(Integer.parseInt(deviceID));
            IPAddress ipAddress = device != null ? new IPAddress(device.getIpAddress()) : new IPAddress();

            ProtocolConfig config = getProtocolConfigByIpAddress(ipAddress);
            List<Integer> openPorts = findOpenPorts(config, protocolSets, ipAddress);
            Map<Double, ProtocolSet> toReturn = new TreeMap<Double, ProtocolSet>();
            for (String ps : protocolSets)
            {
                reconcileEnabledAndOpenPorts(ps, config, toReturn, openPorts);
            }
            List<ProtocolSet> protocolSetList = new ArrayList<ProtocolSet>(toReturn.values());
            if (protocolSetList.size() == 0)
            {
                throw new NoEnabledProtocolsException("The necessary protocols for " + ipAddress + " are either disabled or unreachable.");
            }
            return protocolSetList;
        }
    }

    /**
     * Attempts to scan every protocol port value that is specified within the defined {@link ProtocolConfig} to see which ports are open.
     * A {@list List} of integers is returned that represents each port that was open.
     * 
     * @param protocolConfig The protocol configuration that contains all of the protocols that will have their port values scanned to see if
     * they are open.
     * @param protocolSets A list of strings that define a protocol set.  Protocol set is a set of protocol names that are delimited by a
     * hyphen.
     * @param ipAddress The IP address of the device that will have it's ports scanned.
     * @return A list of all the ports that were open.
     */
    private List<Integer> findOpenPorts(ProtocolConfig protocolConfig, List<String> protocolSets, IPAddress ipAddress)
    {
        if (isDoTCPScan())
        {
            Set<Integer> portsToScan = new HashSet<Integer>();
            for (Protocol protocol : protocolConfig.getProtocols())
            {
                if (protocol.isTCP() && protocol.isEnabled())
                {
                    for (String protocolSet : protocolSets)
                    {
                        if (protocolSet.contains(protocol.getName()))
                        {
                            portsToScan.add(Integer.valueOf(protocol.getPort()));
                            break;
                        }
                    }
                }
            }
            return PortScan.getInstance().scan(ipAddress, portsToScan);
        }
        return new ArrayList<Integer>();
    }

    /**
     * Determines which protocols that were determined as being open by a port scanned are actually enabled for use by ZipTie and
     * maps a priority value to the reconciled protocol set.
     * 
     * @param protocolSetString A string representing the protocol set to examine.
     * @param protocolConfig The protocol configuration that contains the protocol set being examined.
     * @param protocolTracker A map containing priority values as the keys and protocol set objects as the values.
     * @param openPorts A list of all the ports that were determined to be open.
     */
    private void reconcileEnabledAndOpenPorts(String protocolSetString, ProtocolConfig protocolConfig, Map<Double, ProtocolSet> protocolTracker,
                                              List<Integer> openPorts)
    {
        StringBuilder sortableString = new StringBuilder();
        Set<Protocol> protocolList = new TreeSet<Protocol>();

        String[] adapterProtocols = protocolSetString.split(ProtocolSet.DELIMITER);
        for (int i = 0; i < adapterProtocols.length; i++)
        {
            Protocol checkedProtocol = checkIfEnabledAndOpen(protocolConfig, adapterProtocols[i], openPorts);
            if (checkedProtocol == null)
            {
                return;
            }
            protocolList.add(checkedProtocol);
            sortableString.append(threeDigitString(checkedProtocol.getPriority()));
            if (sortableString.indexOf(".") < 0)
            {
                sortableString.append(".").append(100 - adapterProtocols.length);
            }
        }
        ProtocolSet protocolSet = new ProtocolSet(protocolList);
        protocolSet.setProtocolConfigId(protocolConfig.getId());
        protocolTracker.put(new Double(sortableString.toString()), protocolSet);
    }

    /**
     * Traverses each protocol from a protocol configuration to find the one that matches the specified name and determines if it
     * is enables within the configuration and if a port scan revealed that the port associated with the protocol is open.
     * 
     * @param protocolConfig The protocol configuration that contains all of the protocols to traverse.
     * @param protocolName The name of the protocol to check.
     * @param openPorts The list of ports that were determined to be open by a TCP port scan.
     * @return If the protocol is enabled and its port is open on the device, the protocol object itself will be returned;
     * otherwise, <code>null</code> is returned.
     */
    private Protocol checkIfEnabledAndOpen(ProtocolConfig protocolConfig, String protocolName, List<Integer> openPorts)
    {
        Set<Protocol> protocols = protocolConfig.getProtocols();
        for (Protocol protocolFromConfig : protocols)
        {
            if (protocolFromConfig.getName().equals(protocolName))
            {
                if (protocolFromConfig.isEnabled())
                {
                    if (!protocolFromConfig.isTCP() || !isDoTCPScan() || openPorts.contains(Integer.valueOf(protocolFromConfig.getPort())))
                    {
                        return protocolFromConfig;
                    }
                }
                else
                {
                    return null;
                }
            }
        }
        return null;
    }

    /**
     * Converts an integer into a three digit string. For example, 3 is turned
     * into 003. If it is greater than 3 digits nothing is done.
     * 
     * @param enabledValue The integer to convert.
     * @return The string representation of the integer.
     */
    private String threeDigitString(int enabledValue)
    {
        if (enabledValue < 1000)
        {
            return String.format("%03d", enabledValue); //$NON-NLS-1$
        }
        else
        {
            return Integer.toString(enabledValue);
        }
    }
}
