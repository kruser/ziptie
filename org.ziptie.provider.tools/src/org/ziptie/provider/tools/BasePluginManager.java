package org.ziptie.provider.tools;

import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.log4j.Logger;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleContext;
import org.ziptie.provider.tools.internal.PluginsActivator;
import org.ziptie.zap.security.IUserSession;

/**
 * BasePluginManager
 */
public abstract class BasePluginManager implements IPluginManager
{
    protected static final String PLUGIN_TYPE_PROPERTY = "tool.type"; //$NON-NLS-1$

    private static final Logger LOGGER = Logger.getLogger(BasePluginManager.class);

    private Set<Bundle> pluginBundles;
    private ConcurrentHashMap<Locale, ConcurrentHashMap<String, PluginDescriptor>> langToDescriptorsMap;
    private BundleContext context;
    private boolean initialized;

    protected BasePluginManager()
    {
        this.context = PluginsActivator.getContext();
        pluginBundles = new HashSet<Bundle>();
        langToDescriptorsMap = new ConcurrentHashMap<Locale, ConcurrentHashMap<String, PluginDescriptor>>();
    }

    /**
     * Get the set of available tools in the form of <code>ScriptToolDescriptor</code>
     * objects.
     *
     * @return a Set of <code>ScriptToolDescriptors</code>
     */
    public Set<PluginDescriptor> getPluginDescriptors()
    {
        ConcurrentHashMap<String, PluginDescriptor> toolDescMap = getPluginDescriptorMap();

        HashSet<PluginDescriptor> set = new HashSet<PluginDescriptor>();
        set.addAll(toolDescMap.values());

        return set;
    }

    /**
     * Get a <code>ScriptToolDescriptor</code> for the specified tool.
     *
     * @param toolName the name of the tool
     * @return a <code>ScriptToolDescriptor</code> or <code>null</code>
     */
    public PluginDescriptor getPluginDescriptor(String toolName)
    {
        ConcurrentHashMap<String, PluginDescriptor> toolDescMap = getPluginDescriptorMap();
        if (toolDescMap == null)
        {
            LOGGER.warn(String.format("Plugin descriptor map was null for requested plugin '%s'", toolName)); //$NON-NLS-1$
            return null;
        }

        return toolDescMap.get(toolName);
    }

    /**
     * Get the ZToolProperties object for the specified tool.
     *
     * @param pluginName the name of the tool
     * @return the ZToolProperties for the specified tool, or <code>null</code>
     */
    public ZToolProperties getPluginProperties(String pluginName)
    {
        PluginDescriptor toolDescriptor = getPluginDescriptor(pluginName);
        if (toolDescriptor == null)
        {
            return null;
        }

        return toolDescriptor.getProperties();
    }

    /**
     * Scan the bundles looking for Manifests with ZTool-Directory entries and then
     * search those bundles for tools.
     *
     * @param locale the language of the resources to scan for
     */
    private void scanBundles(Locale locale)
    {
        LOGGER.info(Messages.bind(Messages.ScriptToolManager_scanningBundles, getPluginTypeDisplayName()));
        Bundle[] bundles = context.getBundles();
        for (Bundle bundle : bundles)
        {
            scanBundleForInstall(bundle, locale);
        }

        ConcurrentHashMap<String, PluginDescriptor> descriptorMap = getPluginDescriptorMap();
        LOGGER.info(String.format(Messages.ScriptToolManager_totalToolsDiscovered, descriptorMap.size()));
    }

    protected abstract void scanBundleForInstall(Bundle bundle, Locale locale);

    protected abstract String getPluginTypeDisplayName();

    /**
     * Get the locale that the user's client is running in.
     *
     * @return the user's locale
     */
    private Locale getUserLocale()
    {
        IUserSession userSession = PluginsActivator.getSecurityService().getUserSession();

        return (userSession != null ? userSession.getLocale() : Locale.getDefault());
    }

    /**
     * Get the map of tool-name to ToolDescriptor, taking the user's client
     * locale into consideration.
     *
     * @return the map of tool-names to ToolDescriptors specific to the client locale
     */
    protected ConcurrentHashMap<String, PluginDescriptor> getPluginDescriptorMap()
    {
        Locale locale = getUserLocale();

        ConcurrentHashMap<String, PluginDescriptor> pluginDescMap;
        if (langToDescriptorsMap.containsKey(locale))
        {
            pluginDescMap = langToDescriptorsMap.get(locale);
        }
        else
        {
            pluginDescMap = new ConcurrentHashMap<String, PluginDescriptor>();
            langToDescriptorsMap.put(locale, pluginDescMap);

            scanBundles(locale);
        }
        return pluginDescMap;
    }

    /**
     * @return the set of plugin bundles
     */
    protected Set<Bundle> getPluginBundles()
    {
        return pluginBundles;
    }

    /**
     * @param initialized set this manager to initialized state
     */
    protected void setInitialized(boolean initialized)
    {
        this.initialized = initialized;
    }

    /**
     * @return true if this manager has been initialized
     */
    protected boolean isInitialized()
    {
        return initialized;
    }
}
