package org.ziptie.provider.tools;

import java.util.List;

import javax.jws.WebService;

import org.ziptie.provider.tools.internal.PluginsActivator;
import org.ziptie.server.security.SecurityHandler;

/**
 * ToolsProviderDelegate
 */
@WebService(endpointInterface = "org.ziptie.provider.tools.IPluginProvider", serviceName = "PluginsService", portName = "PluginsPort")
public class PluginProviderDelegate implements IPluginProvider
{
    /** {@inheritDoc} */
    public List<PluginDescriptor> getPluginDescriptors()
    {
        return getProvider().getPluginDescriptors();
    }

    /** {@inheritDoc} */
    public List<ToolRunDetails> getExecutionDetails(int executionId)
    {
        return getProvider().getExecutionDetails(executionId);
    }

    /** {@inheritDoc} */
    public PluginExecRecord getExecutionRecord(int executionId)
    {
        return getProvider().getExecutionRecord(executionId);
    }

    /** {@inheritDoc} */
    public List<String> getFileStoreEntries(String path)
    {
        return getProvider().getFileStoreEntries(path);
    }

    private IPluginProvider getProvider()
    {
        IPluginProvider toolsProvider = PluginsActivator.getToolsProvider();

        return (IPluginProvider) SecurityHandler.newProxy(toolsProvider);
    }
}
