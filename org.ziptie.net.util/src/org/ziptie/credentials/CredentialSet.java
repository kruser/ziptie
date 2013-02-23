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

import java.util.HashSet;
import java.util.Set;

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

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * Holds a list of <code>Credential</code> objects
 * 
 * @author rkruse
 */
@Entity
@Table(name = "cred_set")
public class CredentialSet implements Comparable<CredentialSet>, Cloneable
{
    private static final int UNSAVED = -1;

    @OneToMany(fetch = FetchType.EAGER)
    @JoinColumn(name = "fkCredentialSetId", nullable = false)
    @Cascade(value = { CascadeType.ALL, CascadeType.DELETE_ORPHAN })
    private Set<Credential> credentials;

    @Column(name = "credSetName")
    private String name = "";

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name",
                    valueColumnName = "seq_value", pkColumnValue = "Credential_Set_seq", initialValue = 1, allocationSize = 1)
    private long id = -1;
    // CHECKSTYLE:ON

    private int priority = UNSAVED;

    /**
     * Default constructor needed for any web services to utilize the <code>CredentialSet</code> class.
     */
    public CredentialSet()
    {
        credentials = new HashSet<Credential>();
    }

    /**
     * Constructs a <code>CredentialSet</code> based on the incoming
     * credentials
     * 
     * @param name the credential set name
     * @param credentials the credentials
     */
    public CredentialSet(String name, Set<Credential> credentials)
    {
        this.name = name;
        this.credentials = credentials;
    }

    /**
     * Constructs a <code>CredentialSet</code> with an empty list of
     * credentials
     * 
     * @param name the name of this credential set
     */
    public CredentialSet(String name)
    {
        this(name, new HashSet<Credential>());
    }

    /**
     * @return Returns the credentials.
     */
    public Set<Credential> getCredentials()
    {
        return credentials;
    }

    /**
     * @param credentials The credentials to set.
     */
    public void setCredentials(Set<Credential> credentials)
    {
        this.credentials = credentials;
    }

    /**
     * Add a <code>Credential</code> to the list
     * 
     * @param credential the credential to add
     */
    public void addCredential(Credential credential)
    {
        credentials.add(credential);
    }

    /**
     * @return Returns the name.
     */
    public String getName()
    {
        return name;
    }

    /**
     * @param name The name to set.
     */
    public void setName(String name)
    {
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
     * @param id The id to set.
     */
    public void setId(long id)
    {
        this.id = id <= 0 ? -1 : id;
    }

    /**
     * @param credentialName the named credential
     * @return the value of this credential
     * @throws CredentialNotSetException if the credential with the given name isn't set
     */
    public String getCredentialValue(String credentialName) throws CredentialNotSetException
    {
        for (Credential cred : credentials)
        {
            if (cred.getName().equalsIgnoreCase(credentialName))
            {
                return cred.getValue();
            }
        }
        throw new CredentialNotSetException("Credential '" + credentialName + "' not set in the CredentialSet named '" + getName() + "'.");
    }

    /**
     * @return Returns the priority.
     */
    public int getPriority()
    {
        return priority;
    }

    /**
     * @param priorityValue a relative priority number
     */
    public void setPriority(int priorityValue)
    {
        this.priority = priorityValue;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(CredentialSet cs)
    {
        int result = this.getPriority() - cs.getPriority();
        if (result != 0)
        {
            return result;
        }
        else
        {
            return name.compareTo(cs.getName());
        }
    }

    /**
     * Returns true if all of the {@link Credential} key/value pairs underneath
     * are the same. Pays no attention to the {@link Credential#getId()} or any
     * other instance variables.
     * 
     * @param other the other object
     * @return true if the given <code>CredentialSet</code> has the same credentials as this one
     */
    public boolean credentialsEqual(CredentialSet other)
    {
        if (credentials == null)
        {
            if (other.credentials != null)
            {
                return false;
            }
        }
        else if (!credentials.equals(other.credentials))
        {
            return false;
        }
        return true;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        final int prime = 31;

        int result = 1;
        result = prime * result + ((credentials == null) ? 0 : credentials.hashCode());
        result = prime * result + (int) (id ^ (id >>> 32));
        result = prime * result + ((name == null) ? 0 : name.hashCode());
        result = prime * result + priority;
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
        final CredentialSet other = (CredentialSet) obj;
        if (id != other.id)
        {
            return false;
        }
        if (name == null)
        {
            if (other.name != null)
            {
                return false;
            }
        }
        else if (!name.equals(other.name))
        {
            return false;
        }
        if (priority != other.priority)
        {
            return false;
        }
        return credentialsEqual(other);
    }

    /** {@inheritDoc} */
    @Override
    public CredentialSet clone() throws CloneNotSupportedException
    {
        CredentialSet clone = (CredentialSet) super.clone();

        Set<Credential> creds = getCredentials();
        HashSet<Credential> newCreds = new HashSet<Credential>(creds.size());
        for (Credential credential : creds)
        {
            newCreds.add(credential.clone());
        }
        clone.setCredentials(newCreds);
        return clone;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        StringBuilder string = new StringBuilder();
        for (Credential credential : credentials)
        {
            string.append(credential + "\n");
        }
        return string.toString();
    }

    /**
     * If there is an existing <code>Credential</code> already in this set,
     * remove it and add the new one. Otherwise just add the new one with teh
     * given credentialName and credentialValue.
     * 
     * @param credentialName the name of the credential, e.g. 'username'
     * @param credentialValue the value of the credential
     */
    public void addOrUpdate(String credentialName, String credentialValue)
    {
        synchronized (credentials)
        {
            Credential toDelete = null;
            for (Credential cred : credentials)
            {
                if (cred.getName().equalsIgnoreCase(credentialName))
                {
                    toDelete = cred;
                }
            }

            if (toDelete != null)
            {
                credentials.remove(toDelete);
            }

            addCredential(new Credential(credentialName, credentialValue));
        }
    }

    /**
     * Sets the ID of this object to the unsaved value as well as of the
     * underlying {@link Credential} objects.
     */
    public void resetIds()
    {
        setId(UNSAVED);
        for (Credential credential : credentials)
        {
            credential.setId(UNSAVED);
        }
    }
}
