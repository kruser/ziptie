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
package org.ziptie.provider.tools;

import java.util.Date;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.Lob;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.TableGenerator;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import org.ziptie.provider.devices.ZDeviceCore;

/**
 * Describes an execution of a command list.
 */
@XmlRootElement
@Entity(name = "ToolRunDetails")
@Table(name = "tool_details")
public class ToolRunDetails
{
    @Id
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "persistent_gen")
    @TableGenerator(name = "persistent_gen",
                    table = "persistent_key_gen",
                    pkColumnName = "seq_name",
                    valueColumnName = "seq_value",
                    pkColumnValue = "Tool_Run_Details_seq",
                    initialValue = 1,
                    allocationSize = 5)
    @Column(name = "id")
    private int id;

    @Column(name = "execution_id")
    private int executionId;

    @ManyToOne
    @JoinColumn(name = "device_id", nullable = true)
    private ZDeviceCore device;

    @Column(name = "error")
    private String error;

    @Lob
    @Column(name = "grid_data", length = Integer.MAX_VALUE)
    private String gridData;

    @Lob
    @Column(name = "details", length = Integer.MAX_VALUE)
    @Basic(fetch = FetchType.LAZY)
    private String details;

    @Column(name = "start_time")
    private Date startTime;

    @Column(name = "end_time")
    private Date endTime;

    /**
     * Default constructor. 
     */
    public ToolRunDetails()
    {
        id = -1;
    }

    /**
     * Set the hibernate ID.
     * @param id The ID
     */
    public void setId(int id)
    {
        this.id = id;
    }

    /**
     * Get the hibernate ID.
     * @return The ID
     */
    public int getId()
    {
        return id;
    }

    /**
     * Get the IP Address for the device.
     * @return The device's IP address.
     */
    public String getIpAddress()
    {
        return getDevice() == null ? "" : getDevice().getIpAddress(); //$NON-NLS-1$
    }

    /**
     * Not supported.  This method is here to facilitate WSDL generation.
     * @param ipAddress IP
     * @see #setDevice(ZDeviceCore)
     */
    public void setIpAddress(String ipAddress)
    {
        throw new UnsupportedOperationException();
    }

    /**
     * Get the managed network.
     * @return The managed network.
     */
    public String getManagedNetwork()
    {
        return getDevice() == null ? "" : getDevice().getManagedNetwork(); //$NON-NLS-1$
    }

    /**
     * Not supported.  This method is here to facilitate WSDL generation.
     * @param managedNetwork Managed Network
     * @see #setDevice(ZDeviceCore)
     */
    public void setManagedNetwork(String managedNetwork)
    {
        throw new UnsupportedOperationException();
    }

    /**
     * Get the ID for the exectution this output is for.
     *
     * @return the execution's ID
     */
    public int getExecutionId()
    {
        return executionId;
    }

    /**
     * Set the ID for the execution.
     * @param executionId The execution's ID
     */
    public void setExecutionId(int executionId)
    {
        this.executionId = executionId;
    }

    /**
     * Get the error message for this run if applicable.
     * @return The error or <code>null</code>.
     */
    public String getError()
    {
        return error;
    }

    /**
     * Set the error message for the run if applicable.
     * @param error The error or <code>null</code>
     */
    public void setError(String error)
    {
        this.error = error;
    }

    /**
     * Set the device.
     * @param device The device
     */
    public void setDevice(ZDeviceCore device)
    {
        this.device = device;
    }

    /**
     * Get the device.
     *
     * @return The device, or null
     */
    @XmlTransient
    public ZDeviceCore getDevice()
    {
        return device;
    }

    /**
     * @return the gridData
     */
    public String getGridData()
    {
        return gridData;
    }

    /**
     * @param gridData the gridData to set
     */
    public void setGridData(String gridData)
    {
        this.gridData = gridData;
    }

    /**
     * Get the list of command/responses
     *
     * @return a list of interactions.
     */
    @XmlTransient
    public String getDetails()
    {
        return details == null ? "" : details; //$NON-NLS-1$
    }

    /**
     * Set the command/response details.
     *
     * @param details The command/response pairs.
     */
    public void setDetails(String details)
    {
        this.details = details;
    }

    /**
     * Sets the start time.
     * @param startTime The start time
     */
    public void setStartTime(Date startTime)
    {
        this.startTime = startTime;
    }

    /**
     * Gets the time that the command run was started.
     * @return The start time.
     */
    public Date getStartTime()
    {
        return startTime;
    }

    /**
     * Sets the time that the command run finished.
     * @param endTime The end time.
     */
    public void setEndTime(Date endTime)
    {
        this.endTime = endTime;
    }

    /**
     * Gets the time that the command run finished.
     * @return The end time.
     */
    public Date getEndTime()
    {
        return endTime;
    }
}
