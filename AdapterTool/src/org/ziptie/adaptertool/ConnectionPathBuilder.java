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

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.StringReader;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.common.XPathElf;
import org.ziptie.credentials.Credential;
import org.ziptie.credentials.CredentialKey;
import org.ziptie.credentials.CredentialSet;
import org.ziptie.credentials.utils.CredentialKeyElf;
import org.ziptie.net.utils.FileServerInfo;
import org.ziptie.net.utils.OperationInputXMLElf;
import org.ziptie.protocols.Protocol;
import org.ziptie.protocols.ProtocolSet;
import org.ziptie.protocols.ProtocolSetElf;

import sun.misc.BASE64Encoder;

// CHECKSTYLE:ON

/**
 * ConnectionPathBuilder
 */
public class ConnectionPathBuilder
{
    public static final String TELEMETRY_CALCULATE_ADMIN_IP = "calculateAdminIp";

    private String host;
    private CredentialSet credentials;
    private ProtocolSet protocols;
    private RestoreFile restoreFile;
    private File filestoreRoot;
    private File inputFile;
    private LinkedList<FileServerInfo> servers;
    private Operation operation;
    private Properties telemetryParams;

    /**
     * default
     */
    public ConnectionPathBuilder()
    {
        credentials = new CredentialSet();
        protocols = new ProtocolSet();
        operation = Operation.backup;
    }

    /**
     * @return the inputFile
     */
    public File getInputFile()
    {
        return inputFile;
    }

    /**
     * @param inputFile the inputFile to set
     */
    public void setInputFile(File inputFile)
    {
        this.inputFile = inputFile;
    }

    /**
     * @return the servers
     */
    public LinkedList<FileServerInfo> getServers()
    {
        return servers;
    }

    /**
     * @param servers the servers to set
     */
    public void setServers(LinkedList<FileServerInfo> servers)
    {
        this.servers = servers;
    }

    /**
     * Asks the user a series of questions which will be used to build the connectionPath
     */
    public void buildConnectionPathXml()
    {
        if (inputFile == null)
        {
            try
            {
                if (host == null)
                {
                    setHost(CliElf.get(Messages.getString("AdapterCli.specifyHost"))); //$NON-NLS-1$
                }

                if (protocols.getProtocols().size() == 0)
                {
                    protocols = ProtocolSetElf.createProtocolSet(CliElf.get(Messages.getString("AdapterCli.specifyProtocolSet"))); //$NON-NLS-1$
                }

                if (credentials.getCredentials().isEmpty())
                {
                    List<CredentialKey> keys = CredentialKeyElf.loadCredentialKeys(new FileInputStream("conf/credentialKeys.xml")); //$NON-NLS-1$
                    for (CredentialKey key : keys)
                    {
                        credentials.addCredential(new Credential(key.getKeyName(), CliElf.get(key.getDisplayName() + ": "))); //$NON-NLS-1$
                    }
                }

                switch (operation)
                {
                case restore:
                    restoreFile = new RestoreFile();
                    File file = new File(CliElf.get(Messages.getString("AdapterCli.restoreSpecifyFile"))); //$NON-NLS-1$
                    restoreFile.setOriginalFile(file);
                    if (!file.exists())
                    {
                        System.err.println(Messages.getString("AdapterCli.restoreFileMissing") + " " + file.getAbsolutePath()); //$NON-NLS-1$ //$NON-NLS-2$
                        System.exit(1);
                    }

                    BASE64Encoder encoder = new BASE64Encoder();
                    FileInputStream fis = new FileInputStream(file);
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    encoder.encode(fis, baos);
                    restoreFile.setBase64EncodedFileBlob(baos.toString());
                    restoreFile.setFullPathOnDevice(CliElf.get(Messages.getString("AdapterCli.restoreSpecifyFilePath"))); //$NON-NLS-1$
                    break;
                case commands:
                    // TODO rkruse - this needs to be implemented
                    break;
                case ospull:
                    filestoreRoot = new File(CliElf.get(Messages.getString("AdapterCli.filestoreRoot"))); //$NON-NLS-1$
                    if (!filestoreRoot.isDirectory())
                    {
                        System.err.println(Messages.getString("AdapterCli.filestoreRootMissing") + " " //$NON-NLS-1$ //$NON-NLS-2$
                                           + filestoreRoot.getAbsolutePath());
                        System.exit(1);
                    }
                    break;
                case telemetry:
                    telemetryParams = new Properties();
                    String calculateAdminIp = CliElf.get(Messages.getString("AdapterCli.telemetryCalculateAdminIp")); //$NON-NLS-1$
                    telemetryParams.put(TELEMETRY_CALCULATE_ADMIN_IP, Boolean.toString(calculateAdminIp.matches("^[Yy].*")));
                    break;
                default:
                    break;
                }
            }
            catch (Exception e)
            {
                e.printStackTrace();
            }
        }
    }

    /**
     * @return the credentials
     */
    public CredentialSet getCredentials()
    {
        return credentials;
    }

    /**
     * @param credentials the credentials to set
     */
    public void setCredentials(CredentialSet credentials)
    {
        this.credentials = credentials;
    }

    /**
     * @return the host
     */
    public String getHost()
    {
        return host;
    }

    /**
     * @param host the host to set
     */
    public void setHost(String host)
    {
        this.host = host;
    }

    /**
     * @return the protocols
     */
    public ProtocolSet getProtocols()
    {
        return protocols;
    }

    /**
     * @param protocols the protocols to set
     */
    public void setProtocols(ProtocolSet protocols)
    {
        this.protocols = protocols;
    }

    /**
     * Add a single credential
     * 
     * @param name the name of the cred, e.g. 'username'
     * @param value the value of the credential
     */
    public void addCredential(String name, String value)
    {
        credentials.addOrUpdate(name, value);
    }

    /**
     * set the protocols via a name like 'Telnet-TFTP-SNMP' 
     * @param protocolSet the '-' delimited protocols
     */
    public void setProtocolSet(String protocolSet)
    {
        protocols = ProtocolSetElf.createProtocolSet(protocolSet);
    }

    /**
     * @return the restoreFile
     */
    public RestoreFile getRestoreFile()
    {
        return restoreFile;
    }

    /**
     * @param restoreFile the restoreFile to set
     */
    public void setRestoreFile(RestoreFile restoreFile)
    {
        this.restoreFile = restoreFile;
    }

    /**
     * Returns the ConnectionPath as XML
     * 
     * @return the XML
     */
    public String getOperationInputXml()
    {
        try
        {
            servers = new LinkedList<FileServerInfo>();
            String input = getInputXmlFromFile();

            if (input == null)
            {
                for (Protocol proto : getProtocols().getProtocols())
                {
                    prepareForProtocol(proto.getName());
                }
                input = createInputXml(servers);
            }
            else
            {
                Document dom = getDom(input);

                // Parse out the host information first
                Node connectionPathNode = XPathElf.selectSingleNode(dom.getDocumentElement(), "//connectionPath"); //$NON-NLS-1$
                Node hostNode = connectionPathNode.getAttributes().getNamedItem("host"); //$NON-NLS-1$
                if (hostNode != null)
                {
                    setHost(hostNode.getNodeValue());
                }

                NodeList nodes = XPathElf.selectNodeList(dom.getDocumentElement(), "//connectionPath/protocols/protocol"); //$NON-NLS-1$
                int len = nodes.getLength();
                for (int i = 0; i < len; i++)
                {
                    Node node = nodes.item(i);
                    Node name = node.getAttributes().getNamedItem("name"); //$NON-NLS-1$
                    if (name != null)
                    {
                        prepareForProtocol(name.getNodeValue());
                    }
                }
            }
            return input;
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return ""; //$NON-NLS-1$
        }
    }

    private void prepareForProtocol(String name) throws Exception
    {
        // Determine whether or not the host we are trying to connect to is a IPv4 or IPv6 compatible device
        boolean useIPv6 = (NetworkAddressElf.isValidIpAddress(host) && NetworkAddressElf.isIPv6AddressOrMask(host)) ? true : false;

        if (name.equalsIgnoreCase("TFTP")) //$NON-NLS-1$
        {
            servers.add(FileServerElf.startTftpd(useIPv6));
        }
        else if (name.equalsIgnoreCase("FTP")) //$NON-NLS-1$
        {
            servers.add(FileServerElf.startFtpd(useIPv6));
        }
    }

    private Document getDom(String input) throws SAXException, IOException, ParserConfigurationException
    {
        DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();

        return builder.parse(new InputSource(new StringReader(input)));
    }

    /**
     * Create the input XML for the currently set parameters.
     * @param fileServers The fileservers.
     * @return the input XML as a string.
     */
    public String createInputXml(List<FileServerInfo> fileServers)
    {
        switch (operation)
        {
        case restore:
            return ExtendedOperationInputXmlElf.generateRestoreInputXml(host, protocols, credentials, fileServers, restoreFile);
        case ospull:
            return ExtendedOperationInputXmlElf.generateOspullInputXml(host, protocols, credentials, fileServers, filestoreRoot);
        case telemetry:
            return ExtendedOperationInputXmlElf.generateTelemetryInputXml(host, protocols, credentials, fileServers, telemetryParams);
        default:
            return OperationInputXMLElf.generateXMLString(host, protocols, credentials, fileServers);
        }
    }

    /**
     * Get the contents of the specified input file or <code>null</code> if none.
     * @return The input XML.
     */
    private String getInputXmlFromFile()
    {
        if (inputFile == null)
        {
            return null;
        }

        try
        {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            FileInputStream fis = new FileInputStream(inputFile);

            byte[] buf = new byte[2048];
            int len = 0;
            while ((len = fis.read(buf)) > 0)
            {
                baos.write(buf, 0, len);
            }

            return baos.toString();
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Set the file to use for the XML input.
     * @param file The XML input file.
     * @throws FileNotFoundException if the file does not exist.
     */
    public void setInputXmlFile(String file) throws FileNotFoundException
    {
        inputFile = new File(file);
        if (!inputFile.isFile())
        {
            throw new FileNotFoundException(file);
        }
    }

    /**
     * @return the operation
     */
    public Operation getOperation()
    {
        return operation;
    }

    /**
     * @param operation the operation to set
     */
    public void setOperation(Operation operation)
    {
        this.operation = operation;
    }

    /**
     * @return the filestoreRoot
     */
    File getFilestoreRoot()
    {
        return filestoreRoot;
    }

    /**
     * @param filestoreRoot the filestoreRoot to set
     */
    void setFilestoreRoot(File filestoreRoot)
    {
        this.filestoreRoot = filestoreRoot;
    }
}
