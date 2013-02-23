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

/**
 * Helper class to generate simple <code>ProtocolSet</code> objects from a
 * String that is something like 'Telnet-TFTP'.
 * 
 * @author rkruse
 */
public final class ProtocolSetElf
{
    /**
     * Private constructor for the <code>ProtocolSetElf</code> class to disable support of a public default constructor.
     *
     */
    private ProtocolSetElf()
    {
        // Does nothing.
    }

    /**
     * Given a string (possible from an adapter), generate a
     * <code>ProtocolSet</code>. Ports won't be legit ports on the Protocols.
     * Only the names will be as described.
     * 
     * @param protocolSetName
     * @return
     */
    public static ProtocolSet createProtocolSet(String protocolSetName)
    {
        ProtocolSet newSet = new ProtocolSet();
        String[] protocolNames = protocolSetName.split(ProtocolSet.DELIMITER);
        for (int i = 0; i < protocolNames.length; i++)
        {
            Protocol newProtocol = new Protocol();
            newProtocol.setName(protocolNames[i]);
            newProtocol.setPriority(i);
            newSet.addProtocol(newProtocol);
        }
        return newSet;
    }

}
