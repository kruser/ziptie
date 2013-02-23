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
package org.ziptie.provider.configstore;

import java.util.Date;
import java.util.List;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;

import org.ziptie.zap.security.ZInvocationSecurity;

/**
 * IConfigStore
 */
// MULTIPLESTRINGS:OFF
@WebService(name = "ConfigStore", targetNamespace = "http://www.ziptie.org/server/configstore")
@SOAPBinding(style = SOAPBinding.Style.DOCUMENT, parameterStyle = SOAPBinding.ParameterStyle.WRAPPED)
public interface IConfigStore
{
    /**
     * This method returns the change history for the specified device.  The result is
     * a List of ChangeLog objects, each of which represents one 'snapshot' or back-up
     * of the device.  As a result of a single back-up of a device it is possible for
     * configurations to be added, updated, or deleted from the revision control system.
     *
     * See the documentation on the ChangeLog class for how these changes are encoded
     * in the path information.
     *
     * @param ipAddress the IP address of a device
     * @param managedNetwork the name of the managed network in which the device resides,
     *    if <code>null</code> then the Default Managed Network is used
     * @return an List of ChangeLog objects
     */
    @ZInvocationSecurity(perm = "org.ziptie.configs.view")
    List<ChangeLog> retrieveChangeLog(@WebParam(name = "ipAddress") String ipAddress,
                                      @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * This method returns information about the current configuration revisions for the
     * specified device.  The result is a List of RevisionInfo objects, each of which
     * represents one configuration item in the current set of revisions for the device.
     * Some of the RevisionInfo objects represent directories rather than files.
     * 
     * See the documentation on the RevisionInfo class for details of the revision inforamtion.
     *
     * @param ipAddress the IP address of a device
     * @param managedNetwork the name of the managed network in which the device resides,
     *    if <code>null</code> then the Default Managed Network is used
     * @return a List of RevisionInfo objects
     */
    @ZInvocationSecurity(perm = "org.ziptie.configs.view")
    List<RevisionInfo> retrieveCurrentRevisionInfo(@WebParam(name = "ipAddress") String ipAddress,
                                                   @WebParam(name = "managedNetwork") String managedNetwork);

    /**
     * Retrieve a revision of a configuration for the specified device.
     *
     * @param ipAddress the IP address of a device
     * @param managedNetwork the name of the managed network in which the device resides,
     *    if <code>null</code> then the Default Managed Network is used
     * @param configPath the name of the configuration to retrieve.  This value is most
     *    easily obtained from the <code>ChangeLog</code> objects.
     * @param timestamp the time-stamp of the revision of the configuration to retrieve.  This
     *    time-stamp is most easily obtained by consulting the ChangeLog objects for the
     *    specified device obtained from the <code>retreiveRevisionInfo()</code> method
     * @return a Revision object containing the configuration (either raw text or BASE64 encoded binary),
     *    or null if the there is no such configuration revision for the device
     */
    @ZInvocationSecurity(perm = "org.ziptie.configs.view")
    Revision retrieveRevision(@WebParam(name = "ipAddress") String ipAddress,
                              @WebParam(name = "managedNetwork") String managedNetwork,
                              @WebParam(name = "configPath") String configPath,
                              @WebParam(name = "timestamp") Date timestamp);

    /**
     * Retrieve a Unified Diff of the specified revision and the previous revision of a
     * configuration for the specified device.
     *
     * @param ipAddress the IP address of a device
     * @param managedNetwork the name of the managed network in which the device resides,
     *    if <code>null</code> then the Default Managed Network is used
     * @param configPath the name of the configuration to retrieve.  This value is most
     *    easily obtained from the <code>ChangeLog</code> objects.
     * @param timestamp1 the time-stamp of the revision of the configuration to retrieve.  This
     *    time-stamp is most easily obtained by consulting the ChangeLog objects for the
     *    specified device obtained from the <code>retreiveRevisionInfo()</code> method
     * @param timestamp2 the time-stamp of the revision of the configuration to retrieve.  This
     *    time-stamp is most easily obtained by consulting the ChangeLog objects for the
     *    specified device obtained from the <code>retreiveRevisionInfo()</code> method
     * @return a String that contains the specified XML model revision for the device, or null
     *    if the there is no such configuration revision for the device
     */
    @ZInvocationSecurity(perm = "org.ziptie.configs.view")
    String retrieveRevisionUnifiedDiff(@WebParam(name = "ipAddress") String ipAddress,
                                         @WebParam(name = "managedNetwork") String managedNetwork,
                                         @WebParam(name = "configPath") String configPath,
                                         @WebParam(name = "timestamp1") Date timestamp1,
                                         @WebParam(name = "timestamp2") Date timestamp2);
}
