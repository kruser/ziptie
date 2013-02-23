/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/07/21 20:38:56 $
 * $Revision: 1.3 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/discovery/IDiscoveryEventHandler.java,v $e
 */

package org.ziptie.discovery;

/**
 * IDiscoveryEventHandler
 */
public interface IDiscoveryEventHandler
{
    /**
     * Method called when a discovery event occurs.
     *
     * @param discoveryEvent the discovery event that occurred
     */
    void handleEvent(DiscoveryEvent discoveryEvent);
}

