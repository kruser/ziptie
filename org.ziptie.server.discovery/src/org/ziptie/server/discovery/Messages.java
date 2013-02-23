package org.ziptie.server.discovery;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String discoveryServiceNotAvailable;
    public static String snmpNotEnabled;
    public static String unsupportedAdapter0;
    private static final String BUNDLE_NAME = "org.ziptie.server.discovery.messages"; //$NON-NLS-1$

    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
