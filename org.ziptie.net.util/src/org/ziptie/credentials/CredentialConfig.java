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

package org.ziptie.credentials;

import java.util.Set;
import java.util.TreeSet;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.TableGenerator;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.addressing.AddressSet;

/**
 * @author rkruse
 */
@Entity
@Table(name = "cred_config")
public class CredentialConfig implements Comparable, Cloneable
{
    public static final int UNSAVED_ID = -1;

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value", pkColumnValue = "Credential_Config_seq", initialValue = 1, allocationSize = 1)
    private long id = UNSAVED_ID;
    // CHECKSTYLE:ON

    private int priority = -1;
    private boolean theDefault;

    @OneToOne
    @JoinColumn(name = "fkAddressSetIdCc")
    @Cascade(value = { CascadeType.ALL, CascadeType.DELETE_ORPHAN })
    private AddressSet addressSet;

    @Column(name = "configName")
    private String name = "";

    @Column(name = "network")
    private String managedNetwork;

    @OneToMany
    @JoinColumn(name = "fkCredentialConfigId", nullable = false)
    @Cascade(value = { CascadeType.ALL, CascadeType.DELETE_ORPHAN })
    private Set<CredentialSet> credentialSets;

    /**
     * Default constructor needed for any web services to utilize the <code>CredentialConfig</code> class.
     */
    public CredentialConfig()
    {
        this.name = "";
        this.credentialSets = new TreeSet<CredentialSet>();
        this.addressSet = new AddressSet();
    }

    /**
     * Create a new <code>CredentialConfig</code> with the given name and an
     * empty set of credentials
     * 
     * @param name the name of the configuration
     */
    public CredentialConfig(String name)
    {
        this();
        this.name = name;

    }

    /**
     * @return Returns the id.
     */
    public long getId()
    {
        return id;
    }

    /**
     * @param id
     *            The id to set.
     */
    public void setId(long id)
    {
        this.id = id <= 0 ? -1 : id;
    }

    /**
     * @return Returns the name.
     */
    public String getName()
    {
        return name;
    }

    /**
     * @param name
     *            The name to set.
     */
    public void setName(String name)
    {
        this.name = name;
    }

    public AddressSet getAddressSet()
    {
        return addressSet;
    }

    public void setAddressSet(AddressSet addressSet)
    {
        this.addressSet = addressSet;
    }

    /**
     * Add a {@link CredentialSet} to this configuration
     * @param credentialSet the credentialSet to be added
     */
    public void addCredentialSet(CredentialSet credentialSet)
    {
        credentialSets.add(credentialSet);
    }

    /**
     * @param credentialSets all credentialSets
     */
    public void setCredentialSets(Set<CredentialSet> credentialSets)
    {
        if (credentialSets instanceof TreeSet)
        {
            this.credentialSets = credentialSets;
        }
        else
        {
            this.credentialSets = new TreeSet<CredentialSet>(credentialSets);
        }
    }

    /**
     * Get all configured CredentialSets
     * @return the credential sets
     */

    public Set<CredentialSet> getCredentialSets()
    {
        return credentialSets;
    }

    /**
     * Retrieve the name of the managed network that this credential config belongs to.
     * 
     * @return the managedNetwork The name of a managed network.
     */
    public String getManagedNetwork()
    {
        return managedNetwork;
    }

    /**
     * Sets the managed network name that this credential config belongs to.
     * 
     * @param managedNetwork The name of a managed network.
     */
    public void setManagedNetwork(String managedNetwork)
    {
        this.managedNetwork = managedNetwork;
    }

    /**
     * @return Returns the priority.
     */
    public int getPriority()
    {
        return priority;
    }

    /**
     * @param priority
     *            The priority to set.
     */
    public void setPriority(int priority)
    {
        this.priority = priority;
    }

    /**
     * There should only be one default <code>CredentialConfig</code>
     *
     * @return the theDefault
     */
    @XmlTransient
    public boolean isTheDefault()
    {
        return theDefault;
    }

    /**
     * There should only be one default <code>CredentialConfig</code>
     *
     * @param theDefault the theDefault to set
     */
    public void setTheDefault(boolean theDefault)
    {
        this.theDefault = theDefault;
    }

    /** {@inheritDoc} */
    public int compareTo(Object o)
    {
        if (!(o instanceof CredentialConfig))
        {
            throw new ClassCastException("Expected a CredentialConfig object");
        }
        else
        {
            return this.getPriority() - ((CredentialConfig) o).getPriority();
        }
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = super.hashCode();

        result = prime * result + (int) (id ^ (id >>> 32));
        return result;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object obj)
    {
        if (this == obj)
        {
            return true;
        }
        if (obj == null)
        {
            return false;
        }
        if (getClass() != obj.getClass())
        {
            return false;
        }

        final CredentialConfig other = (CredentialConfig) obj;
        if ((id > UNSAVED_ID) && (other.getId() > UNSAVED_ID))
        {
            return (id == other.getId());
        }
        else
        {
            if (credentialSets == null)
            {
                if (other.credentialSets != null)
                {
                    return false;
                }
            }
            else if (!credentialSets.equals(other.credentialSets))
            {
                return false;
            }
            if (id != other.id)
            {
                return false;
            }
            if (priority != other.priority)
            {
                return false;
            }
            if (theDefault != other.theDefault)
            {
                return false;
            }
            if (managedNetwork == null)
            {
                if (other.managedNetwork != null)
                {
                    return false;
                }
            }
            else if (!managedNetwork.equals(other.managedNetwork))
            {
                return false;
            }
            return true;
        }
    }

    /** {@inheritDoc} */
    @Override
    public CredentialConfig clone()
    {
        try
        {
            CredentialConfig clone = (CredentialConfig) super.clone();

            Set<CredentialSet> sets = getCredentialSets();
            TreeSet<CredentialSet> newSets = new TreeSet<CredentialSet>();
            for (CredentialSet set : sets)
            {
                newSets.add(set.clone());
            }
            clone.setCredentialSets(newSets);
            return clone;
        }
        catch (CloneNotSupportedException e)
        {
            // this should never happen. (using runtime exception to remove exceptions from the method signiture)
            throw new RuntimeException(e);
        }
    }
}
