package org.ziptie.server.job.backup;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.events.XMLEvent;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;
import org.ziptie.provider.devices.ZDeviceCore;
import org.ziptie.server.job.internal.CoreJobsActivator;

/**
 * StaxProcessor
 */
public class StaxProcessor
{
    private static final Logger LOGGER = Logger.getLogger(StaxProcessor.class);

    private static final String EXTENSION_NAMESPACE = "org.ziptie.server.core.jobs"; //$NON-NLS-1$
    private static final String EXTENSION_POINT_ID = EXTENSION_NAMESPACE + ".backupPersist"; //$NON-NLS-1$

    private static final int BUF_SIZE = 16384;

    private static Class<?>[] persisterExtensions;
    private static Lock extensionLoadLock;

    private static XMLInputFactory factory;

    private Stack tagStack;

    private Map<String, ArrayList<IBackupPersister>> interestMap;
    private Map<String, ArrayList<IBackupPersister>> trailingWildcardInterestMap;
    private Set<IBackupPersister> wildInterestSet;
    private Set<IBackupPersister> currentInterestSet;
    private List<IBackupPersister> extensionList;
    private List<IBackupPersisterEx> extendedPersisters;

    static
    {
        extensionLoadLock = new ReentrantLock();

        factory = XMLInputFactory.newInstance();
        if (!factory.isPropertySupported(XMLInputFactory.IS_NAMESPACE_AWARE))
        {
            throw new RuntimeException("A namespace-aware STaX parser is not available."); //$NON-NLS-1$
        }
    }

    /**
     * Default constructor.
     */
    public StaxProcessor()
    {
        tagStack = new Stack();
        interestMap = new HashMap<String, ArrayList<IBackupPersister>>();
        trailingWildcardInterestMap = new HashMap<String, ArrayList<IBackupPersister>>();
        wildInterestSet = new HashSet<IBackupPersister>();
        currentInterestSet = new HashSet<IBackupPersister>();

        createPersisterExtensions();
        populateInterestMap();
    }

    /**
     * Process the backup model XML document using a STaX parser.  This method iterates through
     * the document using the STaX "event" style of parsing.  Whenever it encounters a document
     * path (composed of "local QNames" separated by "/") that a persister extension(s) is interested
     * in, it calls that extension(s) with the current XmlEvent from the parser.  The events that
     * this method honors are:
     * <ul>
     *    <li>XMLEvent.START_DOCUMENT</li> 
     *    <li>XMLEvent.END_DOCUMENT</li>
     *    <li>XMLEvent.START_ELEMENT</li>
     *    <li>XMLEvent.END_ELEMENT</li>
     *    <li>XMLEvent.CHARACTERS</li>
     * </ul>
     * 
     * See the class level documentation for more details.
     *
     * @param device the device whose XML model we are parsing
     * @param backupOutput a File reference to a temporary file containing the backup model XML
     * @throws Exception thrown if an internal error occurs in parsing or an exception thrown by
     *    one of the persister extensions
     */
    // CHECKSTYLE:OFF
    public void process(ZDeviceCore device, File backupOutput) throws Exception
    {
        // CHECKSTYLE:ON
        long startTime = LOGGER.isDebugEnabled() ? System.currentTimeMillis() : 0;

        for (IBackupPersister persister : extensionList)
        {
            persister.setDevice(device);
        }

        BufferedReader reader = new BufferedReader(new FileReader(backupOutput), BUF_SIZE);
        XMLEventReader parser = factory.createXMLEventReader(reader);
        try
        {
            Set<IBackupPersister> callees = null;
            String currentPath = null;

            XMLEvent peekEvent = parser.peek();
            while (parser.hasNext())
            {
                XMLEvent xmlEvent = parser.nextEvent();
                if (xmlEvent != peekEvent)
                {
                    throw new RuntimeException("One or more persist extensions advanced the STaX iterator.  This is not allowed."); //$NON-NLS-1$
                }

                if (parser.hasNext())
                {
                    peekEvent = parser.peek();
                }

                switch (xmlEvent.getEventType())
                {
                case XMLEvent.CHARACTERS:
                    callees = getInterestedParties(currentPath, XMLEvent.CHARACTERS);
                    for (IBackupPersister persister : callees)
                    {
                        persister.characterData(xmlEvent);
                    }
                    break;
                case XMLEvent.START_ELEMENT:
                    tagStack.push(xmlEvent.asStartElement().getName().getLocalPart());
                    currentPath = tagStack.toString();

                    callees = getInterestedParties(currentPath, XMLEvent.START_ELEMENT);
                    for (IBackupPersister persister : callees)
                    {
                        persister.startElement(xmlEvent);
                    }
                    break;
                case XMLEvent.END_ELEMENT:
                    callees = getInterestedParties(currentPath, XMLEvent.END_ELEMENT);
                    for (IBackupPersister persister : callees)
                    {
                        persister.endElement(xmlEvent);
                    }

                    tagStack.pop();
                    currentPath = tagStack.toString();
                    break;
                case XMLEvent.START_DOCUMENT:
                    for (IBackupPersister persister : extensionList)
                    {
                        persister.startDocument(xmlEvent);
                    }
                    break;
                case XMLEvent.END_DOCUMENT:
                    for (IBackupPersister persister : extensionList)
                    {
                        persister.endDocument(xmlEvent);
                    }
                    break;
                default:
                    break;
                }

                for (IBackupPersisterEx persister : extendedPersisters)
                {
                    persister.handleEvent(xmlEvent);
                }
            }
        }
        finally
        {
            cleanupPersisters();

            parser.close();
        }

        if (LOGGER.isDebugEnabled())
        {
            LOGGER.debug(String.format("Total STaX parse/persist time: %dms", (System.currentTimeMillis() - startTime))); //$NON-NLS-1$
        }
    }

    // ----------------------------------------------------------------------
    //                           Private Methods
    // ----------------------------------------------------------------------

    /**
     * This method obtains a fresh list of new instance of the persister
     * extensions, and queries each extension for it's list of "paths"
     * in the model document that it is interested in.  It then builds
     * a Map of paths to interested extensions to be used during the
     * processing phase.
     *
     * Additionally, as it is visiting each extension to query it's list
     * of paths, it calls that extension to inform it of the device that
     * the model XML represents.  This is accomplished by calling the
     * {@link IBackupPersister#setDevice(ZDeviceCore)} method on each
     * extension.
     */
    private void populateInterestMap()
    {
        for (IBackupPersister persister : extensionList)
        {
            Map<String, ArrayList<IBackupPersister>> workMap = null;
            List<String> pathsOfInterest = persister.getPathsOfInterest();
            for (String path : pathsOfInterest)
            {
                workMap = interestMap;

                if (path.contains("*"))
                {
                    if (!path.endsWith("*"))
                    {
                        throw new RuntimeException("Only trailing wildcards are allowed in 'paths of interest'.");
                    }
                    else
                    {
                        path = path.substring(0, (path.endsWith("/*") ? path.length() - 2 : path.length() - 1));
                        workMap = trailingWildcardInterestMap;
                    }
                }

                ArrayList<IBackupPersister> list = workMap.get(path);
                if (list == null)
                {
                    list = new ArrayList<IBackupPersister>();
                    workMap.put(path, list);
                }
                list.add(persister);
            }
        }
    }

    /**
     * This method returns a set of IBackupPersister instances that are interested in
     * the current path in the document.  In the case of wildcard interest, if the
     * current path is a 'super-path' of the wildcard path, those IBackupPersister
     * instances are returned as well.
     *
     * @param path the current path in the document
     * @param xmlEventType the XMLEvent type that is querying
     * @return a set of IBackupPersisters that which to be called back for this
     *    path
     */
    private Set<IBackupPersister> getInterestedParties(String path, int xmlEventType)
    {
        switch (xmlEventType)
        {
        case XMLEvent.START_ELEMENT:
        {
            ArrayList<IBackupPersister> wildInterests = trailingWildcardInterestMap.get(path);
            if (wildInterests != null)
            {
                wildInterestSet.addAll(wildInterests);
            }
            break;
        }
        case XMLEvent.END_ELEMENT:
        {
            ArrayList<IBackupPersister> wildInterests = trailingWildcardInterestMap.get(path);
            if (wildInterests != null)
            {
                wildInterestSet.removeAll(wildInterests);
            }
            break;
        }
        default:
            break;
        }

        ArrayList<IBackupPersister> interests = interestMap.get(path);
        if (interests != null)
        {
            currentInterestSet.clear();
            currentInterestSet.addAll(wildInterestSet);
            currentInterestSet.addAll(interests);
            return currentInterestSet;
        }
        else
        {
            return wildInterestSet;
        }
    }

    /**
     * This method will "lazily" load the persister extensions that implement the persister
     * extension point defined by this bundle.  This load only occurs once in the lifetime
     * of the bundle.
     *
     * The primary purpose of this method is to populate a list of new instances of the
     * persister extension classes.  If there are no persister extensions, this method
     * produces an empty list.
     */
    private void createPersisterExtensions()
    {
        extensionLoadLock.lock();
        try
        {
            if (persisterExtensions == null)
            {
                IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();
                IConfigurationElement[] configElements = extensionRegistry.getConfigurationElementsFor(EXTENSION_POINT_ID);

                persisterExtensions = new Class[configElements.length];
                if (configElements.length == 0)
                {
                    LOGGER.warn("No Backup Persist extensions discovered."); //$NON-NLS-1$
                }
                else
                {
                    int i = 0;
                    for (IConfigurationElement element : configElements)
                    {
                        String className = element.getAttribute("class"); //$NON-NLS-1$
                        try
                        {
                            String targetBundle = element.getContributor().getName();
                            Bundle bundle = CoreJobsActivator.getBundle(targetBundle);
                            Class<?> clazz = bundle.loadClass(className);
                            persisterExtensions[i++] = clazz;
                        }
                        catch (ClassNotFoundException cnfe)
                        {
                            LOGGER.error(String.format("BackupTask bundle unable to load extension class '%s'", className), cnfe); //$NON-NLS-1$
                        }
                    }
                }
            }
        }
        finally
        {
            extensionLoadLock.unlock();
        }

        extendedPersisters = new ArrayList<IBackupPersisterEx>();
        extensionList = new ArrayList<IBackupPersister>();
        for (Class<?> clazz : persisterExtensions)
        {
            try
            {
                IBackupPersister persister = (IBackupPersister) clazz.newInstance();
                extensionList.add(persister);
                if (persister instanceof IBackupPersisterEx)
                {
                    extendedPersisters.add((IBackupPersisterEx) persister);
                }
            }
            catch (Exception e)
            {
                LOGGER.warn(String.format("Unable to create persister extension %s", clazz.getName())); //$NON-NLS-1$
            }
        }
    }

    /**
     * Called after processing.
     */
    private void cleanupPersisters()
    {
        for (IBackupPersister persister : extensionList)
        {
            try
            {
                persister.cleanup();
            }
            catch (Exception e)
            {
                // Don't let anything stop us from calling all of the persister's cleanup() method
                continue;
            }
        }
    }

    // ----------------------------------------------------------------------
    //                            Inner Classes
    // ----------------------------------------------------------------------

    /**
     * This is a private stack class that maintains a stack of "paths" that
     * represent the paths leading up to the current node in the XML document
     * we are parsing.  The "top" of the stack represents the current path
     * can be be obtained by calling the overridden toString() method.
     */
    private class Stack
    {
        private static final long serialVersionUID = -2256664251063165517L;

        private LinkedList<String> pathStack;

        Stack()
        {
            pathStack = new LinkedList<String>();
            pathStack.add(""); //$NON-NLS-1$
        }

        String pop()
        {
            return pathStack.removeLast();
        }

        void push(String s)
        {
            StringBuilder sb = new StringBuilder(pathStack.getLast());
            sb.append('/');
            sb.append(s);

            pathStack.add(sb.toString());
        }

        /** {@inheritDoc} */
        @Override
        public String toString()
        {
            try
            {
                return pathStack.getLast();
            }
            catch (NoSuchElementException nsee)
            {
                return ""; //$NON-NLS-1$
            }
        }
    }
}
