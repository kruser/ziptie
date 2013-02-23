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
 * Copyright the ZipTie Project (www.ziptie.org)
 */

package org.ziptie.provider.devices;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;


/**
 * IDeviceProvider
 */
// MULTIPLESTRINGS:OFF
@WebService(name = "Devices", targetNamespace = "http://www.ziptie.org/server/devices")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IDeviceProvider
{
    /**
     * Create a device with the specified IPv4 or IPv6 address, in the specified Managed Network,
     * having the specified Adapter ID.  If the Managed Network name is <code>null</code>
     * the the default Managed Network is used.
     *
     * @param ipAddress the device IPv4 or IPv6 address
     * @param managedNetwork the name of the Managed Network or <code>null</code>
     * @param adapterId the ID of the adapter
     */
    @ZInvocationSecurity(perm = "org.ziptie.devices.administer")
    void createDevice(@WebParam(name = "ipAddress") String ipAddress,
                      @WebParam(name = "managedNetwork") String managedNetwork,
                      @WebParam(name = "adapterId") String adapterId);

    /**
     * Create the specified devices.  This method returns a list of devices that
     * failed to be added.  The devices will not undergo any validation as to
     * whether they exist on the network or whether their specified Adapter IDs
     * are correct.  If that kind of validation is required use the Discovery
     * provider.
     *
     * If there are many devices to be added, it is <em>strongly</em> recommended
     * that the set of devices be divided into groups of 10,000 or less and this
     * method called repeatedly.  The invocation overhead is very low compared to
     * the memory footprint for a large set of devices.
     *
     * The devices which cannot be added are returned in the collection from this
     * method, but there is no way to determine why they were not added, just that
     * they were not.
     *
     * @param devices a collection of ZDeviceCore objects to add to the inventory
     * @return returns a <code>List</code> of failed devices
     */
    @ZInvocationSecurity(perm = "org.ziptie.devices.administer")
    List<ZDeviceCore> createDeviceBatched(@WebParam(name = "devices") List<ZDeviceCore> devices);

    /**
     * Delete the device with the specified IPv4 or IPv6 address and residing in
     * the specified Managed Network from the system.  If the <code>managedNetwork</code>
     * parameter is <code>null</code> then the default Managed Network is used.
     *
     * @param ipAddress the IPv4 or IPv6 address of the device to delete
     * @param managedNetwork the Managed Network name of the device to delete, or
     *    <code>null</code>
     */
    @ZInvocationSecurity(perm = "org.ziptie.devices.administer")
    void deleteDevice(@WebParam(name = "ipAddress") String ipAddress, @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * Get a device from ZipTie.
     *
     * @param ipAddress the IPv4 or IPv6 address of the device to retrieve
     * @param managedNetwork the Managed Network name of the device to retrieve, or
     *    <code>null</code>
     * @return a ZDeviceCore object or <code>null</code> if the device was not
     *    found
     */
    ZDeviceCore getDevice(@WebParam(name = "ipAddress") String ipAddress, @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * Get a device from ZipTie.  Similar to {@link #getDevice(String, String)} except that the
     * IP address that you ask for doesn't have to be the same administrative IP address known to ziptie.
     * The IP only needs to live on an interface.  Where there is more than one match, the first is returned.
     * 
     * @param ipAddress the IPv4 or IPv6 address of the device to retrieve
     * @param managedNetwork the Managed Network name of the device to retrieve, or
     *    <code>null</code>
     * @return a ZDeviceCore object or <code>null</code> if the device was not
     *    found
     */
    ZDeviceCore getDeviceByInterfaceIp(@WebParam(name = "ipAddress") String ipAddress, @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * Get the device status.
     * @param ipAddress The IPv4 or IPv6 address of the device to retreive
     * @param managedNetwork the Managed Network name of the device to retreive, or
     *    <code>null</code>
     * @return the device status for the device or <code>null</code> if the device was not found.
     */
    ZDeviceStatus getDeviceStatus(@WebParam(name = "ipAddress") String ipAddress, @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * Retrieves a list of device lites for the given devices.
     *
     * @param devices an array of IP ManageNetwork combos (ie: 10.10.1.1@Default)
     * @return The devices
     */
    List<ZDeviceLite> getDeviceLites(@WebParam(name = "devices") String[] devices);

    /**
     * Update the device information for device with the specified IPv4 or IPv6 address on the
     * given Managed Network.  The IP address and Managed Network within the provided ZDeviceCore
     * object need not match the device being changed.  If it is the case that they do not
     * match, those fields will also be updated, and therefore the device will no longer be
     * identified by the original IP address/Managed Network pair, but by the new one.
     * 
     * @param ipAddress the IPv4 or IPv6 address of the device to update, as it currently
     *    exists in the system
     * @param managedNetwork a Managed Network name of the device to update, as it currently
     *    exists in the system
     * @param device a ZDeviceCore object containing the values to update
     */
    @ZInvocationSecurity(perm = "org.ziptie.devices.administer")
    void updateDevice(@WebParam(name = "ipAddress") String ipAddress,
                      @WebParam(name = "managedNetwork") String managedNetwork,
                      @WebParam(name = "device") ZDeviceCore device);

    /**
     * Gets the hardware vendors that are represented in the device inventory.
     *
     * @return The set of vendors.
     */
    List<String> getAllHardwareVendors();
}
