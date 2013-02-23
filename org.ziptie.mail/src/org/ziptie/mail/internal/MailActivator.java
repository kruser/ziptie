package org.ziptie.mail.internal;

import java.net.URI;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

/**
 * MailActivator
 */
public class MailActivator implements BundleActivator
{
    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        // Load the mail properties
        String configRoot = System.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        String mailProps = configRoot + "mail/mail.properties"; //$NON-NLS-1$
        System.getProperties().load(URI.create(mailProps).toURL().openStream());
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
    }
}
