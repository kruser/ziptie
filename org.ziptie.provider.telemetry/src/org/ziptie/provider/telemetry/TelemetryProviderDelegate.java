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
package org.ziptie.provider.telemetry;

import java.util.List;

import javax.jws.WebService;

/**
 * TelemetryProviderDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.telemetry.ITelemetryProvider", //$NON-NLS-1$
serviceName = "TelemetryService", portName = "TelemetryPort")
public class TelemetryProviderDelegate implements ITelemetryProvider
{

    /** {@inheritDoc} */
    public SwitchPortResult findSwitchPort(String host)
    {
        return getProvider().findSwitchPort(host);
    }

    /** {@inheritDoc} */
    public MacPageData getMacTable(MacPageData pageData, String ipAddress, String managedNetwork)
    {
        return getProvider().getMacTable(pageData, ipAddress, managedNetwork);
    }

    /** {@inheritDoc} */
    public ArpPageData getArpTable(ArpPageData pageData, String ipAddress, String managedNetwork)
    {
        return getProvider().getArpTable(pageData, ipAddress, managedNetwork);
    }
    
    /** {@inheritDoc} */
    public DeviceArpPageData getArpEntries(DeviceArpPageData pageData, String networkAddress, String sort, boolean descending)
    {
        return getProvider().getArpEntries(pageData, networkAddress, sort, descending);
    }
    
    /** {@inheritDoc} */
    public List<Neighbor> getNeighbors(String ipAddress, String managedNetwork)
    {
        return getProvider().getNeighbors(ipAddress, managedNetwork);
    }
    
    /**
     * This is an accessor to get the 'true' scheduler as a service.  If the bundle
     * has been restarted, this may return a different Scheduler than previous
     * invocations.  But they should be backed by the same job store, so it would
     * be transparent to the client.
     * 
     * @return the Scheduler to which to delegate
     */
    private ITelemetryProvider getProvider()
    {
        ITelemetryProvider provider = TelemetryActivator.getTelemetryProvider();
        if (provider == null)
        {
            throw new RuntimeException(Messages.providerUnavailable);
        }
        return provider;
    }

}
