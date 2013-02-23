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

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.TableGenerator;

/**
 * Holds a key-value pair
 *
 * @author rkruse
 */
@Entity
@Table(name = "protocol_props")
public class ProtocolProperty implements Cloneable
{
    public static final int UNSAVED_ID = -1;

    @Column(name = "propKey")
    private String key = "";

    @Column(name = "propValue")
    private String value = "";

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value",
                    pkColumnValue = "Protocol_Property_seq", initialValue = 1, allocationSize = 1)
    private long id = UNSAVED_ID;
    // CHECKSTYLE:ON

    /**
     * Default constructor for the <code>ProtocolProperty</code> class.
     */
    public ProtocolProperty()
    {
        // Do nothing
    }

    /**
     * Constructs a new <code>ProtocolProperty</code> instance and populates it with the specified key and value.
     * 
     * @param key The key for this protocol property.
     * @param value The value value of the protocol property.
     */
    public ProtocolProperty(String key, String value)
    {
        this.key = key;
        this.value = value;
    }

    /**
     * Retrieves the ID for this protocol property.
     * 
     * @return The ID.
     */
    public long getId()
    {
        return id;
    }

    /**
     * Sets the ID for this protocol property.
     * 
     * @param id The ID to assign this protocol property.
     */
    public void setId(long id)
    {
        this.id = id == 0 ? -1 : id;
    }

    /**
     * The key of the property.
     * @return the key
     */
    public String getKey()
    {
        return key;
    }

    /**
     * @param key the key to set
     */
    public void setKey(String key)
    {
        this.key = key;
    }

    /**
     * The value of the property.
     * @return the value
     */
    public String getValue()
    {
        return value;
    }

    /**
     * @param value the value to set
     */
    public void setValue(String value)
    {
        this.value = value;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString()
    {
        return key + "/" + value;
    }

    /** {@inheritDoc} */
    @Override
    public ProtocolProperty clone() throws CloneNotSupportedException
    {
        return (ProtocolProperty) super.clone();
    }
}