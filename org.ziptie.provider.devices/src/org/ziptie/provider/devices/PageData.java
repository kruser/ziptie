package org.ziptie.provider.devices;

/**
 * PageData
 */
public class PageData
{
    private int offset;
    private int pageSize;
    private int total;
    private ZDeviceLite[] devices;

    /**
     * 
     */
    public PageData()
    {
        // default constructor
    }

    /**
     * @return the devices
     */
    public ZDeviceLite[] getDevices()
    {
        return devices;
    }

    /**
     * @param devices the devices to set
     */
    public void setDevices(ZDeviceLite[] devices)
    {
        this.devices = devices;
    }

    /**
     * @return the offset
     */
    public int getOffset()
    {
        return offset;
    }

    /**
     * @param offset the offset to set
     */
    public void setOffset(int offset)
    {
        this.offset = offset;
    }

    /**
     * @return the pageSize
     */
    public int getPageSize()
    {
        return pageSize;
    }

    /**
     * @param pageSize the pageSize to set
     */
    public void setPageSize(int pageSize)
    {
        this.pageSize = pageSize;
    }

    /**
     * @return the total
     */
    public int getTotal()
    {
        return total;
    }

    /**
     * @param total the total to set
     */
    public void setTotal(int total)
    {
        this.total = total;
    }
}
