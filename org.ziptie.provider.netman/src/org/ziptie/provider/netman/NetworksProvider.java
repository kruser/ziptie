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
 */
package org.ziptie.provider.netman;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import org.hibernate.Criteria;
import org.hibernate.HibernateException;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.Restrictions;
import org.osgi.framework.BundleContext;
import org.ziptie.provider.netman.internal.NetworksActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * NetworksProvider
 */
public class NetworksProvider implements INetworksProvider
{
    private static final String NAME = "name"; //$NON-NLS-1$
    private static final String IS_DEFAULT = "isDefault"; //$NON-NLS-1$

    private ManagedNetwork defaultNetwork;
    private ReadWriteLock rwLock;

    /**
     * Initialize this class with the BundleContext for this bundle so it can
     * lookup services.
     *
     * @param context the BundleContext for this bundle.
     */
    public NetworksProvider(BundleContext context)
    {
        rwLock = new ReentrantReadWriteLock();

    }

    /** {@inheritDoc} */
    public void defineManagedNetwork(String name)
    {
        if (name == null || name.length() == 0)
        {
            return;
        }

        Session session = null;
        try
        {
            rwLock.writeLock().lock();

            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            ManagedNetwork defaultManagedNetwork = getDefaultManagedNetwork();

            ManagedNetwork managedNetwork = new ManagedNetwork();
            managedNetwork.setName(name);
            managedNetwork.setDefault((defaultManagedNetwork == null));

            SessionFactory sessionFactory = NetworksActivator.getSessionFactory();
            session = sessionFactory.getCurrentSession();

            session.save(managedNetwork);

            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
        catch (RuntimeException e)
        {
            TransactionElf.rollback();
            throw e;
        }
        finally
        {
            rwLock.writeLock().unlock();
        }
    }

    /** {@inheritDoc} */
    public void deleteManagedNetwork(String name)
    {
        if (name == null || name.length() == 0)
        {
            return;
        }

        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            SessionFactory sessionFactory = NetworksActivator.getSessionFactory();
            Session session = sessionFactory.getCurrentSession();

            Criteria criteria = session.createCriteria(ManagedNetwork.class).add(Restrictions.eq(NAME, name));
            ManagedNetwork network = (ManagedNetwork) criteria.uniqueResult();
            session.delete(network);

            if (ownTransaction)
            {
                TransactionElf.commit();
            }

            throw new RuntimeException("Not implemented."); //$NON-NLS-1$
        }
        catch (RuntimeException e)
        {
            TransactionElf.rollback();
            throw e;
        }
    }

    /** {@inheritDoc} */
    public ManagedNetwork getManagedNetwork(String name)
    {
        if (name == null || name.trim().length() == 0)
        {
            return null;
        }

        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            SessionFactory sessionFactory = NetworksActivator.getSessionFactory();
            Session session = sessionFactory.getCurrentSession();

            Criteria criteria = session.createCriteria(ManagedNetwork.class).add(Restrictions.eq(NAME, name));
            ManagedNetwork network = (ManagedNetwork) criteria.uniqueResult();

            if (ownTransaction)
            {
                TransactionElf.commit();
            }

            return network;
        }
        catch (RuntimeException e)
        {
            TransactionElf.rollback();
            throw e;
        }
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    public List<String> getManagedNetworkNames()
    {
        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            SessionFactory sessionFactory = NetworksActivator.getSessionFactory();
            Session session = sessionFactory.getCurrentSession();

            SQLQuery query = session.createSQLQuery("SELECT name FROM managed_network ORDER BY name"); //$NON-NLS-1$
            List<?> list = query.list();

            if (ownTransaction)
            {
                TransactionElf.commit();
            }

            if (list != null)
            {
                return (List<String>) list;
            }

            return new ArrayList<String>();
        }
        catch (RuntimeException e)
        {
            TransactionElf.rollback();
            throw e;
        }
    }

    /** {@inheritDoc} */
    public ManagedNetwork getDefaultManagedNetwork()
    {
        rwLock.readLock().lock();

        try
        {
            if (defaultNetwork != null)
            {
                return defaultNetwork;
            }

            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            SessionFactory sessionFactory = NetworksActivator.getSessionFactory();
            Session session = sessionFactory.getCurrentSession();

            Criteria criteria = session.createCriteria(ManagedNetwork.class).add(Restrictions.eq(IS_DEFAULT, true));
            defaultNetwork = (ManagedNetwork) criteria.uniqueResult();

            if (ownTransaction)
            {
                TransactionElf.commit();
            }

            return defaultNetwork;
        }
        catch (HibernateException he)
        {
            TransactionElf.rollback();
            throw he;
        }
        finally
        {
            rwLock.readLock().unlock();
        }
    }

    /** {@inheritDoc} */
    public void setDefaultManagedNetwork(String name)
    {
        if (name == null || name.length() == 0)
        {
            return;
        }

        rwLock.writeLock().lock();
        try
        {
            boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

            ManagedNetwork newDefault = getManagedNetwork(name);
            if (newDefault == null)
            {
                return;
            }
            ManagedNetwork currentDefault = getDefaultManagedNetwork();

            SessionFactory sessionFactory = NetworksActivator.getSessionFactory();
            Session session = sessionFactory.getCurrentSession();

            if (currentDefault != null)
            {
                currentDefault.setDefault(false);
                session.update(currentDefault);
                defaultNetwork = null;
            }

            newDefault.setDefault(true);
            session.update(newDefault);

            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
        catch (Exception e)
        {
            TransactionElf.rollback();
            throw new RuntimeException(e);
        }
        finally
        {
            rwLock.writeLock().unlock();
        }
    }

    /** {@inheritDoc} */
    public void updateManagedNetwork(ManagedNetwork managedNetwork)
    {
        throw new RuntimeException("Not implemented"); //$NON-NLS-1$
    }
}
