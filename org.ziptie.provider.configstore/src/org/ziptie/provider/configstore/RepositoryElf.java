package org.ziptie.provider.configstore;

import org.ziptie.provider.devices.ZDeviceCore;

/**
 * RepositoryElf
 */
public final class RepositoryElf
{
    private static final int TWO_HUNDRED = 200;

    /**
     * Private default constructor.
     */
    private RepositoryElf()
    {
        // private default constructor
    }

    /**
     * Get a calculated directory path for where this device's configurations
     * should reside in the repository.  This is designed to scale to 10 million
     * devices.  It calculates a directory structure based on modulus calculations
     * on the device's database ID.  An inventory with ten million devices
     * numbered 0..10000000 should result in a two deep directory hierarchy with
     * the first level containing 200 directories, and each of those directories
     * containing 200 directories, and each of those directories containing 250
     * device directories (200 x 200 x 250 = 10 million).
     * 
     * The first-level directory is calculated as the Device ID mod 200 -- therefore
     * it's directory names will be 0..199.  The Device ID is then divided by 200
     * and a second Device ID mod 200 is performed to calculate the second-level
     * directory -- therefore it's directory names will also be 0..199.  For example:
     * <pre>
     *    Device ID: 312767
     *
     *    Level-one: 167 = (312767 % 200)
     *    Level-two: 163 = ((312767 / 200) % 200) = (1563 % 200)
     *    
     *    Result: 167/163/312767
     * </pre>
     * As the number of devices approaches 10 million, the number of device
     * directories will approach 250 in any given second-level directory.
     *
     * @param device a device to make into a file system structure
     * @return a relative directory
     */
    public static String getDirectory(ZDeviceCore device)
    {
        int deviceId = device.getDeviceId();
        int level1 = deviceId % TWO_HUNDRED;
        int level2 = (deviceId / TWO_HUNDRED) % TWO_HUNDRED;

        return String.format("%d/%d/%d", level1, level2, deviceId); //$NON-NLS-1$
    }
}
