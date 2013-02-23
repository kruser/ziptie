package org.ziptie.provider.devices;

import org.eclipse.osgi.util.NLS;

/**
 * Messages
 */
public final class Messages extends NLS
{
    public static String createdDevice;
    public static String DeviceProvider_addedBatchDevices;
    public static String DeviceProvider_invalidAdapterId;
    public static String DeviceProviderDelegate_deviceProviderUnavailable;
    public static String DeviceTagProviderDelegate_tagProviderUnavailable;
    public static String exceptionDuringRollback;
    public static String exceptionDuringTransaction;
    public static String SimpleDeviceSearch_adapterServiceUnavailable;
    public static String SimpleDeviceSearchDelegate_searchProviderUnavailable;
    public static String IpResolutionScheme_invalidAddress;
    private static final String BUNDLE_NAME = "org.ziptie.provider.devices.messages"; //$NON-NLS-1$

    static
    {
        // initialize resource bundle
        NLS.initializeMessages(BUNDLE_NAME, Messages.class);
    }

    private Messages()
    {
    }
}
