package org.ziptie.zap.hibernate.internal;

import java.util.Properties;

import javax.transaction.TransactionManager;

import org.hibernate.HibernateException;
import org.hibernate.transaction.TransactionManagerLookup;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;

/**
 * ZTransactionManagerLookup
 * 
 * This class implements the Hibernate TransactionManagerLookup interface to
 * provide a custom OSGi-based service lookup of a Transaction Manager.
 *
 */
public class ZTransactionManagerLookup implements TransactionManagerLookup
{
    private static ServiceTracker tmTracker;

    /** {@inheritDoc} */
    public TransactionManager getTransactionManager(Properties props)
    {
        try
        {
            return getTM();
        }
        catch (Exception e)
        {
            throw new HibernateException("Unable to lookup JTA Transaction Manager", e); //$NON-NLS-1$
        }
    }

    /** {@inheritDoc} */
    public String getUserTransactionName()
    {
        return null;
    }

    static void init(BundleContext context)
    {
        tmTracker = new ServiceTracker(context, TransactionManager.class.getName(), null);
        tmTracker.open();
    }

    static void destroy()
    {
        tmTracker.close();
    }

    /**
     * Get the TransactionManager that was registered as a Service.
     *
     * @return a TransactionManager
     */
    private TransactionManager getTM()
    {
        Object object = tmTracker.getService();
        return (TransactionManager) object;
    }
}
