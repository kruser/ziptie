package org.ziptie.provider.devices;

import java.util.List;

import org.ziptie.server.core.AbstractExtensionNotifier;

/**
 * DeviceNotifier
 */
public class DeviceNotifier extends AbstractExtensionNotifier
{
    private static final String EXTENSION_NAMESPACE = "org.ziptie.provider.devices"; //$NON-NLS-1$
    private static final String EXTENSION_POINT_ID = EXTENSION_NAMESPACE + ".inventoryChange"; //$NON-NLS-1$

    /**
     * Default constructor.
     */
    public DeviceNotifier()
    {
        super(EXTENSION_POINT_ID, "Device Provider Notifier"); //$NON-NLS-1$
    }

    /**
     * @param device the device to notify observers about.
     *
     * @param notification a DeviceNotification enum
     */
    public void notifyDeviceObservers(ZDeviceCore device, DeviceNotification notification)
    {
        getExecutor().execute(new NotifierRunnable(device, notification));
    }

    /**
     * NotifierRunnable
     */
    private class NotifierRunnable implements Runnable
    {
        private ZDeviceCore device;
        private DeviceNotification notificationType;

        public NotifierRunnable(ZDeviceCore device, DeviceNotification notification)
        {
            this.device = device;
            this.notificationType = notification;
        }

        @SuppressWarnings("unchecked")
        public void run()
        {
            List<IDeviceStoreObserver> observers = (List<IDeviceStoreObserver>) createObserverExtensions();
            for (IDeviceStoreObserver observer : observers)
            {
                try
                {
                    switch (notificationType)
                    {
                    case CREATE:
                        observer.deviceCreated(device);
                        break;
                    case DELETE:
                        observer.deviceDeleted(device);
                        break;
                    case CHANGE_DEVICE_TYPE:
                        observer.deviceTypeChanged(device);
                        break;
                    default:
                        break;
                    }
                }
                catch (Exception e)
                {
                    // Don't let anyone interrupt us from calling all observers.
                    // They better log their own errors, etc. because we're going
                    // to keep going.
                    continue;
                }
            }
        }
    }

    /**
     * DeviceNotification
     */
    public static enum DeviceNotification
    {
        CREATE,
        DELETE,
        CHANGE_DEVICE_TYPE,
    }
}
