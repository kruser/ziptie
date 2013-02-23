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

import java.io.Serializable;
import java.util.LinkedList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.TableGenerator;
import javax.persistence.Transient;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * A <code>Protocol</code> object contains a name (for example: "Telnet"), a
 * port value, a priority value, and a <code>HashMap</code> containing any
 * number of properties that could be associated with a <code>Protocol</code>.
 * 
 * @author dwhite
 */
@Entity
@Table(name = "protocols")
public class Protocol implements Serializable, Comparable, Cloneable
{
    public static final int UNSAVED_ID = -1;

    private static final long serialVersionUID = -407324601057271126L;

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value", pkColumnValue = "Protocol_seq", initialValue = 1, allocationSize = 1)
    private long id = UNSAVED_ID;
    // CHECKSTYLE:ON

    @Column(name = "protocolName")
    private String name;

    private int port;
    private int priority;
    private boolean enabled = true;

    @Column(name = "TCP")
    private boolean isTCP;

    @OneToMany(fetch = FetchType.EAGER)
    @JoinColumn(name = "fkProtocolId", nullable = false)
    @Cascade(value = { CascadeType.ALL, CascadeType.DELETE_ORPHAN })
    private List<ProtocolProperty> properties;
    
    @Transient
    private boolean validatedOnDevice;

    /**
     * Public constructor for creating a <code>Protocol</code> object.
     * 
     * The name is initialized to an empty string, the port and priority values
     * are initialized to -1, and the <code>HashMap</code> of properties is
     * initialized to a brand new <code>HashMap</code>.
     */
    public Protocol()
    {
        setName("");
        setPort(UNSAVED_ID);
        setPriority(-1);
        setProperties(new LinkedList<ProtocolProperty>());
    }

    /**
     * 
     * @param name The name of the <code>Protocol</code> (for example:
     *            "Telnet").
     * @param port The port value of the <code>Protocol</code>.
     * @param priority The priority value of the <code>Protocol</code>.
     * @param isTCP - default false, set this to true on all TCP ports like
     *            HTTP. TCP ports will be scanned by the
     *            <code>ProtocolManager</code> when it decides what protocols
     *            to list for a given device.
     */
    public Protocol(String name, int port, int priority, boolean isTCP)
    {
        this(name, port, priority, isTCP, new LinkedList<ProtocolProperty>());
    }

    /**
     * Public constructor for creating a <code>Protocol</code> object.
     * 
     * @param name
     * @param port
     * @param priority
     * @param isTCP
     * @param properties
     */
    public Protocol(String name, int port, int priority, boolean isTCP, LinkedList<ProtocolProperty> properties)
    {
        this(name, port, priority, isTCP, true, properties);
    }

    /**
     * Public constructor for creating a <code>Protocol</code> object.
     * 
     * @param name
     * @param port
     * @param priority
     * @param isTCP
     * @param enabled
     */
    public Protocol(String name, int port, int priority, boolean isTCP, boolean enabled)
    {
        this(name, port, priority, isTCP, enabled, new LinkedList<ProtocolProperty>());
    }

    /**
     * Public constructor for creating a <code>Protocol</code> object.
     * 
     * @param name
     * @param port
     * @param priority
     * @param isTCP
     * @param enabled
     * @param sshProperties
     */
    public Protocol(String name, int port, int priority, boolean isTCP, boolean enabled, List<ProtocolProperty> properties)
    {
        setName(name);
        setPort(port);
        setPriority(priority);
        setProperties(properties);
        this.isTCP = isTCP;
        this.enabled = enabled;
    }

    /**
     * Retrieves the name assigned to this <code>Protocol</code> object.
     * 
     * @return The name assigned to this <code>Protocol</code> object (for
     *         example: "Telnet").
     */
    public String getName()
    {
        return name;
    }

    /**
     * Sets the name for this <code>Protocol</code> object.
     * 
     * @param name The name to assign this <code>Protocol</code> object (for
     *            example: "Telnet").
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * Retrieves the port value assigned to this <code>Protocol</code> object.
     * 
     * @return The port value assigned to this <code>Protocol</code> object.
     */
    public int getPort()
    {
        return port;
    }

    /**
     * Sets the port value for this <code>Protocol</code> object.
     * 
     * @param port The port value to assign this <code>Protocol</code> object.
     */
    public void setPort(int port)
    {
        this.port = port;
    }

    /**
     * Retrieves the priority value assigned to this <code>Protocol</code>
     * object.
     * 
     * @return The priority value assigned to this <code>Protocol</code>
     *         object.
     */
    public int getPriority()
    {
        return priority;
    }

    /**
     * Sets the priority value for this <code>Protocol</code> object.
     * 
     * @param priority The priority value to assign this <code>Protocol</code>
     *            object.
     */
    public void setPriority(int priority)
    {
        this.priority = priority;
    }

    /**
     * Retrieves the value of a property, specified by a key/name identifier,
     * that has been set on this <code>Protocol</code> object.
     * 
     * @param key The key/name identifier for the property value to be
     *            retrieved.
     * @return The value of a property, specified by a key/name identifier, that
     *         has been set on this <code>Protocol</code> object. Returns
     *         <code>null</code> if there isn't a matching property set
     */
    public String getProperty(String key)
    {
        // Grab the ProtocolProperty object that is represented by the specified key
        ProtocolProperty foundProperty = getProtocolProperty(key);

        // Grab the value from the found ProtocolProperty
        String value = foundProperty != null ? foundProperty.getValue() : null;

        return value;
    }

    private ProtocolProperty getProtocolProperty(String key)
    {
        ProtocolProperty foundProperty = null;

        if (properties != null)
        {
            for (ProtocolProperty property : properties)
            {
                if (property.getKey().equalsIgnoreCase(key))
                {
                    foundProperty = property;
                    break;
                }
            }
        }

        return foundProperty;
    }

    /**
     * Sets a property on this <code>Protocol</code> object according to a
     * key/value pair.
     * 
     * @param key The key/name identifier of the property being set.
     * @param value The value to of the property being set.
     */
    public void setProperty(String key, String value)
    {
        // Create an LinkedList if our internal properties list is undefined
        if (properties == null)
        {
            properties = new LinkedList<ProtocolProperty>();
        }

        // Make sure that we aren't adding another property of the same name
        ProtocolProperty existingProp = getProtocolProperty(key);
        if (existingProp != null)
        {
            // Update the existing property
            existingProp.setValue(value);
        }
        else
        {
            // Create the property
            ProtocolProperty newProp = new ProtocolProperty(key, value);

            // Add the new property to our list
            properties.add(newProp);
        }

    }

    /**
     * Retrieves the <code>List</code> of <code>ProtocolProperty</code> objects representing all of the properties
     * associated with this <code>Protocol</code> object.
     * 
     * @return The <code>List</code> of <code>ProtocolProperty</code> objects representing all of the properties
     *         associated with this <code>Protocol</code> object.
     */
    public List<ProtocolProperty> getProperties()
    {
        return properties;
    }

    /**
     * Sets the properties on this <code>Protocol</code> object according to a
     * specified <code>List</code> of <code>ProtocolProperty</code> objects.
     * 
     * @param properties The <code>List</code> of <code>ProtocolProperty</code> objects
     * representing the properties to assign this <code>Protocol</code> object.
     */
    public void setProperties(List<ProtocolProperty> protocolPropertiesList)
    {
        this.properties = protocolPropertiesList;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString()
    {
        StringBuilder buffer = new StringBuilder();

        buffer.append("Name: ").append(name).append('\n');
        buffer.append("Port: ").append(port).append('\n');
        buffer.append("Priority: ").append(priority).append('\n');

        for (ProtocolProperty prop : properties)
        {
            buffer.append("Key/Value: ").append(prop.toString()).append('\n');
        }

        return buffer.toString();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        return this.toString().hashCode();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object object)
    {
        if (this == object)
        {
            return true;
        }

        if (object == null)
        {
            return false;
        }

        try
        {
            Protocol other = (Protocol) object;
            return (checkEquals(getName(), other.getName()) && (getPort() == other.getPort()) && (getPriority() == other.getPriority()));
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    /**
     * Private utility method to check if two <code>String</code> object are
     * equal. It also checks for null values.
     * 
     * @param left
     * @param right
     * @return Whether or not two <code>String</code> objects are equal.
     */
    private boolean checkEquals(String left, String right)
    {
        if ((left == null && right != null) || (left != null && right == null))
        {
            return false;
        }
        else if (left == null && right == null)
        {
            return true;
        }
        return left != null && left.equals(right);
    }

    /**
     * @see java.lang.Comparable#compareTo(java.lang.Object)
     */
    public int compareTo(Object o) throws ClassCastException
    {
        if (!(o instanceof Protocol))
        {
            throw new ClassCastException("Expected a Protocol object");
        }
        else
        {
            return this.getPriority() - ((Protocol) o).getPriority();
        }
    }

    /**
     * The enabled flag is mainly used by the ProtocolManager to determine which
     * protocols are allowed.
     * 
     * @return
     */
    public boolean isEnabled()
    {
        return enabled;
    }

    /**
     * The enabled flag is mainly used by the ProtocolManager to determine which
     * protocols are allowed.
     * 
     * @param enabled
     */
    public void setEnabled(boolean enabled)
    {
        this.enabled = enabled;
    }

    /**
     * @return the id
     */
    public long getId()
    {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(long id)
    {
        this.id = id == 0 ? -1 : id;
    }

    /**
     * Indicates if this <code>Protocol</code> is TCP. The default value is
     * false and should stay false for all other transfer protocols, e.g. UDP.
     * 
     * @return the isTCP
     */
    public boolean isTCP()
    {
        return isTCP;
    }

    /**
     * Indicates if this <code>Protocol</code> is TCP. The default value is
     * false and should stay false for all other transfer protocols, e.g. UDP.
     * 
     * @param isTCPflag the isTCP to set
     */
    public void setTCP(boolean isTCPflag)
    {
        isTCP = isTCPflag;
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    // ignore erasure warning.
    @Override
    public Protocol clone() throws CloneNotSupportedException
    {
        Protocol clone = (Protocol) super.clone();

        List<ProtocolProperty> clonedProps = new LinkedList<ProtocolProperty>();
        for (ProtocolProperty prop : properties)
        {
            clonedProps.add(prop.clone());
        }

        clone.setProperties(clonedProps);

        return clone;
    }

    /**
     * @return the validatedOnDevice
     */
    public boolean isValidatedOnDevice()
    {
        return validatedOnDevice;
    }

    /**
     * @param validatedOnDevice the validatedOnDevice to set
     */
    public void setValidatedOnDevice(boolean validatedOnDevice)
    {
        this.validatedOnDevice = validatedOnDevice;
    }
}
