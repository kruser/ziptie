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
 */
package org.ziptie.discovery;

import javax.persistence.Column;
import javax.persistence.MappedSuperclass;

import org.hibernate.annotations.AccessType;

/**
 * TelemetryObject
 */
@MappedSuperclass
@AccessType(value = "field")
public abstract class TelemetryObject
{
    @Column(name = "device_id")
    private int deviceId = -1;

    /**
     * @return the deviceId
     */
    public int getDeviceId()
    {
        return deviceId;
    }

    /**
     * @param deviceId the deviceId to set
     */
    public void setDeviceId(int deviceId)
    {
        this.deviceId = deviceId;
    }
}
