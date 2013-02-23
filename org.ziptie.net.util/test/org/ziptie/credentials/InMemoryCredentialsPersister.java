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

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.TreeSet;

import org.ziptie.exception.PersistenceException;

/**
 * An in-memory implementation of the <code>ICredentialsPersister</code> to be
 * used with unit testing. <br>
 * <br>
 * Note: this doesn't use thread safe collections. It is intended to be used for
 * unit testing only.
 * 
 * @author rkruse
 */
public class InMemoryCredentialsPersister implements ICredentialsPersister
{
    private static final String PRIVATE = "private";
    private static final String PUBLIC = "public";
    private static final String BIGTEX = "bigtex";
    private static final String TESTLAB = "testlab";
    private static final String HOBBIT = "hobbit";
    private static final String DEFAULT = "default";
    private static final String SET_COMMUNITY = "setCommunity";
    private static final String GET_COMMUNITY = "getCommunity";
    private static final String ENABLE_PASSWORD = "enablePassword";
    private static final String ENABLE_USERNAME = "enableUsername";
    private static final String PASSWORD = "password";
    private static final String USERNAME = "username";
    private Set<CredentialConfig> credentialConfigs;
    private CredentialConfig defaultCredentialConfig;
    private long idCounter = 1;
    private Map<String, CredentialSetStatus> workingCredentialSetIDs;
    private Properties globalProperties;

    /**
     * Default constructor
     */
    public InMemoryCredentialsPersister()
    {
        credentialConfigs = new TreeSet<CredentialConfig>();
        workingCredentialSetIDs = new HashMap<String, CredentialSetStatus>();
        globalProperties = new Properties();
        setupDefault();
    }

    /**
     * {@inheritDoc}
     */
    public CredentialConfig saveDefaultCredentialConfig(CredentialConfig credentialConfig)
    {
        idEverything(credentialConfig);
        this.defaultCredentialConfig = credentialConfig;
        return credentialConfig;
    }

    /**
     * {@inheritDoc}
     */
    public Collection<CredentialConfig> getAllCredentialConfigs()
    {
        return credentialConfigs;
    }

    /**
     * {@inheritDoc}
     */
    public CredentialConfig getDefaultCredentialConfig()
    {
        return defaultCredentialConfig;
    }

    /**
     * {@inheritDoc}
     */
    public CredentialConfig saveCredentialConfig(CredentialConfig credentialConfig)
    {
        idEverything(credentialConfig);
        credentialConfigs.add(credentialConfig);
        return credentialConfig;
    }

    /**
     * {@inheritDoc}
     */
    public void purgeUnmappedCredentialSets()
    {
        throw new RuntimeException("The credentials purge functionality is not implemented in " + InMemoryCredentialsPersister.class.getName() + ".");
    }

    /**
     * {@inheritDoc}
     */
    public void deleteCredentialConfig(CredentialConfig credentialConfig)
    {
        CredentialConfig toDelete = null;
        for (CredentialConfig cc : credentialConfigs)
        {
            if (cc.getId() == credentialConfig.getId())
            {
                toDelete = cc;
            }
        }
        if (toDelete != null)
        {
            credentialConfigs.remove(toDelete);
        }
    }

    /**
     * {@inheritDoc}
     */
    public String getProperty(String key)
    {
        return globalProperties.getProperty(key);
    }

    /**
     * {@inheritDoc}
     */
    public void saveProperty(String key, String value)
    {
        globalProperties.setProperty(key, value);
    }

    /**
     * {@inheritDoc}
     */
    public void clearDeviceToCredentialSetMapping(String deviceID) throws PersistenceException
    {
        workingCredentialSetIDs.remove(deviceID);
    }

    /**
     * {@inheritDoc}
     */
    public void clearDeviceToCredentialSetMappings(CredentialSet credentialSet) throws PersistenceException
    {
        Set<String> keys = workingCredentialSetIDs.keySet();
        for (String key : keys)
        {
            CredentialSetStatus csStatus = workingCredentialSetIDs.get(key);
            if (csStatus.getCredentialSetId() == credentialSet.getId())
            {
                workingCredentialSetIDs.remove(key);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public CredentialSet getCredentialSetByDeviceID(String deviceID, boolean returnStaleCredential) throws PersistenceException
    {
        CredentialSetStatus csStatus = workingCredentialSetIDs.get(deviceID);
        if (csStatus == null)
        {
            return null;
        }
        else
        {
            if (!returnStaleCredential && csStatus.isStale())
            {
                return null;
            }
            else
            {
                return getCredentialSet(csStatus.getCredentialSetId());
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void mapDeviceToCredentialSetMapping(String deviceID, CredentialSet credentialSet) throws PersistenceException
    {
        workingCredentialSetIDs.put(deviceID, new CredentialSetStatus(credentialSet.getId(), false));
    }

    /**
     * {@inheritDoc}
     */
    public void markDeviceToCredentialSetMappingAsStale(String deviceID) throws PersistenceException
    {
        CredentialSetStatus csStatus = workingCredentialSetIDs.get(deviceID);
        if (csStatus != null)
        {
            csStatus.setStale(true);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void markDeviceToCredentialSetMappingsAsStale(CredentialSet credentialSet) throws PersistenceException
    {
        Set<String> keys = workingCredentialSetIDs.keySet();
        for (String key : keys)
        {
            CredentialSetStatus csStatus = workingCredentialSetIDs.get(key);
            if (csStatus.getCredentialSetId() == credentialSet.getId())
            {
                csStatus.setStale(true);
            }
        }
    }

    /**
     * Retrieves the <code>CredentialSet</code> based on the object's ID field
     * 
     * @param tempID
     * @return
     */
    private CredentialSet getCredentialSet(Long tempID)
    {
        // Try all configs stored by address
        for (CredentialConfig cc : getAllCredentialConfigs())
        {
            for (CredentialSet cs : cc.getCredentialSets())
            {
                if (cs.getId() == tempID.longValue())
                {
                    return cs;
                }
            }
        }

        // try the default
        for (CredentialSet cs : getDefaultCredentialConfig().getCredentialSets())
        {
            if (cs.getId() == tempID.longValue())
            {
                return cs;
            }
        }
        return null;
    }

    /**
     * Increments a counter ID much like an auto incrementing database field
     * 
     * @return
     */
    private long getNewID()
    {
        idCounter++;
        return idCounter;
    }

    /**
     * Put an ID on everything in the <code>CredentialConfig</code>
     * 
     * @param credentialConfig
     */
    private void idEverything(CredentialConfig credentialConfig)
    {
        if (credentialConfig.getId() < 0)
        {
            credentialConfig.setId(getNewID());
            for (CredentialSet cs : credentialConfig.getCredentialSets())
            {
                cs.setId(getNewID());
                for (Credential cred : cs.getCredentials())
                {
                    cred.setId(getNewID());
                }
            }
        }
    }

    /**
     * Sets up the default <code>Credentials</code>
     */
    private void setupDefault()
    {
        CredentialSet defaultCS = new CredentialSet(DEFAULT);
        defaultCS.addCredential(new Credential(USERNAME, "boy_george"));
        defaultCS.addCredential(new Credential(PASSWORD, HOBBIT));
        defaultCS.addCredential(new Credential(ENABLE_USERNAME, TESTLAB));
        defaultCS.addCredential(new Credential(ENABLE_PASSWORD, BIGTEX));
        defaultCS.addCredential(new Credential(GET_COMMUNITY, PUBLIC));
        defaultCS.addCredential(new Credential(SET_COMMUNITY, PRIVATE));
        defaultCS.setPriority(1);

        CredentialSet defaultCS2 = new CredentialSet("default2");
        defaultCS2.addCredential(new Credential(USERNAME, TESTLAB));
        defaultCS2.addCredential(new Credential(PASSWORD, HOBBIT));
        defaultCS2.addCredential(new Credential(ENABLE_USERNAME, TESTLAB));
        defaultCS2.addCredential(new Credential(ENABLE_PASSWORD, BIGTEX));
        defaultCS2.addCredential(new Credential(GET_COMMUNITY, PUBLIC));
        defaultCS2.addCredential(new Credential(SET_COMMUNITY, PRIVATE));
        defaultCS2.setPriority(2);

        CredentialConfig defaultCC = new CredentialConfig(DEFAULT);
        defaultCC.addCredentialSet(defaultCS);
        defaultCC.addCredentialSet(defaultCS2);

        saveDefaultCredentialConfig(defaultCC);
    }

    /**
     * Internally used class for keeping track if an IP-to-CredentialSet mapping
     * is stale or not
     * 
     * @author rkruse
     */
    private static class CredentialSetStatus
    {
        private boolean stale;
        private long credentialSetId = -1;

        public CredentialSetStatus(long credentialSetId, boolean stale)
        {
            this.stale = stale;
            this.credentialSetId = credentialSetId;
        }

        /**
         * @return the credentialSetId
         */
        public long getCredentialSetId()
        {
            return credentialSetId;
        }

        /**
         * @param credentialSetId the credentialSetId to set
         */
        public void setCredentialSetId(long credentialSetId)
        {
            this.credentialSetId = credentialSetId;
        }

        /**
         * @return the stale
         */
        public boolean isStale()
        {
            return stale;
        }

        /**
         * @param stale the stale to set
         */
        public void setStale(boolean stale)
        {
            this.stale = stale;
        }
    }
}

// -------------------------------------------------
// $Log: UnitTestCredentialsPersister.java
// $Revision 1.1 Oct 23, 2006 rkruse
// $Code Templates
// $
// --------------------------------------------------
