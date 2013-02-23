package org.ziptie.provider.tools;

import java.io.File;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.apache.log4j.Logger;
import org.osgi.framework.Filter;
import org.osgi.framework.FrameworkUtil;
import org.osgi.framework.InvalidSyntaxException;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.net.utils.FileServerInfo;
import org.ziptie.net.utils.OperationInputXMLElf;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolNames;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.server.job.backup.ConnectionPathElf;
import org.ziptie.server.job.backup.CredentialElf;

/**
 * ScriptBindingElf
 */
public final class ScriptBindingElf
{
    private static final Logger LOGGER = Logger.getLogger(ScriptBindingElf.class);
    private static final String DEVICES_SELECTED_KEY = "devices.selected"; //$NON-NLS-1$
    private static final String CONNECTION_PATH_KEY = "connectionPath"; //$NON-NLS-1$
    private static final String FILESTORE_KEY = "filestore"; //$NON-NLS-1$
    private static final String DEFAULT_FILESTORE_LOCATION = "tool-file-store"; //$NON-NLS-1$

    private ScriptBindingElf()
    {
        // private constructor
    }

    /**
     * Bind the properties and device into a string using the supplied format.
     *
     * @param device the device with properties to bind
     * @param overrides overridden properties (can be null)
     * @param format the format string describing the binding
     * @return the formatted (aka bound) string
     */
    public static String bindProperties(ZDeviceLite device, Properties overrides, String format)
    {
        IProperties properties = new ScriptDeviceProperties(device);

        if (properties != null)
        {
            return format(format, new CompoundProperties(properties, overrides));
        }
        return format(format, overrides);
    }

    /**
     * This bind is exactly like bindProperties(IZDevice, Properties, String) with the exception
     * that it binds many devices and stores them as individual strings in a list
     * space.
     *
     * @param devices the device with properties to bind
     * @param overrides overridden properties (can be null)
     * @param format the format string describing the binding
     * @param deviceSelectedReplaceString allows a double-binding of values
     *
     * @return the formatted (aka bound) string
     */
    public static List<String> bindProperties(List<ZDeviceLite> devices, Properties overrides, String format, String deviceSelectedReplaceString)
    {
        Properties replacements = new Properties();
        replacements.putAll(overrides);

        // Create an array list to store all the properties that are possibly resolved
        List<String> bindings = new ArrayList<String>();

        if (format.contains(DEVICES_SELECTED_KEY))
        {
            for (ZDeviceLite device : devices)
            {
                // Split up all of the properties in the device.selected string
                String[] deviceSelectedProps = deviceSelectedReplaceString.split(" "); //$NON-NLS-1$

                //  For each property that exists within the device.selected property, bind it
                for (String deviceSelectProp : deviceSelectedProps)
                {
                    bindings.add(bindProperties(device, overrides, deviceSelectProp));
                }
            }
        }
        else
        {
            bindings.add(format(format, replacements));
        }

        return bindings;
    }

    /**
     * Tests whether or not a tool is supported for use against a list of devices based on the LDAP filter string specified in its properties.
     * 
     * @param devices A list of {@link ZDeviceLite} objects that the tool is attempting to be run against.
     * @param toolProperties The {@link ZToolProperties} object that contains all the properties specified for the tool.
     * @return Whether or not a tool is supported for use against all of the devices in the specified list.
     * @throws InvalidSyntaxException if the LDAP filter string is invalid/malformed.
     */
    public static boolean isToolSupportedForDevices(List<ZDeviceLite> devices, ZToolProperties toolProperties) throws InvalidSyntaxException
    {
        for (ZDeviceLite device : devices)
        {
            if (!isToolSupportedForDevice(device, toolProperties))
            {
                return false;
            }
        }

        return true;
    }

    /**
     * Tests whether or not a tool is supported for use against a device based on the LDAP filter string specified in its properties.
     * 
     * @param device The {@link ZDeviceLite} object that the tool is attempting to be run against.
     * @param toolProperties The {@link ZToolProperties} object that contains all the properties specified for the tool.
     * @return Whether or not a tool is supported for use against a device.
     * @throws InvalidSyntaxException if the LDAP filter string is invalid/malformed.
     */
    public static boolean isToolSupportedForDevice(ZDeviceLite device, ZToolProperties toolProperties) throws InvalidSyntaxException
    {
        String filterString = toolProperties.getEnableFilterString();

        if (filterString != null && filterString.length() > 0)
        {
            try
            {
                // Test the LDAP filter string to see if the tool is supported or not
                Filter filter = FrameworkUtil.createFilter(filterString);

                IProperties properties = new ScriptDeviceProperties(device);
                PropertiesDictionary propDict = new PropertiesDictionary(properties);

                return filter.matchCase(propDict);
            }
            catch (InvalidSyntaxException e)
            {
                InvalidSyntaxException ise = new InvalidSyntaxException("The enable filter string for the '" + toolProperties.getToolName() //$NON-NLS-1$
                        + "' tool is invalid/malformed!", e.getFilter(), e); //$NON-NLS-1$

                throw ise;
            }
        }

        return true;
    }

    /**
     * Formats a string based on a set of bindings.
     * Example:
     * <pre>
     *    Map bindings = new HashMap();
     *    bindings.put("value", "bar");
     *    String result = format("foo{value}", bindings);
     *    // result will now equal "foobar"
     * </pre>
     * 
     * @param format The format string
     * @param bindings The replace variables.
     * @return A formatted string.
     */
    private static String format(String format, final Map<Object, Object> bindings)
    {
        return format(format, new IProperties()
        {
            public String get(String key)
            {
                return (String) bindings.get(key);
            }
        });
    }

    /**
     * @param format The format string.
     * @param bindings The replace variables.
     * @return A formatted string.
     */
    private static String format(String format, IProperties bindings)
    {
        StringBuilder output = new StringBuilder();

        int length = format.length();
        int start = -1;
        int end = length;
        while (true)
        {
            end = format.indexOf('{', start);
            if (end > -1)
            {
                output.append(format.substring(start + 1, end));
                start = format.indexOf('}', end);
                if (start > -1)
                {
                    String key = format.substring(end + 1, start);
                    String s = bindings.get(key);

                    if (s != null)
                    {
                        output.append(s);
                    }
                }
                else
                {
                    output.append(format.substring(end, length));
                    break;
                }
            }
            else
            {
                output.append(format.substring(start + 1, length));
                break;
            }
        }
        return output.toString();
    }

    /**
     * IProperties
     */
    private static interface IProperties
    {
        String get(String key);
    }

    /**
     * Get the path to the tool-file-store directory
     * @return the path
     */
    public static String getFilestoreRoot()
    {
        String repositoryRoot = System.getProperty("tool.file.store", DEFAULT_FILESTORE_LOCATION); //$NON-NLS-1$
        File file = new File(repositoryRoot);
        if (repositoryRoot.equals(DEFAULT_FILESTORE_LOCATION) && !file.exists())
        {
            file.mkdir();
        }

        if (repositoryRoot.endsWith("/")) //$NON-NLS-1$
        {
            repositoryRoot = repositoryRoot.substring(0, repositoryRoot.length() - 1);
        }
        return repositoryRoot;
    }

    /**
     * CompoundProperties
     */
    private static class CompoundProperties implements IProperties
    {
        private IProperties props;
        private Properties overrides;

        public CompoundProperties(IProperties props, Properties overrides)
        {
            this.props = props;
            this.overrides = overrides == null ? new Properties() : overrides;
        }

        public String get(String key)
        {
            if (overrides.containsKey(key))
            {
                return (String) overrides.get(key);
            }
            return props.get(key);
        }
    }

    /**
     * ScriptDeviceProperties
     */
    @SuppressWarnings("nls")
    private static class ScriptDeviceProperties implements IProperties
    {
        private static HashMap<String, Method> methodMap;
        private static final Map<String, String> PROPERTIES;
        private static final String ADAPTER_SHORTNAME = "device.osTypeShort";

        private ZDeviceLite device;

        static
        {
            methodMap = new HashMap<String, Method>();
            Method[] methods = ZDeviceLite.class.getMethods();
            for (Method method : methods)
            {
                methodMap.put(method.getName(), method);
            }

            // Use an additional map to map certain keys to other aliases 
            PROPERTIES = new HashMap<String, String>();
            PROPERTIES.put("device.ipAddress", "ipAddress");
            PROPERTIES.put("device.osType", "adapterId");
            PROPERTIES.put(ADAPTER_SHORTNAME, "adapterId");
            PROPERTIES.put("device.hostname", "hostname");
            PROPERTIES.put("config.hostname", "hostname");
            PROPERTIES.put("device.managedNetwork", "managedNetwork");
            PROPERTIES.put("config.make", "hardwareVendor");
            PROPERTIES.put("config.hardwareVendor", "hardwareVendor");
            PROPERTIES.put("config.model", "model");
            PROPERTIES.put("config.chassis.softwareVersion", "osVersion");
            PROPERTIES.put("device.osVersion", "osVersion");
        }

        public ScriptDeviceProperties(ZDeviceLite device)
        {
            this.device = device;
        }

        public String get(String key)
        {
            String localKey = key;

            // Check to see if the key should be aliased into something else.  If not, then use the local key
            String aliasedKey = PROPERTIES.get(localKey);

            if (aliasedKey != null)
            {
                localKey = aliasedKey;
            }
            else if (key.indexOf('.') > 0)
            {
                localKey = key.substring(key.indexOf('.') + 1);

                if (key.startsWith("cred.")) //$NON-NLS-1$
                {
                    return getCredentialValue(localKey);
                }
            }

            // Attempt to generate a connection path XML
            if (key.equals(CONNECTION_PATH_KEY))
            {
                return getConnectionPathXML();
            }
            else if (key.equals(FILESTORE_KEY))
            {
                return getFilestoreRoot();
            }

            StringBuilder sb = new StringBuilder();
            sb.append("get").append(Character.toUpperCase(localKey.charAt(0))).append(localKey.substring(1)); //$NON-NLS-1$

            String getter = sb.toString();

            Method method = methodMap.get(getter);
            Object result;
            try
            {
                result = method.invoke(device, new Object[0]);
                return result.toString();
            }
            catch (Exception e)
            {
                return ""; //$NON-NLS-1$
            }
        }

        private String getCredentialValue(String key)
        {
            // Retrieve the credentials
            try
            {
                List<CredentialSet> credentialSets = CredentialElf.calculateCredentialSets(device);
                if (credentialSets.size() > 0)
                {
                    CredentialSet credSet = credentialSets.get(0);
                    return credSet.getCredentialValue(key);
                }

                return ""; //$NON-NLS-1$
            }
            catch (Exception e)
            {
                LOGGER.warn("Invalid credential reference cred." + key); //$NON-NLS-1$
                return ""; //$NON-NLS-1$
            }
        }

        /**
         * Generates a connection path XML based on the IP address, credentials, and protocols associated with the device that is
         * part of this {@link ScriptDeviceProperty}.
         * 
         * @return XML representation of a connection path.
         */
        private String getConnectionPathXML()
        {
            String host = device.getIpAddress();
            ProtocolSet protocolHint = null;
            ProtocolSet enabledProtocols = null;
            CredentialSet credentials = null;
            List<FileServerInfo> fsi = new ArrayList<FileServerInfo>();

            // Attempt to get the credentials and protocols to use for this device
            try
            {
             // Determine whether or not the host we are trying to connect to is a IPv4 or IPv6 compatible device
                boolean useIPv6 = (NetworkAddressElf.isValidIpAddress(host) && NetworkAddressElf.isIPv6AddressOrMask(host)) ? true : false;
                
                // Attempt to use a stored credential set that is known to work with the device in question
                List<CredentialSet> credSets = CredentialElf.calculateCredentialSets(device);
                credentials = credSets.get(0);

                /*
                 * All enabled protocols will be given to the script tool
                 */
                enabledProtocols = CredentialElf.getEnabledProtocols(device);
                for (Protocol protocol : enabledProtocols.getProtocols())
                {
                    if (protocol.getName().equals(ProtocolNames.TFTP.name()))
                    {
                        fsi.add(ConnectionPathElf.getTftpFileServerInfo(useIPv6));
                    }
                    else if (protocol.getName().equals(ProtocolNames.FTP.name()))
                    {
                        fsi.add(ConnectionPathElf.getFtpFileServerInfo(useIPv6));
                    }
                }
            }
            catch (Exception e)
            {
                return ""; //$NON-NLS-1$
            }

            return OperationInputXMLElf.generateXMLString(host, enabledProtocols, credentials, fsi);
        }
    }

    /**
     * Inner-class used to wrap the functionality of a {@link Dictionary} around an implementation of the {@link IProperties} interface.
     * 
     * @author Dylan White (dylamite@ziptie.org)
     */
    @SuppressWarnings("nls")
    private static class PropertiesDictionary extends Dictionary<String, String>
    {
        private IProperties properties;

        /**
         * Constructs a new instance of the {@link PropertiesDictionary} that uses an implementation of the
         * {@link IProperties} interface as the back-end.
         * 
         * @param properties An instance of an implementation of the {@link IProperties} interface.
         */
        public PropertiesDictionary(IProperties properties)
        {
            this.properties = properties;
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public Enumeration<String> elements()
        {
            throw new RuntimeException("elements() is not yet implemented!");
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public String get(Object key)
        {
            return properties.get((String) key);
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public boolean isEmpty()
        {
            throw new RuntimeException("isEmpty() is not yet implemented!");
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public Enumeration<String> keys()
        {
            throw new RuntimeException("keys() is not yet implemented!");
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public String put(String key, String value)
        {
            throw new RuntimeException("put() is not yet implemented!");
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public String remove(Object key)
        {
            throw new RuntimeException("remove() is not yet implemented!");
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public int size()
        {
            throw new RuntimeException("size() is not yet implemented!");
        }
    }
}
