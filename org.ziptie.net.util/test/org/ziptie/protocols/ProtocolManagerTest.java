/*
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint. Portions created by
 * AlterPoint are Copyright (C) 2006, AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.protocols;

import junit.framework.TestCase;

public class ProtocolManagerTest extends TestCase
{
//    ProtocolManager manager;
//    ProtocolConfig defaultProtocolConfig = null;
//
//    @Override
//    protected void setUp() throws PersistenceException, PermissionDeniedException
//    {
//        manager = ProtocolManager.startup(new InMemoryProtocolPersister());
//        manager.setDoTCPScan(false);
//        defaultProtocolConfig = manager.getDefaultProtocolConfig();
//        System.out.println("--------------------------------------------\nTest");
//    }
//
//    public void testGetInstance()
//    {
//        // test not throwing the exception
//        ProtocolManager.getInstance();
//    }
//
//    public void testNewProtocolManager()
//    {
//        assertNotNull(manager);
//    }
//
//    /**
//     * Tests that there is a config set as the default even before any user
//     * would have set such a config
//     * 
//     * @throws PermissionDeniedException
//     * 
//     */
//    public void testEmtpyConfig() throws PermissionDeniedException, PersistenceException
//    {
//        ProtocolConfig config = manager.getDefaultProtocolConfig();
//        assertNotNull(config);
//        assertEquals(8, config.getProtocols().size());
//    }
//
//    /**
//     * Disable a few things, change a few ports on the CLI protocols, set Telnet
//     * as the preferred.
//     * 
//     * Then get it back from the service and verify everything was set
//     * correctly.
//     * 
//     * @throws PermissionDeniedException
//     * 
//     */
//    public void testSetDefaultConfig() throws PermissionDeniedException, PersistenceException
//    {
//        // This section sets the CLI protocols with Telnet the first priority
//        // and SSH disabled.
//        ProtocolConfig config = new ProtocolConfig();
//        config.addProtocol(new Protocol("Telnet", 23, 1, true));
//        config.addProtocol(new Protocol("SSH", 23, 2, true));
//        manager.saveDefaultProtocolConfig(config);
//
//        // now retreive it and assert the values we set above
//        ProtocolConfig after = manager.getDefaultProtocolConfig();
//        assertNotNull(after);
//        Set<Protocol> clis = after.getProtocols();
//        assertEquals(2, clis.size());
//    }
//
//    /**
//     * with an empty protocol config this should also return the default
//     * ProtocolConfig
//     * 
//     * @throws ValueFormatFault
//     * @throws NonContiguousSubnetMask
//     * @throws PermissionDeniedException
//     * 
//     */
//    public void testGettingByAddress() throws ValueFormatFault, NonContiguousSubnetMask, PermissionDeniedException,
//            PersistenceException
//    {
//        IPAddress hostAddr = new IPAddress("10.100.45.66");
//
//        ProtocolConfig configByAddr = manager.getProtocolConfig(hostAddr);
//        assertNotNull(configByAddr);
//
//        // Since we haven't set anything yet this ProtocolConfig should be the
//        // same as the default config
//        assertEquals(configByAddr, manager.getDefaultProtocolConfig());
//
//        // only enable a single protocol on this subnet
//        ProtocolConfig newConfig = new ProtocolConfig();
//        newConfig.addProtocol(new Protocol("Telnet", 23, 1, true));
//
//        // Create the AddressSet
//        NetworkAddress subnet = new Subnet(new IPAddress("10.100.0.0"), new IPAddress("255.255.0.0"));
//        AddressSet addrSet = new AddressSet();
//        addrSet.add(subnet);
//        newConfig.setAddressSet(addrSet);
//        manager.saveProtocolConfig(newConfig);
//
//        // now it should be different from the default
//        ProtocolConfig configByAddr2 = manager.getProtocolConfig(hostAddr);
//        assertNotNull(configByAddr2);
//        assertFalse(configByAddr2.equals(manager.getDefaultProtocolConfig()));
//
//        // make sure there is only one protocol for that IP
//        assertEquals(1, configByAddr2.getProtocols().size());
//    }
//
//    /**
//     * Tests getting all the configs, except the default
//     * 
//     * @throws PermissionDeniedException
//     * @throws PersistenceException
//     * @throws ValueFormatFault
//     * @throws NonContiguousSubnetMask
//     */
//    public void testGetAllConfigs() throws PermissionDeniedException, PersistenceException, NonContiguousSubnetMask,
//            ValueFormatFault
//    {
//        assertEquals(0, manager.getAllProtocolConfigs().size());
//
//        // only enable a single protocol on this subnet
//        ProtocolConfig newConfig = new ProtocolConfig();
//        newConfig.addProtocol(new Protocol("Telnet", 23, 1, true));
//
//        // Create the AddressSet
//        NetworkAddress subnet = new Subnet(new IPAddress("10.100.0.0"), new IPAddress("255.255.0.0"));
//        AddressSet addrSet = new AddressSet();
//        addrSet.add(subnet);
//        newConfig.setAddressSet(addrSet);
//        manager.saveProtocolConfig(newConfig);
//
//        assertEquals(1, manager.getAllProtocolConfigs().size());
//    }
//
//    /**
//     * Get a few protocols from an adapter and return the protocol sets based on
//     * preferences
//     * 
//     * @throws ValueFormatFault
//     * @throws PermissionDeniedException
//     * @throws NoEnabledProtocolsException
//     * @throws IllegalArgumentException
//     * 
//     */
//    public void testProtocolResolution() throws ValueFormatFault, PermissionDeniedException, PersistenceException,
//            IllegalArgumentException, NoEnabledProtocolsException
//    {
//        List<ProtocolSet> protocolSets = manager.calculateProtocolSets(getCiscoProtocols(), new IPAddress("10.10.1.1"));
//        System.out.println("Most wanted protocol set: " + protocolSets.get(0));
//        assertEquals("SSH-SCP-SNMP", protocolSets.get(0).toString());
//    }
//
//    /**
//     * Gets a list of protocols for a device and then tells the ProtocolManager
//     * that one of the given protocols worked. In reality the server should tell
//     * the ProtocolManager that a certain protocol set resulted in a successful
//     * backup and the protocolManager should remember this.
//     * 
//     * Then the next time we ask the protocol manager for the list of protocol
//     * sets there should only be one....the one that worked the previous time.
//     * This will guard against forceful retries of backups using a protocol set
//     * that never works.
//     * 
//     * For example, lets say SSH-SCP and Telnet-TFTP are valid for a device, in
//     * that order. If SSH-SCP never works then we should remember that fact and
//     * use Telnet-TFTP the next time.
//     * 
//     * @throws ValueFormatFault
//     * @throws NoEnabledProtocolsException
//     * 
//     */
//    public void testProtocolManagerMemory() throws ValueFormatFault, PermissionDeniedException, PersistenceException,
//            NoEnabledProtocolsException
//    {
//        IPAddress ip = new IPAddress("192.168.1.100");
//        List<ProtocolSet> protocolSets = manager.calculateProtocolSets(getCiscoProtocols(), ip);
//        assertEquals(10, protocolSets.size());
//
//        System.out.println("Reporting a working protocol: " + protocolSets.get(1));
//        manager.mapProtocolSetToDevice(protocolSets.get(1), ip);
//        List<ProtocolSet> protocolSets2 = manager.calculateProtocolSets(getCiscoProtocols(), ip);
//        System.out.println("\tNow retrieving the protocolSet to use: " + protocolSets2.get(0));
//        assertEquals(1, protocolSets2.size());
//
//        // Now clear it out
//        manager.clearWorkingProtocols(ip);
//        List<ProtocolSet> protocolSets3 = manager.calculateProtocolSets(getCiscoProtocols(), ip);
//        assertEquals(10, protocolSets3.size());
//
//        // clean up
//        manager.clearWorkingProtocols(ip);
//    }
//
//    public void testDeleteProtocolConfig() throws ValueFormatFault, PermissionDeniedException, AddressingException,
//            PersistenceException
//    {
//        ProtocolConfig config = new ProtocolConfig();
//        config.addProtocol(new Protocol("Telnet", 23, 1, true));
//        config.addProtocol(new Protocol("SSH", 23, 2, true));
//        AddressSet test = new AddressSet();
//        test.add(new IPAddress("7.7.7.7"));
//        config.setAddressSet(test);
//        manager.saveProtocolConfig(config);
//
//        ProtocolConfig protConfig = manager.getProtocolConfig(new IPAddress("7.7.7.7"));
//        assertEquals(2, protConfig.getProtocols().size());
//
//        // now delete it
//        System.out.println("Deleting ProtocolConfig ID: " + protConfig.getId());
//        manager.deleteProtocolConfig(protConfig);
//        ProtocolConfig protConfig2 = manager.getProtocolConfig(new IPAddress("7.7.7.7"));
//        System.out.println("New ProtocolConfig has the ID " + protConfig2.getId());
//        assertFalse(protConfig.equals(protConfig2));
//    }
//
//    /**
//     * Saves a workingProtocolSet for a device. Then resaves the protocolConfig,
//     * which should mark the saved ProtocolSet as stale.
//     * @throws PersistenceException 
//     * @throws NoEnabledProtocolsException 
//     * @throws PermissionDeniedException 
//     * 
//     */
//    public void testSavingWorking() throws PersistenceException, PermissionDeniedException, NoEnabledProtocolsException
//    {
//        IPAddress ip = new IPAddress("192.168.1.100");
//        List<ProtocolSet> protocolSets = manager.calculateProtocolSets(getCiscoProtocols(), ip);
//        assertEquals(10, protocolSets.size());
//
//        System.out.println("Reporting a working protocol: " + protocolSets.get(1));
//        manager.mapProtocolSetToDevice(protocolSets.get(1), ip);
//        List<ProtocolSet> protocolSets2 = manager.calculateProtocolSets(getCiscoProtocols(), ip);
//        System.out.println("\tNow retrieving the protocolSet to use: " + protocolSets2.get(0));
//        assertEquals(1, protocolSets2.size());
//        
//        // resave the default to trigger the stale mark
//        ProtocolConfig defaultPc = manager.getDefaultProtocolConfig();
//        manager.saveDefaultProtocolConfig(defaultPc);
//        List<ProtocolSet> protocolSets3 = manager.calculateProtocolSets(getCiscoProtocols(), ip, false);
//        assertEquals(10, protocolSets3.size());
//        
//        // Clean up
//        manager.clearWorkingProtocols(ip);
//    }
//
//    /**
//     * Set the protocol manager up to do port scans while deciding which ports
//     * and address can use.
//     * 
//     * This test will be disabled as it touches real network equipment.
//     * 
//     * @throws ValueFormatFault
//     * @throws PermissionDeniedException
//     * @throws NoEnabledProtocolsException
//     * 
//     */
//    public void DISABLED_USES_NETWORK_DEVICES_testWithPortScan() throws ValueFormatFault, PermissionDeniedException,
//            PersistenceException, NoEnabledProtocolsException
//    {
//        manager.setDoTCPScan(true);
//        IPAddress ip = new IPAddress("10.100.4.8");
//        System.out.println("PortScan of " + ip.toString());
//        List<ProtocolSet> protocolSets = manager.calculateProtocolSets(getCiscoProtocols(), ip);
//        for (ProtocolSet currPS : protocolSets)
//        {
//            System.out.println("\t" + currPS);
//        }
//        assertEquals(3, protocolSets.size());
//
//        IPAddress ip2 = new IPAddress("10.100.20.214");
//        System.out.println("PortScan of " + ip2.toString());
//        List<ProtocolSet> protocolSets2 = manager.calculateProtocolSets(getCiscoProtocols(), ip2);
//        for (ProtocolSet currPS : protocolSets2)
//        {
//            System.out.println("\t" + currPS);
//        }
//        assertEquals(3, protocolSets2.size());
//    }
//
//    /**
//     * If only SSH is enabled, but the adapter only supports Telnet, it should
//     * throw the NoEnabledProtocolsException
//     * 
//     * @throws PersistenceException
//     * @throws PermissionDeniedException
//     * @throws ValueFormatFault
//     * 
//     */
//    public void testNoEnabledProtocolsException() throws PermissionDeniedException, PersistenceException,
//            ValueFormatFault
//    {
//        // Set the default protocolConfigTO with only SSH
//        ProtocolConfig protocolConfig = new ProtocolConfig();
//        protocolConfig.setName("DEFAULT FOR TEST");
//        protocolConfig.addProtocol(new Protocol("SSH", 22, 1, true));
//        manager.saveDefaultProtocolConfig(protocolConfig);
//
//        ProtocolSet telnetOnlyProtocolSet = new ProtocolSet();
//        telnetOnlyProtocolSet.addProtocol(new Protocol("Telnet", 23, 1, true));
//        try
//        {
//            manager.calculateSupportedProtocolSets(Collections.singletonList(telnetOnlyProtocolSet),
//                    new IPAddress("10.100.4.8"));
//            fail("this should have thrown an exception");
//        }
//        catch (NoEnabledProtocolsException e)
//        {
//            // we should reach this point
//            assertTrue(true);
//        }
//
//    }
//
//    // --------------- private helpers ------------------//
//
//    /**
//     * Returns protocols similar to those represented in the IOS adapter
//     */
//    private List<String> getCiscoProtocols()
//    {
//        List<String> protocolSets = new ArrayList<String>();
//        protocolSets.add(("Telnet-TFTP"));
//        protocolSets.add(("SSH-TFTP"));
//        protocolSets.add(("SSH-SCP"));
//        protocolSets.add(("Telnet"));
//        protocolSets.add(("SSH"));
//        protocolSets.add(("Telnet-SNMP-TFTP"));
//        protocolSets.add(("SSH-SNMP-TFTP"));
//        protocolSets.add(("SSH-SNMP-SCP"));
//        protocolSets.add(("Telnet-SNMP"));
//        protocolSets.add(("SSH-SNMP"));
//        return protocolSets;
//    }
//
//    /*
//     * (non-Javadoc)
//     * 
//     * @see junit.framework.TestCase#tearDown()
//     */
//    @Override
//    protected void tearDown() throws Exception
//    {
//        super.tearDown();
//        manager.saveDefaultProtocolConfig(defaultProtocolConfig);
//    }

}
