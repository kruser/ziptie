package org.ziptie.provider.devices;

import java.util.List;

import javax.jws.WebService;

import org.ziptie.provider.devices.internal.DeviceProviderActivator;
import org.ziptie.server.security.SecurityHandler;

/**
 * DeviceTagProviderDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.devices.IDeviceTagProvider", //$NON-NLS-1$
            serviceName = "DeviceTagsService", portName = "DeviceTagsPort")
public class DeviceTagProviderDelegate implements IDeviceTagProvider
{
    /** {@inheritDoc} */
    public void addTag(String tag)
    {
        if (tag != null)
        {
            getProvider().addTag(tag);
        }
    }

    /** {@inheritDoc} */
    public List<String> getAllTags()
    {
        return getProvider().getAllTags();
    }

    /** {@inheritDoc} */
    public void renameTag(String oldName, String newName)
    {
        if (oldName != null && newName != null)
        {
            getProvider().renameTag(oldName, newName);
        }
    }

    /** {@inheritDoc} */
    public List<String> getTags(String ipAddress, String managedNetwork)
    {
        if (ipAddress != null)
        {
            return getProvider().getTags(ipAddress, managedNetwork);
        }

        return null;
    }

    /** {@inheritDoc} */
    public void removeTag(String tag)
    {
        if (tag != null)
        {
            getProvider().removeTag(tag);
        }
    }

    /** {@inheritDoc} */
    public List<String> getIntersectionOfTags(String devicesCsv)
    {
        if (devicesCsv != null)
        {
            return getProvider().getIntersectionOfTags(devicesCsv);
        }

        return null;
    }

    /** {@inheritDoc} */
    public List<String> getUnionOfTags(String devicesCsv)
    {
        if (devicesCsv != null)
        {
            return getProvider().getUnionOfTags(devicesCsv);
        }

        return null;
    }

    /** {@inheritDoc} */
    public void tagDevices(String tag, String devicesCsv)
    {
        if (tag != null && devicesCsv != null)
        {
            getProvider().tagDevices(tag, devicesCsv);
        }
    }

    /** {@inheritDoc} */
    public void untagDevices(String tag, String devicesCsv)
    {
        if (tag != null && devicesCsv != null)
        {
            getProvider().untagDevices(tag, devicesCsv);
        }
    }

    /**
     * This is an accessor to get the 'true' scheduler as a service.  If the bundle
     * has been restarted, this may return a different Scheduler than previous
     * invocations.  But they should be backed by the same job store, so it would
     * be transparent to the client.
     * 
     * @return the Scheduler to which to delegate
     */
    private IDeviceTagProvider getProvider()
    {
        IDeviceTagProvider provider = DeviceProviderActivator.getTagProvider();
        if (provider == null)
        {
            throw new RuntimeException(Messages.DeviceTagProviderDelegate_tagProviderUnavailable);
        }

        return (IDeviceTagProvider) SecurityHandler.newProxy(provider);
    }
}
