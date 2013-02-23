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
 * Copyright the ZipTie Project (www.ziptie.org)
 */
package org.ziptie.provider.netman;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;

/**
 * ManagedNetwork
 */
@Entity(name = "managed_network")
public class ManagedNetwork
{
    @Id
    @Column(name = "name")
    private String name;

    @Column(name = "is_default")
    private boolean isDefault;

    /**
     * @return the name
     */
    public String getName()
    {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * @return whether this is the default Managed Network
     */
    public boolean isDefault()
    {
        return isDefault;
    }

    /**
     * Set whether this Managed Network is the default Managed Network.
     *
     * @param isDefault true if it is the default Managed Network, false otherwise
     */
    void setDefault(boolean def)
    {
        this.isDefault = def;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        try
        {
            return name.equals(((ManagedNetwork) obj).getName());
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return name.hashCode();
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return name;
    }
}
