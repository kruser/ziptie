/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.adapters.ws;

import javax.jws.WebService;

import org.ziptie.adapters.ws.internal.AdaptersWsActivator;

/**
 * SOAP delegate for the NIL Settings Provider.
 */
@WebService(endpointInterface = "org.ziptie.adapters.ws.INilSettingsProvider", //$NON-NLS-1$
serviceName = "NilSettingsService", portName = "NilSettingsPort")
public class NilSettingsProviderDelegate implements INilSettingsProvider
{
    /** {@inheritDoc} */
    public FileServerInfo getFileServerInfo(String name)
    {
        return getProvider().getFileServerInfo(name);
    }

    /** {@inheritDoc} */
    public FileServerInfo getFileServerInfoForIPv6(String protocolName, boolean useIPv6)
    {
        return getProvider().getFileServerInfoForIPv6(protocolName, useIPv6);
    }

    /** {@inheritDoc} */
    public void enableLoggingAdapterOperationsToFile(boolean enable)
    {
        getProvider().enableLoggingAdapterOperationsToFile(enable);
    }

    /** {@inheritDoc} */
    public void setAdapterLoggingLevel(int level)
    {
        getProvider().setAdapterLoggingLevel(level);
    }

    /** {@inheritDoc} */
    public void enableRecordingAdapterOperations(boolean enable)
    {
        getProvider().enableRecordingAdapterOperations(enable);
    }

    /** {@inheritDoc} */
    public int getAdapterLoggingLevel()
    {
        return getProvider().getAdapterLoggingLevel();
    }

    /** {@inheritDoc} */
    public boolean isLoggingAdapterOperationsToFileEnabled()
    {
        return getProvider().isLoggingAdapterOperationsToFileEnabled();
    }

    /** {@inheritDoc} */
    public boolean isRecordingAdapterOperationsEnabled()
    {
        return getProvider().isRecordingAdapterOperationsEnabled();
    }

    /**
     * Retrieves the implementation of the {@link INilSettingsProvider} interface for use.
     * 
     * @return The implementation of the {@link INilSettingsProvider} interface.
     */
    private INilSettingsProvider getProvider()
    {
        INilSettingsProvider provider = AdaptersWsActivator.getSettingsProvider();
        if (provider == null)
        {
            throw new RuntimeException();
        }
        return provider;
    }
}
