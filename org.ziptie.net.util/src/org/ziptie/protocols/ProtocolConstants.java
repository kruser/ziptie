/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: rkruse $
 *     $Date: 2008/02/26 22:43:49 $
 * $Revision: 1.4 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net.util/src/org/ziptie/protocols/ProtocolConstants.java,v $e
 */

package org.ziptie.protocols;

/**
 * Used in the properties of a {@link Protocol} as the keys
 * 
 * @author rkruse
 */
public interface ProtocolConstants
{
    /**
     * Example usage is for SSH or SNMP versions
     */
    String VERSION = "Version";

    /**
     * SSH v1 cipher types
     */
    String CIPHER = "Cipher";

    /**
     * Example usage is for SNMP timeout times
     */
    String TIMEOUT = "Timeout(ms)";

    /**
     * Example usage is for SNMP retry counts
     */
    String RETRIES = "Retries";

    /**
     * Used for the SNMPv3 authentication alogorithm
     */
    String SNMP_V3_AUTH_ALGORITHM = "V3 Authentication";

    /**
     * Used for the SNMPv3 encryption mechanism
     */
    String SNMP_V3_PRIVACY = "V3 Encryption";
}
