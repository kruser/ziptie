package org.ziptie.zap.hibernate.internal;

import java.util.Properties;

import javax.transaction.Status;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import org.hibernate.ConnectionReleaseMode;
import org.hibernate.HibernateException;
import org.hibernate.Transaction;
import org.hibernate.TransactionException;
import org.hibernate.jdbc.JDBCContext;
import org.hibernate.util.JTAHelper;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;

/**
 * TransactionFactory
 */
public class ZTransactionFactory implements org.hibernate.transaction.TransactionFactory
{
    private static final int TWO_MINUTES = 120000;
    private static final String UNABLE_TO_CHECK_TRANSACTION_STATUS = "Unable to check transaction status"; //$NON-NLS-1$
    private static ServiceTracker utTracker;

    /**
     * Default constructor.
     */
    public ZTransactionFactory()
    {
        // default constructor
    }

    /**
     * Set the BundleContext so we can do things like lookup services.
     *
     * @param context the BundleContext for this bundle
     */
    public static void init(BundleContext context)
    {
        utTracker = new ServiceTracker(context, UserTransaction.class.getName(), null);
        utTracker.open();
    }

    /**
     * Shutdown this factory instance.
     */
    public static void shutdown()
    {
        if (utTracker != null)
        {
            utTracker.close();
        }
    }

    /** {@inheritDoc} */
    public boolean areCallbacksLocalToHibernateTransactions()
    {
        return false;
    }

    /** {@inheritDoc} */
    public void configure(Properties props)
    {
        // nothing
    }

    /** {@inheritDoc} */
    public Transaction createTransaction(JDBCContext jdbcContext, Context context)
    {
        try
        {
            UserTransaction ut = (UserTransaction) utTracker.getService();
            // TODO brettw read this from a config file, or better yet initialize JOTM from a config file.
            ut.setTransactionTimeout(TWO_MINUTES);
            return new ZTransaction(ut, jdbcContext, context);
        }
        catch (SystemException e)
        {
            throw new HibernateException("Unable to set transaction timeout."); //$NON-NLS-1$
        }
    }

    /** {@inheritDoc} */
    public ConnectionReleaseMode getDefaultReleaseMode()
    {
        return ConnectionReleaseMode.AFTER_TRANSACTION; //AFTER_STATEMENT;
    }

    /** {@inheritDoc} */
    public boolean isTransactionInProgress(JDBCContext jdbcContext, Context transactionContext, Transaction transaction)
    {
        try
        {
            // Essentially:
            // 1) If we have a local (Hibernate) transaction in progress
            //      and it already has the UserTransaction cached, use that
            //      UserTransaction to determine the status.
            // 2) If a transaction manager has been located, use
            //      that transaction manager to determine the status.
            if (transaction != null)
            {
                UserTransaction ut = ((ZTransaction) transaction).getUserTransaction();
                if (ut != null)
                {
                    return ut.getStatus() == Status.STATUS_ACTIVE || ut.getStatus() == Status.STATUS_MARKED_ROLLBACK;
                }
            }

            if (jdbcContext.getFactory().getTransactionManager() != null)
            {
                return JTAHelper.isInProgress(jdbcContext.getFactory().getTransactionManager().getStatus());
            }

            throw new TransactionException(UNABLE_TO_CHECK_TRANSACTION_STATUS);
        }
        catch (SystemException se)
        {
            throw new TransactionException(UNABLE_TO_CHECK_TRANSACTION_STATUS, se);
        }
    }

    /** {@inheritDoc} */
    public boolean isTransactionManagerRequired()
    {
        return true;
    }

}
