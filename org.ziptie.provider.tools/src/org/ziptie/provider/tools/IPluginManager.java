package org.ziptie.provider.tools;

import java.util.Set;

/**
 * IPluginManager
 */
public interface IPluginManager
{
    /**
     * Get a list of all available plugins.  The return value is a list of
     * <code>PluginDescriptor</code> objects which encapsulate the
     * text of the properties definitions.
     *
     * @return a list of <code>PluginDescriptor</code> objects
     */
    Set<PluginDescriptor> getPluginDescriptors();
}
