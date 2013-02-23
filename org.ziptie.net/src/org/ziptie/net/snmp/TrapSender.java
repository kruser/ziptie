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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.log4j.Logger;
import org.snmp4j.CommunityTarget;
import org.snmp4j.PDU;
import org.snmp4j.Snmp;
import org.snmp4j.mp.SnmpConstants;
import org.snmp4j.smi.Address;
import org.snmp4j.smi.GenericAddress;
import org.snmp4j.smi.IpAddress;
import org.snmp4j.smi.OID;
import org.snmp4j.smi.OctetString;
import org.snmp4j.smi.TimeTicks;
import org.snmp4j.smi.VariableBinding;
import org.snmp4j.transport.DefaultUdpTransportMapping;
import org.ziptie.net.common.NILProperties;

/**
 * TrapSender allows the sending of well defined SNMP traps.
 */
public final class TrapSender
{
    private static final Logger LOGGER = Logger.getLogger(TrapSender.class);
    private static TrapSender instance;
    private static Lock mutex;

    private static final String ZIPTIE_EID = ".1.3.6.1.4.1.29510";
    private static final String ZIPTIE_TRAP_OBJECTS = ZIPTIE_EID + ".2";
    private static final String ZIPTIE_TRAP = ZIPTIE_EID + ".1";
    private static final int CHAANGE_TRAP_TYPE = 1;
    private static final OID CHANGE_TRAP_OID = new OID(ZIPTIE_TRAP + "." + CHAANGE_TRAP_TYPE);
    private static final int DEVICE_ADD_TYPE = 2;
    private static final OID DEVICE_ADD_TRAP_OID = new OID(ZIPTIE_TRAP + "." + DEVICE_ADD_TYPE);
    private static final int DEVICE_DELETE_TYPE = 3;
    private static final OID DEVICE_DELETE_TRAP_OID = new OID(ZIPTIE_TRAP + "." + DEVICE_DELETE_TYPE);
    private static final int FAILED_OPERATION_TYPE = 4;
    private static final OID FAILED_OPERATION_TRAP_OID = new OID(ZIPTIE_TRAP + "." + FAILED_OPERATION_TYPE);

    private DefaultUdpTransportMapping udpTransportMap;
    private Snmp snmp;
    private Set<CommunityTarget> receivers;

    static
    {
        mutex = new ReentrantLock();
    }

    /**
     * private constructor
     */
    private TrapSender()
    {
        try
        {
            udpTransportMap = new DefaultUdpTransportMapping();
            snmp = new Snmp(udpTransportMap);
        }
        catch (IOException e)
        {
            throw new RuntimeException("Error setting up the trap sender");
        }
        receivers = loadReceivers();
    }

    /**
     * Get the singleton instance of the TrapSender, or set one up if there isn't one yet. 
     * 
     * @return the <code>TrapSender</code> singleton instance
     */
    public static TrapSender getInstance()
    {
        mutex.lock();
        try
        {
            if (instance == null)
            {
                instance = new TrapSender();
            }
            return instance;
        }
        finally
        {
            mutex.unlock();
        }
    }

    /**
     * Closes out the SNMP sender.
     */
    public void shutdown()
    {
        try
        {
            snmp.close();
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            instance = null;
        }
    }

    /**
     * Returns true if there are hosts to send traps too.  This method is useful if you are about to send
     * many traps, but want to be sure there are hosts to send them to.
     * 
     * @return true if there are receivers, false otherwise
     */
    public boolean hasTrapReceivers()
    {
        return (receivers.size() > 0);
    }

    /**
     * Sends an SNMP trap denoting a configuration change on a device. 
     * 
     * @param deviceHostname the hostname of the device
     * @param deviceIpAddress the IPAddress of the device
     * @param managedNetwork the ZipTie managedNetwork that the device lives in
     * @param configurationName the name of the configuration that changed.
     */
    public void sendConfigChangeTrap(String deviceHostname, String deviceIpAddress, String managedNetwork, String configurationName)
    {
        List<VariableBinding> variables = new ArrayList<VariableBinding>();
        variables.add(getVarBind(TrapObjects.deviceHostname, deviceHostname));
        variables.add(getVarBind(TrapObjects.deviceIpAddress, deviceIpAddress));
        variables.add(getVarBind(TrapObjects.managedNetwork, managedNetwork));
        variables.add(getVarBind(TrapObjects.configurationName, configurationName));
        sendTrap(CHANGE_TRAP_OID, CHAANGE_TRAP_TYPE, variables);
    }

    /**
     * Send a trap indicating that a new device has been added to the inventory.
     * @param deviceHostname the hostname of the device
     * @param deviceIpAddress the primary IP address of the device
     * @param managedNetwork the managedNetwork to which the device belongs
     * @param adapterId the full Adapter ID associated with this device.  e.g. "ZipTie::Adapters::Cisco::IOS"
     * @param adapterShortName the shortName of the adapter associated with the device 
     */
    public void sendAddDeviceTrap(String deviceHostname, String deviceIpAddress, String managedNetwork, String adapterId, String adapterShortName)
    {
        List<VariableBinding> variables = new ArrayList<VariableBinding>();
        variables.add(getVarBind(TrapObjects.deviceHostname, deviceHostname));
        variables.add(getVarBind(TrapObjects.deviceIpAddress, deviceIpAddress));
        variables.add(getVarBind(TrapObjects.managedNetwork, managedNetwork));
        variables.add(getVarBind(TrapObjects.adapterName, adapterId));
        variables.add(getVarBind(TrapObjects.osType, adapterShortName));
        sendTrap(DEVICE_ADD_TRAP_OID, DEVICE_ADD_TYPE, variables);
    }

    /**
     * Send a trap indicating that a new device has been added to the inventory.
     * @param deviceHostname the hostname of the device
     * @param deviceIpAddress the primary IP address of the device
     * @param managedNetwork the managedNetwork to which the device belongs
     * @param adapterId the full Adapter ID associated with this device.  e.g. "ZipTie::Adapters::Cisco::IOS"
     * @param adapterShortName the shortName of the adapter associated with the device 
     */
    public void sendDeleteDeviceTrap(String deviceHostname, String deviceIpAddress, String managedNetwork, String adapterId, String adapterShortName)
    {
        List<VariableBinding> variables = new ArrayList<VariableBinding>();
        variables.add(getVarBind(TrapObjects.deviceHostname, deviceHostname));
        variables.add(getVarBind(TrapObjects.deviceIpAddress, deviceIpAddress));
        variables.add(getVarBind(TrapObjects.managedNetwork, managedNetwork));
        variables.add(getVarBind(TrapObjects.adapterName, adapterId));
        variables.add(getVarBind(TrapObjects.osType, adapterShortName));
        sendTrap(DEVICE_DELETE_TRAP_OID, DEVICE_DELETE_TYPE, variables);
    }

    /**
     * Send a trap indicating that an operation on a device failed, such as a backup failure. 
     * 
     * @param deviceHostname the hostname of the device
     * @param deviceIpAddress the primary IP address of the device
     * @param managedNetwork the managedNetwork to which the device belongs
     * @param operationName the name of the adapter operation, e.g. "backup"
     * @param messageDetail the reason for the failued, e.g. "invalid credentials"
     */
    public void sendFailedOperationTrap(String deviceHostname, String deviceIpAddress, String managedNetwork, String operationName, String messageDetail)
    {
        List<VariableBinding> variables = new ArrayList<VariableBinding>();
        variables.add(getVarBind(TrapObjects.deviceHostname, deviceHostname));
        variables.add(getVarBind(TrapObjects.deviceIpAddress, deviceIpAddress));
        variables.add(getVarBind(TrapObjects.managedNetwork, managedNetwork));
        variables.add(getVarBind(TrapObjects.operationName, operationName));
        variables.add(getVarBind(TrapObjects.messageDetail, messageDetail));
        sendTrap(FAILED_OPERATION_TRAP_OID, FAILED_OPERATION_TYPE, variables);
    }

    /**
     * Sends a ZipTie enterprise trap and puts the properties inside the arguments as varbindings on the trap.
     * 
     * @param trap the OID of the specific trap
     * @param specificType the specific trap type 
     * @param arguments an ordered array of arguments to be placed on the trap as OctetSting types
     */
    public void sendTrap(OID trap, int specificType, List<VariableBinding> arguments)
    {
        if (hasTrapReceivers())
        {
            PDU pdu = new PDU();
            pdu.setType(PDU.TRAP);
            pdu.add(new VariableBinding(SnmpConstants.sysUpTime, new TimeTicks()));
            pdu.add(new VariableBinding(SnmpConstants.snmpTrapOID, trap));
            pdu.add(new VariableBinding(SnmpConstants.snmpTrapEnterprise, new OID(ZIPTIE_EID)));

            for (VariableBinding vb : arguments)
            {
                pdu.add(vb);
            }

            try
            {
                for (CommunityTarget target : receivers)
                {
                    snmp.send(pdu, target);
                }
            }
            catch (Exception e)
            {
                LOGGER.error("Error sending SNMP trap. " + e.getMessage());
            }
        }
    }

    /**
     * Load up the trap receivers from the nil.properties file
     * 
     * @return the receivers.  This will be an empty set if there are none defined.
     */
    private Set<CommunityTarget> loadReceivers()
    {
        Set<CommunityTarget> targets = new HashSet<CommunityTarget>();
        String trapHosts = NILProperties.getInstance().getString(NILProperties.SNMP_TRAP_RECEIVERS);
        if (trapHosts.contains("@"))
        {
            int retries = Integer.parseInt(NILProperties.getInstance().getString(NILProperties.SNMP_TRAP_RETRIES));
            long timeout = Long.parseLong(NILProperties.getInstance().getString(NILProperties.SNMP_TRAP_TIMEOUT));
            String[] hosts = trapHosts.split(",");
            for (int i = 0; i < hosts.length; i++)
            {
                String[] pieces = hosts[i].split("@", 2);
                Address targetAddress = GenericAddress.parse("udp:" + pieces[1]);
                CommunityTarget target = new CommunityTarget();
                target.setCommunity(new OctetString(pieces[0]));
                target.setAddress(targetAddress);
                target.setVersion(SnmpConstants.version2c);
                target.setRetries(retries);
                target.setTimeout(timeout);
                targets.add(target);
            }
        }
        return targets;
    }

    /**
     * Get a {@link VariableBinding} for a well known type with the given string value.
     * 
     * @param objectType the type of the variable.
     * @param value the value of the varBind.
     * @return the SNMP4J var bind
     */
    private VariableBinding getVarBind(TrapObjects objectType, String value)
    {
        VariableBinding vb = new VariableBinding();

        String varValue = value;
        if (varValue == null)
        {
            varValue = "NULL";
        }

        switch (objectType)
        {
        case deviceHostname:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".1"));
            vb.setVariable(new OctetString(varValue));
            break;
        case deviceIpAddress:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".2"));
            vb.setVariable(new IpAddress(varValue));
            break;
        case managedNetwork:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".3"));
            vb.setVariable(new OctetString(varValue));
            break;
        case configurationName:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".4"));
            vb.setVariable(new OctetString(varValue));
            break;
        case adapterName:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".5"));
            vb.setVariable(new OctetString(varValue));
            break;
        case osType:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".6"));
            vb.setVariable(new OctetString(varValue));
            break;
        case operationName:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".7"));
            vb.setVariable(new OctetString(varValue));
            break;
        case messageDetail:
            vb.setOid(new OID(ZIPTIE_TRAP_OBJECTS + ".8"));
            vb.setVariable(new OctetString(varValue));
            break;
        default:
            break;
        }
        return vb;
    }

    /**
     * Defines the different SNMP trap object types.
     * 
     * TrapObjects
     */
    private enum TrapObjects
    {
        deviceHostname,
        deviceIpAddress,
        managedNetwork,
        configurationName,
        adapterName,
        osType,
        operationName,
        messageDetail,
    }
}
