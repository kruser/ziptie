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
package org.ziptie.adaptertool;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.snmp4j.AbstractTarget;
import org.ziptie.addressing.IPAddress;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.discovery.DiscoveryEvent;
import org.ziptie.net.snmp.SnmpException;
import org.ziptie.net.snmp.SnmpManager;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolNames;

/**
 * Tests the discovery against a set of devices.
 */
public class DiscoverCli
{
    private static final int SNMP_PORT = 161;
    private static String SYS_DESCR = "1.3.6.1.2.1.1.1.0"; //$NON-NLS-1$
    private static String SYS_OID = "1.3.6.1.2.1.1.2.0"; //$NON-NLS-1$
    private static String SYS_NAME = "1.3.6.1.2.1.1.5.0"; //$NON-NLS-1$

    private List<String> ipAddresses;
    private String roCommunity = "public"; //$NON-NLS-1$

    {
        ipAddresses = new LinkedList<String>();
    }

    /**
     * Execute the discover.
     */
    public void run()
    {
        CredentialSet cs = new CredentialSet("Discovery-Credentials"); //$NON-NLS-1$
        cs.addOrUpdate(SnmpManager.GET_COMMUNITY_KEY, roCommunity);
        Protocol snmpProtocol = new Protocol(ProtocolNames.SNMP.name(), SNMP_PORT, 1, false);

        List<String> oids = new ArrayList<String>();
        oids.add(SYS_DESCR);
        oids.add(SYS_OID);
        oids.add(SYS_NAME);

        for (String ipAddress : ipAddresses)
        {
            IPAddress ip = new IPAddress(ipAddress);
            DiscoveryEvent event = new DiscoveryEvent(ip);
            AbstractTarget target = SnmpManager.getInstance().buildTarget(ip, snmpProtocol, cs);
            try
            {
                Map<String, String> result = SnmpManager.getInstance().snmpGet(oids, target);
                event.setSysName(result.get(SYS_NAME));
                event.setSysOID(result.get(SYS_OID));
                event.setSysDescr(result.get(SYS_DESCR));
                event.setGoodEvent(true);

                String adapterId = AtConfigElf.getAdapterService().getAdapterId(event);
                if (ipAddresses.size() == 1)
                {
                    System.err.println(Messages.getString("DiscoverCli.eventDetails")); //$NON-NLS-1$
                    System.err.println("sysName:  " + event.getSysName()); //$NON-NLS-1$
                    System.err.println("sysOid:   " + event.getSysOID()); //$NON-NLS-1$
                    System.err.println("sysDescr: " + event.getSysDescr()); //$NON-NLS-1$
                    System.err.println();
                }
                System.err.printf(Messages.getString("DiscoverCli.identified"), ipAddress, adapterId); //$NON-NLS-1$
            }
            catch (SnmpException e)
            {
                System.err.println("The host " + ip + " is not responding to SNMP.");
            }
        }
    }

    /**
     * Add an IP Address to the list of devices to test.
     * @param ipAddress The IP Address.
     */
    public void addIpAddress(String ipAddress)
    {
        ipAddresses.add(ipAddress);
    }

    /**
     * Set the SNMP community string to use.
     * @param roCommunity The community string
     */
    public void setRoCommunity(String roCommunity)
    {
        this.roCommunity = roCommunity;
    }

    /**
     * Main
     * @param args the CLI arguments.
     */
    public static void main(String[] args)
    {
        try
        {
            CliElf.setupLog4j();
            AtConfigElf.loadSetup();

            DiscoverCli discover = new DiscoverCli();
            for (int i = 0; i < args.length; i++)
            {
                if (args[i].equals("-c")) //$NON-NLS-1$
                {
                    discover.setRoCommunity(CliElf.next(args, ++i));
                }
                else
                {
                    if (!NetworkAddressElf.isValidIpAddress(args[i]))
                    {
                        System.err.println(Messages.getString("DiscoverCli.invalidIp") + args[i]); //$NON-NLS-1$
                        System.exit(1);
                    }
                    discover.addIpAddress(args[i]);
                }
            }

            while (discover.ipAddresses.isEmpty())
            {
                String ip = CliElf.get(Messages.getString("DiscoverCli.specifyIpAddress")); //$NON-NLS-1$
                if (!NetworkAddressElf.isValidIpAddress(ip))
                {
                    System.err.println(Messages.getString("DiscoverCli.invalidIp") + ip); //$NON-NLS-1$
                }
                else
                {
                    discover.addIpAddress(ip);
                }
            }

            discover.run();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
    }
}
