/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.provider.scheduler;

import java.util.List;


/**
 * Page object for execution data.
 */
public class PageData
{
    private int offset;
    private int pageSize;
    private int total;
    private List<ExecutionData> executionData;

    /**
     * 
     */
    public PageData()
    {
        // default constructor
    }

    /**
     * @return the executions
     */
    public List<ExecutionData> getExecutionData()
    {
        return executionData;
    }

    /**
     * @param executionData the executions to set
     */
    public void setExecutionData(List<ExecutionData> executionData)
    {
        this.executionData = executionData;
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
