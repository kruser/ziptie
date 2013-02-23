package org.ziptie.provider.configstore;

import java.util.List;

import org.apache.log4j.Logger;
import org.ziptie.net.snmp.TrapSender;
import org.ziptie.provider.configstore.internal.ConfigStoreActivator;
import org.ziptie.provider.devices.ZDeviceCore;

/**
 * SnmpTrapRevisionObserver
 */
public class SnmpTrapRevisionObserver implements IRevisionObserver
{
    private static final Logger LOGGER = Logger.getLogger(SnmpTrapRevisionObserver.class);

    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public void revisionChange(ZDeviceCore device, List<ConfigHolder> configs)
    {
        TrapSender trapSender = ConfigStoreActivator.getTrapSender();
        for (ConfigHolder holder : configs)
        {
            // Don't raise an event for the ZED ... this is an internal artifact of configuration
            // change and is typically not meaningful to externally integrated systems.
            if (holder.getFullName().contains(ConfigBackupPersister.ZIPTIE_ELEMENT_DOCUMENT))
            {
                continue;
            }

            if (holder.getType().equals("A") || holder.getType().equals("M"))
            {
                try
                {
                    String hostname = (device.getHostname() == null ? "" : device.getHostname());
                    trapSender.sendConfigChangeTrap(hostname, device.getIpAddress(), device.getManagedNetwork(), holder.getFullName());
                }
                catch (Throwable t)
                {
                    LOGGER.warn("Unable to raise change trap.", t); //$NON-NLS-1$
                }
            }
        }
    }
}
