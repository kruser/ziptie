package org.ziptie.server.hibernate.test.internal;

import org.apache.log4j.Logger;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.ziptie.server.hibernate.test.TestAll;
import junit.framework.TestSuite;
import junit.framework.TestResult;

/**
 * Activator.
 */
public class Activator implements BundleActivator
{
    private static Logger USER_LOG = Logger.getLogger(Activator.class);

    /**
     * Default constructor.
     */
    public Activator()
    {
    }

    /**
     * {@inheritDoc}
     */
    public void start(BundleContext bundleContext) throws Exception
    {
        USER_LOG.info("HibernateBundle test starting...");
        try
        {
            TestAll.setBundleContext(bundleContext);
            TestSuite suite = TestAll.suite();
            TestResult result = junit.textui.TestRunner.run(suite);

            if (result.wasSuccessful())
            {
                USER_LOG.info("HibernateBundle test finished.");
            }
            else
            {
                USER_LOG.error("HibernateBundle test failed.");
            }
        }
        catch (Exception e)
        {
            USER_LOG.fatal("HibernateBundle test failed to start.", e);
            throw e;
        }
    }

    /**
     * {@inheritDoc}
     */
    public void stop(BundleContext bundleContext) throws Exception
    {
    }
}
