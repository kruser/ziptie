package org.ziptie.provider.devices;

import javax.xml.bind.annotation.XmlType;

/**
 * DeviceProviderFault
 */
@XmlType(name = "DeviceProviderFault")
public class DeviceProviderFault extends RuntimeException
{
    private static final long serialVersionUID = -3487073746568837520L;

    /**
     * Default constructor.
     */
    public DeviceProviderFault()
    {
        super();
    }

    /**
     * Constructor with a throwable.
     *
     * @param t a throwable
     */
    public DeviceProviderFault(Throwable t)
    {
        super(t);
    }

    /**
     * Constructor with a message.
     *
     * @param msg a message
     */
    public DeviceProviderFault(String msg)
    {
        super(msg);
    }

    /**
     * Constructor with a message and a throwable.
     *
     * @param msg a message
     * @param t a throwable
     */
    public DeviceProviderFault(String msg, Throwable t)
    {
        super(msg, t);
    }
}
