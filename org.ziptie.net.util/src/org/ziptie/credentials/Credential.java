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

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.TableGenerator;

/**
 * Network Interface Layer (NIL) implementation of a credential object.
 * <p>
 * <p>
 * A <code>Credential</code> object is a simple name/value pair to map a
 * specific credential value a name identifier.
 * 
 * @author dwhite
 */
@Entity
@Table(name = "creds")
public class Credential implements Serializable, Cloneable
{
    public static final int UNSAVED_ID = -1;

    /**
     * <code>serialVersionUID</code> for serialization purposes.
     */
    private static final long serialVersionUID = -194418756728337558L;

    // Name of this credential
    @Column(name = "credentialName")
    private String name;

    // Value for this credential
    @Column(name = "credentialValue")
    private String value;

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value",
                    pkColumnValue = "Credentials_seq", initialValue = 1, allocationSize = 1)
    private long id = UNSAVED_ID;
    // CHECKSTYLE:ON

    /**
     * Public constructor for creating a <code>Credential</code> object. Both
     * the name and value are initialized to empty.
     */
    public Credential()
    {
        setName("");
        setValue("");
    }

    /**
     * Public constructor for creating a <code>Credential</code> object.
     * 
     * @param name
     *            The name of the <code>Credential</code> (for example:
     *            "username").
     * @param value
     *            The value of the <code>Credential</code> (for example:
     *            "secretValue").
     */
    public Credential(String name, String value)
    {
        setName(name);
        setValue(value);
    }

    /**
     * Retrieves the name of this <code>Credential</code> object.
     * 
     * @return The name of this <code>Credential</code> object.
     */
    public String getName()
    {
        return name;
    }

    /**
     * Sets the name on this <code>Credential</code> object.
     * 
     * @param name
     *            The name to assign this <code>Credential</code> object (for
     *            example: "username").
     */
    public void setName(String name)
    {
        this.name = name;
    }

    /**
     * Retrieves the value of this <code>Credential</code> object.
     * 
     * @return The value stored within this <code>Credential</code> object.<code>Credential</code> object.
     */
    public String getValue()
    {
        return value;
    }

    /**
     * Sets the value on this <code>Credential</code> object.
     * 
     * @param value
     *            The value to assign this <code>Credential</code> object (for
     *            example: "secretValue").
     */
    public void setValue(String value)
    {
        this.value = value;
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

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return getName() + "(" + getValue() + ")";
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return this.toString().hashCode();
    }

    /** {@inheritDoc} */
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
            Credential other = (Credential) object;
            return (checkEquals(getName(), other.getName()) && checkEquals(getValue(), other.getValue()));
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
        else if (null == left && null == right)
        {
            return true;
        }
        return left.equals(right);
    }

    /** {@inheritDoc} */
    @Override
    public Credential clone() throws CloneNotSupportedException
    {
        // do nothing more than copy the atomic primitives.
        return (Credential) super.clone();
    }
}
