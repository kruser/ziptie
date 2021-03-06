package org.ziptie.provider.telemetry;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String providerUnavailable;
    public static String providerStarting;
    
    private static final String BUNDLE_NAME = "org.ziptie.provider.telemetry.messages"; //$NON-NLS-1$

    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
