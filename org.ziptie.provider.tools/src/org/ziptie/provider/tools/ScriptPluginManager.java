package org.ziptie.provider.tools;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.util.Dictionary;
import java.util.Enumeration;
import java.util.Locale;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.log4j.Logger;
import org.osgi.framework.Bundle;
import org.ziptie.zap.util.ResourceElf;

/**
 * ScriptToolManager
 */
public class ScriptPluginManager extends BasePluginManager
{
    private static final Logger LOGGER = Logger.getLogger(ScriptPluginManager.class);

    private static final String SCRIPT_TOOL_TYPE = "script"; //$NON-NLS-1$

    /**
     * Constructor.
     */
    public ScriptPluginManager()
    {
        super();

        // Cause an initial scan of the bundles for the default locale
        getPluginDescriptorMap();

        setInitialized(true);
    }

    /**
     * Get the script for the specified tool.
     *
     * @param toolName the name of the tool
     * @return the script for the specified tool, or empty string if the
     *    tool does not exist or an I/O error occurred.
     */
    public String getToolScript(String toolName)
    {
        PluginDescriptor descriptor = getPluginDescriptor(toolName);
        if (descriptor == null)
        {
            return ""; //$NON-NLS-1$
        }

        ZToolProperties properties = descriptor.getProperties();
        Bundle scriptBundle = descriptor.getBundle();
        String bundlePath = descriptor.getBundlePath();
        String scriptName = properties.getScriptName();

        try
        {
            URL entry = scriptBundle.getEntry(String.format("%s/%s", bundlePath, scriptName)); //$NON-NLS-1$
            InputStream is = entry.openStream();
            Reader reader = new InputStreamReader(is);

            StringBuilder sb = new StringBuilder();
            char[] cbuf = new char[1024];
            while (true)
            {
                int rc = reader.read(cbuf);
                if (rc <= 0)
                {
                    break;
                }
                sb.append(cbuf, 0, rc);
            }
            is.close();

            return sb.toString();
        }
        catch (IOException io)
        {
            return ""; //$NON-NLS-1$
        }
    }

    /**
     * Scan a bundle to see if it contains tools.
     *
     * @param bundle the bundle to scan
     * @param locale the language of the properties files to load
     */
    protected void scanBundleForInstall(Bundle bundle, Locale locale)
    {
        Dictionary<?, ?> headers = bundle.getHeaders();
        Object object = headers.get("ZTool-Directory"); //$NON-NLS-1$
        if (!(object instanceof String))
        {
            return;
        }

        String path = (String) object;
        Enumeration<?> enumeration = bundle.findEntries(path, "*.properties", true); //$NON-NLS-1$
        if (enumeration.hasMoreElements())
        {
            getPluginBundles().add(bundle);
        }

        while (enumeration != null && enumeration.hasMoreElements())
        {
            URL url = (URL) enumeration.nextElement();
            try
            {
                String propPath = url.getPath();
                if (propPath.indexOf('_') >= 0)
                {
                    // ignore property files with an "_", these are i18n property files.
                    // we only care about base properties.
                    continue;
                }

                PluginDescriptor descriptor = new PluginDescriptor(bundle, path);
                Properties props = ResourceElf.loadLanguageProperties(bundle, propPath, locale);
                descriptor.setPluginType(SCRIPT_TOOL_TYPE);
                descriptor.setProperties(new ZToolProperties(props));
                descriptor.setToolName(props.getProperty("menu.label").trim()); //$NON-NLS-1$
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                props.storeToXML(baos, ""); //$NON-NLS-1$
                descriptor.setPropertyText(baos.toString());

                if (descriptor.getToolName() != null)
                {
                    ConcurrentHashMap<String, PluginDescriptor> pluginDescriptorMap = getPluginDescriptorMap();
                    pluginDescriptorMap.put(descriptor.getToolName(), descriptor);
                    LOGGER.info(String.format(Messages.ScriptToolManager_discoveredTool, descriptor.getToolName(),
                                              (isInitialized() ? String.format("(%s)", locale.toString()) : ""))); //$NON-NLS-1$ //$NON-NLS-2$
                }
            }
            catch (Exception io)
            {
                LOGGER.warn(Messages.ScriptToolManager_errorReadingProperties, io);
                continue;
            }
        }
    }

    /**
     * Scan bundle for uninstall.
     *
     * @param bundle the bundle to scan
     */
    public void scanBundleForUninstall(Bundle bundle)
    {
    }

    @Override
    protected String getPluginTypeDisplayName()
    {
        return Messages.ScriptPluginManager_pluginTypeDisplayName;
    }
}
