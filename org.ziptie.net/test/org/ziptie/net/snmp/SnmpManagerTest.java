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
package org.ziptie.net.snmp;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import junit.framework.TestCase;

import org.snmp4j.AbstractTarget;
import org.ziptie.addressing.IPAddress;
import org.ziptie.credentials.Credential;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolConstants;
import org.ziptie.protocols.ProtocolNames;
import org.ziptie.protocols.ProtocolProperty;

/**
 * SnmpManagerTest
 */
public class SnmpManagerTest extends TestCase
{
    private Protocol snmpProtocol;
    private CredentialSet credentials;
    
    private static String SYS_DESCR = "1.3.6.1.2.1.1.1.0";
    private static String SYS_OID = "1.3.6.1.2.1.1.2.0";
    private static String SYS_NAME = "1.3.6.1.2.1.1.5.0";
    
    /** {@inheritDoc} */
    @Override
    protected void setUp() throws Exception
    {
        snmpProtocol = getSnmpProtocol();
        credentials = getCredentials();
    }

    /**
     * test out the get method on the SnmpManager
     * @throws SnmpException 
     */
    public void testSystemGets() throws SnmpException
    {
        SnmpManager manager = SnmpManager.getInstance();
        AbstractTarget target = manager.buildTarget(new IPAddress("10.100.4.8"), snmpProtocol, credentials);
        
        List<String> oids = new ArrayList<String>();
        oids.add(SYS_DESCR);
        oids.add(SYS_OID);
        oids.add(SYS_NAME);
        
        Map<String, String> snmpGet = manager.snmpGet(oids, target);
        System.out.println(snmpGet);

    }

    private CredentialSet getCredentials()
    {
        CredentialSet credentialSet = new CredentialSet();
        credentialSet.addCredential(new Credential(SnmpManager.GET_COMMUNITY_KEY, "public"));
        return credentialSet;
    }

    private Protocol getSnmpProtocol()
    {
        List<ProtocolProperty> snmpProperties = new LinkedList<ProtocolProperty>();
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.TIMEOUT, Long.toString(800)));
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.RETRIES, Integer.toString(1)));
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.VERSION, "v1"));
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.SNMP_V3_AUTH_ALGORITHM, "MD5"));
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.SNMP_V3_PRIVACY, "DES"));
        return new Protocol(ProtocolNames.SNMP.name(), 161, 1, false, true, snmpProperties);
    }

}
