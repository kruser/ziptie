/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2008
 */

package org.ziptie.zap.util;

import java.util.List;

public class PageData<T>
{
    private int offset;
    private int pageSize;
    private int total;
    private List<T> data;

    public PageData()
    {
    }

    public PageData(int offset, int pageSize, int total, List<T> data)
    {
        this.offset = offset;
        this.pageSize = pageSize;
        this.total = total;
        this.data = data;
    }

    public List<T> getData()
    {
        return data;
    }

    public void setData(List<T> data)
    {
        this.data = data;
    }

    public int getOffset()
    {
        return offset;
    }

    public void setOffset(int offset)
    {
        this.offset = offset;
    }

    public int getPageSize()
    {
        return pageSize;
    }

    public void setPageSize(int pageSize)
    {
        this.pageSize = pageSize;
    }

    public int getTotal()
    {
        return total;
    }

    public void setTotal(int total)
    {
        this.total = total;
    }
}
