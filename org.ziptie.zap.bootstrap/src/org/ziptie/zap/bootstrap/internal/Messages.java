package org.ziptie.zap.bootstrap.internal;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String Activator_divider;
    public static String Activator_serverStarting;
    public static String Activator_startupComplete;
    public static String Activator_startupComplete_errorCount;
    public static String Activator_unableToInitSslTrustManager;
    private static final String BUNDLE_NAME = "org.ziptie.zap.bootstrap.internal.messages"; //$NON-NLS-1$
    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
