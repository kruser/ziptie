package org.ziptie.server.lucene.internal;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

/**
 * LuceneActivator
 */
public class LuceneActivator implements BundleActivator
{
    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        // Configure Lucene to use Memory Mapped Files
        System.setProperty("org.apache.lucene.FSDirectory.class", "org.apache.lucene.store.MMapDirectory"); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
    }
}
