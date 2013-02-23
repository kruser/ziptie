/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: mdessureault $
 *     $Date: 2008/03/28 18:28:52 $
 * $Revision: 1.6 $
 *   $Source: /usr/local/cvsroot/EclipseBuild/src/org/ziptie/build/Plugin.java,v $
 */

package org.ziptie.build;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.Map.Entry;
import java.util.jar.JarFile;
import java.util.jar.Manifest;
import java.util.zip.ZipEntry;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.eclipse.osgi.util.ManifestElement;
import org.osgi.framework.BundleException;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * Describes a plugin.
 */
@SuppressWarnings("nls")
public final class Plugin
{
    public static final String META_INF = "META-INF";
    public static final String MANIFEST_MF = META_INF + "/MANIFEST.MF";
    public static final String PLUGIN_XML = "plugin.xml";

    private static final String BUNDLE_ID_KEY = "Bundle-SymbolicName";
    private static final String BUNDLE_REQUIRES_KEY = "Require-Bundle";
    private static final String BUNDLE_CLASSPATH_KEY = "Bundle-ClassPath";
    private static final String BUDNLE_PLATFORM_FILTER_KEY = "Eclipse-PlatformFilter";
    private static final String BUNDLE_HOST_KEY = "Fragment-Host";
    private static final String BUNDLE_IMPORT_PKG_KEY = "Import-Package";
    private static final String BUNDLE_EXPORT_PKG_KEY = "Export-Package";
    private static final String BUNDLE_VERSION_KEY = "Bundle-Version";

    private static final String BUILD_PROPERTIES = "build.properties";
    private static final String BIN_INCLUDES = "bin.includes";

    private static final String ATTR_NAME = "name";
    private static final String ATTR_PLUGIN = "plugin";
    private static final String ATTR_VERSION = "version";

    private String id;
    private String version;
    private File dir;
    private Set<String> imports = new HashSet<String>();
    private Set<String> libraries = new HashSet<String>();
    private Set<String> packages = new HashSet<String>();

    private List<Entry<File, List<File>>> sources = new LinkedList<Entry<File, List<File>>>();
    private Map<File, File> outputs = new HashMap<File, File>();
    private String binIncludes;
    private String fragmentHost;

    /** The plugin dir location or <code>null</code> */
    private String location;

    private Set<String> importPackage = new HashSet<String>();

    /** Fragment Operating System filter. */
    private String osFilter;
    /** Fragment Window System filter. */
    private String wsFilter;
    /** Fragment architecture filter. */
    private String archFilter;

    private boolean enabled = true;

    private boolean hasNoBuildProperties;

    /**
     * Hidden constructor
     * @see #loadPlugin(Project, File, PlatformConfig)
     */
    private Plugin()
    {
        // do nothing.
    }

    /**
     * This plugin's ID (symbolic-name).
     * @return The id.
     */
    public String getId()
    {
        return id;
    }

    /**
     * This plugin's version.
     * @return The version.
     */
    public String getVersion()
    {
        return version;
    }

    /**
     * The directory or jar containing this plugin.
     * @return The container directory.
     */
    public File getDir()
    {
        return dir;
    }

    /**
     * Libraries dependencies.
     * @return The set of jars this plugin depends on directly.
     */
    public Set<String> getLibraries()
    {
        return libraries;
    }

    /**
     * The set of imported plugins.
     * @return The pluginIds
     */
    public Set<String> getImports()
    {
        return imports;
    }

    /**
     * A map of jars to bin dirs.
     * @return The bin dirs.
     */
    public Map<File, File> getOutputs()
    {
        return outputs;
    }

    /**
     * The list of output jars.
     * @return The output jars.
     */
    public List<File> getJars()
    {
        LinkedList<File> jars = new LinkedList<File>();
        for (Entry<File, List<File>> entry : getSources())
        {
            jars.add(entry.getKey());
        }
        return jars;
    }

    /**
     * A map of jars to source directories
     * @return The source dirs.
     */
    public List<Entry<File, List<File>>> getSources()
    {
        return sources;
    }

    /**
     * The set of files and folders that will be distributed in this plugin.
     * @return The bin.includes line.
     */
    public String getBinIncludes()
    {
        return binIncludes;
    }

    /**
     * If this is a fragment, the plugin that it is injected into.
     * @return The fragment's host plugin.
     */
    public String getFragmentHost()
    {
        return fragmentHost;
    }

    /**
     * The set of imported packages.
     * @return The imported packages.
     */
    public Set<String> getImportPackage()
    {
        return importPackage;
    }

    /**
     * Is this plugin enabled.
     * @return <code>true</code> if the plugin should be built for the current platform configuration.
     */
    public boolean isEnabled()
    {
        return enabled;
    }

    /**
     * The architecture filter.
     * @return The arch platform filter.
     */
    public String getArchFilter()
    {
        return archFilter;
    }

    /**
     * The operating system filter.
     * @return The OS platform filter
     */
    public String getOsFilter()
    {
        return osFilter;
    }

    /**
     * The window system filter.
     * @return the window system platform filter.
     */
    public String getWsFilter()
    {
        return wsFilter;
    }

    /**
     * Get the exported packages.
     * @return A set of exported packages.
     */
    public Set<String> getPackages()
    {
        return packages;
    }

    /**
     * Gets the directory name to distribute the plugin to.
     * @return the directory name or <code>null</code> if the default location should be used.
     */
    public String getLocation()
    {
        return location;
    }

    private void setId(String value)
    {
        id = value;
    }

    private void setVersion(String value)
    {
        version = value;
    }

    private void addImport(String emport)
    {
        imports.add(emport);
    }

    private void setDir(File dir)
    {
        this.dir = dir;
    }

    private void addLibrary(String lib)
    {
        libraries.add(lib);
    }

    private void addOutput(String jar, String outputDir)
    {
        outputs.put(new File(getDir(), jar), new File(getDir(), outputDir));
    }

    private void addSource(String jar, String srcdir)
    {
        LinkedList<File> list = new LinkedList<File>();
        String[] srcs = srcdir.split(",");
        for (String src : srcs)
        {
            src = src.trim();
            if (src.length() > 0)
            {
                list.add(new File(getDir(), src));
            }
        }

        sources.add(new PEntry(new File(getDir(), jar), list));
    }

    private void setBinIncludes(String binIncludes)
    {
        this.binIncludes = binIncludes;
    }

    private void setFragmentHost(String value)
    {
        fragmentHost = value;
    }

    private void addPackageImport(String packge)
    {
        importPackage.add(packge);
    }

    private void setEnabled(boolean enabled)
    {
        this.enabled = enabled;
    }

    private void setArchFilter(String archFilter)
    {
        this.archFilter = archFilter;
    }

    private void setOsFilter(String osFilter)
    {
        this.osFilter = osFilter;
    }

    private void setWsFilter(String wsFilter)
    {
        this.wsFilter = wsFilter;
    }

    /**
     * Sets the directory name to distribute this plugin to.
     * @param location the plugin directory (ie: 'plugins');
     */
    public void setLocation(String location)
    {
        this.location = location;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return getId().hashCode();
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        try
        {
            return ((Plugin) obj).getId().equals(getId());
        }
        catch (ClassCastException e)
        {
            return false;
        }
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return getId();
    }

    private boolean loadBuildProperties() throws IOException
    {
        File propFile = new File(getDir(), BUILD_PROPERTIES);
        if (!propFile.isFile())
        {
            hasNoBuildProperties = true;
            return false;
        }

        FileInputStream in = new FileInputStream(propFile);
        try
        {
            Properties buildProps = new Properties();
            buildProps.load(in);
            HashMap<String, String> buildSources = new HashMap<String, String>();

            for (Entry<Object, Object> entry : buildProps.entrySet())
            {
                String key = (String) entry.getKey();
                if (key.startsWith("source."))
                {
                    buildSources.put(key.substring(7), (String) entry.getValue());
                }
                if (key.startsWith("output."))
                {
                    addOutput(key.substring(7), (String) entry.getValue());
                }
            }
            String strOrder = buildProps.getProperty("jars.compile.order");
            if (strOrder != null)
            {
                String[] order = strOrder.split(",");
                for (String jarName : order)
                {
                    String src = buildSources.get(jarName);
                    if (src != null)
                    {
                        addSource(jarName, src);
                    }
                }
            }
            else
            {
                for (Entry<String, String> entry : buildSources.entrySet())
                {
                    addSource(entry.getKey(), entry.getValue());
                }
            }
            setBinIncludes(buildProps.getProperty(BIN_INCLUDES));

            return true;
        }
        finally
        {
            in.close();
        }
    }

    /**
     * Loads a plugin from a "plugin.xml" file.
     *
     * @param input The contents of the plugin file.
     * @return A newly create {@link Plugin} instance representing this plugin.
     * @throws IOException
     */
    private boolean loadFromPluginXml(InputStream pluginXml) throws ParserConfigurationException, SAXException, IOException
    {
        SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
        parser.parse(pluginXml, new DefaultHandler()
        {
            @Override
            public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
            {
                if (qName.equals(ATTR_PLUGIN))
                {
                    setId(attributes.getValue("id"));
                    setVersion(attributes.getValue(ATTR_VERSION));
                }
                else if (qName.equals("import"))
                {
                    addImport(attributes.getValue(ATTR_PLUGIN));
                }
                else if (qName.equals("library"))
                {
                    addLibrary(attributes.getValue(ATTR_NAME));
                }
            }
        });
        return true;
    }

    /**
     * Loads a plugin from a "MANIFEST.MF" file.
     *
     * @param input The contents of the manifest file.
     * @return <code>true</code> if the inputstream is a plugin's manifest, <code>false</code> otherwise
     * @throws IOException on error.
     */
    private boolean loadFromManifest(InputStream input, PlatformConfig config) throws IOException
    {
        InputStream normalizedInput = BuildElf.normalizeLastNewlinesEOF(input);

        Manifest manifest = new Manifest(normalizedInput);

        java.util.jar.Attributes attrs = manifest.getMainAttributes();

        String idAttr = attrs.getValue(BUNDLE_ID_KEY);
        if (idAttr == null)
        {
            // this is not a plugin (it might be a feature that just has a MANIFEST.MF defined).
            return false;
        }

        int end = idAttr.indexOf(';');
        if (end == -1)
        {
            setId(idAttr.trim());
        }
        else
        {
            setId(idAttr.substring(0, end).trim());
        }

        String versionAttr = attrs.getValue(BUNDLE_VERSION_KEY);
        if (versionAttr != null)
        {
            setVersion(versionAttr.trim());
        }

        String filter = attrs.getValue(BUDNLE_PLATFORM_FILTER_KEY);
        if (filter != null)
        {
            String pos = findFilter("osgi.os", filter);
            String pws = findFilter("osgi.ws", filter);
            String parch = findFilter("osgi.arch", filter);

            setOsFilter(pos);
            setWsFilter(pws);
            setArchFilter(parch);

            if (!config.isInConfig(pos, pws, parch))
            {
                setEnabled(false);
                // even though the fragment isn't enabled we still need to add it to the injected fragments list so
                // that it will appear in the dependency output file.
            }
        }


        try
        {
            String host = attrs.getValue(BUNDLE_HOST_KEY);
            if (host != null)
            {
                ManifestElement[] elements = ManifestElement.parseHeader(BUNDLE_HOST_KEY, host);
                host = elements[0].getValue();

                setFragmentHost(host);
            }

            // nothing more needs to be done if this fragment is not applicable (disabled) for this platform.
            if (isEnabled())
            {
                loadDependencies(attrs);
            }

            return true;
        }
        catch (BundleException e)
        {
            throw new BuildException(e);
        }
    }

    private void loadDependencies(java.util.jar.Attributes attrs) throws BundleException
    {
        String requires = attrs.getValue(BUNDLE_REQUIRES_KEY);
        if (requires != null)
        {
            ManifestElement[] elements = ManifestElement.parseHeader(BUNDLE_REQUIRES_KEY, requires);
            for (ManifestElement element : elements)
            {
                addImport(element.getValue());
            }
        }

        String classpath = attrs.getValue(BUNDLE_CLASSPATH_KEY);
        if (classpath != null)
        {
            ManifestElement[] elements = ManifestElement.parseHeader(BUNDLE_CLASSPATH_KEY, classpath);
            for (ManifestElement element : elements)
            {
                addLibrary(element.getValue());
            }
        }

        String importPackages = attrs.getValue(BUNDLE_IMPORT_PKG_KEY);
        if (importPackages != null)
        {
            ManifestElement[] elements = ManifestElement.parseHeader(BUNDLE_IMPORT_PKG_KEY, importPackages);
            for (ManifestElement element : elements)
            {
                addPackageImport(element.getValue());
            }
        }

        String exportPackages = attrs.getValue(BUNDLE_EXPORT_PKG_KEY);
        if (exportPackages != null)
        {
            ManifestElement[] elements = ManifestElement.parseHeader(BUNDLE_EXPORT_PKG_KEY, exportPackages);
            for (ManifestElement element : elements)
            {
                packages.add(element.getValue());
            }
        }
    }

    /**
     * Loads the plugin represented by the specified directory.
     * <p>If <code>dir</code> is a file then it will be loaded as a jar.
     *
     * @param project The ant project
     * @param dir The plugin
     * @param config the platform configuration that is currently being built for.
     * @return The newly created {@link Plugin} instance
     * @throws ParserConfigurationException on error
     * @throws SAXException on error
     * @throws IOException on error.
     */
    public static Plugin loadPlugin(Project project, File dir, PlatformConfig config) throws ParserConfigurationException, SAXException, IOException
    {
        Plugin plugin = null;

        if (dir.isFile() && dir.getName().toLowerCase().endsWith(".jar"))
        {
            plugin = loadFromJar(dir, config);
        }
        else if (dir.isDirectory())
        {
            plugin = loadFromDirectory(dir, config);
        }

        if (plugin == null)
        {
            return null;
        }

        plugin.setDir(dir);
        plugin.loadBuildProperties();

        return plugin;
    }

    private static Plugin loadFromDirectory(File dir, PlatformConfig config) throws IOException, ParserConfigurationException, SAXException
    {
        Plugin plugin = new Plugin();

        File manifest = new File(new File(dir, META_INF), "MANIFEST.MF");
        File pluginXml = new File(dir, PLUGIN_XML);
        if (manifest.isFile())
        {
            FileInputStream manifestIn = new FileInputStream(manifest);
            try
            {
                if (plugin.loadFromManifest(manifestIn, config))
                {
                    return plugin;
                }
            }
            catch (IOException ioe)
            {
                System.err.println("Error loading up manifest [" + manifest.getAbsolutePath() + "], " + ioe.getMessage() + ".");
                throw ioe;
            }
            finally
            {
                manifestIn.close();
            }
        }
        else if (pluginXml.isFile())
        {
            FileInputStream xmlIn = new FileInputStream(pluginXml);
            try
            {
                if (plugin.loadFromPluginXml(xmlIn))
                {
                    return plugin;
                }
            }
            finally
            {
                xmlIn.close();
            }
        }

        return null;
    }

    private static Plugin loadFromJar(File dir, PlatformConfig config) throws IOException, ParserConfigurationException, SAXException
    {
        Plugin plugin = new Plugin();

        JarFile jar = new JarFile(dir);
        try
        {

            ZipEntry manifest = jar.getEntry(MANIFEST_MF);
            ZipEntry pluginXml = jar.getEntry(PLUGIN_XML);
            if (manifest != null)
            {
                InputStream manifestIn = jar.getInputStream(manifest);
                try
                {
                    if (plugin.loadFromManifest(manifestIn, config))
                    {
                        return plugin;
                    }
                }
                finally
                {
                    manifestIn.close();
                }
            }
            else if (pluginXml != null)
            {
                InputStream xmlIn = jar.getInputStream(pluginXml);
                try
                {
                    if (plugin.loadFromPluginXml(xmlIn))
                    {
                        return plugin;
                    }
                }
                finally
                {
                    xmlIn.close();
                }
            }

            return null;
        }
        finally
        {
            jar.close();
        }
    }

    /**
     * Parses the system filter string.
     *
     * @param key The property to get.
     * @param string The filter string to parse.
     * @return The value for the given key.
     */
    private static String findFilter(String key, String string)
    {
        String match = key + "=";
        int start = string.indexOf(match);
        if (start != -1)
        {
            start += match.length();
            int end = string.indexOf(')', start);
            return string.substring(start, end);
        }
        return null;
    }

    /**
     * Version with qualifier appended.
     * @param qualifier The version qualifier.
     * @return The version with a qualifier appended.
     */
    public String version(String qualifier)
    {
        if (hasNoBuildProperties)
        {
            return getVersion();
        }

        return isQualifierSet(qualifier) ? getVersion() + '.' + qualifier : getVersion();
    }

    private static boolean isQualifierSet(String qualifier)
    {
        return qualifier != null && qualifier.length() > 0;
    }

    /**
     * A mapping of jar to source location.
     */
    private static class PEntry implements Map.Entry<File, List<File>>
    {
        private File key;
        private List<File> value;

        public PEntry(File key, List<File> value)
        {
            this.key = key;
            this.value = value;
        }

        public File getKey()
        {
            return key;
        }

        public List<File> getValue()
        {
            return value;
        }

        public List<File> setValue(List<File> v)
        {
            throw new UnsupportedOperationException();
        }
    }
}
