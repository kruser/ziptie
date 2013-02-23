package org.ziptie.provider.configstore;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.zip.CheckedOutputStream;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLEventWriter;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.events.Attribute;
import javax.xml.stream.events.Characters;
import javax.xml.stream.events.EndElement;
import javax.xml.stream.events.StartElement;
import javax.xml.stream.events.XMLEvent;

import org.apache.log4j.Logger;
import org.ziptie.provider.configstore.internal.ConfigStoreActivator;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.server.job.backup.IBackupPersisterEx;
import org.ziptie.zap.util.Base64;
import org.ziptie.zap.util.Base64.Base64OutputStream;

/**
 * ConfigBackupPersister
 */
public class ConfigBackupPersister implements IBackupPersisterEx
{
    public static final String ZIPTIE_ELEMENT_DOCUMENT = "ZipTie-Element-Document"; //$NON-NLS-1$

    private static final Logger LOGGER = Logger.getLogger(ConfigBackupPersister.class);

    private static final String TEXT_BLOB = "textBlob"; //$NON-NLS-1$
    private static final int FILE_BUFFER = 4096;

    private static XMLOutputFactory XML_OUTPUT_FACTORY;
    private static List<String> pathsOfInterest;
    private static Map<String, State> localName2StateMap;

    private State state;
    private StringBuilder charData;
    private ZDeviceCore device;
    private String mediaType;
    private String configName;
    private OutputStream outputStream;
    private boolean ignoreElementContents;
    private boolean acceptingZed;

    private ConfigStore configStore;
    private List<ConfigHolder> configs;
    private LinkedList<String> pathStack;

    private OutputStream zedOutputStream;
    private XMLEventWriter xmlEventWriter;

    private File currentConfigFile;

    static
    {
        pathsOfInterest = new ArrayList<String>();
        pathsOfInterest.add("/ZiptieElementDocument/configRepository"); //$NON-NLS-1$
        pathsOfInterest.add("/ZiptieElementDocument/configRepository/*"); //$NON-NLS-1$
        pathsOfInterest.add("/ZiptieElementDocument/lastReboot"); //$NON-NLS-1$

        localName2StateMap = new HashMap<String, State>();
        localName2StateMap.put("configRepository", State.REPOSITORY); //$NON-NLS-1$
        localName2StateMap.put("folder", State.FOLDER); //$NON-NLS-1$
        localName2StateMap.put("config", State.CONFIG); //$NON-NLS-1$
        localName2StateMap.put("context", State.CONFIG_CONTEXT); //$NON-NLS-1$
        localName2StateMap.put("mediaType", State.CONFIG_MEDIA_TYPE); //$NON-NLS-1$
        localName2StateMap.put("name", State.NAME); //$NON-NLS-1$
        localName2StateMap.put(TEXT_BLOB, State.CONFIG_TEXTBLOB);
        localName2StateMap.put("lastReboot", State.LAST_REBOOT); //$NON-NLS-1$

        XML_OUTPUT_FACTORY = XMLOutputFactory.newInstance();
    }

    /**
     * Default constructor.
     */
    public ConfigBackupPersister()
    {
        state = State.NONE;
        charData = new StringBuilder();
        configs = new ArrayList<ConfigHolder>();
        acceptingZed = true;

        configStore = (ConfigStore) ConfigStoreActivator.getConfigStore();

        pathStack = new LinkedList<String>();
    }

    /** {@inheritDoc} */
    public void setDevice(ZDeviceCore device)
    {
        this.device = device;
    }

    /** {@inheritDoc} */
    public void startDocument(XMLEvent xmlEvent)
    {
    }

    /** {@inheritDoc} */
    public void startElement(XMLEvent xmlEvent)
    {
        StartElement element = xmlEvent.asStartElement();
        String localPart = element.getName().getLocalPart();
        state = localName2StateMap.get(localPart);
        if (state == null)
        {
            state = State.NONE;
            return;
        }

        switch (state)
        {
        case CONFIG_TEXTBLOB:
            ignoreElementContents = true;
            acceptingZed = false;
            startConfigSave();
            break;
        case REPOSITORY:
            // fall thru
        case FOLDER:
            Attribute attributeByName = element.getAttributeByName(new QName("name"));
            if (attributeByName != null)
            {
                String path = attributeByName.getValue();
                path = (pathStack.isEmpty() ? path : pathStack.peek() + path + "/"); //$NON-NLS-1$
                pathStack.addFirst(path);
            }
            break;
        case LAST_REBOOT:
            ignoreElementContents = true;
            break;
        default:
            break;
        }
    }

    /** {@inheritDoc} */
    public void characterData(XMLEvent xmlEvent)
    {
        Characters characters = xmlEvent.asCharacters();
        if (state == State.CONFIG_TEXTBLOB)
        {
            charData.append(characters.getData().trim());
            writeConfigFile();
        }
        else
        {
            String data = characters.getData();
            if (characters.isIgnorableWhiteSpace())
            {
                return;
            }

            charData.append(data);
        }
    }

    /** {@inheritDoc} */
    public void endElement(XMLEvent xmlEvent)
    {
        EndElement element = xmlEvent.asEndElement();
        String localPart = element.getName().getLocalPart();
        state = localName2StateMap.get(localPart);
        if (state != null)
        {
            switch (state)
            {
            case NAME:
                this.configName = charData.toString().trim();
                break;
            case CONFIG_MEDIA_TYPE:
                this.mediaType = charData.toString().trim();
                break;
            case CONFIG_TEXTBLOB:
                endConfigSave();
                ignoreElementContents = false;
                break;
            case LAST_REBOOT:
                ignoreElementContents = false;
                acceptingZed = false;
                break;
            case REPOSITORY:
                // fall thru
            case FOLDER:
                pathStack.poll();
                break;
            default:
                break;
            }
        }

        charData.setLength(0);
        state = State.NONE;
    }

    /** {@inheritDoc} */
    public void endDocument(XMLEvent xmlEvent)
    {
        try
        {
            xmlEventWriter.close();
            zedOutputStream.close();

            configStore.updateVersions(device, configs);

            for (ConfigHolder holder : configs)
            {
                holder.getConfigFile().delete();
            }
        }
        catch (XMLStreamException e)
        {
            throw new RuntimeException("Error closing ZED XMLEventWriter.", e); //$NON-NLS-1$
        }
        catch (IOException e)
        {
            throw new RuntimeException("Error closing ZED XMLEventWriter.", e); //$NON-NLS-1$
        }
    }

    /** {@inheritDoc} 
     * @throws XMLStreamException */
    public void handleEvent(XMLEvent xmlEvent) throws XMLStreamException
    {
        if (!ignoreElementContents)
        {
            if (xmlEventWriter == null)
            {
                createZed();
            }

            if (acceptingZed)
            {
                xmlEventWriter.add(xmlEvent);
            }
            else
            {
                acceptingZed = true;
            }
        }
    }

    /** {@inheritDoc} */
    public void cleanup()
    {
        try
        {
            xmlEventWriter.close();
            zedOutputStream.close();
        }
        catch (Exception e)
        {
            return;
        }
    }

    /** {@inheritDoc} */
    public List<String> getPathsOfInterest()
    {
        return pathsOfInterest;
    }

    // -----------------------------------------------------------------------
    //                     P R I V A T E   M E T H O D S
    // -----------------------------------------------------------------------

    private void createZed()
    {
        try
        {
            File outputFile = File.createTempFile(ZIPTIE_ELEMENT_DOCUMENT, ".xml"); //$NON-NLS-1$
            ConfigHolder configHolder = new ConfigHolder(outputFile, '/' + ZIPTIE_ELEMENT_DOCUMENT, "text/xml"); //$NON-NLS-1$
            BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(outputFile), FILE_BUFFER);
            zedOutputStream = new CheckedOutputStream(bos, configHolder.getChecksum());
            xmlEventWriter = XML_OUTPUT_FACTORY.createXMLEventWriter(zedOutputStream);

            configs.add(configHolder);
        }
        catch (IOException e)
        {
            throw new RuntimeException("Error copying ZipTie Element Document to configuration repository.", e); //$NON-NLS-1$
        }
        catch (XMLStreamException e)
        {
            throw new RuntimeException("Error copying ZipTie Element Document to configuration repository.", e); //$NON-NLS-1$
        }
    }

    /**
     * Called when a configuration entry in the ZED is first encountered
     */
    private void startConfigSave()
    {
        if (configName != null)
        {
            try
            {
                String subDir = pathStack.peek();
                if (subDir != null && subDir.endsWith("/")) //$NON-NLS-1$
                {
                    subDir = subDir.substring(0, subDir.lastIndexOf('/'));
                }
                else
                {
                    subDir = ""; //$NON-NLS-1$
                }

                currentConfigFile = File.createTempFile(configName, ".cfg"); //$NON-NLS-1$
                ConfigHolder configHolder = new ConfigHolder(currentConfigFile, subDir + '/' + configName, mediaType);
                configs.add(configHolder);

                FileOutputStream fos = new FileOutputStream(currentConfigFile);
                BufferedOutputStream bos = new BufferedOutputStream(fos);
                CheckedOutputStream crc32os = new CheckedOutputStream(bos, configHolder.getChecksum());
                Base64OutputStream b64os = new Base64.Base64OutputStream(crc32os, Base64.DECODE);
                outputStream = new BufferedOutputStream(b64os, FILE_BUFFER);
            }
            catch (IOException e)
            {
                e.printStackTrace();
            }
        }
    }

    /**
     * Called when a configuration entry in the ZED is finished
     */
    private void endConfigSave()
    {
        try
        {
            // Finish writing the temp file
            writeConfigFile();
            outputStream.close();
            configName = null;
        }
        catch (IOException e)
        {
            LOGGER.error(Messages.ConfigBackupPersister_unableToWriteOrClose, e);
        }
    }

    /**
     * Called to write configuration data to a file
     */
    private void writeConfigFile()
    {
        if (outputStream == null)
        {
            return;
        }

        try
        {
            outputStream.write(charData.toString().getBytes("UTF-8")); //$NON-NLS-1$
            charData.setLength(0);
        }
        catch (Exception e)
        {
            throw new RuntimeException(Messages.ConfigBackupPersister_unableToWriteOrClose, e);
        }
    }

    // -----------------------------------------------------------------------
    //                       I N N E R   C L A S S E S
    // -----------------------------------------------------------------------

    /**
     * State
     */
    private enum State
    {
        NONE,
        REPOSITORY,
        FOLDER,
        CONFIG,
        CONFIG_CONTEXT,
        CONFIG_MEDIA_TYPE,
        NAME,
        CONFIG_TEXTBLOB,
        LAST_REBOOT,
    }
}
