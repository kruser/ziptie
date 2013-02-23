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
 * Contributor(s):
 */

package org.ziptie.credentials;

import junit.framework.TestCase;

/**
 * @author rkruse
 */
public class CredentialsManagerTest extends TestCase
{
//    private CredentialsManager manager;
//
//    
//    public void testNewCredentialsManager()
//    {
//        assertNotNull(manager);
//    }
//
//    /**
//     * Sets a default <code>CredentialConfig</code> and then makes sure it is
//     * given back when we ask for it.
//     * 
//     * @throws CredentialNotSetException
//     * @throws PermissionDeniedException
//     * 
//     */
//    public void testSetDefault() throws CredentialNotSetException, PermissionDeniedException, PersistenceException
//    {
//        // Create a credential set
//        CredentialSet credSet = new CredentialSet("default-1");
//        credSet.addCredential(new Credential("username", "testlab"));
//        credSet.setPriority(1);
//
//        // Create a credential config, which will just be the one CredentialSet
//        CredentialConfig cc = new CredentialConfig("default");
//        cc.addCredentialSet(credSet);
//        manager.saveDefaultCredentialConfig(cc);
//
//        // now test that it comes back with only one set...the default
//        CredentialConfig defaultCC = manager.getDefaultCredentialConfig();
//        assertEquals(1, defaultCC.getCredentialSets().size());
//    }
//
//    /**
//     * using a default credential, make sure you can get it back by IP address
//     * 
//     * @throws ValueFormatFault
//     * @throws PermissionDeniedException
//     * @throws CredentialNotSetException
//     * @throws PersistenceException
//     * 
//     */
//    public void testRetrievalByAddress() throws PermissionDeniedException, ValueFormatFault, CredentialNotSetException,
//            PersistenceException
//    {
//        // Create a credential set
//        CredentialSet credSet = new CredentialSet("default-1");
//        credSet.addCredential(new Credential("username", "testlab"));
//        credSet.setPriority(1);
//
//        // Create a credential config, which will just be the one CredentialSet
//        CredentialConfig cc = new CredentialConfig("default");
//        cc.addCredentialSet(credSet);
//        manager.saveDefaultCredentialConfig(cc);
//
//        List<CredentialSet> credSets = manager.getCredentialSets(new IPAddress("10.10.10.1"));
//        assertEquals(1, credSets.size());
//        assertEquals("testlab", credSets.get(0).getCredentialValue("username"));
//    }
//
//    /**
//     * Gets the credentials for a given IP. This should get one from an Address
//     * definition and another from the default.
//     * 
//     * @throws ValueFormatFault
//     * @throws PermissionDeniedException
//     * @throws CredentialNotSetException
//     * @throws PersistenceException
//     * 
//     */
//    public void testGettingAFew() throws ValueFormatFault, PermissionDeniedException, CredentialNotSetException,
//            PersistenceException
//    {
//        setDefaultCredentialConfig();
//
//        // now create another CredentialConfig which we'll set on a network
//        // address
//        CredentialSet credSet2 = new CredentialSet("routers1");
//        credSet2.addCredential(new Credential("username", "admin"));
//        credSet2.setPriority(1);
//        CredentialConfig cc2 = new CredentialConfig("routers");
//        cc2.addCredentialSet(credSet2);
//        cc2.setPriority(1);
//        AddressSet routerAddrSet = new AddressSet();
//        routerAddrSet.add(new IPWildcard("10.*.*.1-3"));
//        cc2.setAddressSet(routerAddrSet);
//        manager.saveCredentialConfig(cc2);
//
//        // now get the CredentialSets for the IP 10.145.12.1 and it should get
//        // both of the above
//        List<CredentialSet> credentialsList = manager.getCredentialSets(new IPAddress("10.145.12.1"));
//        assertEquals(2, credentialsList.size());
//        assertEquals("admin", credentialsList.get(0).getCredentialValue("username"));
//        assertEquals("testlab", credentialsList.get(1).getCredentialValue("username"));
//
//        // get the credentials for another address
//        List<CredentialSet> credentialsList2 = manager.getCredentialSets(new IPAddress("10.145.12.99"));
//        assertEquals(1, credentialsList2.size());
//        assertEquals("testlab", credentialsList2.get(0).getCredentialValue("username"));
//    }
//
//    /**
//     * When a process recognizes that a particular CredentialSet works they
//     * should save the ID of that credentialSet.
//     * 
//     * @throws ValueFormatFault
//     * @throws PermissionDeniedException
//     * @throws CredentialNotSetException
//     * @throws PersistenceException
//     * 
//     */
//    public void testReportingWorkingCredentials() throws ValueFormatFault, PermissionDeniedException,
//            CredentialNotSetException, PersistenceException
//    {
//        setDefaultCredentialConfig();
//        AddressSet as = new AddressSet();
//        as.add(new IPRange("10.100.0.0", "10.100.0.255"));
//        CredentialConfig cc1 = getTwoMoreCredentials();
//        cc1.setAddressSet(as);
//        manager.saveCredentialConfig(cc1);
//
//        IPAddress ip = new IPAddress("10.100.0.123");
//        List<CredentialSet> credSets = manager.getCredentialSets(ip);
//        assertEquals(3, credSets.size());
//        assertEquals("z1", credSets.get(0).getCredentialValue("username"));
//
//        // now report one as working and verify it is the first one returned the
//        // next time we ask
//        manager.mapCredentialSetToDevice(credSets.get(1), ip);
//        List<CredentialSet> credSets2 = manager.getCredentialSets(ip);
//        assertEquals(1, credSets2.size());
//        assertEquals("z2", credSets2.get(0).getCredentialValue("username"));
//
//        // clear out the saved relationship once again
//        manager.clearWorkingCredentialSet(ip);
//        List<CredentialSet> credSets3 = manager.getCredentialSets(ip);
//        assertEquals(3, credSets3.size());
//        assertEquals("z1", credSets3.get(0).getCredentialValue("username"));
//
//        // Now set the max creds down to 2 and make sure you only get 2 back
//        manager.setMaxCredentialTries(2);
//        List<CredentialSet> credSets4 = manager.getCredentialSets(ip);
//        assertEquals(2, credSets4.size());
//    }
//
//    /**
//     * Tests out saving a relationship between a previously unsaved
//     * credentialSet and an IP. This should add the credentialSet to the
//     * matching CredentialConfig.
//     * @throws PersistenceException 
//     * @throws PermissionDeniedException 
//     */
//    public void testSaveWorking2() throws PermissionDeniedException, PersistenceException
//    {
//
//        IPAddress ip = new IPAddress("99.45.5.1");
//        int initialSize = manager.getCredentialSets(ip).size();
//        
//        CredentialSet newSet = new CredentialSet("SAVE ME");
//        newSet.addCredential(new Credential("username", "coolio"));
//        
//        manager.mapCredentialSetToDevice(newSet, ip);
//        
//        // since we saved one it should be only 1
//        assertEquals(1, manager.getCredentialSets(ip).size());
//        
//        // now mark stale and we should get the extra one back
//        manager.markWorkingCredentialsStale(ip);
//        assertEquals(initialSize + 1, manager.getCredentialSets(ip, false).size());
//    }
//
//    /**
//     * Tests out deleting a CredentialConfig
//     * 
//     * @throws ValueFormatFault
//     * @throws PermissionDeniedException
//     * @throws AddressingException
//     * @throws PersistenceException
//     * 
//     */
//    public void testDeleteCredentialConfig() throws PermissionDeniedException, AddressingException,
//            PersistenceException
//    {
//        setDefaultCredentialConfig();
//        CredentialSet credSet2 = new CredentialSet("routers1");
//        credSet2.addCredential(new Credential("username", "admin"));
//        credSet2.setPriority(1);
//        CredentialConfig cc2 = new CredentialConfig("routers");
//        cc2.addCredentialSet(credSet2);
//        cc2.setPriority(1);
//        AddressSet routerAddrSet = new AddressSet();
//        routerAddrSet.add(new IPWildcard("10.*.*.1-3"));
//        cc2.setAddressSet(routerAddrSet);
//        manager.saveCredentialConfig(cc2);
//
//        List<CredentialConfig> ccList = manager.getAllCredentialConfigs();
//        assertEquals(1, ccList.size());
//
//        for (CredentialConfig cc : ccList)
//        {
//            System.out.println("Deleting CredentialConfig ID " + cc.getId());
//            manager.deleteCredentialConfig(cc);
//        }
//
//        List<CredentialConfig> ccList2 = manager.getAllCredentialConfigs();
//        assertEquals(0, ccList2.size());
//    }
//
//    /**
//     * Saves a working credential from the default bunch, but then adds one that
//     * takes precedence. This should clear out the working credential that was
//     * saved previously.
//     * 
//     * @throws ValueFormatFault
//     * @throws PermissionDeniedException
//     * @throws PersistenceException
//     */
//    public void testClearWorkingCredential() throws PermissionDeniedException, PersistenceException
//    {
//        IPAddress targetIP = new IPAddress("10.10.10.10");
//        setDefaultCredentialConfig();
//        AddressSet as = new AddressSet();
//        as.add(targetIP);
//        CredentialConfig cc1 = getTwoMoreCredentials();
//        cc1.setPriority(2);
//        cc1.setAddressSet(as);
//        manager.saveCredentialConfig(cc1);
//
//        // Make sure we get three possible credential sets
//        List<CredentialSet> cs = manager.getCredentialSets(targetIP);
//        assertEquals(3, cs.size());
//
//        // report back that one credential set is the working one
//        manager.mapCredentialSetToDevice(cs.get(2), targetIP);
//        List<CredentialSet> cs2 = manager.getCredentialSets(targetIP);
//        assertEquals(1, cs2.size());
//
//        // now clear it
//        manager.clearWorkingCredentialSet(targetIP);
//        List<CredentialSet> cs3 = manager.getCredentialSets(targetIP);
//        assertEquals(3, cs3.size());
//    }
//
//    public void testMarkingStale() throws PermissionDeniedException, PersistenceException
//    {
//        IPAddress targetIP = new IPAddress("10.10.10.10");
//        setDefaultCredentialConfig();
//        AddressSet as = new AddressSet();
//        as.add(targetIP);
//        CredentialConfig cc1 = getTwoMoreCredentials();
//        cc1.setPriority(2);
//        cc1.setAddressSet(as);
//        manager.saveCredentialConfig(cc1);
//
//        // Make sure we get three possible credential sets
//        List<CredentialSet> cs = manager.getCredentialSets(targetIP);
//        assertEquals(3, cs.size());
//
//        // report back that one credential set is the working one
//        manager.mapCredentialSetToDevice(cs.get(2), targetIP);
//        List<CredentialSet> cs2 = manager.getCredentialSets(targetIP);
//        assertEquals(1, cs2.size());
//
//        // now mark it stale
//        manager.markWorkingCredentialsStale(targetIP);
//
//        // ordinary call should still get back the stale one
//        List<CredentialSet> cs3 = manager.getCredentialSets(targetIP);
//        assertEquals(1, cs3.size());
//
//        // special call should get back the master list
//        List<CredentialSet> cs4 = manager.getCredentialSets(targetIP, false);
//        assertEquals(3, cs4.size());
//    }
//
//    /**
//     * We'll mark the default one as working for a given IP and then add a new
//     * protocolConfig. Even though there was a previously saved relationship,
//     * saving the new one should mark things stale.
//     * 
//     * @throws PersistenceException
//     * @throws PermissionDeniedException
//     */
//    public void testNewConfigAfterSavedSet() throws PermissionDeniedException, PersistenceException
//    {
//        IPAddress ip = new IPAddress("192.168.1.100");
//        List<CredentialSet> credentialSets = manager.getCredentialSets(ip);
//
//        CredentialSet original = credentialSets.get(0);
//        manager.mapCredentialSetToDevice(original, ip);
//
//        // Make sure the original is the only one provided since we saved it
//        List<CredentialSet> credentialSets2 = manager.getCredentialSets(ip);
//        assertEquals(1, credentialSets2.size());
//        assertEquals(original, credentialSets2.get(0));
//
//        // Now save a new CredentialConfig....we'll want it to be first in the
//        // list the next time
//        // we ask for non-stale.
//        CredentialConfig newConfig = new CredentialConfig("new guy");
//        newConfig.setPriority(1);
//        CredentialSet newSet = new CredentialSet("TESTER");
//        newSet.addCredential(new Credential("username", "t-bone"));
//        newSet.addCredential(new Credential("password", "ko-ko"));
//        newConfig.addCredentialSet(newSet);
//        AddressSet as = new AddressSet();
//        as.add(new IPWildcard("192.*.*.1-200"));
//        newConfig.setAddressSet(as);
//        manager.saveCredentialConfig(newConfig);
//
//        // There should be three sets returned now....the new one and the two
//        // defaults
//        List<CredentialSet> credentialSets3 = manager.getCredentialSets(ip, false);
//        assertEquals(3, credentialSets3.size());
//        assertEquals("TESTER", credentialSets3.get(0).getName());
//        assertEquals(2, credentialSets3.get(0).getCredentials().size());
//
//        // ask for stale you should get back the saved default one
//        List<CredentialSet> credentialSets4 = manager.getCredentialSets(ip);
//        assertEquals(1, credentialSets4.size());
//        assertEquals(original, credentialSets4.get(0));
//
//        // resave so we only have one again
//        manager.mapCredentialSetToDevice(original, ip);
//        assertEquals(1, manager.getCredentialSets(ip).size());
//
//        // now resave the new one with a new priority. It should mark things
//        // stale for that one only
//        newConfig.setPriority(5);
//        newConfig.setAddressSet(as);
//        manager.saveCredentialConfig(newConfig);
//        assertEquals(1, manager.getCredentialSets(ip).size());
//    }
//
//    /**
//     * Tests setting the max creds property
//     * 
//     */
//    public void testMaxCreds() throws PersistenceException
//    {
//        assertEquals("Three should be the default number of credential tries", 3, manager.getMaxCredentialTries());
//
//        manager.setMaxCredentialTries(1);
//        assertEquals(1, manager.getMaxCredentialTries());
//    }
//
//    /**
//     * Sets a single CredentialConfig with a couple CredentialSets
//     * 
//     * @throws PermissionDeniedException
//     */
//    private CredentialConfig getTwoMoreCredentials() throws PermissionDeniedException
//    {
//        CredentialSet credSet = new CredentialSet("test1");
//        credSet.addCredential(new Credential("username", "z1"));
//        credSet.setPriority(1);
//
//        CredentialSet credSet2 = new CredentialSet("test1");
//        credSet2.addCredential(new Credential("username", "z2"));
//        credSet2.setPriority(2);
//
//        CredentialConfig cc = new CredentialConfig("test");
//        cc.addCredentialSet(credSet);
//        cc.addCredentialSet(credSet2);
//        return cc;
//    }
//
//    /**
//     * Sets a default CredentialConfig
//     */
//    private void setDefaultCredentialConfig() throws PersistenceException
//    {
//        // Create a CredentialConfig for the default
//        CredentialSet credSet = new CredentialSet("default1");
//        credSet.addCredential(new Credential("username", "testlab"));
//        credSet.setPriority(1);
//        CredentialConfig cc = new CredentialConfig("default");
//        cc.addCredentialSet(credSet);
//        manager.saveDefaultCredentialConfig(cc);
//    }
//
//    /*
//     * (non-Javadoc)
//     * 
//     * @see junit.framework.TestCase#setUp()
//     */
//    @Override
//    protected void setUp() throws Exception
//    {
//        super.setUp();
//        CredentialsManager.startup(new InMemoryCredentialsPersister());
//        manager = CredentialsManager.getInstance();
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
//    }

}

// -------------------------------------------------
// $Log: CredentialsManagerTest.java
// $Revision 1.1 Oct 23, 2006 rkruse
// $Code Templates
// $
// --------------------------------------------------
