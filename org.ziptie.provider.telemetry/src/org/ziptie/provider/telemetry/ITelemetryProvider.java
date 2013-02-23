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
package org.ziptie.provider.telemetry;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

/**
 * ITelemetryProvider
 */
@WebService(name = "Telemetry", targetNamespace = "http://www.ziptie.org/server/telemetry")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface ITelemetryProvider
{
    /**
     * Retrieves an entire ARP table for the given device.
     * @param ipAddress the administrative IP address of the device
     * @param managedNetwork the managed network that the device lives in
     * @return the latest ARP table
     */
    ArpPageData getArpTable(@WebParam(name = "pageData") ArpPageData pageData, 
                            @WebParam(name = "ipAddress") String ipAddress, 
                            @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * Retrieves all ARP entries from all devices where the IP Address of the ARP entry is contained in the provided networkAddress.
     * @param networkAddress the address to get entries on, e.g. '10.100.0.0/16'
     * @return a list of the entries
     */
    DeviceArpPageData getArpEntries(@WebParam(name = "pageData") DeviceArpPageData pageData, 
                                    @WebParam(name = "networkAddress") String networkAddress,
                                    @WebParam(name = "sort") String sort,
                                    @WebParam(name = "descending") boolean descending);

    /**
     * Retrieves an entire MAC forwarding table for the given device.
     * @param ipAddress the administrative IP address of the device
     * @param managedNetwork the managed network that the device lives in
     * @return the latest MAC forwarding table
     */
    MacPageData getMacTable(@WebParam(name = "pageData") MacPageData pageData, 
                            @WebParam(name = "ipAddress") String ipAddress, 
                            @WebParam(name = "managedNetwork") String managedNetwork);
    
    /**
     * Retrieves routing (OSPF, EIGRP, BGP) and discovery protocol neighbors (CDP, NDP) for the given device.
     * @param ipAddress the administrative IP address of the device
     * @param managedNetwork the managed network that the device lives in
     * @return the list of neighbors
     */
    List<Neighbor> getNeighbors(@WebParam(name = "ipAddress") String ipAddress, 
                                @WebParam(name = "managedNetwork") String managedNetwork);
    
    /**
     * Given a host IP, MAC address or hostname, find the switch port that the device is physically plugged into. 
     * @param host the host as a MAC address, and IP address or a hostname
     * @return the best match
     */
    SwitchPortResult findSwitchPort(@WebParam(name = "host") String host);
}
