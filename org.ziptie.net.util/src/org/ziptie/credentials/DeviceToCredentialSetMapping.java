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
 * Contributor(s): rkruse, Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.credentials;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.TableGenerator;

/**
 * The {@link DeviceToCredentialSetMapping} class provides functionality for mapping a device ID to a {@link CredentialSet} object.
 * This indicates the exact credentials that worked for the particular device that the device ID is associated with.
 *
 * @author rkruse
 * @author Dylan White (dylamite@ziptie.org)
 */
@Entity
@Table(name = "device_to_cred_set_mappings")
public class DeviceToCredentialSetMapping
{
    public static final int UNSAVED_ID = -1;

    @Column(name = "device_id")
    private int deviceId = UNSAVED_ID;
    private boolean stale;

    @ManyToOne
    @JoinColumn(name = "fkCredentialSetId", nullable = false)
    private CredentialSet credentialSet;

    // CHECKSTYLE:OFF
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen", table = "persistent_key_gen", pkColumnName = "seq_name", valueColumnName = "seq_value",
                    pkColumnValue = "device_to_cred_set_mappings_seq", initialValue = 1, allocationSize = 1)
    private long id = UNSAVED_ID;

    // CHECKSTYLE:ON

    /**
     * Retrieves the ID for this device-to-credential set mapping.
     * 
     * @return The ID.
     */
    public long getId()
    {
        return id;
    }

    /**
     * Sets the ID for this device-to-credential set mapping.
     * 
     * @param id The ID to assign this device-to-credential set mapping.
     */
    public void setId(long id)
    {
        this.id = id == 0 ? -1 : id;
    }

    /**
     * Retrieves that {@link CredentialSet} object used in this mapping.
     * 
     * @return the credentialSet
     */
    public CredentialSet getCredentialSet()
    {
        return credentialSet;
    }

    /**
     * Sets the {@link CredentialSet} object to be used in this mapping.
     * 
     * @param credentialSet The credential set to use in this mapping.
     */
    public void setCredentialSet(CredentialSet credentialSet)
    {
        this.credentialSet = credentialSet;
    }

    /**
     * Retrieves the ID of the device that is used in this mapping.
     * 
     * @return The ID of the device used in this mapping.
     */
    public int getDeviceId()
    {
        return deviceId;
    }

    /**
     * Sets the ID of the device to be used in this mapping.
     * 
     * @param deviceId The ID of the device to be used in this mapping.
     */
    public void setDeviceId(int deviceId)
    {
        this.deviceId = deviceId;
    }

    /**
     * Retrieves a boolean flag denoting whether or not the {@link CredentialSet} object used in this mapping is considered to
     * be stale/old.
     *
     * @return Whether or not the credential set is stale/old.
     */
    public boolean isStale()
    {
        return stale;
    }

    /**
     * Specifies whether or not the {@link CredentialSet} object used in this mapping is to be considered stale/old.
     *
     * @param stale Whether or not the {@link CredentialSet} object used in this mapping is to be considered stale/old.
     */
    public void setStale(boolean stale)
    {
        this.stale = stale;
    }
}
