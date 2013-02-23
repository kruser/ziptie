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

package org.ziptie.protocols;

import java.util.LinkedList;
import java.util.List;

import org.ziptie.protocols.utils.ProtocolConfigElf;

/**
 * Used to generate a ProtocolConfig object with the protocols filled out.
 * 
 * @author rkruse
 */
public final class UnitTestProtocolConfigElf
{
    private static final int SNMP_PRIORITY = 9;
    private static final int SNMP = 161;
    private static final int TFTP = 69;
    private static final int FTP_DATA = 21;
    private static final int HTTP = 80;
    private static final int HTTPS = 443;
    private static final int TELNET = 23;
    private static final int SSH = 22;

    /**
     * Private constructor for the <code>UnitTestProtocolConfigElf</code> class to disable support of a public default constructor.
     *
     */
    private UnitTestProtocolConfigElf()
    {
        // Does nothing.
    }

    /**
     * Get a new <code>ProtocolConfig</code> with the protocols preordered
     * 
     * @return a ProtocolConfig object
     */
    public static ProtocolConfig getNewConfig()
    {
        ProtocolConfig config = new ProtocolConfig();
        List<ProtocolProperty> sshProperties = new LinkedList<ProtocolProperty>();
        sshProperties.add(new ProtocolProperty(ProtocolConstants.VERSION, "auto"));
        config.addProtocol(new Protocol(ProtocolNames.SSH.name(), SSH, 1, true, true, sshProperties));
        config.addProtocol(new Protocol(ProtocolNames.Telnet.name(), TELNET, 2, true));
        config.addProtocol(new Protocol(ProtocolNames.HTTPS.name(), HTTPS, 3, true));
        config.addProtocol(new Protocol(ProtocolNames.HTTP.name(), HTTP, 4, true));
        config.addProtocol(new Protocol(ProtocolNames.SCP.name(), SSH, 5, true, true));

        // FTP is set as not TCP because we often act as the FTP server, 
        // i.e. we won't be hitting tcp/21 on the device
        config.addProtocol(new Protocol(ProtocolNames.FTP.name(), FTP_DATA, 6, false, true));
        config.addProtocol(new Protocol(ProtocolNames.TFTP.name(), TFTP, 7, false, true));

        List<ProtocolProperty> snmpProperties = new LinkedList<ProtocolProperty>();
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.TIMEOUT, Long.toString(ProtocolConfigElf.DEFAULT_TIMEOUT)));
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.RETRIES, Integer.toString(ProtocolConfigElf.DEFAULT_MAX_RETRIES)));
        snmpProperties.add(new ProtocolProperty(ProtocolConstants.VERSION, "v1"));
        config.addProtocol(new Protocol(ProtocolNames.SNMP.name(), SNMP, SNMP_PRIORITY, false, true, snmpProperties));
        return config;
    }
}
