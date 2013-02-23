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
package org.ziptie.provider.update.internal;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Map.Entry;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

/**
 * Provides a linkable way to update.
 */
public class UpdateServlet extends HttpServlet
{
    private static final long serialVersionUID = -7724306803962099347L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        String op = req.getParameter("op"); //$NON-NLS-1$

        if (op == null)
        {
            drawFirstAid(req, resp);
        }
        else if (op.equals("upload")) //$NON-NLS-1$
        {
            String id = req.getParameter("id"); //$NON-NLS-1$
            String version = req.getParameter("ver"); //$NON-NLS-1$

            try
            {
                resp.setContentType("text/xml"); //$NON-NLS-1$
                ServletOutputStream out = resp.getOutputStream();
                UpdateActivator.getUpdateProvider().upload(out, id, version, req.getInputStream());
                out.close();
            }
            catch (Exception e)
            {
                throw new ServletException(e);
            }
        }
        else if (op.equals("summary"))
        {
            try
            {
                resp.setContentType("text/html");
                printSummary(new OutputStreamWriter(resp.getOutputStream()));
            }
            catch (XMLStreamException e)
            {
                e.printStackTrace();
            }
        }
        else if (op.equals("post")) //$NON-NLS-1$
        {
            try
            {
                post(req.getParameter("email"), req.getParameter("name"));
                resp.getOutputStream().write("Done".getBytes());
            }
            catch (XMLStreamException e)
            {
                e.printStackTrace();
            }
        }
        else if (op.equals("log"))
        {
            FileInputStream in = new FileInputStream("ziptieServer.log");
            writeFile("text/plain", in, resp);
        }
    }

    private void drawFirstAid(HttpServletRequest req, HttpServletResponse resp) throws IOException
    {
        InputStream stream = getClass().getResourceAsStream("first-aid.html");
        writeFile("text/html", stream, resp);
    }

    private void writeFile(String type, InputStream stream, HttpServletResponse resp) throws IOException
    {
        resp.setContentType(type);

        ServletOutputStream out = resp.getOutputStream();

        int len;
        byte[] buf = new byte[2048];
        while ((len = stream.read(buf)) > 0)
        {
            out.write(buf, 0, len);
        }
    }

    private void printSummary(java.io.Writer out) throws XMLStreamException
    {
        XMLStreamWriter w = XMLOutputFactory.newInstance().createXMLStreamWriter(out);
        w.writeStartDocument();
        w.writeStartElement("html");
        w.writeStartElement("head");
        w.writeStartElement("title");
        w.writeCharacters("Summary");
        w.writeEndElement();
        w.writeEndElement();
        w.writeStartElement("body");
        w.writeStartElement("table");

        w.writeStartElement("h3");
        w.writeCharacters("System Properties");
        w.writeEndElement();
        w.writeEmptyElement("hr");

        Properties props = System.getProperties();
        List<Entry<Object, Object>> entries = new ArrayList<Entry<Object, Object>>();
        entries.addAll(props.entrySet());
        Collections.sort(entries, new Comparator<Entry<Object, Object>>()
        {
            public int compare(Entry<Object, Object> o1, Entry<Object, Object> o2)
            {
                return o1.getKey().toString().compareToIgnoreCase(o2.toString());
            }
        });

        for (Entry<Object, Object> entry : entries)
        {
            w.writeStartElement("tr");
            w.writeStartElement("td");
            w.writeCharacters(entry.getKey().toString());
            w.writeEndElement();
            w.writeStartElement("td");
            w.writeCharacters(entry.getValue().toString());
            w.writeEndElement();
            w.writeEndElement();
        }

        w.writeEndElement(); // table

        w.writeEmptyElement("br");
        w.writeStartElement("h3");
        w.writeCharacters("Threads");
        w.writeEndElement();
        w.writeEmptyElement("hr");

        Map<Thread, StackTraceElement[]> allStackTraces = Thread.getAllStackTraces();
        List<Entry<Thread, StackTraceElement[]>> traces = new ArrayList<Entry<Thread, StackTraceElement[]>>();
        traces.addAll((Collection<? extends Entry<Thread, StackTraceElement[]>>) allStackTraces.entrySet());
        Collections.sort(traces, new Comparator<Entry<Thread, StackTraceElement[]>>()
        {
            public int compare(Entry<Thread, StackTraceElement[]> o1, Entry<Thread, StackTraceElement[]> o2)
            {
                Thread t1 = o1.getKey();
                Thread t2 = o2.getKey();
                return t1.getName().compareToIgnoreCase(t2.getName());
            }
        });

        for (Entry<Thread, StackTraceElement[]> entry : traces)
        {
            w.writeStartElement("h4");
            w.writeCharacters(entry.getKey().getName());
            w.writeEndElement();
            w.writeStartElement("pre");
            for (StackTraceElement ste : entry.getValue())
            {
                w.writeCharacters(ste.toString());
                w.writeCharacters("\n");
            }
            w.writeEndElement();
        }
        w.writeEmptyElement("br");
        w.writeStartElement("h3");
        w.writeCharacters("Summary");
        w.writeEndElement();
        w.writeEmptyElement("hr");

        w.writeStartElement("pre");
        w.writeCharacters(UpdateActivator.getUpdateProvider().getSummaryXml());
        w.writeEndElement();
        w.writeEndElement(); // body
        w.writeEndElement(); // html
        w.writeEndDocument();
        w.flush();
    }

    @SuppressWarnings("deprecation")
    private void post(String email, String name) throws XMLStreamException, IOException
    {
        String query = String.format("email=%s&name=%s", URLEncoder.encode(email), URLEncoder.encode(name));
        URL url = new URL("http://dev.ziptie.org/bin/support-doc?" + query);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.connect();

        OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream());
        printSummary(writer);
        writer.close();

        if (conn.getResponseCode() != HttpServletResponse.SC_OK)
        {
            throw new IOException(conn.getResponseMessage());
        }
    }
}
