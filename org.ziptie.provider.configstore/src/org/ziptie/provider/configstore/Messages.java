package org.ziptie.provider.configstore;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String ConfigBackupPersister_unableToWriteOrClose;
    public static String ConfigBackupPersister_unableToRead;
    public static String ConfigSearch_errorAccessingLucene;
    public static String ConfigSearch_errorParsingLastChangedDate;
    public static String ConfigSearch_errorParsingSearchExpression;
    public static String ConfigSearch_luceneCorrupt;
    public static String ConfigSearch_luceneLockFailure;
    public static String ConfigSearch_unableToIndexConfig;
    public static String ConfigStore_clientFactoryException;
    public static String ConfigStore_configError;
    public static String ConfigStore_creatingWorkingCopy;
    public static String ConfigStore_createdFileRepository;
    public static String ConfigStore_errorAccessingRevision;
    public static String ConfigStore_failureCreatingRepository;
    public static String ConfigStore_failureCreatingWorkingCopy;
    public static String ConfigStore_invalidClientType;
    public static String ConfigStore_repositoryBinding;
    public static String ConfigStoreDelegate_serviceUnavailable;
    public static String ConfigSearchDelegate_serviceUnavailable;
    public static String ConfigStoreActivator_registered;
    public static String ConfigStoreActivator_serviceFailed;
    public static String ConfigStoreActivator_starting;
    public static String ConfigStoreActivator_stopped;
    public static String RepositoryConfig_reposRootNotDefined;

    private static final String BUNDLE_NAME = "org.ziptie.provider.configstore.messages"; //$NON-NLS-1$
    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
