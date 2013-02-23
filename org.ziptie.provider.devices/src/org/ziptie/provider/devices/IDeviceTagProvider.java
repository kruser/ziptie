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
package org.ziptie.provider.devices;

import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * Interface for managing device tags.
 */
// MULTIPLESTRINGS:OFF
@WebService(name = "DeviceTags", targetNamespace = "http://www.ziptie.org/server/devicetags")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IDeviceTagProvider
{
    /**
     * Add the given tag to the system.
     *
     * @param tag The tag.
     */
    @ZInvocationSecurity(perm = "org.ziptie.tags.administer")
    void addTag(@WebParam(name = "tag") String tag);

    /**
     * Change the name of a tag.
     * @param oldTagName The old name of the tag.
     * @param newTagName The new name for the tag.
     */
    @ZInvocationSecurity(perm = "org.ziptie.tags.administer")
    void renameTag(@WebParam(name = "oldTagName") String oldTagName, @WebParam(name = "newTagName") String newTagName);

    /**
     * Remove the given tag from the system.
     * @param tag The tag to remove.
     */
    @ZInvocationSecurity(perm = "org.ziptie.tags.administer")
    void removeTag(@WebParam(name = "tag") String tag);

    /**
     * Gets all the tags in the system.
     * @return A list of tags.
     */
    List<String> getAllTags();

    /**
     * Apply the given tag to the given devices.
     * @param tag The tag to apply.
     * @param devicesCsv The IP Address/Managed Network CSV of the devices to tag.
     */
    @ZInvocationSecurity(perm = "org.ziptie.devices.tag")
    void tagDevices(@WebParam(name = "tag") String tag,
                    @WebParam(name = "devicesCsv") String devicesCsv);

    /**
     * Dissociate the given tag from the given devices.
     * @param tag The tag.
     * @param devicesCsv The IP Address/Managed Network CSV of the devices to untag.
     */
    @ZInvocationSecurity(perm = "org.ziptie.devices.tag")
    void untagDevices(@WebParam(name = "tag") String tag,
                      @WebParam(name = "deviceCsv") String devicesCsv);

    /**
     * Get the tags that are associated with the given device.
     * @param ipAddress The IP Address of the device.
     * @param managedNetwork The managed network the device belongs to.
     * @return The tags associated with the device.
     */
    List<String> getTags(@WebParam(name = "ipAddress") String ipAddress, @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * Retrieves the intersection of tags shared by the specified devices.
     * @param devicesCsv The IP Address/Managed Network CSV of the devices
     * @return The tags.
     */
    List<String> getIntersectionOfTags(@WebParam(name = "deviceCsv") String devicesCsv);

    /**
     * Retrieves the union of tags associated with the specified devices.
     * @param devicesCsv The IP Address/Managed Network CSV of the devices
     * @return The tags.
     */
    List<String> getUnionOfTags(@WebParam(name = "deviceCsv") String devicesCsv);
}
