package org.ziptie.server.update.devices.internal;


import java.util.List;

import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import org.hibernate.Session;
import org.ziptie.provider.update.ISummaryBuilder;

/**
 * Provides a summary of the inventory for the ZipForge.
 */
public class InventorySummaryBuilder implements ISummaryBuilder
{
    /** {@inheritDoc} */
    @SuppressWarnings("nls")
    public void buildSummary(XMLStreamWriter writer) throws XMLStreamException
    {
        Session session = UpdateDevicesActivator.getSessionFactory().getCurrentSession();

        // Device Count...
        writer.writeStartElement("deviceCount");
        writer.writeCharacters(session.createQuery("SELECT count(d.deviceId) FROM ZDeviceLite d").uniqueResult().toString());
        writer.writeEndElement();

        // Hardware Vendor Counts...
        writer.writeStartElement("vendors");
        List<?> list = session.createQuery("SELECT d.hardwareVendor, count(d.hardwareVendor) FROM ZDeviceLite d GROUP BY d.hardwareVendor").list();
        for (Object object : list)
        {
            Object[] result = (Object[]) object;
            if (result[1].equals(0L))
            {
                continue;
            }

            writer.writeStartElement("vendor");
            writer.writeAttribute("name", result[0] == null ? "" : result[0].toString());
            writer.writeAttribute("count", result[1].toString());
            writer.writeEndElement();
        }
        writer.writeEndElement();

        // Adapter Counts...
        writer.writeStartElement("adapters");
        list = session.createQuery("SELECT d.adapterId, count(d.adapterId) FROM ZDeviceLite d GROUP BY d.adapterId").list();
        for (Object object : list)
        {
            Object[] result = (Object[]) object;

            writer.writeStartElement("adapter");
            writer.writeAttribute("id", result[0].toString());
            writer.writeAttribute("count", result[1].toString());
            writer.writeEndElement();
        }
        writer.writeEndElement();
    }
}
