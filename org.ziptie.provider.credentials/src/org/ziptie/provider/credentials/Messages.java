package org.ziptie.provider.credentials;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String credentialsServiceNotAvailable;
    public static String loadingPropsFile;
    public static String noPropsFileLoaded;
    public static String noPropsFileSaved;
    
    private static final String BUNDLE_NAME = "org.ziptie.provider.credentials.messages"; //$NON-NLS-1$

    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
