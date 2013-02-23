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

import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

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

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.ziptie.addressing.AddressSet;

/**
 * Maintains an ordered list of <code>Protocol</code> objects.
 * 
 * @author rkruse
 */
@Entity
@Table(name = "protocol_config")
public class ProtocolConfig implements Comparable, Cloneable
{
    public static final int UNSAVED_ID = -1;

    // CHECKSTYLE:OFF    
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value", pkColumnValue = "Protocol_Config_seq", initialValue = 1, allocationSize = 1)
    private long id = UNSAVED_ID;
    // CHECKSTYLE:OFN

    private int priority = -1;

    @OneToOne
    @JoinColumn(name = "fkAddressSetIdPc")
    @Cascade(value = { CascadeType.ALL, CascadeType.DELETE_ORPHAN })
    private AddressSet addressSet;

    @Column(name = "network")
    private String managedNetwork;

    private boolean theDefault;

    @Column(name = "configName")
    private String name = "";

    @OneToMany
    @JoinColumn(name = "fkProtocolConfigId", nullable = false)
    @Cascade(value = { CascadeType.ALL, CascadeType.DELETE_ORPHAN })
    private Set<Protocol> protocols;

    /**
     * Default constructor needed for any web services to utilize the <code>ProtocolConfig</code> class.
     */
    public ProtocolConfig()
    {
        protocols = new TreeSet<Protocol>();
        addressSet = new AddressSet();
    }

    /**
     * Returns an ordered Set of Protocol objects
     * 
     * @return protocols
     */
    public Set<Protocol> getProtocols()
    {
        return protocols;
    }

    /**
     * Sets the protocols.
     * @param protocols The protocol
     */
    public void setProtocols(Set<Protocol> protocols)
    {
        if (protocols instanceof TreeSet)
        {
            this.protocols = protocols;
        }
        else
        {
            this.protocols = new TreeSet<Protocol>(protocols);
        }
    }

    /**
     * Add a single protocol
     * @param protocol the protocol
     */
    public void addProtocol(Protocol protocol)
    {
        protocols.add(protocol);
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

    public AddressSet getAddressSet()
    {
        return addressSet;
    }

    public void setAddressSet(AddressSet addressSet)
    {
        this.addressSet = addressSet;
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
     * {@inheritDoc}
     */
    @Override
    public String toString()
    {
        StringBuilder string = new StringBuilder();
        string.append("Name(").append(name).append(") ID(").append(getId()).append(")\n");
        for (Protocol protocol : protocols)
        {
            string.append(protocol.toString());
        }
        return string.toString();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object obj)
    {
        try
        {
            if (this == null)
            {
                return false;
            }
            else if (this == obj)
            {
                return true;
            }

            final ProtocolConfig other = (ProtocolConfig) obj;
            if ((id > UNSAVED_ID) && other.getId() > UNSAVED_ID)
            {
                return (id == other.getId());
            }
            else
            {
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

                if (id != other.id)
                {
                    return false;
                }
                if (priority != other.priority)
                {
                    return false;
                }
                if (protocols == null)
                {
                    if (other.protocols != null)
                    {
                        return false;
                    }
                }
                else if (!protocols.equals(other.protocols))
                {
                    return false;
                }
                if (theDefault != other.theDefault)
                {
                    return false;
                }
                return true;
            }
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + (int) (id ^ (id >>> 32));
        return result;
    }

    /**
     * The priorty indicates its importance in regards to other ProtocolConfig
     * objects. The lower the number, the higher the priority.
     * 
     * @return the priority
     */
    public int getPriority()
    {
        return priority;
    }

    /**
     * The priorty indicates its importance in regards to other ProtocolConfig
     * objects. The lower the number, the higher the priority.
     * 
     * @param priority
     *            the priority to set
     */
    public void setPriority(int priority)
    {
        this.priority = priority;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o)
    {
        if (!(o instanceof ProtocolConfig))
        {
            throw new ClassCastException("Expected a ProtocolConfig object");
        }
        else
        {
            return this.getPriority() - ((ProtocolConfig) o).getPriority();
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ProtocolConfig clone()
    {
        try
        {
            ProtocolConfig clone = (ProtocolConfig) super.clone();
            Set<Protocol> protos = getProtocols();
            HashSet<Protocol> newProtos = new HashSet<Protocol>(protos.size());
            for (Protocol protocol : protos)
            {
                newProtos.add(protocol.clone());
            }
            clone.protocols = newProtos;
            return clone;
        }
        catch (CloneNotSupportedException e)
        {
            // this should never happen. (using runtime exception to remove
            // exceptions from the method signiture)
            throw new RuntimeException(e);
        }
    }

    /**
     * Set the name of this <code>ProtocolConfig</code>
     * 
     * @param name the name
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * The user defined name of the <code>ProtocolConfig</code>. This has no
     * effect on the operation of the underlying <code>Protocol</code>
     * objects.
     * 
     * @return the name
     */
    public String getName()
    {
        return name;
    }

    /**
     * There should only be one default <code>ProtocolConfig</code>
     *
     * @return the theDefault
     */
    @XmlTransient
    public boolean isTheDefault()
    {
        return theDefault;
    }

    /**
     * There should only be one default <code>ProtocolConfig</code>
     *
     * @param theDefault the theDefault to set
     */
    public void setTheDefault(boolean theDefault)
    {
        this.theDefault = theDefault;
    }
}
