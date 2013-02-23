package org.ziptie.provider.netman;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String exceptionDuringRollback;
    public static String exceptionDuringTransaction;
    public static String serviceUnavailable;
    private static final String BUNDLE_NAME = "org.ziptie.provider.devices.messages"; //$NON-NLS-1$

    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
