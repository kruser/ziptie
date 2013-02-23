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
 * Portions created by AlterPoint are Copyright (C) 2006, 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s): Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.server.job.backup;

import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.ziptie.net.client.Properties;
import org.ziptie.net.client.Property;
import org.ziptie.net.client.Protocol;
import org.ziptie.protocols.ProtocolProperty;
import org.ziptie.protocols.ProtocolSet;

/**
 * The <code>ProtocolElf</code> class provides a number of helper functions for converting internal ZipTie <code>Protocol</code>
 * objects into SOAP-compatible <code>Protocol</code> objects.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
public final class ProtocolElf
{
    /**
     * Private default constructor for the <code>ProtocolElf</code> class in order to hide it from being used.
     */
    private ProtocolElf()
    {
        // Does nothing
    }

    /**
     * Converts an internal ZipTie <code>Protocol</code> to a SOAP-compatible <code>Protocol</code> object.
     * 
     * @param ziptieProtocol An internal ZipTie <code>Protocol</code> object to be converted.
     * @return A SOAP-compatible <code>Protocol</code> object.
     */
    public static Protocol convertProtocolToSoapProtocol(org.ziptie.protocols.Protocol ziptieProtocol)
    {
        Protocol soapProtocol = null;

        // Only convert the internal ZipTie protocol object if it is valid
        if (ziptieProtocol != null)
        {
            // Create a new SOAP-compatible protocol object
            soapProtocol = new Protocol();

            // Set the name and port value on the SOAP-compatible protocol object
            soapProtocol.setName(ziptieProtocol.getName());
            soapProtocol.setPort(ziptieProtocol.getPort());

            // Convert the ZipTie protocol properties into SOAP-compatible protocol properties
            Property[] soapProtocolProperties = convertProtocolPropertiesToSoapProtocolProperties(ziptieProtocol.getProperties());

            // Set the properties
            Properties props = new Properties();
            Collections.addAll(props.getProperty(), soapProtocolProperties);

            soapProtocol.setProperties(props);
        }

        // Return the newly created SOAP-compatible protocol
        return soapProtocol;
    }

    /**
     * Converts an array of internal ZipTie <code>Protocol</code> objects to an array of SOAP-compatible <code>Protocol</code>
     * objects.
     *
     * @param ziptieProtocolSet An array of internal ZipTie <code>Protocol</code> objects.
     * @return An array of SOAP-compatiable <code>Protocol</code> objects.
     */
    public static Protocol[] convertProtocolsToSoapProtocols(ProtocolSet ziptieProtocolSet)
    {
        Protocol[] soapProtocols = null;

        // Only convert the internal ZipTie protocol set if it is valid
        if (ziptieProtocolSet != null)
        {
            // Grab the set of ZipTie protocol objects
            Set<org.ziptie.protocols.Protocol> ziptieProtocols = ziptieProtocolSet.getProtocols();

            // Create an array of SOAP-compatible protocols equal to the number of ZipTie protocols
            soapProtocols = new Protocol[ziptieProtocols.size()];

            // Create a counter to keep track of where we are in the array of SOAP-compatible protocols
            int i = 0;

            // For each ZipTie protocol, convert it to a SOAP-compatible protocol
            for (org.ziptie.protocols.Protocol ziptieProtocol : ziptieProtocols)
            {
                soapProtocols[i++] = convertProtocolToSoapProtocol(ziptieProtocol);
            }
        }

        // Return the newly created array of SOAP-compatible protocol objects
        return soapProtocols;
    }

    /**
     * Converts an internal ZipTie protocol property to a SOAP-compatible protocol <code>Property</code> object.
     * 
     * @param ziptieProtocolProperty A <code>ProtocolProperty</code> object representing a property on an internal ZipTie
     * <code>Protocol</code> object.
     * @return A SOAP-compatible protocol <code>Property</code> object.
     */
    public static Property convertProtocolPropertyToSoapProtocolProperty(ProtocolProperty ziptieProtocolProperty)
    {
        Property soapProtocolProperty = null;

        // Only convert the internal ZipTie protocol property if it is valid
        if (ziptieProtocolProperty != null)
        {
            // Create a SOAP-compatible protocol property
            soapProtocolProperty = new Property();

            // Set the name and the value of the SOAP-compatible protocol property
            soapProtocolProperty.setName(ziptieProtocolProperty.getKey());
            soapProtocolProperty.setValue(ziptieProtocolProperty.getValue());
        }

        // Return the newly created SOAP-compatible protocol property
        return soapProtocolProperty;
    }

    /**
     * Converts an array of internal ZipTie protocol properties to an array of SOAP-compatible protocol <code>Property</code>
     * objects.
     *
     * @param propertiesList A <code>List</code> of <code>ProtocolProperty</code> object representing all of the properties for a
     * certain protocol.
     * @return An array of SOAP-compatiable protocol <code>Property</code> objects.
     */
    public static Property[] convertProtocolPropertiesToSoapProtocolProperties(List<ProtocolProperty> propertiesList)
    {
        Property[] soapProtocolProperties = null;

        // Only convert the array of internal ZipTie protocol properties if the map representing it is valid
        if (propertiesList != null)
        {
            // Create an array of SOAP-compatible protocol property objects equal to the number of protocol properties that
            // were specified on the ZipTie protocol object
            soapProtocolProperties = new Property[propertiesList.size()];

            // Create a counter to keep track of where we are in the array of SOAP-compatible protocol properties
            int i = 0;

            // For each ZipTie protocol property, convert it to a SOAP-compatible protocol property object
            for (ProtocolProperty protocolProperty : propertiesList)
            {
                soapProtocolProperties[i++] = convertProtocolPropertyToSoapProtocolProperty(protocolProperty);
            }
        }

        // Return the newly created array of SOAP-compatible protocol property objects
        return soapProtocolProperties;
    }
}
