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

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.snmp4j.AbstractTarget;
import org.snmp4j.CommunityTarget;
import org.snmp4j.PDU;
import org.snmp4j.Snmp;
import org.snmp4j.TransportMapping;
import org.snmp4j.UserTarget;
import org.snmp4j.event.ResponseEvent;
import org.snmp4j.mp.MPv3;
import org.snmp4j.mp.SnmpConstants;
import org.snmp4j.security.AuthMD5;
import org.snmp4j.security.AuthSHA;
import org.snmp4j.security.PrivAES128;
import org.snmp4j.security.PrivAES192;
import org.snmp4j.security.PrivAES256;
import org.snmp4j.security.PrivDES;
import org.snmp4j.security.SecurityLevel;
import org.snmp4j.security.SecurityModels;
import org.snmp4j.security.SecurityProtocols;
import org.snmp4j.security.USM;
import org.snmp4j.security.UsmUser;
import org.snmp4j.security.UsmUserEntry;
import org.snmp4j.smi.OID;
import org.snmp4j.smi.OctetString;
import org.snmp4j.smi.UdpAddress;
import org.snmp4j.smi.VariableBinding;
import org.snmp4j.transport.DefaultUdpTransportMapping;
import org.snmp4j.util.DefaultPDUFactory;
import org.ziptie.addressing.IPAddress;
import org.ziptie.credentials.Credential;
import org.ziptie.credentials.CredentialNotSetException;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.net.snmp.SnmpException.SnmpError;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolConstants;
import org.ziptie.protocols.ProtocolNames;

/**
 * SnmpManager
 */
public final class SnmpManager
{
    public static final String GET_COMMUNITY_KEY = "roCommunityString";
    public static final String SET_COMMUNITY_KEY = "rwCommunityString";
    public static final String AUTH_USERNAME_KEY = "snmpUsername";
    public static final String AUTH_PASSWORD_KEY = "snmpAuthPassword";
    public static final String PRIV_PASSWORD_KEY = "snmpPrivPassword";
    public static final int DEFAULT_RETRIES = 1;
    public static final int DEFAULT_TIMEOUT = 800;
    public static final String DEFAULT_VERSION = "1";

    private static SnmpManager instance;
    private Snmp snmp;

    /**
     * hidden
     */
    private SnmpManager()
    {
        try
        {
            TransportMapping transport = new DefaultUdpTransportMapping();
            snmp = new Snmp(transport);
            USM usm = new USM(SecurityProtocols.getInstance(), new OctetString(MPv3.createLocalEngineID()), 0);
            SecurityModels.getInstance().addSecurityModel(usm);
            transport.listen();
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Get an instance of the snmp manager
     * @return the instance
     */
    public static SnmpManager getInstance()
    {
        if (instance == null)
        {
            instance = new SnmpManager();
        }
        return instance;
    }

    /**
     * @param oids the OIDs to get
     * @param target the target, use the {@link #buildTarget(IPAddress, Protocol, CredentialSet)} method to build the target 
     * @return a map of results, the key of each entry being the OID
     * @throws SnmpException when there is an issue such as timeout or bad credentials
     */
    public Map<String, String> snmpGet(List<String> oids, AbstractTarget target) throws SnmpException
    {
        // Create a protocol data unit (PDU)
        PDU requestPDU = DefaultPDUFactory.createPDU(target, PDU.GET);

        // Add all the attributes from the specified attribute list to the PDU
        for (String oid : oids)
        {
            OID targetOID = new OID(oid);
            requestPDU.add(new VariableBinding(targetOID));
        }

        try
        {
            Map<String, String> results = new HashMap<String, String>();
            ResponseEvent responseEvent = snmp.send(requestPDU, target);
            PDU responsePDU = (responseEvent != null ? responseEvent.getResponse() : null);
            if (responseEvent != null && responsePDU != null)
            {
                VariableBinding[] varBindings = responsePDU.toArray();
                for (int i = 0; i < varBindings.length; i++)
                {
                    String oid = varBindings[i].getOid().toString();
                    String result = varBindings[i].getVariable().toString();
                    results.put(oid, result);
                }
            }
            else
            {
                throw new SnmpException(SnmpError.TIMEOUT);
            }
            return results;
        }
        catch (IOException e)
        {
            throw new SnmpException(SnmpError.GENERAL);
        }
    }

    /**
     * Builds an SNMP4J {@link AbstractTarget} using the provided protocol settings and credentials
     * @param ipAddress the target IP address
     * @param snmpProtocol the SNMP protocol
     * @param credentials the SNMP authentication credentials
     * @return the target
     */
    public AbstractTarget buildTarget(IPAddress ipAddress, Protocol snmpProtocol, CredentialSet credentials)
    {
        if (!snmpProtocol.getName().equals(ProtocolNames.SNMP.name()))
        {
            throw new IllegalArgumentException("The provided protocol isn't " + ProtocolNames.SNMP);
        }

        String version = snmpProtocol.getProperty(ProtocolConstants.VERSION);
        String retriesProp = snmpProtocol.getProperty(ProtocolConstants.RETRIES);
        String timeoutProp = snmpProtocol.getProperty(ProtocolConstants.TIMEOUT);

        version = (version == null) ? DEFAULT_VERSION : version;
        int maxRetries = (retriesProp == null) ? DEFAULT_RETRIES : Integer.parseInt(retriesProp);
        int timeout = (timeoutProp == null) ? DEFAULT_TIMEOUT : Integer.parseInt(timeoutProp);

        if (version.contains("3"))
        {
            UserTarget target = new UserTarget();
            target.setAddress(new UdpAddress(ipAddress.getIPAddress() + "/" + snmpProtocol.getPort()));
            target.setRetries(maxRetries);
            target.setTimeout(timeout);
            target.setVersion(SnmpConstants.version3);

            String authPassword = null;
            String authUsername = null;
            String privPassword = null;
            for (Credential credential : credentials.getCredentials())
            {
                if (credential.getValue().length() > 0)
                {
                    if (credential.getName().equals(AUTH_USERNAME_KEY))
                    {
                        authUsername = credential.getValue();
                    }
                    else if (credential.getName().equals(AUTH_PASSWORD_KEY))
                    {
                        authPassword = credential.getValue();
                    }
                    else if (credential.getName().equals(PRIV_PASSWORD_KEY))
                    {
                        privPassword = credential.getValue();
                    }
                }
            }

            if (authPassword != null && privPassword != null)
            {
                target.setSecurityLevel(SecurityLevel.AUTH_PRIV);
            }
            else if (authPassword != null)
            {
                target.setSecurityLevel(SecurityLevel.AUTH_NOPRIV);
            }
            else
            {
                target.setSecurityLevel(SecurityLevel.NOAUTH_NOPRIV);
            }
            target.setSecurityName(new OctetString(authUsername));
            validateUsmUser(target, authPassword, privPassword, snmpProtocol);
            return target;
        }
        else
        {
            try
            {
                CommunityTarget communityTarget = new CommunityTarget();
                communityTarget.setAddress(new UdpAddress(ipAddress.getIPAddress() + "/" + snmpProtocol.getPort()));
                communityTarget.setCommunity(new OctetString(credentials.getCredentialValue(GET_COMMUNITY_KEY)));
                communityTarget.setRetries(maxRetries);
                communityTarget.setTimeout(timeout);
                communityTarget.setVersion(convertSNMPVersionToSNMP4J(version));
                return communityTarget;
            }
            catch (CredentialNotSetException cnse)
            {
                throw new IllegalArgumentException(cnse);
            }
        }
    }

    /**
     * Verifies that the current SnmpManager instance has a SNMPv3 {@link UsmUser}
     * associated with it already for this target.  If not, one will
     * be created and added.
     * 
     * @param target the target
     * @param authPasswordString the v3 auth password
     * @param privPasswordString the v3 priv password
     * @param snmpProtocol the Protocol
     */
    private void validateUsmUser(UserTarget target, String authPasswordString, String privPasswordString, Protocol snmpProtocol)
    {
        UsmUserEntry userEntry = snmp.getUSM().getUserTable().getUser(target.getSecurityName());
        if (userEntry == null)
        {
            OID authProtocol = AuthMD5.ID;
            String authProtString = snmpProtocol.getProperty(ProtocolConstants.SNMP_V3_AUTH_ALGORITHM);
            if (authProtString != null && authProtString.contains("SHA"))
            {
                authProtocol = AuthSHA.ID;
            }

            OID privProtocol = PrivDES.ID;
            String privProtString = snmpProtocol.getProperty(ProtocolConstants.SNMP_V3_PRIVACY);
            if (privProtString != null)
            {
                if (privProtString.contains("AES256"))
                {
                    privProtocol = PrivAES256.ID;
                }
                else if (privProtString.contains("AES192"))
                {
                    privProtocol = PrivAES192.ID;
                }
                else if (privProtString.contains("AES"))
                {
                    privProtocol = PrivAES128.ID;
                }
            }

            OctetString authPassword = (authPasswordString != null) ? new OctetString(authPasswordString) : null;
            OctetString privPassword = (privPasswordString != null) ? new OctetString(privPasswordString) : null;
            authProtocol = (authPasswordString == null) ? null : authProtocol;
            privProtocol = (target.getSecurityName() == null || privPasswordString == null) ? null : privProtocol;

            UsmUser user = new UsmUser(target.getSecurityName(), authProtocol, authPassword, privProtocol, privPassword);
            snmp.getUSM().addUser(target.getSecurityName(), user);
        }
    }

    private int convertSNMPVersionToSNMP4J(String version)
    {
        if (version.contains("2"))
        {
            return SnmpConstants.version2c;
        }
        else if (version.contains("3"))
        {
            return SnmpConstants.version3;
        }
        else
        {
            return SnmpConstants.version1;
        }
    }

}
