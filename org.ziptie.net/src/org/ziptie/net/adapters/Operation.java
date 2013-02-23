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
 * Contributor(s): Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.net.adapters;

import java.util.LinkedList;
import java.util.List;

import org.ziptie.protocols.ProtocolSet;

/**
 * The <code>Operation</code> class represents a simple container to store the name of an operation that
 * an adapter can perform and what collection of protocols can be used to perform that operation.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
@SuppressWarnings("nls")
public class Operation
{
    /**
     * The name of the operation.
     */
    private String name;
    
    /**
     * Regular expression used to match the name of a configuration file that can restored during a restore
     * operation.
     */
    private String restoreValidationRegex;

    /**
     * The collection of protocol sets that the operation can be used with.
     */
    private List<ProtocolSet> protocolSets;

    /**
     * Package-accessible constructor since only the <code>AdapterService</code> class
     * should be able to create new <code>Operation</code> objects. 
     */
    protected Operation()
    {
        name = "";
        protocolSets = new LinkedList<ProtocolSet>();
    }

    /**
     * Retrieves the name of this <code>Operation</code>.
     * 
     * @return The name of the operation.
     */
    public String getName()
    {
        return name;
    }

    /**
     * Sets a new name for this <code>Operation</code>.
     * 
     * @param name The new name for the operation.
     */
    protected void setName(String newName)
    {
        name = newName;
    }

    /**
     * Retrieves all of the <code>ProtocolSet</code> objects that this <code>Operation</code>
     * currently supports.
     *  
     * @return A <code>List</code> of <code>ProtocolSet</code> objects that the operation is able to
     * use to perform its task(s).
     */
    public List<ProtocolSet> getProtocolSets()
    {
        return protocolSets;
    }

    /**
     * Adds all of the protocol sets in a list to the existing list of protocol sets that this
     * <code>Operation</code> supports.
     * 
     * @param protocolSetsToAdd A <code>List</code> of addition <code>ProtocolSet</code> objects that the operation
     * can use to perform its task(s).
     */
    protected void addProtocolSets(List<ProtocolSet> protocolSetsToAdd)
    {
        protocolSets.addAll(protocolSetsToAdd);
    }

    /**
     * Adds a protocol set to the existing list of supported protocol sets that this <code>Operation</code> supports.
     * 
     * @param protocolSet A <code>ProtocolSet</code> that the operation can use to perform its task(s).
     */
    protected void addProtocolSet(ProtocolSet protocolSet)
    {
        protocolSets.add(protocolSet);
    }
    
    /**
     * Gets the regular expression that can be used to validate whether or not a device configuration
     * can be restored.
     * 
     * @return A validation regular expression.
     */
    public String getRestoreValidationRegex()
    {
        return restoreValidationRegex;
    }

    /**
     * Sets the regular expression that can be used to validate whether or not a device configuration
     * can be restored.
     * 
     * @param regex A validation regular expression.
     */
    protected void setRestoreValidationRegex(String regex)
    {
        this.restoreValidationRegex = regex;
    }
    
    /**
     * Appends a new restore validation regular expression to the existing restore validation regular expression.
     * 
     * @param regexToAppend A new restore validation regular expression to append to the existing 
     * restore validation regular expression.
     */
    protected void addRestoreValidationRegex(String regexToAppend)
    {
        // Make sure that our existing regular expression exists
        if (getRestoreValidationRegex() != null)
        {
            String newRegex = String.format("%s|%s", getRestoreValidationRegex(), regexToAppend.trim());
            setRestoreValidationRegex(newRegex);
        }
        else
        {
            setRestoreValidationRegex(regexToAppend.trim());
        }
    }

    /**
     * {@inheritDoc}
     */
    public String toString()
    {
        StringBuilder buffer = new StringBuilder();
        buffer.append("Name: ").append(getName()).append("\n");

        buffer.append("Supported Protocol Sets:\n");
        for (ProtocolSet ps : protocolSets)
        {
            buffer.append("\t").append(ps.getName()).append("\n");
        }

        return buffer.toString();
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj)
    {
        // Check to see if both objects reference the same object in memory
        if (this == obj)
        {
            return true;
        }

        // Check to see if the object passed in is valid
        if (obj == null)
        {
            return false;
        }

        try
        {
            final Operation other = (Operation) obj;

            // Check the names against each other
            if (name != other.name)
            {
                return false;
            }
            // Check the protocol sets against each other
            else if (protocolSets == null)
            {
                if (other.protocolSets != null)
                {
                    return false;
                }
            }
            else if (!protocolSets.equals(other.protocolSets))
            {
                return false;
            }

        }
        catch (ClassCastException e)
        {
            return false;
        }

        // If we have gotten this far, then return true
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode()
    {
        return toString().hashCode();
    }
}
