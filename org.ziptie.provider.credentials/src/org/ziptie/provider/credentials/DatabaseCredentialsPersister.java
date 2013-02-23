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

package org.ziptie.provider.credentials;

import java.io.IOException;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.Restrictions;
import org.ziptie.credentials.CredentialConfig;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.credentials.DeviceToCredentialSetMapping;
import org.ziptie.credentials.ICredentialsPersister;
import org.ziptie.exception.PersistenceException;
import org.ziptie.provider.credentials.internal.CredentialsProviderActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * The {@link DatabaseCredentialsPersister} class provides an implementation of the {@link ICredentialsPersister}
 * interface that uses a database in order to persist credential information.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public class DatabaseCredentialsPersister implements ICredentialsPersister
{
    private static final String DEVICE_ID = "deviceId"; //$NON-NLS-1$
    private static final String STALE = "stale"; //$NON-NLS-1$
    private static final String THE_DEFAULT = "theDefault"; //$NON-NLS-1$
    private static final String CREDENTIAL_SET_ID = "fkCredentialSetId"; //$NON-NLS-1$
    private static final Logger LOGGER = Logger.getLogger(DatabaseCredentialsPersister.class);
    private static ICredentialsPersister instance = null;

    /**
     * Default private constructor for the {@link DatabaseCredentialsPersister} classes in order to
     * prevent unnecessary instances of it from being created.
     */
    private DatabaseCredentialsPersister()
    {
        // Do nothing.
    }

    /**
     * Retrieves the singleton instance of the {@link DatabaseCredentialsPersister} class.
     * 
     * @return The singleton instance of the {@link DatabaseCredentialsPersister} class.
     */
    public synchronized static ICredentialsPersister getInstance()
    {
        if (instance == null)
        {
            instance = new DatabaseCredentialsPersister();
        }
        return instance;
    }

    /** {@inheritDoc} */
    public void clearDeviceToCredentialSetMapping(String deviceID) throws PersistenceException
    {
        String hql = "DELETE " + DeviceToCredentialSetMapping.class.getName() + " WHERE " + DEVICE_ID + " = " + Integer.valueOf(deviceID).intValue();
        executeUpdate(hql);
    }

    /** {@inheritDoc} */
    public void clearDeviceToCredentialSetMappings(CredentialSet credentialSet) throws PersistenceException
    {
        String hql = "DELETE " + DeviceToCredentialSetMapping.class.getName() + " WHERE " + CREDENTIAL_SET_ID + " = " + credentialSet.getId();
        executeUpdate(hql);
    }

    /** {@inheritDoc} */
    public void deleteCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException
    {
        if (credentialConfig != null)
        {
            try
            {
                boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
                SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
                Session currentSession = sessionFactory.getCurrentSession();

                if (credentialConfig != null)
                {
                    currentSession.delete(credentialConfig);
                }

                if (ownTransaction)
                {
                    TransactionElf.commit();
                }
            }
            catch (RuntimeException e)
            {
                TransactionElf.rollback();
                throw new PersistenceException(e);
            }
        }
    }

    /** {@inheritDoc} */
    public Collection<CredentialConfig> getAllCredentialConfigs() throws PersistenceException
    {
        Set<CredentialConfig> credentialConfigs = new HashSet<CredentialConfig>();

        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            // Grab all of the non-default credential configurations
            Criteria criteria = currentSession.createCriteria(CredentialConfig.class);
            criteria.add(Restrictions.eq(THE_DEFAULT, false));
            List<?> list = criteria.list();

            for (Iterator<?> iter = list.iterator(); iter.hasNext();)
            {
                CredentialConfig cc = (CredentialConfig) iter.next();
                credentialConfigs.add(cc);
            }

            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
        catch (RuntimeException e)
        {
            throw new PersistenceException(e);
        }

        return credentialConfigs;
    }

    /** {@inheritDoc} */
    public CredentialSet getCredentialSetByDeviceID(String deviceID, boolean returnStaleCredential) throws PersistenceException
    {
        CredentialSet credentialSet = null;

        DeviceToCredentialSetMapping mapping = getDeviceToCredentialSetMapping(deviceID, returnStaleCredential);
        if (mapping != null)
        {
            credentialSet = mapping.getCredentialSet();
        }

        return credentialSet;
    }

    /** {@inheritDoc} */
    public CredentialConfig getDefaultCredentialConfig() throws PersistenceException
    {
        CredentialConfig defaultCC = null;

        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            // Grab the default credential configuration
            Criteria criteria = currentSession.createCriteria(CredentialConfig.class);
            criteria.add(Restrictions.eq(THE_DEFAULT, true));
            Object uniqueResult = criteria.uniqueResult();

            if (uniqueResult != null)
            {
                defaultCC = (CredentialConfig) uniqueResult;
            }

            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
        catch (RuntimeException e)
        {
            throw new PersistenceException(e);
        }

        return defaultCC;
    }

    /** {@inheritDoc} */
    public String getProperty(String key)
    {
        return CredentialProperties.getInstance().getProperty(key);
    }

    /** {@inheritDoc} */
    public void mapDeviceToCredentialSetMapping(String deviceID, CredentialSet credentialSet) throws PersistenceException
    {
        DeviceToCredentialSetMapping savedMapping = getDeviceToCredentialSetMapping(deviceID, true);
        DeviceToCredentialSetMapping mapping = new DeviceToCredentialSetMapping();

        if (savedMapping != null)
        {
            mapping = savedMapping;
        }

        mapping.setDeviceId(Integer.valueOf(deviceID).intValue());
        mapping.setStale(false);
        mapping.setCredentialSet(credentialSet);

        saveOrUpdate(mapping);
    }

    /** {@inheritDoc} */
    public void markDeviceToCredentialSetMappingAsStale(String deviceID) throws PersistenceException
    {
        DeviceToCredentialSetMapping mapping = getDeviceToCredentialSetMapping(deviceID, false);
        if (mapping != null)
        {
            mapping.setStale(true);
            saveOrUpdate(mapping);
        }
    }

    /** {@inheritDoc} */
    public void markDeviceToCredentialSetMappingsAsStale(CredentialSet credentialSet) throws PersistenceException
    {
        String hql = "UPDATE " + DeviceToCredentialSetMapping.class.getName() + " SET " + STALE + " = " + true + " WHERE " + CREDENTIAL_SET_ID + " = "
                + credentialSet.getId();
        executeUpdate(hql);
    }

    /** {@inheritDoc} */
    public void purgeUnmappedCredentialSets() throws PersistenceException
    {
        try
        {
            // Begin of join a transaction
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            // Retrieve the current Hibernate session
            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            // Retrieve all of the credentials to purge.  The keys in the map are credential set IDs and the values
            // in the map are credential config IDs
            Map<Long, Long> credSetsToPurge = getCredentialSetsToPurge();
            for (Entry<Long, Long> mapping : credSetsToPurge.entrySet())
            {
                // Attempt to grab the credential config object from the database
                Object credConfigObj = currentSession.get(CredentialConfig.class, mapping.getValue());
                if (credConfigObj != null)
                {
                    CredentialConfig credentialConfig = (CredentialConfig) credConfigObj;
                    boolean isTheDefault = credentialConfig.isTheDefault();
                    if (!isTheDefault || (isTheDefault && credentialConfig.getCredentialSets().size() > 1))
                    {
                        Object retrievedObj = currentSession.get(CredentialSet.class, mapping.getKey());
                        if (retrievedObj != null)
                        {
                            CredentialSet credentialSet = (CredentialSet) retrievedObj;
                            credentialConfig.getCredentialSets().remove(credentialSet);
                            deleteCredentialSet(credentialSet);
                        }
                    }
                }
            }

            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
        catch (PersistenceException e)
        {
            TransactionElf.rollback();
            throw e;
        }
    }

    /** {@inheritDoc} */
    public synchronized CredentialConfig saveCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException
    {
        // Mark the credential config as NOT being the default one and save it
        credentialConfig.setTheDefault(false);

        // Make sure that at least the default managed network is set on the credential config
        if (credentialConfig.getManagedNetwork() == null)
        {
            credentialConfig.setManagedNetwork(CredentialsProviderActivator.getNetworksProvider().getDefaultManagedNetwork().getName());
        }

        // Save the credential config
        saveOrUpdate(credentialConfig);

        return credentialConfig;
    }

    /** {@inheritDoc} */
    public synchronized CredentialConfig saveDefaultCredentialConfig(CredentialConfig credentialConfig) throws PersistenceException
    {
        // Grab the previous default credential config since a new default is about to be saved
        CredentialConfig theDefaultCredConfig = getDefaultCredentialConfig();

        // Mark the new credential config as the default
        credentialConfig.setTheDefault(true);

        // Make sure that at least the default managed network is set on the credential config
        if (credentialConfig.getManagedNetwork() == null)
        {
            credentialConfig.setManagedNetwork(CredentialsProviderActivator.getNetworksProvider().getDefaultManagedNetwork().getName());
        }

        // Save the credential config
        saveOrUpdate(credentialConfig);

        // Delete the old default if this wasn't just an update
        if (theDefaultCredConfig != null && theDefaultCredConfig.getId() != credentialConfig.getId())
        {
            for (CredentialSet credSet : theDefaultCredConfig.getCredentialSets())
            {
                clearDeviceToCredentialSetMappings(credSet);
            }
            deleteCredentialConfig(theDefaultCredConfig);
        }

        return credentialConfig;
    }

    /** {@inheritDoc} */
    public synchronized void saveProperty(String key, String value) throws PersistenceException
    {
        CredentialProperties props = CredentialProperties.getInstance();
        props.setProperty(key, value);
        try
        {
            props.save();
        }
        catch (IOException e)
        {
            throw new PersistenceException("Error saving property!", e);
        }
    }

    /**
     * Purges any device-to-credential set mappings containing the {@link CredentialSet} object specified,
     * and then the actual {@link CredentialSet} object is removed from the database.
     * 
     * @param credentialSet The credentials set to remove.
     * @throws PersistenceException if there was an error while clearing out the device-to-credential set mappings.
     */
    private void deleteCredentialSet(CredentialSet credentialSet) throws PersistenceException
    {
        if (credentialSet != null)
        {
            // Clear out all the credentials associated with the ID of the credential set
            LOGGER.info("Removing the unused credential set '" + credentialSet.getName() + "'");
            clearDeviceToCredentialSetMappings(credentialSet);

            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            if (credentialSet != null)
            {
                currentSession.delete(credentialSet);
            }
        }
    }

    /**
     * Retrieves the {@link DeviceToCredentialSetMapping} object for the specified device ID.
     * 
     * @param deviceID The device ID that should exists on the located device-to-credential set mapping.
     * @param returnStaleCredential Flag to determine whether or not a credential set that has been marked as stale should be returned.
     * @return A valid {@link DeviceToCredentialSetMapping} object if the specified device associated with the device ID has
     * a mapping to a valid credential set; null if there is no such mapping.
     */
    private DeviceToCredentialSetMapping getDeviceToCredentialSetMapping(String deviceID, boolean returnStaleCredential)
    {
        DeviceToCredentialSetMapping toReturn = null;

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
        Session currentSession = sessionFactory.getCurrentSession();

        // Get the device to credential set mapping for the specified device ID
        Criteria criteria = currentSession.createCriteria(DeviceToCredentialSetMapping.class);
        criteria.add(Restrictions.eq(DEVICE_ID, Integer.valueOf(deviceID).intValue()));

        // If stale credentials should not be returned, make sure they are culled out
        if (!returnStaleCredential)
        {
            criteria.add(Restrictions.eq(STALE, false));
        }

        // Grab the actual DeviceToCredentialSetMapping object
        Object uniqueResult = criteria.uniqueResult();
        if (uniqueResult != null)
        {
            toReturn = (DeviceToCredentialSetMapping) uniqueResult;
        }

        if (ownTransaction)
        {
            TransactionElf.commit();
        }

        return toReturn;
    }

    /**
     * Retrieves a {@link Map} of all the credential sets to be purged. The keys of the {@link Map} are the IDs of the
     * {@link CredentialSet} objects to purge, and the values are the IDs of the {@link CredentialConfig} objects associated with
     * the credential sets.
     * 
     * @return A {@link Map} of credential set IDs to credential config IDs.
     */
    private Map<Long, Long> getCredentialSetsToPurge()
    {
        Map<Long, Long> credSetsToPurge = new HashMap<Long, Long>();
        String sql = "SELECT DISTINCT a.id, a.fkCredentialConfigId FROM cred_set a LEFT OUTER JOIN device_to_cred_set_mappings b ON a.id = b.fkCredentialSetId WHERE (b.id IS NULL)";

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
        Session currentSession = sessionFactory.getCurrentSession();
        SQLQuery sqlQuery = currentSession.createSQLQuery(sql);

        // Execute our SQL statement and grab the results
        List<?> list = sqlQuery.list();

        // Iterate through all of the results, grabbing the CredentialSet ID from the 1st column,
        // and the CredentialConfig ID from the 2nd column.  Unlike JDBC, columns of results are numbered from zero.
        for (Iterator<?> iter = list.iterator(); iter.hasNext();)
        {
            Object[] row = (Object[]) iter.next();
            credSetsToPurge.put(Long.parseLong(row[0].toString()), Long.parseLong(row[1].toString()));
        }

        if (ownTransaction)
        {
            TransactionElf.commit();
        }

        return credSetsToPurge;
    }

    /**
     * Saves or updates a generic object to the database
     *
     * @param obj The generic object to save or update.
     * @throws PersistenceException If any issue occurred while trying save or update the generic object to the database.
     */
    private void saveOrUpdate(Object obj) throws PersistenceException
    {
        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            obj = currentSession.merge(obj);

            currentSession.saveOrUpdate(obj);

            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
        catch (RuntimeException e)
        {
            TransactionElf.rollback();
            throw new PersistenceException(e);
        }
    }

    /**
     * Executes an update against the database according to a specified HQL string.
     * 
     * @param hql The HQL string to describing the update to be executed against the database.
     * @throws PersistenceException If any issue occurred while trying to execute the update against the database.
     */
    private void executeUpdate(String hql) throws PersistenceException
    {
        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            currentSession.createQuery(hql).executeUpdate();

            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
        catch (RuntimeException e)
        {
            TransactionElf.rollback();
            throw new PersistenceException(e);
        }
    }
}
