package org.ziptie.provider.configstore;

import java.util.List;

import org.ziptie.provider.devices.ZDeviceCore;

/**
 * IRevisionObserver
 */
public interface IRevisionObserver
{
    /**
     * Called on the implementer of this interface to inform them of
     * a revision change.
     *
     * @param device the device whose revision(s) changed
     * @param configs a list of ConfigHolder objects reflecting changes
     */
    void revisionChange(ZDeviceCore device, List<ConfigHolder> configs);
}
