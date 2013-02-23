package org.ziptie.provider.telemetry;

/**
 * DeviceArpPageData
 */
public class DeviceArpPageData extends PageData
{
    private DeviceArpTableEntry[] arpEntries;

    /**
     * @return the arpEntries
     */
    public DeviceArpTableEntry[] getArpEntries()
    {
        return arpEntries;
    }

    /**
     * @param arpEntries the arpEntries to set
     */
    public void setArpEntries(DeviceArpTableEntry[] arpEntries)
    {
        this.arpEntries = arpEntries;
    }
}
