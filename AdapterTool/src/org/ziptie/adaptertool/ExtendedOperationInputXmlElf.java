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
package org.ziptie.adaptertool;

import java.io.File;
import java.io.StringWriter;
import java.util.List;
import java.util.Properties;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.net.utils.FileServerInfo;
import org.ziptie.net.utils.OperationInputXMLElf;
import org.ziptie.protocols.ProtocolSet;

/**
 * Offers a few methods similar to the {@link OperationInputXMLElf}.  
 * This class has been placed in the AdpaterTool project in order not to compromise classpaths of other projects.
 */
public final class ExtendedOperationInputXmlElf
{

    private static final String BASE64ENCODED_FILE_BLOB = "base64EncodedFileBlob"; //$NON-NLS-1$
    private static final String FULL_PATH_ON_DEVICE = "fullPathOnDevice"; //$NON-NLS-1$
    private static final String RESTORE_FILE_INFO = "restoreFileInfo"; //$NON-NLS-1$
    private static final String FILESTORE_ROOT = "filestoreRoot"; //$NON-NLS-1$
    private static final String FILESTORE_PATH = "path"; //$NON-NLS-1$
    private static final String DISCOVERY_PARAMS = "discoveryParams"; //$NON-NLS-1$

    /**
     * Hidden
     */
    private ExtendedOperationInputXmlElf()
    {
    }

    /**
     * Generates XML for the 'restore' operation.
     * 
     * @param host the target
     * @param protocols the protocols involved
     * @param credentials the credentials involved
     * @param fileServers the file servers invovled
     * @param restoreFile the file to restore
     * @return the XML version of everything
     */
    public static String generateRestoreInputXml(String host, ProtocolSet protocols, CredentialSet credentials, List<FileServerInfo> fileServers,
                                                 RestoreFile restoreFile)
    {
        Document document = OperationInputXMLElf.generateXMLDoc(host, protocols, credentials, fileServers);

        Element restoreFileElement = document.createElement(RESTORE_FILE_INFO);
        restoreFileElement.setAttribute(FULL_PATH_ON_DEVICE, restoreFile.getFullPathOnDevice());

        Element fileContents = document.createElement(BASE64ENCODED_FILE_BLOB);
        fileContents.setTextContent(restoreFile.getBase64EncodedFileBlob());
        restoreFileElement.appendChild(fileContents);

        document.getFirstChild().appendChild(restoreFileElement);

        Source source = new DOMSource(document);
        StringWriter stringOutput = new StringWriter();
        Result result = new StreamResult(stringOutput);
        try
        {
            TransformerFactory.newInstance().newTransformer().transform(source, result);
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
        return stringOutput.toString();
    }

    /**
     * Generates XML for the 'ospull' operation.
     * 
     * @param host the target
     * @param protocols the protocols involved
     * @param credentials the credentials involved
     * @param fileServers the file servers invovled
     * @param filestoreRoot where the OS images should go
     * @return the XML version of everything
     */
    public static String generateOspullInputXml(String host, ProtocolSet protocols, CredentialSet credentials, List<FileServerInfo> fileServers,
                                                File filestoreRoot)
    {
        Document document = OperationInputXMLElf.generateXMLDoc(host, protocols, credentials, fileServers);

        Element filestoreRootElement = document.createElement(FILESTORE_ROOT);
        filestoreRootElement.setAttribute(FILESTORE_PATH, filestoreRoot.getAbsolutePath());
        document.getFirstChild().appendChild(filestoreRootElement);

        Source source = new DOMSource(document);
        StringWriter stringOutput = new StringWriter();
        Result result = new StreamResult(stringOutput);
        try
        {
            TransformerFactory.newInstance().newTransformer().transform(source, result);
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
        return stringOutput.toString();
    }

    /**
     * Generate XML for the 'telemetry' operation
     * @param host the target
     * @param protocols the protocols involved
     * @param credentials the credentials involved
     * @param fileServers the file servers invovled
     * @param telemetryParams the telemetry properties
     * @return the XML version of everything
     */
    public static String generateTelemetryInputXml(String host, ProtocolSet protocols, CredentialSet credentials, List<FileServerInfo> fileServers,
                                                   Properties telemetryParams)
    {
        Document document = OperationInputXMLElf.generateXMLDoc(host, protocols, credentials, fileServers);

        Element discoveryParamsElement = document.createElement(DISCOVERY_PARAMS);
        discoveryParamsElement.setAttribute(ConnectionPathBuilder.TELEMETRY_CALCULATE_ADMIN_IP,
                                            telemetryParams.getProperty(ConnectionPathBuilder.TELEMETRY_CALCULATE_ADMIN_IP));
        document.getFirstChild().appendChild(discoveryParamsElement);

        Source source = new DOMSource(document);
        StringWriter stringOutput = new StringWriter();
        Result result = new StreamResult(stringOutput);
        try
        {
            TransformerFactory.newInstance().newTransformer().transform(source, result);
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
        return stringOutput.toString();
    }

}
