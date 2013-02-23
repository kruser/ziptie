package org.ziptie.provider.adapters;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.apache.log4j.Logger;
import org.xml.sax.SAXException;
import org.ziptie.credentials.CredentialKey;
import org.ziptie.credentials.utils.CredentialKeyElf;
import org.ziptie.net.adapters.AdapterMetadata;
import org.ziptie.net.adapters.IAdapterService;
import org.ziptie.net.adapters.Operation;
import org.ziptie.provider.adapters.internal.AdapterProviderActivator;

/**
 * AdapterProvider
 */
public class AdapterProvider implements IAdapterProvider
{
    private static final String CREDENTIAL_KEY_FILE = "credentialKeys.xml"; //$NON-NLS-1$
    private List<CredentialKey> credentialKeys;

    /** {@inheritDoc} */
    public List<AdapterLite> getAvailableAdapters()
    {
        Collection<AdapterMetadata> metadata = AdapterProviderActivator.getAdapterService().getAllAdapterMetadata();
        ArrayList<AdapterLite> result = new ArrayList<AdapterLite>(metadata.size());

        for (AdapterMetadata adapter : metadata)
        {
            // Create a new AdapterLite object to travel over the wire
            AdapterLite adapterLite = new AdapterLite(adapter.getAdapterId(), adapter.getShortName(), adapter.getDescription());

            // For potential UI purposes, include the restore validation regular expression with the newly
            // created adapter lite object.
            Operation restoreOperation = adapter.getOperation("restore"); //$NON-NLS-1$
            if (restoreOperation != null)
            {
                adapterLite.setRestoreValidationRegex(restoreOperation.getRestoreValidationRegex());
            }

            // Add the created AdapterLite object to our list to pass over the wire
            result.add(adapterLite);
        }

        return result;
    }

    /** {@inheritDoc} */
    public synchronized List<CredentialKey> getCredentialKeys()
    {
        if (credentialKeys != null)
        {
            return credentialKeys;
        }

        InputStream credentialKeysResource = IAdapterService.class.getResourceAsStream('/' + CREDENTIAL_KEY_FILE);
        try
        {
            credentialKeys = CredentialKeyElf.loadCredentialKeys(credentialKeysResource);
        }
        catch (IOException e)
        {
            Logger.getLogger(getClass()).error(e.getMessage(), e);
            return Collections.emptyList();
        }
        catch (SAXException e)
        {
            Logger.getLogger(getClass()).error(e.getMessage(), e);
            return Collections.emptyList();
        }

        return credentialKeys;
    }
}
