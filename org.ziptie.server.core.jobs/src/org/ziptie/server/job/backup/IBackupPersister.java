package org.ziptie.server.job.backup;

import java.util.List;

import javax.xml.stream.events.XMLEvent;

import org.ziptie.provider.devices.ZDeviceCore;


/**
 * IBackupPersister
 */
public interface IBackupPersister
{
    /**
     * @param device the device.
     */
    void setDevice(ZDeviceCore device);

    /**
     * @return The paths of the nodes that this persister wants to be called for.
     */
    List<String> getPathsOfInterest();

    /**
     * @param xmlEvent The StAX event.
     */
    void startDocument(XMLEvent xmlEvent);

    /**
     * @param xmlEvent The StAX event.
     */
    void endDocument(XMLEvent xmlEvent);

    /**
     * @param xmlEvent The StAX event.
     */
    void startElement(XMLEvent xmlEvent);

    /**
     * @param xmlEvent The StAX event.
     */
    void endElement(XMLEvent xmlEvent);

    /**
     * @param xmlEvent The StAX event.
     */
    void characterData(XMLEvent xmlEvent);

    /**
     * We guarantee that cleanup will always be called after endDocument() or
     * in the event of an exception in processing.
     */
    void cleanup();
}
