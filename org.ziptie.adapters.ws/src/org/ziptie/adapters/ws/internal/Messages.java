package org.ziptie.adapters.ws.internal;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String providerStarted;
    public static String providerStarting;
    public static String providerStopped;
    private static final String BUNDLE_NAME = "org.ziptie.adapters.ws.internal.messages"; //$NON-NLS-1$

    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
