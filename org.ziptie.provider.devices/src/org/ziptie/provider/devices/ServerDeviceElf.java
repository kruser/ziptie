package org.ziptie.provider.devices;

import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * This is a temporary class used until devices are truly remotely
 * managed.  It accesses device information from the local file
 * system.
 */
@SuppressWarnings("nls")
public final class ServerDeviceElf
{
    private static final int MAX_VERSION_GROUPS = 15;
    private static final int VERSION_GROUP_LENGTH = 16;
    private static final char VERSION_NULL_CHAR = '-';

    private ServerDeviceElf()
    {
        // private constructor
    }

    /**
     * Compute a canonical version string that can be used to both sort and search
     * by version strings.
     * <p>
     * Given an input like:
     * <pre>
     * 12.1.2c
     * </pre>
     * We produce an output like:
     * <pre>
     * --12---1--2c
     * </pre>
     * 
     * @param version the version string to canonicalize
     * @param regex the regular expression used to break the version into match groups
     * @return a canonicalized version string
     */
    public static String computeCononicalVersion(String version, String regex)
    {
        char[] canonChars = new char[MAX_VERSION_GROUPS * VERSION_GROUP_LENGTH];
        Arrays.fill(canonChars, VERSION_NULL_CHAR);

        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(version);
        if (matcher.matches())
        {
            int offset = 0;
            char[] groupVal = new char[VERSION_GROUP_LENGTH];
            final int groupCount = Math.min(matcher.groupCount(), MAX_VERSION_GROUPS);
            // skip group 0, because it is the entire match
            for (int i = 1; i <= groupCount; i++)
            {
                Arrays.fill(groupVal, VERSION_NULL_CHAR);
                String groupStr = matcher.group(i);
                if (groupStr != null && groupStr.length() > 0)
                {
                    groupStr.getChars(0, Math.min(groupStr.length(), VERSION_GROUP_LENGTH), groupVal, 0);
                    if (groupStr.length() <= VERSION_GROUP_LENGTH && Character.isDigit(groupVal[0]))
                    {
                        // right align numbers
                        int numToShift = VERSION_GROUP_LENGTH - groupStr.length();
                        System.arraycopy(groupVal, 0, groupVal, numToShift, VERSION_GROUP_LENGTH - numToShift);
                        Arrays.fill(groupVal, 0, numToShift, VERSION_NULL_CHAR);
                    }
                    System.arraycopy(groupVal, 0, canonChars, offset, VERSION_GROUP_LENGTH);
                }
                offset += VERSION_GROUP_LENGTH;
            }
        }

        return new String(canonChars);
    }

    /**
     * Convert a ZDeviceLite object into a ZDeviceCore object.
     *
     * @param device a ZDeviceLite object
     * @return a ZDeviceCore object
     */
    public static ZDeviceCore convertLiteToCore(ZDeviceLite device)
    {
        ZDeviceCore core = new ZDeviceCore();
        core.setAdapterId(device.getAdapterId());
        core.setDeviceId(device.getDeviceId());
        core.setHostname(device.getHostname());
        core.setIpAddress(device.getIpAddress());
        core.setManagedNetwork(device.getManagedNetwork());
        core.setIpLow(device.getIpLow());
        core.setIpHigh(device.getIpHigh());

        return core;
    }
}
