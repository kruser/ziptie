package org.ziptie.provider.telemetry;

/**
 * ArpPageData
 */
public class ArpPageData extends PageData
{
    private ArpTableEntry[] arpEntries;

    /**
     * @return the arpEntries
     */
    public ArpTableEntry[] getArpEntries()
    {
        return arpEntries;
    }

    /**
     * @param arpEntries the arpEntries to set
     */
    public void setArpEntries(ArpTableEntry[] arpEntries)
    {
        this.arpEntries = arpEntries;
    }

}
