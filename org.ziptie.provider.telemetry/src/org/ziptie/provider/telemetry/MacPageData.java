package org.ziptie.provider.telemetry;

/**
 * ArpPageData
 */
public class MacPageData extends PageData
{

    private MacTableEntry[] macEntries;

    /**
     * @return the macEntries
     */
    public MacTableEntry[] getMacEntries()
    {
        return macEntries;
    }

    /**
     * @param macEntries the macEntries to set
     */
    public void setMacEntries(MacTableEntry[] macEntries)
    {
        this.macEntries = macEntries;
    }


}
