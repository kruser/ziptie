/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is Ziptie Client Framework.
 *
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 *
 * Contributor(s): Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.net.adapters;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.log4j.Logger;
import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;
import org.ziptie.common.StringElf;
import org.ziptie.discovery.DiscoveryEvent;
import org.ziptie.discovery.XdpEntry;
import org.ziptie.net.snmp.DiscoveryMapping;
import org.ziptie.net.snmp.DiscoveryMapping.DiscoverySource;
import org.ziptie.protocols.ProtocolSetElf;

/**
 * The {@link AdapterService} class provides a service to load all of the adapter metadata files that are stored
 * within the local file-system in an adapters resource directory.  Every file and directory in the adapters resource
 * directory is parsed to locate any adapter metadata files.  Once all of the adapter metadata files are found, they
 * are parsed into equivalent {@link AdapterMetadata} objects that provide access to the metadata in a simple
 * fashion.
 *
 * @author Dylan White (dylamite@ziptie.org)
 */
@SuppressWarnings("nls")
public final class AdapterService implements IAdapterService
{
    /**
     * The name of the bundle that contains all of the implementation-specific adapter files.
     * This includes perl modules, adapter metadata and WSDL XML documents, and so on.
     */
    public static final String GENERIC_ADAPTER_ID = "ZipTie::Adapters::Generic::SNMP";
    public static final String BASE_ADAPTER_ID = "ZipTie::Adapters::BaseAdapter";
    public static final String BUNDLE_TYPE = "Bundle-Type";
    public static final String ADAPTER_BUNDLE_TYPE = "adapter";
    public static final String ADAPTER_MANIFEST_ENTRY = BUNDLE_TYPE + ": " + ADAPTER_BUNDLE_TYPE;

    private static final String MANIFEST = "META-INF/MANIFEST.MF";
    private static final Logger LOGGER = Logger.getLogger(AdapterService.class);
    private static final String NAME_ATTR = "name";

    /**
     * The extension of an adapter metadata XML file to look for when trying to locate adapters.
     */
    private static String METADATA_FILE_EXT = ".metadata.xml";

    /**
     * Stores a map of all the {@link AdapterMetadata} objects loaded from the adapter metadata XML files
     * by mapping the adapter's unique ID to its actual {@link AdapterMetadata} representation.
     */
    private Map<String, AdapterMetadata> adapterMetadataMap;
    private AdapterMetadata baseAdapterMetadata;

    /**
     * Stores the {@link DiscoveryMapping} objects as loaded from each adapters metadata.
     */
    private List<DiscoveryMapping> discoveryMappings;

    /** Maps the adapters that are contained within a given folder. */
    private Map<File, Set<String>> adapterFolders;

    /** List of places to perform schema lookups against. If none are specified validation won't be enabled. */
    private Set<URL> schemaLocations;
    private WeakReference<SAXParser> ref;
    /** if <code>true</code>, xml schema validation will be performed. */
    private boolean shouldValidate = true;

    /**
     * Default constructor that initialize the new instance of the {@link AdapterService}.
     * By default, xml schema validation is performed.
     * Use {@link #performSchemaValidation(boolean) performSchemaValidation} to change this behavior.
     */
    public AdapterService()
    {
        this(true);
    }

    /**
     * Default constructor that initialize the new instance of the {@link AdapterService}.
     *
     * @param performSchemaValidation <code>true</code> to perform xml schema validation, <code>false</code> otherwise.
     */
    public AdapterService(boolean performSchemaValidation)
    {
        init();
        performSchemaValidation(performSchemaValidation);
    }

    /** {@inheritDoc} */
    public Collection<AdapterMetadata> getAllAdapterMetadata()
    {
        return adapterMetadataMap.values();
    }

    /** {@inheritDoc} */
    public Set<String> getAllAdapterIDs()
    {
        return adapterMetadataMap.keySet();
    }

    /** {@inheritDoc} */
    public AdapterMetadata getAdapterMetadata(String adapterID)
    {
        AdapterMetadata retrievedMetadata = null;

        if (adapterID != null)
        {
            retrievedMetadata = adapterMetadataMap.get(adapterID);
        }

        return retrievedMetadata;
    }

    /** {@inheritDoc} */
    public String getAdapterId(DiscoveryEvent discoveryEvent)
    {
        for (DiscoveryMapping mapping : discoveryMappings)
        {
            if (discoveryMatches(mapping, discoveryEvent))
            {
                return mapping.getAdapterId();
            }
        }
        return null;
    }

    /**
     * {@inheritDoc}
     */
    public String getAdapterId(XdpEntry xdpEntry)
    {
        DiscoveryEvent event = new DiscoveryEvent();
        event.setAddress(xdpEntry.getIpAddress());
        event.setSysDescr(xdpEntry.getSysDescr());
        event.setSysOID(xdpEntry.getSysOid());
        event.setSysName(xdpEntry.getSysName());
        return getAdapterId(event);
    }

    /** {@inheritDoc} */
    public void removeSchemaLocation(URL url)
    {
        schemaLocations.remove(url);
    }

    /** {@inheritDoc} */
    public void addSchemaLocation(URL url)
    {
        schemaLocations.add(url);
    }

    /** {@inheritDoc} */
    public Set<String> unregisterAdapters(File directory)
    {
        Set<String> ids = adapterFolders.remove(directory);
        if (ids == null)
        {
            return Collections.emptySet();
        }

        // Remove discovery mappings that reference any of these adapters.
        Iterator<DiscoveryMapping> iter = discoveryMappings.iterator();
        while (iter.hasNext())
        {
            DiscoveryMapping mapping = iter.next();
            if (ids.contains(mapping.getAdapterId()))
            {
                iter.remove();
            }
        }

        for (String id : ids)
        {
            adapterMetadataMap.remove(id);
        }

        return ids;
    }

    /** {@inheritDoc} */
    public Set<String> registerAdapters(File directory)
    {
        if (!directory.isDirectory())
        {
            throw new IllegalArgumentException("Could not retrieve a file handle to the '" + directory.getAbsolutePath()
                    + "' bundle when attempting to load adapter metadata!");
        }

        Set<String> ids = findAndLoadMetadataFiles(directory);
        adapterFolders.put(directory, ids);

        return ids;
    }

    /**
     * Using the adapter MANIFEST.MF, determine if this is an adapter bundle.
     *
     * @param jar the jar to search.
     * @return true if it is.
     * @throws IOException if the jar can't be opened.
     */
    public static boolean isAdapterBundle(ZipFile jar) throws IOException
    {
        ZipEntry manifest = jar.getEntry(MANIFEST);
        if (manifest != null)
        {
            String manifestContents = StringElf.inputStreamToString(jar.getInputStream(manifest));
            return manifestContents.contains(ADAPTER_MANIFEST_ENTRY);
        }

        return false;
    }

    /**
     * Sets the flag used to perform xml schema validation when parsing the adapter metadata files.
     *
     * @param performValidation <code>true</code> to turn on validation.
     */
    public void performSchemaValidation(boolean performValidation)
    {
        shouldValidate = performValidation;
    }

    /**
     * Gets the flag used to perform xml schema validation.
     * @return <code>true</code> if schema validation is on, <code>false</code> otherwise.
     */
    public boolean isPerformSchemaValidation()
    {
        return shouldValidate;
    }

    /**
     * If the provided mapping matches the provided discoveryEvent return true, false otherwise.
     *
     * @param mapping read from adapter metadata, contains the regex to parse a discoveryEvent
     * @param discoveryEvent data from discovery
     * @return true if the event matches the mapping, false otherwise
     */
    private boolean discoveryMatches(DiscoveryMapping mapping, DiscoveryEvent discoveryEvent)
    {
        String target;
        switch (mapping.getSource())
        {
        case sysOid:
            target = discoveryEvent.getSysOID();
            break;
        case sysDescr:
            target = discoveryEvent.getSysDescr();
            break;
        case sysName:
            target = discoveryEvent.getSysName();
            break;
        default:
            target = "";
            break;
        }

        Matcher matcher = mapping.getPattern().matcher(target);
        return matcher.find();
    }

    /**
     * Initializes this {@link AdapterService} by creating instances
     * of all the collections used by this {@link AdapterService}.
     */
    private void init()
    {
        schemaLocations = new HashSet<URL>();
        adapterFolders = new HashMap<File, Set<String>>();
        adapterMetadataMap = new ConcurrentHashMap<String, AdapterMetadata>(50);
        discoveryMappings = new LinkedList<DiscoveryMapping>();
    }

    private synchronized SAXParser getParser() throws SAXException
    {
        try
        {
            if (ref != null)
            {
                SAXParser parser = ref.get();
                if (parser != null)
                {
                    return parser;
                }
            }

            SAXParserFactory factory = SAXParserFactory.newInstance();
            factory.setValidating(shouldValidate);
            factory.setNamespaceAware(true);

            SAXParser parser = factory.newSAXParser();
            parser.setProperty("http://java.sun.com/xml/jaxp/properties/schemaLanguage", "http://www.w3.org/2001/XMLSchema");

            if (shouldValidate)
            {
                // Try to enable schema (grammar) caching in the parser
                try
                {
                    Class poolClass = Class.forName("com.sun.org.apache.xerces.internal.util.XMLGrammarPoolImpl");
                    Object grammarPool = poolClass.newInstance();

                    parser.setProperty("http://apache.org/xml/properties/internal/grammar-pool", grammarPool);
                }
                catch (Exception e)
                {
                    // Ignore, we just won't cache grammars then
                    LOGGER.warn("Adapter schemas will not be cached due to unavailablity of a grammer pool.");
                }
            }

            ref = new WeakReference<SAXParser>(parser);

            return parser;
        }
        catch (ParserConfigurationException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Loads up the adapter metadata from the given stream.
     *
     * @param inputStream the stream to read the adapter metadata from.
     * @return the adapter ID
     * @throws IOException
     * @throws SAXException
     */
    private String loadAdapterMetadata(InputStream inputStream) throws SAXException, IOException
    {
        // Create a new AdapterMetadata object to store the data parse from the DOM Document
        AdapterMetadata metadataObj = new AdapterMetadata();
        getParser().parse(inputStream, new AdapterMetadataHandler(metadataObj));

        LOGGER.debug(String.format("Discovered adapter with ID '%s'", metadataObj.getAdapterId()));

        // Now that the AdapterMetadata object has been fully populated
        if (metadataObj.getAdapterId().equals(BASE_ADAPTER_ID))
        {
            baseAdapterMetadata = metadataObj;
            LOGGER.debug(String.format("Found the Base Adapter metadata for '%s' .", metadataObj.getAdapterId()));
            resolveAllAdapterOperations();
        }
        else
        {
            resolveBaseOperations(metadataObj);
            adapterMetadataMap.put(metadataObj.getAdapterId(), metadataObj);
            LOGGER.debug(String.format("Added adapter metadata for '%s' to metadata map.", metadataObj.getAdapterId()));
        }
        return metadataObj.getAdapterId();
    }

    /**
     * Add the operations from the base adapter (if not null)
     * @param metadataObj
     */
    private void resolveBaseOperations(AdapterMetadata metadataObj)
    {
        if (baseAdapterMetadata != null)
        {
            for (Operation operation : baseAdapterMetadata.getOperations())
            {
                if (metadataObj.getOperation(operation.getName()) == null)
                {
                    metadataObj.addOperation(operation.getName(), operation);
                }
            }
        }
    }

    /**
     * Should be called when the base adapter is found.  This method will cycle through all
     * previously found adapters and union their operations with the base adapter's operation.
     */
    private void resolveAllAdapterOperations()
    {
        for (Map.Entry<String, AdapterMetadata> adapters : adapterMetadataMap.entrySet())
        {
            resolveBaseOperations(adapters.getValue());
        }
    }

    /**
     * Creates a {@link DiscoveryMapping} object from the provided XML element.
     *
     * @param adapterId the ID of the adapter for this mapping
     * @param element the XML element to parse
     */
    private void createDiscoveryMapping(String adapterId, Attributes element)
    {
        String dataSource = element.getValue("dataSource");
        DiscoveryMapping mapping = new DiscoveryMapping(adapterId, DiscoverySource.valueOf(dataSource));

        int flags = 0;
        if (Boolean.parseBoolean(element.getValue("ignoreCase")))
        {
            flags |= Pattern.CASE_INSENSITIVE;
        }
        if (Boolean.parseBoolean(element.getValue("multiline")))
        {
            flags |= Pattern.MULTILINE;
        }
        if (Boolean.parseBoolean(element.getValue("singleline")))
        {
            flags |= Pattern.DOTALL;
        }
        String regex = element.getValue("regex");
        mapping.setPattern(Pattern.compile(regex, flags));
        discoveryMappings.add(mapping);
    }

    /**
     * Retrieves all of the adapter metadata files that exists within a directory structure.
     * This is done by walking the entire directory structure using recursion.
     *
     * If it finds any intersting jar files that may be adapter bundles, it will also open
     * those jars in search of metadata files.
     *
     * @param rootDir The root directory to begin the traversal at.
     * @return A list of all the adapter metadata files found.
     * @throws AdapterServiceException
     */
    private Set<String> findAndLoadMetadataFiles(File rootDir)
    {
        Set<String> result = new HashSet<String>();

        if (rootDir.isDirectory())
        {
            File[] files = rootDir.listFiles();
            Arrays.sort(files);
            for (File file : files)
            {
                if (file.getName().endsWith(METADATA_FILE_EXT))
                {
                    String id = loadAdapterMetadata(file);
                    if (id != null)
                    {
                        result.add(id);
                    }
                }
                else if (file.getName().matches(".+\\.jar"))
                {
                    searchJarForMetadata(file);
                }
                else if (file.isDirectory())
                {
                    result.addAll(findAndLoadMetadataFiles(file));
                }
            }
        }

        return result;
    }

    /**
     * Opens a jar file in search of adapter metadata.xml files.
     * If one is found, then it is added to the {@link AdapterService}.
     *
     * @param file the jar file to look at.
     */
    private void searchJarForMetadata(File file)
    {
        LOGGER.debug("Searching JAR file for adapters: " + file.getName());
        try
        {
            ZipFile jar = new ZipFile(file);
            if (isAdapterBundle(jar))
            {
                Enumeration<? extends ZipEntry> entries = jar.entries();
                while (entries.hasMoreElements())
                {
                    ZipEntry entry = entries.nextElement();
                    if (entry.getName().endsWith(METADATA_FILE_EXT))
                    {
                        LOGGER.debug("Loading adapter metadata '" + entry.getName() + "' from jar file '" + jar.getName() + "'");
                        loadAdapterMetadata(jar.getInputStream(entry));
                    }
                }
            }
        }
        catch (IOException e)
        {
            LOGGER.error("Error opening up file " + file.getName(), e);
        }
        catch (SAXException e)
        {
            LOGGER.error("Error parsing file " + file.getName(), e);
        }
    }

    /**
     * Loads the adapter metadata file.
     *
     * @param file the adapter matadata file to load.
     * @return the adapter id or <code>null</code> if it cant be loaded.
     */
    private String loadAdapterMetadata(File file)
    {
        try
        {
            LOGGER.debug(String.format("Loading adapter metadata from file '%s'", file.getAbsolutePath()));
            return loadAdapterMetadata(new FileInputStream(file));
        }
        catch (SAXParseException e)
        {
            LOGGER.warn("Invalid adapter metadata: " + file.getAbsolutePath());
            LOGGER.warn(String.format("Validation error: L%d C%d: %s", e.getLineNumber(), e.getColumnNumber(), e.getMessage()));
        }
        catch (IOException e)
        {
            LOGGER.warn("Error loading adapter metdata file '" + file + "'!", e);
        }
        catch (SAXException e)
        {
            LOGGER.warn("Error parsing adapter metdata file '" + file + "'!", e);
        }

        return null;
    }

    /**
     * @return The {@link AdapterService} singleton.
     * @deprecated the {@link AdapterService}'s life-cycle should be managed externally to this class.
     */
    @Deprecated
    public static AdapterService getInstance()
    {
        return AdapterServiceSingleton.instance;
    }

    /**
     * {@link AdapterServiceSingleton} provides a way to "lazy-load" the singleton instance of the
     * {@link AdapterService} class to by-pass the overhead of synchronizing.  This class was designed
     * for use with {@link AdapterService}'s {@link #getInstance()} method, which is designed to
     * retrieve the singleton instance of that class.
     *
     * @author Dylan White (dylamite@ziptie.org)
     * @deprecated
     */
    @Deprecated
    private static class AdapterServiceSingleton
    {
        /**
         * The singleton instance of the {@link AdapterService} class, without xml schema validation.
         */
        private static AdapterService instance = new AdapterService(false);
    }

    /**
     * SAX parser handler for adapter meta-data.
     */
    private final class AdapterMetadataHandler extends DefaultHandler
    {
        private AdapterMetadata metadataObj;
        private StringBuilder builder = new StringBuilder();
        private Operation operation;
        private Set<String> interesting;

        private AdapterMetadataHandler(AdapterMetadata metadataObj)
        {
            this.metadataObj = metadataObj;

            interesting = new HashSet<String>();
            interesting.add("adapterId");
            interesting.add("shortName");
            interesting.add("description");
            interesting.add("softwareVersionRegEx");
            interesting.add("biosVersionRegEx");
            interesting.add("supportedModelVersion");
        }

        @Override
        public InputSource resolveEntity(String publicId, String systemId) throws IOException, SAXException
        {
            int slash = systemId.lastIndexOf('/');
            if (slash >= 0)
            {
                String name = systemId.substring(slash);
                for (URL url : schemaLocations)
                {
                    try
                    {
                        URL loc = new URL(url.toString() + name);
                        loc.openConnection();
                        return new InputSource(loc.toExternalForm());
                    }
                    catch (IOException e)
                    {
                        continue;
                    }
                }
            }

            return new InputSource(systemId);
        }

        @Override
        public void error(SAXParseException e) throws SAXException
        {
            if (!schemaLocations.isEmpty())
            {
                throw e;
            }
        }

        @Override
        public void warning(SAXParseException e) throws SAXException
        {
            if (!schemaLocations.isEmpty())
            {
                throw e;
            }
        }

        @Override
        public void startElement(String uri, String localName, String name, Attributes attrs) throws SAXException
        {
            if (localName.equals("operation"))
            {
                operation = new Operation();
                operation.setName(attrs.getValue(NAME_ATTR));
                metadataObj.addOperation(operation.getName(), operation);
            }
            else if (localName.equals("matchRegex"))
            {
                createDiscoveryMapping(metadataObj.getAdapterId(), attrs);
            }

            builder.setLength(0);
        }

        public void characters(char[] ch, int start, int length) throws SAXException
        {
            builder.append(ch, start, length);
        }

        @Override
        public void endElement(String uri, String localName, String name) throws SAXException
        {
            String value = builder.toString();
            builder.setLength(0);

            if (interesting.contains(localName))
            {
                StringBuilder buf = new StringBuilder(localName.length() + 3);
                buf.append("set").append(localName);
                buf.setCharAt(3, Character.toUpperCase(buf.charAt(3)));

                try
                {
                    Method m = metadataObj.getClass().getDeclaredMethod(buf.toString(), String.class);
                    m.invoke(metadataObj, value);
                }
                catch (Exception e)
                {
                    throw new SAXException(e);
                }
            }
            else if (localName.equals("lastRebootThreshold"))
            {
                metadataObj.setLastRebootThreshold(new Long(value));
            }
            else if (localName.equals("errorRegEx"))
            {
                metadataObj.addErrorForm(value);
            }
            else if (localName.equals("supportedProtocolSet"))
            {
                operation.addProtocolSet(ProtocolSetElf.createProtocolSet(value));
            }
            else if (localName.equals("restoreValidationRegex"))
            {
                operation.addRestoreValidationRegex(value);
            }
        }
    }

}
