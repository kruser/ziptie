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
 */
package org.ziptie.provider.launchers;

import java.util.List;

import javax.jws.WebService;

import org.ziptie.server.security.SecurityHandler;

/**
 * LaunchersProviderDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.launchers.ILaunchersProvider", //$NON-NLS-1$
serviceName = "LaunchersService", portName = "LaunchersPort")
public class LaunchersProviderDelegate implements ILaunchersProvider
{
    /** {@inheritDoc} */
    public void addOrUpdateLauncher(String name, String url)
    {
        getProvider().addOrUpdateLauncher(name, url);
    }

    /** {@inheritDoc} */
    public void deleteLauncher(String name)
    {
        getProvider().deleteLauncher(name);
    }

    /** {@inheritDoc} */
    public List<Launcher> getLaunchers()
    {
        return getProvider().getLaunchers();
    }

    private ILaunchersProvider getProvider()
    {
        ILaunchersProvider provider = LaunchersActivator.getLaunchersProvider();
        if (provider == null)
        {
            throw new RuntimeException("Launchers provider is not available.");
        }
        return (ILaunchersProvider) SecurityHandler.newProxy(provider);
    }

}
