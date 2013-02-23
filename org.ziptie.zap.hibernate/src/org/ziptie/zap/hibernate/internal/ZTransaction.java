package org.ziptie.zap.hibernate.internal;

import javax.transaction.NotSupportedException;
import javax.transaction.Status;
import javax.transaction.Synchronization;
import javax.transaction.SystemException;
import javax.transaction.UserTransaction;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Transaction;
import org.hibernate.TransactionException;
import org.hibernate.jdbc.JDBCContext;
import org.hibernate.transaction.TransactionFactory;

/**
 * ZTransaction
 */
public class ZTransaction implements Transaction
{
    private static final String COULD_NOT_DETERMINE_TRANSACTION_STATUS = "Could not determine transaction status"; //$NON-NLS-1$

    private static final String SET_HIBERNATE_TRANSACTION_MANAGER_LOOKUP_CLASS_IF_CACHE_IS_ENABLED =
        "You should set hibernate.transaction.manager_lookup_class if cache is enabled"; //$NON-NLS-1$

    private static final Logger LOGGER = Logger.getLogger(ZTransaction.class);

    private final TransactionFactory.Context transactionContext;
    private final JDBCContext jdbcContext;

    private UserTransaction userTransaction;

    private boolean begun;
    private boolean callback;
    private boolean commitFailed;
    private boolean commitSucceeded;
    private boolean newTransaction;

    /**
     * Construct a ZTransaction wrapper around the given UserTransaction.
     *
     * @param ut a UserTransaction instance
     * @param jdbcContext the Hibernate JDBCContext instance
     * @param xactionContext the Hibernate transaction context
     */
    public ZTransaction(UserTransaction ut, JDBCContext jdbcContext, TransactionFactory.Context xactionContext)
    {
        this.userTransaction = ut;
        this.jdbcContext = jdbcContext;
        this.transactionContext = xactionContext;
    }

    /** {@inheritDoc} */
    public void begin()
    {
        if (begun)
        {
            return;
        }

        if (commitFailed)
        {
            throw new TransactionException("Cannot re-start transaction after failed commit."); //$NON-NLS-1$
        }

        try
        {
            newTransaction = userTransaction.getStatus() == Status.STATUS_NO_TRANSACTION;
            if (newTransaction)
            {
                userTransaction.begin();
            }
        }
        catch (NotSupportedException e)
        {
            throw new HibernateException(e);
        }
        catch (SystemException e)
        {
            throw new HibernateException(e);
        }

        boolean synchronization = jdbcContext.registerSynchronizationIfPossible();

        if (!newTransaction && !synchronization)
        {
            LOGGER.warn(SET_HIBERNATE_TRANSACTION_MANAGER_LOOKUP_CLASS_IF_CACHE_IS_ENABLED);
        }

        if (!synchronization)
        {
            //if we could not register a synchronization,
            //do the before/after completion callbacks
            //ourself (but we need to let jdbcContext
            //know that this is what we are going to
            //do, so it doesn't keep trying to register
            //synchronizations)
            callback = jdbcContext.registerCallbackIfNecessary();
        }

        begun = true;
        commitSucceeded = false;

        jdbcContext.afterTransactionBegin(this);
    }

    /** {@inheritDoc} */
    public void commit()
    {
        if (!begun)
        {
            throw new TransactionException("Transaction not successfully started."); //$NON-NLS-1$
        }

        boolean flush = !transactionContext.isFlushModeNever() && (callback || !transactionContext.isFlushBeforeCompletionEnabled());

        if (flush)
        {
            transactionContext.managedFlush(); //if an exception occurs during flush, user must call rollback()
        }

        if (callback && newTransaction)
        {
            jdbcContext.beforeTransactionCompletion(this);
        }

        closeIfRequired();

        if (newTransaction)
        {
            try
            {
                userTransaction.commit();
                commitSucceeded = true;
                LOGGER.debug("Committed JTA UserTransaction"); //$NON-NLS-1$
            }
            catch (Exception e)
            {
                // so the transaction is already rolled back, by JTA spec
                commitFailed = true;
                throw new TransactionException("ZTransaction commit failed: ", e); //$NON-NLS-1$
            }
            finally
            {
                afterCommitRollback();
            }
        }
        else
        {
            // this one only really needed for badly-behaved applications!
            // (if the TransactionManager has a Sychronization registered, its a noop)
            // (actually we do need it for downgrading locks)
            afterCommitRollback();
        }
    }

    /** {@inheritDoc} */
    public void rollback()
    {
        if (!begun && !commitFailed)
        {
            throw new TransactionException("Transaction not successfully started"); //$NON-NLS-1$
        }

        try
        {
            closeIfRequired();
        }
        catch (Exception e)
        {
            LOGGER.error("Could not close session during rollback", e); //$NON-NLS-1$
            //swallow it, and continue to roll back JTA transaction
        }

        try
        {
            if (newTransaction)
            {
                if (!commitFailed)
                {
                    userTransaction.rollback();
                }
            }
            else
            {
                userTransaction.setRollbackOnly();
            }
        }
        catch (Exception e)
        {
            throw new HibernateException(e);
        }
        finally
        {
            afterCommitRollback();
        }
    }

    /** {@inheritDoc} */
    public boolean isActive()
    {
        if (!begun || commitFailed || commitSucceeded)
        {
            return false;
        }

        try
        {
            return userTransaction.getStatus() == Status.STATUS_ACTIVE;
        }
        catch (SystemException e)
        {
            throw new HibernateException(e);
        }
    }

    /** {@inheritDoc} */
    public void registerSynchronization(Synchronization synchronization)
    {
        if (transactionContext.getFactory().getTransactionManager() == null)
        {
            throw new IllegalStateException("TransactionManager not available"); //$NON-NLS-1$
        }
        else
        {
            try
            {
                transactionContext.getFactory().getTransactionManager().getTransaction().registerSynchronization(synchronization);
            }
            catch (Exception e)
            {
                throw new TransactionException("Could not register synchronization", e); //$NON-NLS-1$
            }
        }
    }

    /** {@inheritDoc} */
    public void setTimeout(int seconds)
    {
        try
        {
            userTransaction.setTransactionTimeout(seconds);
        }
        catch (SystemException e)
        {
            throw new HibernateException(e);
        }
    }

    /** {@inheritDoc} */
    public boolean wasCommitted()
    {
        try
        {
            int status = userTransaction.getStatus();
            if (status == Status.STATUS_UNKNOWN)
            {
                throw new SystemException();
            }

            return status == Status.STATUS_COMMITTED;
        }
        catch (SystemException se)
        {
            throw new TransactionException(COULD_NOT_DETERMINE_TRANSACTION_STATUS);
        }
    }

    /** {@inheritDoc} */
    public boolean wasRolledBack()
    {
        try
        {
            int status = userTransaction.getStatus();
            if (status == Status.STATUS_UNKNOWN)
            {
                throw new SystemException();
            }

            return status == Status.STATUS_ROLLEDBACK || status == Status.STATUS_ROLLING_BACK || status == Status.STATUS_MARKED_ROLLBACK;
        }
        catch (SystemException se)
        {
            throw new TransactionException(COULD_NOT_DETERMINE_TRANSACTION_STATUS);
        }
    }

    /**
     * Get the contained UserTransaction.
     *
     * @return a UserTransaction object, or null
     */
    public UserTransaction getUserTransaction()
    {
        return userTransaction;
    }

    /**
     * 
     */
    private void closeIfRequired()
    {
        boolean close = callback && transactionContext.shouldAutoClose() && !transactionContext.isClosed();
        if (close)
        {
            transactionContext.managedClose();
        }
    }

    /**
     * 
     */
    private void afterCommitRollback()
    {

        begun = false;

        if (callback)
        {
            // this method is a noop if there is a Synchronization!
            if (!newTransaction)
            {
                LOGGER.warn(SET_HIBERNATE_TRANSACTION_MANAGER_LOOKUP_CLASS_IF_CACHE_IS_ENABLED);
            }

            int status = Integer.MIN_VALUE;
            try
            {
                status = userTransaction.getStatus();
            }
            catch (Exception e)
            {
                throw new TransactionException("Could not determine transaction status after commit", e); //$NON-NLS-1$
            }
            finally
            {
                /*if (status!=Status.STATUS_COMMITTED && status!=Status.STATUS_ROLLEDBACK) {
                 log.warn("Transaction not complete - you should set hibernate.transaction.manager_lookup_class if cache is enabled");
                 //throw exception??
                 }*/
                jdbcContext.afterTransactionCompletion(status == Status.STATUS_COMMITTED, this);
            }

        }
    }
}
