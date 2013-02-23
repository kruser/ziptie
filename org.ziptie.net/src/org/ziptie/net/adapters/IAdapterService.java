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
package org.ziptie.net.adapters;

import java.io.File;
import java.net.URL;
import java.util.Collection;
import java.util.Set;

import org.ziptie.discovery.DiscoveryEvent;
import org.ziptie.discovery.XdpEntry;

/**
 * Provides access to a set of adapters.
 */
public interface IAdapterService
{
    /**
     * Retrieves the unique adapter ID for every {@link AdapterMetadata} object that is currently stored in
     * this {@link AdapterService} instance.
     * 
     * @return A set containing the unique adapter IDs for every {@link AdapterMetadata} object that is 
     * currently stored in this {@link AdapterService} instance.
     */
    Set<String> getAllAdapterIDs();

    /**
     * Load all the adapters that can be found under the given directory.
     * @param directory The directory.
     * @return The set of adapter IDs that were registered.
     */
    Set<String> registerAdapters(File directory);

    /**
     * Unloads all the adapters that were previously loaded from the given directory.
     * @param directory The directory.
     * @return The set of adapter IDs that were unregistered.
     */
    Set<String> unregisterAdapters(File directory);

    /**
     * Remove the given URL from the schema location prefix set.
     * @param url The schema URL location
     */
    void removeSchemaLocation(URL url);

    /**
     * Add a URL as a location to find XML schema in.  If there are schemas in the adapter service, validation of adapters will be attempted.
     * @param url The XML schema location prefix
     */
    void addSchemaLocation(URL url);

    /**
     * Given a {@link DiscoveryEvent}, runs through the adapter metadata to pick the correct adapter
     * 
     * @param discoveryEvent the discovery details
     * @return the String id of the adapter, or null if there isn't a matching adapter
     */
    String getAdapterId(DiscoveryEvent discoveryEvent);

    /**
     * Given a {@link XdpEntry} object, try to find a matching adapter
     * 
     * @param xdpEntry the entry
     * @return the string version of the adapter ID, or null if there isn't a match
     */
    String getAdapterId(XdpEntry xdpEntry);

    /**
     * Retrieves all of the {@link AdapterMetadata} objects that have been loaded by this {@link AdapterService}.
     * 
     * @return A list of all the {@link AdapterMetadata} objects that have been loaded.
     */
    Collection<AdapterMetadata> getAllAdapterMetadata();

    /**
     * Retrieves the {@link AdapterMetadata} object for a given adapter ID.
     * 
     * @param adapterID The ID of the adapter that needs its meta-data retrieved.
     * 
     * @return A {@link AdapterMetadata} object representing all of the meta-data for the specified adapter;
     * {@link null} if no meta-data for the specified adapter exists.
     */
    AdapterMetadata getAdapterMetadata(String adapterID);

}
