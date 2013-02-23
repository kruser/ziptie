package org.ziptie.provider.devices;

import java.io.ByteArrayOutputStream;
import java.util.Properties;

import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.ziptie.zap.jms.EventElf;

/**
 * Produces events for device changes.
 */
@SuppressWarnings("nls")
public class InventoryEventProducer implements IDeviceStoreObserver
{
    private static final String UTF_8_ENCODING = "UTF-8";
    private static final String QUEUE = "devices";

    /** {@inheritDoc} */
    public void deviceCreated(ZDeviceCore device)
    {
        Properties props = new Properties();
        props.setProperty("IpAddress", device.getIpAddress());
        props.setProperty("ManagedNetwork", device.getManagedNetwork());

        sendEvent("created", props);
    }

    /** {@inheritDoc} */
    public void deviceDeleted(ZDeviceCore device)
    {
        Properties props = new Properties();
        props.setProperty("IpAddress", device.getIpAddress());
        props.setProperty("ManagedNetwork", device.getManagedNetwork());

        sendEvent("deleted", props);
    }


    /** {@inheritDoc} */
    public void deviceTypeChanged(ZDeviceCore device)
    {
    }

    private void sendEvent(String type, Properties properties)
    {
        try
        {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            properties.storeToXML(baos, "", UTF_8_ENCODING); //$NON-NLS-1$

            // Tell the producer to send the message
            TextMessage message = EventElf.createTextMessage(QUEUE, baos.toString(UTF_8_ENCODING));
            message.setJMSType(type);
            EventElf.sendMessage(QUEUE, message);
        }
        catch (Exception e)
        {
            Logger.getLogger(getClass()).error("Unable to send JMS event", e);
        }
    }
}
