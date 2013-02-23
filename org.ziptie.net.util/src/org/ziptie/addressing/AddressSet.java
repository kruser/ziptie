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

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.Table;
import javax.persistence.TableGenerator;
import javax.persistence.Transient;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;

/**
 * The <code>AddressSet</code> holds types of {@link NetworkAddress} objects
 * with a special {@link #contains(NetworkAddress)} method that knows how to
 * figure if an {@link IPAddress} is part of a range or a subnet.<br>
 * <br>
 * The <code>AddressSet</code> uses a normal <code>HashSet</code> as the
 * base. The methods {@link #add(NetworkAddress)},
 * {@link #remove(NetworkAddress)} and {@link #contains(NetworkAddress)} all
 * synchronize on the class to allow for the use of the <code>AddressSet</code>
 * as a cache.<br>
 * <br>
 * Note: the {@link #iterator()} method is not thread safe.
 * 
 * @author rkruse
 */
@Entity
@Table(name = "address_set")
public class AddressSet implements Serializable, Iterable<NetworkAddress>, Cloneable
{
    public static final int UNSAVED_ID = -1;
    public static final long serialVersionUID = 1189145515347268669L;

    public static final String TYPE_SINGLE = "ADDRESS";
    public static final String TYPE_RANGE = "RANGE";
    public static final String TYPE_SUBNET = "SUBNET";
    public static final String TYPE_WILDCARD = "WILDCARD";

    @CollectionOfElements
    @JoinTable(name = "addresses", joinColumns = @JoinColumn(name = "fkAddressSetId"))
    @Column(name = "value", nullable = false)
    @Cascade(value = { CascadeType.ALL, CascadeType.DELETE_ORPHAN })
    private List<String> addresses;

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value", pkColumnValue = "Address_Set_seq", initialValue = 1, allocationSize = 1)
    private int id = UNSAVED_ID;
    
    @Transient
    @Deprecated
    private String name;

    // CHECKSTYLE:OFF

    /**
     * Default constructor.
     */
    public AddressSet()
    {
        addresses = new LinkedList<String>();
    }

    /** {@inheritDoc} */
    public Iterator<NetworkAddress> iterator()
    {
        Set<NetworkAddress> networkAddresses = new HashSet<NetworkAddress>();

        for (String networkAddress : addresses)
        {
            NetworkAddress addr = NetworkAddressElf.parseAddress(networkAddress);
            networkAddresses.add(addr);
        }

        return networkAddresses.iterator();
    }

    /**
     * Get the addresses defined by this address set.
     * @return The addresses as strings.
     */
    public List<String> getAddresses()
    {
        return addresses;
    }

    /**
     * Sets the addresses to use for this address set.
     * @param addresses The addresses as strings.
     */
    public void setAddresses(List<String> newAddressesList)
    {
        addresses = new LinkedList<String>(newAddressesList);
    }

    public int getId()
    {
        return id;
    }

    public void setId(int id)
    {
        this.id = id == 0 ? UNSAVED_ID : id;
    }

    /**
     * The number of addresses in this set.
     * @return The number of addresses.
     */
    public int size()
    {
        return addresses.size();
    }

    /**
     * Add the given address to this address set.
     * @param address The address to add.
     * @return <tt>true</tt> if this set did not already contain the specified
     *         address
     */
    public synchronized boolean add(NetworkAddress address)
    {
        return addresses.add(address.toString());
    }

    /**
     * Removes the given address from this set.
     * @param address The address to remove
     * @return <tt>true</tt> if this set contained the specified address
     */
    public synchronized boolean remove(NetworkAddress address)
    {
        return addresses.remove(address.toString());
    }

    /**
     * Determines if an address is contained by this address set.
     * @param networkAddress The address
     * @return <code>true</code> if the given address is encompassed by this set's defined addresses.
     */
    public synchronized boolean contains(NetworkAddress networkAddress)
    {
        boolean addressMatch = true;
        if (addresses != null)
        {
            addressMatch = false;
            IPAddress firstAddress = null;
            IPAddress lastAddress = null;
            if (networkAddress instanceof Subnet)
            {
                firstAddress = ((Subnet) networkAddress).getNetworkAddress();
                lastAddress = ((Subnet) networkAddress).getBroadcastAddress();
            }
            else if (networkAddress instanceof IPRange)
            {
                firstAddress = ((IPRange) networkAddress).getRangeStart();
                lastAddress = ((IPRange) networkAddress).getRangeEnd();
            }
            else if (networkAddress instanceof IPAddress)
            {
                firstAddress = (IPAddress) networkAddress;
                lastAddress = (IPAddress) networkAddress;
            }
            else
            {
                // Only check Subnet, IPAddress and IPRange. Other
                // NetworkAddresses should be considered filters only.
                return false;
            }

            Iterator<NetworkAddress> iterator = iterator();
            while (iterator.hasNext())
            {
                NetworkAddress filterAddr = iterator.next();

                if (filterAddr instanceof Subnet)
                {
                    addressMatch = ((Subnet) filterAddr).contains(firstAddress) || ((Subnet) filterAddr).contains(lastAddress);
                }
                else if (filterAddr instanceof IPRange)
                {
                    addressMatch = ((IPRange) filterAddr).contains(firstAddress) || ((IPRange) filterAddr).contains(lastAddress);
                }
                else if (filterAddr instanceof IPAddress)
                {
                    addressMatch = filterAddr.equals(firstAddress) || filterAddr.equals(lastAddress);
                }
                else if (filterAddr instanceof IPWildcard)
                {
                    addressMatch = ((IPWildcard) filterAddr).contains(firstAddress) || ((IPWildcard) filterAddr).contains(lastAddress);
                }
                if (addressMatch)
                {
                    break;
                }
            }
        }
        return addressMatch;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return addresses.toString();
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((addresses == null) ? 0 : addresses.hashCode());
        return result;
    }

    /** {@inheritDoc} */
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
        final AddressSet other = (AddressSet) obj;
        if (addresses == null)
        {
            if (other.addresses != null)
            {
                return false;
            }
        }
        else if (!addresses.equals(other.addresses))
        {
            return false;

        }
        else if (id != other.id)
        {
            return false;
        }
        return true;
    }

    /** {@inheritDoc} */
    @Override
    public AddressSet clone()
    {
        try
        {
            AddressSet clone = (AddressSet) super.clone();
            List<String> newAddresses = new ArrayList<String>();
            for (String address : addresses)
            {
                newAddresses.add(address);
            }
            clone.setAddresses(newAddresses);
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
     * Clears out all addresses in the set
     * 
     */
    public void clear()
    {
        addresses.clear();
    }

    /**
     * @return Returns the name.
     * @deprecated the id should be used as the key now
     */
    @Deprecated
    public String getName()
    {
        return name;
    }

    /**
     * @param name The name to set.
     * @deprecated the id should be used as the key now
     */
    @Deprecated
    public void setName(String name)
    {
        this.name = name;
    }
}
