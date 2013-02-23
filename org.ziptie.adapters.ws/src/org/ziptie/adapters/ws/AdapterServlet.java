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
package org.ziptie.adapters.ws;

import java.io.IOException;
import java.io.StringWriter;
import java.util.HashMap;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import org.apache.log4j.Logger;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.ziptie.adapters.AdapterInvokerElf;
import org.ziptie.adapters.ws.internal.AdaptersWsActivator;
import org.ziptie.stax.STaXFactoriesElf;

// CHECKSTYLE:OFF
import sun.misc.BASE64Encoder;
// CHECKSTYLE:ON

/**
 * Servlet for handling adapter invocations.
 */
@SuppressWarnings("nls")
public class AdapterServlet extends HttpServlet
{
    private static final long serialVersionUID = 6846394091300359673L;
    private static final String ADAPTER_LOGGING_LEVEL = "ADAPTER_LOGGING_LEVEL"; //$NON-NLS-1$
    private static final String ADAPTER_LOG_TO_FILE = "ADAPTER_LOG_TO_FILE"; //$NON-NLS-1$
    private static final String ADAPTER_LOG_DIR = "ADAPTER_LOG_DIR"; //$NON-NLS-1$
    private static final String ENABLE_RECORDING = "ENABLE_RECORDING"; //$NON-NLS-1$
    private static final String RECORDING_DIR = "RECORDING_DIR"; //$NON-NLS-1$
    private static final String SOAP_ENVELOPE_NS = "http://schemas.xmlsoap.org/soap/envelope/";
    private static final String XSI_NS = "http://www.w3.org/2001/XMLSchema-instance";
    private static final String XSD_NS = "http://www.w3.org/2001/XMLSchema";
    private static final String EX_NS = "http://ziptie.org/faults/exceptions";
    private static final String ENVELOPE = "Envelope";
    private static final String BODY = "Body";

    /** {@inheritDoc} */
    @Override
    public void init(ServletConfig config) throws ServletException
    {
        super.init(config);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String result = null;
        String method = null;
        try
        {
            String adapterId = request.getRequestURI().substring("/services/adapters/".length());

            Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(request.getInputStream());

            OutputFormat format = new OutputFormat(doc);
            format.setIndenting(true);

            StringWriter body = new StringWriter();
            XMLSerializer serializer = new XMLSerializer(body, format);

            // write out the child of the soap "body" element for use as the invoker input xml.
            Node bodyNode = doc.getDocumentElement().getFirstChild().getFirstChild();
            serializer.serialize((Element) bodyNode);

            method = bodyNode.getNodeName();

            // pull namespace prefix off method
            int ndx = method.indexOf(':');
            if (ndx > 0)
            {
                method = method.substring(ndx + 1);
            }

            // Calculate any additional environment variables that should be specified
            HashMap<String, String> additionalEnvVars = new HashMap<String, String>();
            NilSettingsProvider nilSettings = AdaptersWsActivator.getSettingsProvider();

            // Add any environment variables to change the logging level for adapter operations
            additionalEnvVars.put(ADAPTER_LOGGING_LEVEL, Integer.toString(nilSettings.getAdapterLoggingLevel()));

            // Add any environment variables to support logging adapter operations to a file,
            // if the functionality is enabled.
            if (nilSettings.isLoggingAdapterOperationsToFileEnabled())
            {
                additionalEnvVars.put(ADAPTER_LOG_TO_FILE, "1");
                additionalEnvVars.put(ADAPTER_LOG_DIR, nilSettings.getAdapterLogsDir());
            }

            // Add any environment variables to support logging adapter operations to a file
            if (nilSettings.isRecordingAdapterOperationsEnabled())
            {
                additionalEnvVars.put(ENABLE_RECORDING, "1");
                additionalEnvVars.put(RECORDING_DIR, nilSettings.getAdapterRecordingsDir());
            }

            result = AdapterInvokerElf.invoke(adapterId, method, body.toString(), additionalEnvVars);
        }
        catch (Exception e)
        {
            Logger.getLogger(getClass()).debug(e.getMessage(), e);
            writeError(response, e);
            return;
        }

        writeSuccess(response, result, method);
    }

    private void writeSuccess(HttpServletResponse response, String result, String method) throws IOException, ServletException
    {
        try
        {
            ServletOutputStream out = response.getOutputStream();
            response.setContentType("text/xml");

            String ns = "http://www.ziptie.org/adapters/" + method;

            XMLStreamWriter xmlWriter = STaXFactoriesElf.getOutputFactory().createXMLStreamWriter(out);

            // Setting to UTF-8 causes an exception because the underlying response encoding may not match UTF-8
            //   xmlWriter.writeStartDocument("UTF-8", "1.0");
            xmlWriter.setPrefix("S", SOAP_ENVELOPE_NS);
            xmlWriter.setPrefix("op", ns);

            xmlWriter.writeStartElement(SOAP_ENVELOPE_NS, ENVELOPE);
            xmlWriter.writeNamespace("S", SOAP_ENVELOPE_NS);
            xmlWriter.writeNamespace("op", ns);
            xmlWriter.writeStartElement(SOAP_ENVELOPE_NS, BODY);
            xmlWriter.writeStartElement(ns, method + "Response");
            xmlWriter.writeStartElement("return");
            xmlWriter.writeCharacters(result);
            xmlWriter.writeEndElement(); // return;
            xmlWriter.writeEndElement(); // Response
            xmlWriter.writeEndElement(); // Body
            xmlWriter.writeEndElement(); // Envelope
            xmlWriter.writeEndDocument();
            xmlWriter.close();
        }
        catch (XMLStreamException e)
        {
            throw new ServletException(e);
        }
    }

    private void writeError(HttpServletResponse response, Exception e) throws IOException, ServletException
    {
        ServletOutputStream out = response.getOutputStream();
        response.setContentType("text/xml");
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

        String message = e.getMessage();
        String base64 = null;

        int indexOf = message.indexOf('\n');
        if (indexOf > 0)
        {
            String detail = message.substring(indexOf + 1);
            message = message.substring(0, indexOf);
            base64 = new BASE64Encoder().encode(detail.getBytes());
        }

        try
        {
            XMLStreamWriter xmlWriter = STaXFactoriesElf.getOutputFactory().createXMLStreamWriter(out);
            xmlWriter.writeStartDocument();
            xmlWriter.setPrefix("s", SOAP_ENVELOPE_NS);
            xmlWriter.setPrefix("xsi", XSI_NS);
            xmlWriter.setPrefix("xsd", XSD_NS);
            xmlWriter.writeStartElement(SOAP_ENVELOPE_NS, ENVELOPE);
            xmlWriter.writeNamespace("s", SOAP_ENVELOPE_NS);
            xmlWriter.writeNamespace("xsi", XSI_NS);
            xmlWriter.writeNamespace("xsd", XSD_NS);
            xmlWriter.writeStartElement(SOAP_ENVELOPE_NS, BODY);
            xmlWriter.writeStartElement(SOAP_ENVELOPE_NS, "Fault");

            xmlWriter.writeStartElement("faultcode");
            xmlWriter.writeCharacters("s:Server");
            xmlWriter.writeEndElement(); // faultcode

            xmlWriter.writeStartElement("faultstring");
            xmlWriter.writeCharacters(message);
            xmlWriter.writeEndElement(); // faultstring

            if (base64 != null)
            {
                xmlWriter.setPrefix("z", EX_NS);

                xmlWriter.writeStartElement("detail");
                xmlWriter.writeStartElement(EX_NS, "msg");
                xmlWriter.writeNamespace("z", EX_NS);
                xmlWriter.writeCharacters("Base64:");
                xmlWriter.writeCharacters(base64);
                xmlWriter.writeEndElement(); // msg
                xmlWriter.writeEndElement(); // detail
            }
            xmlWriter.writeEndElement(); // Fault
            xmlWriter.writeEndElement(); // Body
            xmlWriter.writeEndElement(); // Envelope
            xmlWriter.writeEndDocument();
            xmlWriter.close();
        }
        catch (XMLStreamException e1)
        {
            // ensure that errors are logged so that nothing is eaten.
            Logger logger = Logger.getLogger(getClass());
            logger.error(e.getMessage(), e);
            logger.error(e1.getMessage(), e1);

            throw new ServletException(e1);
        }
    }
}
