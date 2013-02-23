package org.ziptie.provider.devices;

import org.ziptie.net.adapters.AdapterMetadata;
import org.ziptie.net.adapters.IAdapterService;
import org.ziptie.net.snmp.TrapSender;
import org.ziptie.provider.devices.internal.DeviceProviderActivator;

/**
 * SnmpTrapDeviceObserver
 */
public class SnmpTrapDeviceObserver implements IDeviceStoreObserver
{
    /** {@inheritDoc} */
    public void deviceTypeChanged(ZDeviceCore device)
    {
        // no-op
    }

    /** {@inheritDoc} */
    public void deviceCreated(ZDeviceCore device)
    {
        IAdapterService adapterService = DeviceProviderActivator.getAdapterService();
        AdapterMetadata adapterMetadata = adapterService.getAdapterMetadata(device.getAdapterId());

        TrapSender trapSender = DeviceProviderActivator.getTrapSender();
        String hostname = device.getHostname() == null ? "" : device.getHostname(); //$NON-NLS-1$
        trapSender.sendAddDeviceTrap(hostname, device.getIpAddress(), device.getManagedNetwork(), device.getAdapterId(), adapterMetadata.getShortName());
    }

    /** {@inheritDoc} */
    public void deviceDeleted(ZDeviceCore device)
    {
        IAdapterService adapterService = DeviceProviderActivator.getAdapterService();
        AdapterMetadata adapterMetadata = adapterService.getAdapterMetadata(device.getAdapterId());

        TrapSender trapSender = DeviceProviderActivator.getTrapSender();
        String hostname = device.getHostname() == null ? "" : device.getHostname(); //$NON-NLS-1$
        trapSender.sendDeleteDeviceTrap(hostname, device.getIpAddress(), device.getManagedNetwork(), device.getAdapterId(), adapterMetadata.getShortName());
    }
}
