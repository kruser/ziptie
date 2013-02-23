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
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.Restrictions;
import org.hibernate.exception.ConstraintViolationException;
import org.ziptie.exception.PersistenceException;
import org.ziptie.protocols.DeviceToProtocolMapping;
import org.ziptie.protocols.IProtocolPersister;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolConfig;
import org.ziptie.protocols.ProtocolConstants;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.credentials.internal.CredentialsProviderActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * The {@link DatabaseProtocolPersister} class provides an implementation of the {@link IProtocolPersister}
 * interface that uses a database in order to persist protocol information.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public class DatabaseProtocolPersister implements IProtocolPersister
{
    private static final String DEVICE_ID = "deviceId"; //$NON-NLS-1$
    private static final String STALE = "stale"; //$NON-NLS-1$
    private static final String THE_DEFAULT = "theDefault"; //$NON-NLS-1$

    private static IProtocolPersister instance = null;

    /**
     * Default private constructor for the {@link DatabaseProtocolPersister} classes in order to
     * prevent unnecessary instances of it from being created.
     */
    private DatabaseProtocolPersister()
    {
        // Do nothing.
    }

    /**
     * Retrieves the singleton instance of the {@link DatabaseProtocolPersister} class.
     * 
     * @return The singleton instance of the {@link DatabaseProtocolPersister} class.
     */
    public synchronized static IProtocolPersister getInstance()
    {
        if (instance == null)
        {
            instance = new DatabaseProtocolPersister();
        }
        return instance;
    }

    /**
     * {@inheritDoc}
     */
    public ProtocolConfig getDefaultProtocolConfig() throws PersistenceException
    {
        ProtocolConfig defaultProtocolConfig = null;

        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            // Grab the default protocol configuration
            Criteria criteria = currentSession.createCriteria(ProtocolConfig.class);
            criteria.add(Restrictions.eq(THE_DEFAULT, true));
            Object uniqueResult = criteria.uniqueResult();

            if (uniqueResult != null)
            {
                defaultProtocolConfig = (ProtocolConfig) uniqueResult;
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

        return defaultProtocolConfig;
    }

    /**
     * {@inheritDoc}
     */
    public Set<ProtocolConfig> getAllProtocolConfigs() throws PersistenceException
    {
        Set<ProtocolConfig> protocolConfigs = new HashSet<ProtocolConfig>();

        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
            SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
            Session currentSession = sessionFactory.getCurrentSession();

            // Grab all of the non-default protocol configurations
            Criteria criteria = currentSession.createCriteria(ProtocolConfig.class);
            criteria.add(Restrictions.eq(THE_DEFAULT, false));
            List<?> list = criteria.list();

            for (Iterator<?> iter = list.iterator(); iter.hasNext();)
            {
                ProtocolConfig cc = (ProtocolConfig) iter.next();
                protocolConfigs.add(cc);
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

        return protocolConfigs;
    }

    /** {@inheritDoc} */
    public ProtocolSet getProtocolSetByDeviceID(String deviceID, boolean returnStaleProtocols) throws PersistenceException
    {
        ProtocolSet protocolSet = null;
        List<DeviceToProtocolMapping> mappings = getDeviceToProtocolMappings(deviceID, returnStaleProtocols);
        if (mappings != null && mappings.size() > 0)
        {
            protocolSet = new ProtocolSet();
            for (DeviceToProtocolMapping dpm : mappings)
            {
                protocolSet.addProtocol(convertToProtocol(dpm));
            }
        }
        return protocolSet;
    }

    /**
     * {@inheritDoc}
     */
    public synchronized ProtocolConfig saveDefaultProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException
    {
        // Grab the previous default protocol config since another default config is about to be saved
        ProtocolConfig theDefaultProtoConfig = getDefaultProtocolConfig();

        // Mark the protocol config as the default
        protocolConfig.setTheDefault(true);

        // Make sure that at least the default managed network is set on the protocol config
        if (protocolConfig.getManagedNetwork() == null)
        {
            protocolConfig.setManagedNetwork(CredentialsProviderActivator.getNetworksProvider().getDefaultManagedNetwork().getName());
        }

        // Save the protocol config
        saveOrUpdate(protocolConfig);

        // Delete the old default if this wasn't just an update
        if (theDefaultProtoConfig != null && theDefaultProtoConfig.getId() != protocolConfig.getId())
        {
            clearDeviceToProtocolMappings(theDefaultProtoConfig);
            deleteProtocolConfig(theDefaultProtoConfig);
        }

        return protocolConfig;
    }

    /**
     * {@inheritDoc}
     */
    public synchronized ProtocolConfig saveProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException
    {
        // Mark the protocol config as NOT being the default
        protocolConfig.setTheDefault(false);

        // Make sure that at least the default managed network is set on the protocol config
        if (protocolConfig.getManagedNetwork() == null)
        {
            protocolConfig.setManagedNetwork(CredentialsProviderActivator.getNetworksProvider().getDefaultManagedNetwork().getName());
        }

        // Save the protocol config
        saveOrUpdate(protocolConfig);

        return protocolConfig;
    }

    /**
     * {@inheritDoc}
     */
    public void deleteProtocolConfig(ProtocolConfig protocolConfig) throws PersistenceException
    {
        if (protocolConfig != null)
        {
            try
            {
                boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
                SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
                Session currentSession = sessionFactory.getCurrentSession();

                if (protocolConfig != null)
                {
                    currentSession.delete(protocolConfig);
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

    /**
     * {@inheritDoc}
     */
    public String getProperty(String key)
    {
        return CredentialProperties.getInstance().getProperty(key);
    }

    /**
     * {@inheritDoc}
     */
    public void saveProperty(String key, String value) throws PersistenceException
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

    /** {@inheritDoc} */
    public void clearDeviceToProtocolMappings(ProtocolConfig protocolConfig) throws PersistenceException
    {
        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

        if (protocolConfig != null)
        {
            for (Protocol protocol : protocolConfig.getProtocols())
            {
                String hql = "DELETE " + DeviceToProtocolMapping.class.getName() + " WHERE fkProtocolId = " + protocol.getId();
                executeUpdate(hql);
            }
        }

        if (ownTransaction)
        {
            TransactionElf.commit();
        }
    }

    /** {@inheritDoc} */
    public void clearDeviceToProtocolMapping(String deviceID) throws PersistenceException
    {
        List<DeviceToProtocolMapping> deviceToProtocolMappings = getDeviceToProtocolMappings(deviceID, true);
        if (deviceToProtocolMappings.size() > 0)
        {
            try
            {
                boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
                SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
                Session currentSession = sessionFactory.getCurrentSession();

                for (DeviceToProtocolMapping dpm : deviceToProtocolMappings)
                {
                    currentSession.delete(dpm);
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
    public void mapDeviceToProtocolSet(String deviceID, ProtocolSet protocolSet) throws PersistenceException
    {
        try
        {
            clearDeviceToProtocolMapping(deviceID);
            List<DeviceToProtocolMapping> mappings = convertToDeviceToProtocolMappings(protocolSet, deviceID);
            for (DeviceToProtocolMapping dpm : mappings)
            {
                saveOrUpdate(dpm);
            }
        }
        catch (ConstraintViolationException e)
        {
            throw new PersistenceException(e);
        }
    }

    /** {@inheritDoc} */
    public void markDeviceToProtocolMappingAsStale(String deviceID) throws PersistenceException
    {
        List<DeviceToProtocolMapping> mappings = getDeviceToProtocolMappings(deviceID, false);
        for (DeviceToProtocolMapping dpm : mappings)
        {
            dpm.setStale(true);
            saveOrUpdate(dpm);
        }
    }

    /** {@inheritDoc} */
    public void markDeviceToProtocolMappingsAsStale(ProtocolConfig protocolConfig) throws PersistenceException
    {
        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

        if (protocolConfig != null)
        {
            for (Protocol protocol : protocolConfig.getProtocols())
            {
                String hql = "UPDATE " + DeviceToProtocolMapping.class.getName() + " SET " + STALE + " = " + true + " WHERE fkProtocolId = " + protocol.getId();
                executeUpdate(hql);
            }
        }

        if (ownTransaction)
        {
            TransactionElf.commit();
        }
    }

    /**
     * Retrieves a {@link List} of {@link DeviceToProtocolMapping} objects that are associated with the specified device ID.
     * 
     * @param deviceID The device ID that should exists on the located device-to-protocol mapping.
     * @param returnStaleProtocols Flag to determine whether or not a protocol that has been marked as stale should be returned.
     * @return A valid {@link DeviceToProtocolMapping} object if the specified device associated with the device ID has
     * a mapping to a valid set of protocols; null if there is no such mapping.
     */
    private List<DeviceToProtocolMapping> getDeviceToProtocolMappings(String deviceID, boolean returnStaleProtocol)
    {
        List<DeviceToProtocolMapping> toReturn = new ArrayList<DeviceToProtocolMapping>();

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        SessionFactory sessionFactory = CredentialsProviderActivator.getSessionFactory();
        Session currentSession = sessionFactory.getCurrentSession();

        // Get the device protocol mapping for the specified IP address
        Criteria criteria = currentSession.createCriteria(DeviceToProtocolMapping.class);
        criteria.add(Restrictions.eq(DEVICE_ID, Integer.valueOf(deviceID).intValue()));

        // If stale protocols should not be returned, make sure they are culled out
        if (!returnStaleProtocol)
        {
            criteria.add(Restrictions.eq(STALE, false));
        }

        // Grab all of the DeviceProtocolMapping objects
        List<?> list = criteria.list();
        for (Iterator<?> iter = list.iterator(); iter.hasNext();)
        {
            DeviceToProtocolMapping dpm = (DeviceToProtocolMapping) iter.next();
            toReturn.add(dpm);
        }

        if (ownTransaction)
        {
            TransactionElf.commit();
        }

        return toReturn;
    }

    /**
     * Creates a {@list DeviceToProtocolMapping} object for every protocol within a specified {@link ProtocolSet} object
     * and maps it to the specified device ID.
     *
     * @param protocolSet The protocol set to traverse for all of it's protocols.
     * @param deviceID The device to associate with each protocol.
     * @return A {@link List} of new created {@link DeviceToProtocolMapping} objects.
     */
    private List<DeviceToProtocolMapping> convertToDeviceToProtocolMappings(ProtocolSet protocolSet, String deviceID)
    {
        List<DeviceToProtocolMapping> mappings = new ArrayList<DeviceToProtocolMapping>();
        for (Protocol protocol : protocolSet.getProtocols())
        {
            DeviceToProtocolMapping deviceToProtocolMapping = new DeviceToProtocolMapping();
            deviceToProtocolMapping.setDeviceId(Integer.valueOf(deviceID).intValue());
            deviceToProtocolMapping.setProtocol(protocol);

            // These will keep the device to protocol propertiess at null if they aren't set
            deviceToProtocolMapping.setVersion(protocol.getProperty(ProtocolConstants.VERSION));
            deviceToProtocolMapping.setCipher(protocol.getProperty(ProtocolConstants.CIPHER));
            mappings.add(deviceToProtocolMapping);
        }
        return mappings;
    }

    /**
     * Converts a {@link DeviceToProtocolMapping} object to a {@link Protocol} object, being careful to overwrite the properties of the
     * protocol when necessary.
     *
     * @param deviceToProtocolMapping The device to protocol mapping object to convert into a protocol.
     * @return The protocol with its properties properly set.
     */
    private Protocol convertToProtocol(DeviceToProtocolMapping deviceToProtocolMapping)
    {
        Protocol protocol = deviceToProtocolMapping.getProtocol();
        if (deviceToProtocolMapping.getCipher() != null)
        {
            protocol.setProperty(ProtocolConstants.CIPHER, deviceToProtocolMapping.getCipher());
        }
        if (deviceToProtocolMapping.getVersion() != null)
        {
            protocol.setProperty(ProtocolConstants.VERSION, deviceToProtocolMapping.getVersion());
        }
        return protocol;
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
