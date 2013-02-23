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

package org.ziptie.addressing;

import java.util.Iterator;

/**
 * Interface that can be used to represent single devices, entire subnets, ranges of addresses, etc. etc.
 * 
 * Iterating across these objects is not threadsafe.  Only one iterator at a time is allowed.
 * 
 * @author rkruse
 */
public interface NetworkAddress extends Cloneable, Iterable<IPAddress>, Iterator<IPAddress>
{
    /**
     * Get the first value of this network address.  This may be a start of a range, 
     * a single IP address, or a network address depending on the implementation
     * 
     * @return the string value
     * @deprecated as of 3/13/2008 rjk.  This value was only useful for database storage of a network address.  
     *      Instead, store the toString of the object and use the <code>NetworkAddressElf</code> to recreate it.
     */
    String getFirstValue();

    /**
     * 
     * @return the string value
     * @deprecated as of 3/13/2008 rjk.  This value was only useful for database storage of a network address.  
     *      Instead, store the toString of the object and use the <code>NetworkAddressElf</code> to recreate it.
     */
    String getSecondValue();

    /**
     * @return the exclude
     * @deprecated
     */
    boolean getExclude();

    /**
     * Does this NetworkAddress contain the provided {@link IPAddress} 
     * @param testAddress the address to test
     * @return true if this address contains the testAddress
     */
    boolean contains(IPAddress testAddress);

    /**
     * Clone the address 
     * @return the clone
     * @throws CloneNotSupportedException if it can't be cloned
     */
    NetworkAddress clone() throws CloneNotSupportedException;
}
