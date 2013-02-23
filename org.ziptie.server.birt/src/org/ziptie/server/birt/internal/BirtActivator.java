package org.ziptie.server.birt.internal;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.eclipse.birt.core.framework.Platform;
import org.eclipse.birt.report.engine.api.IReportEngineFactory;
import org.hibernate.SessionFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.osgi.util.tracker.ServiceTracker;
import org.ziptie.server.birt.ReportPluginManager;
import org.ziptie.zap.jta.TransactionElf;

/**
 * BirtActivator
 */
public class BirtActivator implements BundleActivator
{
    private static final Logger LOGGER = Logger.getLogger(BirtActivator.class);

    private static BundleContext context;
    private static ServiceTracker dsTracker;
    private static ServiceTracker sessionFactoryTracker;

    private static IReportEngineFactory factory;


    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        BirtActivator.context = context;

        LOGGER.info("BIRT bundle starting...");
        
        sessionFactoryTracker = new ServiceTracker(context, SessionFactory.class.getName(), null);
        sessionFactoryTracker.open();

        try
        {
            dsTracker = new ServiceTracker(context, DataSource.class.getName(), null);
            dsTracker.open();

            factory = (IReportEngineFactory) Platform.createFactoryObject(IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY);
        }
        catch (Exception ex)
        {
            LOGGER.error(ex);
        }
        
        wipeTempTable();
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        // destroy the engine.
        dsTracker.close();
        sessionFactoryTracker.close();
        sessionFactoryTracker = null;
    }

    /**
     * Get the BIRT reporting engine instance.
     *
     * @return the engine instance
     */
    public static IReportEngineFactory getReportEngineFactory()
    {
        return factory;
    }

    public static ReportPluginManager getReportPluginManager()
    {
       ServiceReference serviceReference = context.getServiceReference(ReportPluginManager.class.getName());
       return (ReportPluginManager) context.getService(serviceReference);
    }

    public static synchronized DataSource getDataSource()
    {
        if (dsTracker != null)
        {
            return (DataSource) dsTracker.getService();
        }
        else
        {
            throw new RuntimeException("DataSource Service Tracker has not be initialized."); //$NON-NLS-1$
        }
    }

    /**
     * Lookup the hibernate session factory instance.
     *
     * @return The singleton session factory.
     */
    public static SessionFactory getSessionFactory()
    {
        return (SessionFactory) sessionFactoryTracker.getService();
    }

    private void wipeTempTable() throws SQLException
    {
        DataSource dataSource = getDataSource();
        
        Connection connection = dataSource.getConnection();

        TransactionElf.beginOrJoinTransaction();

        Statement stmt = connection.createStatement();
        stmt.execute("DELETE FROM birt_resolved_devices"); //$NON-NLS-1$
        stmt.close();
        
        TransactionElf.commit();
    }
}
