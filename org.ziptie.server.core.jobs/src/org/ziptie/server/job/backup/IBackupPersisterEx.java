package org.ziptie.server.job.backup;

import javax.xml.stream.XMLStreamException;
import javax.xml.stream.events.XMLEvent;

/**
 * IBackupPersisterEx
 */
public interface IBackupPersisterEx extends IBackupPersister
{
    /**
     * If a class implementing IBackupPersister also implements this interface,
     * then this method will be invoked for every event encountered by the STaX
     * processor.
     *
     * @param xmlEvent a STaX XMLEvent
     * @throws XMLStreamException thrown if there is a processing error
     */
    void handleEvent(XMLEvent xmlEvent)  throws XMLStreamException;
}
