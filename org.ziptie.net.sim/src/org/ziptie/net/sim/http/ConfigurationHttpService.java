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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim.http;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.URI;
import java.net.URLEncoder;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;

import org.apache.log4j.Logger;
import org.ziptie.net.sim.DeviceSimulator;
import org.ziptie.net.sim.config.Configuration;
import org.ziptie.net.sim.config.ConfigurationService;
import org.ziptie.net.sim.config.IpSubnet;
import org.ziptie.net.sim.recording.RecordingLoader;
import org.ziptie.net.sim.repository.RecordingRepository;
import org.ziptie.net.sim.util.CharSequenceBuffer;

import simple.http.Request;
import simple.http.Response;
import simple.http.load.BasicService;
import simple.http.serve.Context;
import simple.util.net.Parameters;

/**
 * HTTP management interface into the Simulator
 */
public class ConfigurationHttpService extends BasicService
{
    private static final Logger LOG = Logger.getLogger(ConfigurationHttpService.class);

    private ConfigurationService configService = ConfigurationService.getInstance();

    public ConfigurationHttpService(Context ctxt)
    {
        super(ctxt);
        LOG.info("Configuration HTTP Service started.");
    }

    /* (non-Javadoc)
     * @see simple.http.serve.BasicResource#process(simple.http.Request, simple.http.Response)
     */
    protected void process(Request req, Response resp) throws Exception
    {
        String path = req.getURI();
        if (path.equals("/"))
        {
            PrintStream ps = resp.getPrintStream();
            resp.set("Content-Type", "text/html");
            ps.println("<META HTTP-EQUIV=REFRESH CONTENT=\"1; URL=/config/\">");
            ps.close();
            return;
        }

        if (path.startsWith("/config/"))
        {
            path = path.substring(7);
        }

        if (path.equals("/"))
        {
            processGetHtml("index.html", resp);
        }
        else if (path.endsWith(".html") && req.getMethod().equals("GET"))
        {
            String filename = path.substring(1);
            processGetHtml(filename, resp);
        }
        else if (path.startsWith("/repos"))
        {
            processRepos(req, resp);
        }
        else if (path.startsWith("/inventory"))
        {
            processGetInventory(req, resp);
        }
        else if (path.startsWith("/save"))
        {
            processSaveConfig(req, resp);
        }
        else if (path.startsWith("/map"))
        {
            processMapHost(req, resp);
        }
        else if (path.startsWith("/config"))
        {
            processShowConfig(req, resp);
        }
        else if (path.startsWith("/reload"))
        {
            processReloadConfig(req, resp);
        }
        else if (path.startsWith("/recordings/save"))
        {
            processSaveRecording(req, resp);
        }
        else if (path.startsWith("/recordings"))
        {
            processShowRecording(req, resp);
        }
        else if (path.startsWith("/import"))
        {
            processGenerateImport(req, resp);
        }
        else if (path.startsWith("/epitomize"))
        {
            processEpitomizeConfig(req, resp);
        }
        else
        {
            resp.setCode(404);
            resp.getOutputStream().close();
        }
    }

    /**
     * @param req
     * @param resp
     * @throws Exception
     */
    private void processRepos(Request req, Response resp) throws Exception
    {
        resp.set("Content-Type", "text/plain");

        String where = null;
        Parameters params = req.getParameters();
        Enumeration en = params.getParameterNames();
        while (en.hasMoreElements())
        {
            String key = (String) en.nextElement();
            String value = params.getParameter(key);
            if (value != null)
            {
                where = (where == null ? "" : (where + " AND ")) + key + " = '" + value + "' ";
            }
        }

        String driver = DeviceSimulator.getProperty("recording.repository.driver");
        String url = DeviceSimulator.getProperty("recording.repository.url");
        String username = DeviceSimulator.getProperty("recording.repository.username");
        String password = DeviceSimulator.getProperty("recording.repository.password");

        RecordingRepository rr = new RecordingRepository(driver, url, username, password);
        List l = rr.download(new File("recordings"), where);
        rr.close();

        PrintStream ps = resp.getPrintStream();
        for (Iterator iter = l.iterator(); iter.hasNext();)
        {
            ps.println(iter.next());
        }
        ps.close();
    }

    /**
     * @param req
     * @param resp
     * @throws Exception
     */
    private void processEpitomizeConfig(Request req, Response resp) throws Exception
    {
        String ip = req.getParameter("ip");
        ip = ip == null ? req.getInetAddress().getHostAddress() : ip;
        String configName = "epitomizing-config.xml";
        String subnet = req.getParameter("subnet");

        Configuration config = configService.generateEpitomizingConfiguration(new IpSubnet(subnet == null ? "127.1.0.0/255.255.0.0" : subnet));
        CharSequenceBuffer buff = new CharSequenceBuffer();
        config.toXml(buff);
        String configStr = buff.toString();
        configService.saveConfiguration(configName, configStr);
        configService.setConfigurationForIp(ip, configName);

        PrintStream ps = resp.getPrintStream();
        ps.print(configStr);
        ps.close();
    }

    /**
     * @param req
     * @param resp
     */
    private void processSaveRecording(Request req, Response resp)
    {
        // TODO lbayer: save recording
    }

    /**
     * @param req
     * @param resp
     * @throws Exception
     */
    private void processGetInventory(Request req, Response resp) throws Exception
    {
        String ip = req.getParameter("ip");
        ip = ip == null ? req.getInetAddress().getHostAddress() : ip;

        Configuration config = configService.findConfiguration(ip);

        String autotest = req.getParameter("autotest");
        if (autotest != null && autotest.equalsIgnoreCase("TRUE"))
        {
            configService.serializeImport(resp.getOutputStream(), config);
        }
        resp.getOutputStream().close();
    }

    /**
     * @param req
     * @param resp
     * @throws IOException
     */
    private void processReloadConfig(Request req, Response resp) throws IOException
    {
        PrintStream ps = resp.getPrintStream();
        configService.resetAll();
        ps.println("Done");
        ps.close();
    }

    private void processGenerateImport(Request req, Response resp) throws Exception
    {
        String ip = req.getParameter("ip");
        String name = req.getParameter("name");

        Configuration config = null;
        if (name != null)
        {
            config = configService.findConfigurationFile(name);
        }
        else
        {
            ip = ip == null ? req.getInetAddress().getHostAddress() : ip;
            config = configService.findConfiguration(ip);
        }
        PrintStream ps = resp.getPrintStream();
        resp.set("Content-Type", "text/csv; name=import.csv");
        resp.set("Content-Disposition", "inline; filename=import.csv");
        configService.createImport(ps, config);
        ps.close();
    }

    private void processSaveConfig(Request req, Response resp) throws Exception
    {
        if (req.getMethod().equals("POST"))
        {
            String filename = null;
            String contents = null;
            configService.saveConfiguration(filename, contents);
        }
        else
        {
            resp.setCode(405); // Method Not Allowed
            PrintStream ps = resp.getPrintStream();
            ps.println("/config/save is a POST only operation!");
            ps.close();
        }
    }

    private void processShowConfig(Request req, Response resp) throws Exception
    {
        PrintStream ps = resp.getPrintStream();

        String name = req.getParameter("name");
        if (name != null)
        {
            CharSequenceBuffer buf = new CharSequenceBuffer();

            resp.set("Content-Type", "text/xml");
            Configuration configuration = configService.findConfigurationFile(name);

            configuration.toXml(buf);

            ps.print(buf);
            ps.close();
            return;
        }
        resp.set("Content-Type", "text/html");

        ps.println("<html><head><title>Configuration</title></head><body>");
        ps.println("<a href='/config/reload'>Reload All</a><br>");
        ps.println("<a href='/config/epitomize'>Generate Epitomizing Config</a><br>\n");
        ps.println("<table border='1' cellpadding='0' cellspacing='0'>");
        ps.println("<tr><td colspan='2'><h4><center>Currently Mapped Hosts</center></h4></td></tr>");
        ps.println("<tr><td width='300'><center>Host</center></td><td width='300'><center>Configuration</center></td></tr>");

        ps.println("<tr bgcolor='#e7f7ff'><td><center>Default</center></td><td><center>");
        ps.println(ConfigurationService.DEFAULT_CONFIG);
        ps.println("</center></td></tr>");

        String reqHost = req.getInetAddress().getHostAddress();
        String reqConfig = ConfigurationService.DEFAULT_CONFIG;

        Iterator iter = configService.enumerateMappedHosts().entrySet().iterator();
        for (int i = 0; iter.hasNext(); i++)
        {
            Entry entry = (Entry) iter.next();

            ps.println("<tr bgcolor='#" + (i % 2 == 0 ? "adcfe7" : "e7f7ff") + "'><td><center>");
            ps.println(entry.getKey());
            ps.println("</center></td><td><center>");
            ps.println(entry.getValue());
            ps.println("</center></td></tr>");

            if (reqHost.equals(entry.getKey()))
            {
                reqConfig = (String) entry.getValue();
            }
        }
        ps.println("</table>");

        ps.println("<br/><br/>");
        ps.println("<table border='1' cellpadding='0' cellspacing='0'>");
        ps.println("<tr><td colspan='3' width='600'><h4><center>All Configurations</center></h4></td></tr>");
        String[] configs = configService.enumerateConfigs();
        for (int i = 0; i < configs.length; i++)
        {
            ps.println("<tr bgcolor='#" + (i % 2 == 0 ? "adcfe7" : "e7f7ff") + "'><td width='200'>");
            ps.println("<center><a href='/config/config?name=" + URLEncoder.encode(configs[i], "UTF-8") + "'>" + configs[i] + "</a></td><td><center>");
            if (!configs[i].equals(reqConfig))
            {
                ps.println("<a href='/config/map?config=" + URLEncoder.encode(configs[i], "UTF-8") + "'>(Use For Connections From This Host)</a>");
            }
            else
            {
                ps.println("(<i>Used for connections from this host</i>)");
            }
            ps.println("</center></td><td><center><a href='/config/import?name=" + URLEncoder.encode(configs[i], "UTF-8") + "'>[Build Import]</a>");
            ps.println("</center></td><td>");
            ps.println("</td></tr>");
        }
        ps.println("</table>");
        ps.println("</body></html>");
        ps.close();
    }

    private void processShowRecording(Request req, Response resp) throws Exception
    {
        PrintStream ps = resp.getPrintStream();

        String name = req.getParameter("name");
        if (name != null)
        {
            resp.set("Content-Type", "text/xml");
            RecordingLoader.getInstance().printRecordingFile(ps, name);
            ps.close();
            return;
        }

        resp.set("Content-Type", "text/html");
        ps.println("<table border='0' cellpadding='0' cellspacing='0'>");
        Collection operations = RecordingLoader.getInstance().enumerateSessions();
        Iterator iter = operations.iterator();
        for (int i = 0; iter.hasNext(); i++)
        {
            URI op = (URI) iter.next();
            ps.println("<tr bgcolor='#" + (i % 2 == 0 ? "adcfe7" : "e7f7ff") + "'><td width='500'>");
            ps.println("<a href='/config/recordings?name=" + URLEncoder.encode(op.getSchemeSpecificPart(), "UTF-8") + "'>" + op.getSchemeSpecificPart()
                    + "</a>");
            ps.println("</td></tr>");
        }
        ps.println("</table>");
        ps.close();
    }

    private void processMapHost(Request req, Response resp) throws Exception
    {
        String ip = req.getParameter("ip");
        String config = req.getParameter("config");

        ip = ip == null ? req.getInetAddress().getHostAddress() : ip;

        Configuration c = configService.findConfigurationFile(config);
        if (c != null)
        {
            resp.set("Location", "/config/config");
            resp.setCode(302);

            configService.setConfigurationForIp(ip, config);

            PrintStream ps = resp.getPrintStream();
            ps.println("Configuration succesfully mapped for host at: " + ip);
            ps.close();
        }
        else
        {
            PrintStream ps = resp.getPrintStream();
            ps.println("Configuration file does not exist!");
            ps.close();
        }
    }

    private void processGetHtml(String filename, Response resp) throws Exception
    {
        resp.set("Content-Type", "text/html");
        OutputStream os = resp.getOutputStream();
        try
        {
            FileInputStream fis = new FileInputStream(new File("html", filename));
            byte[] buf = new byte[1024];
            while (true)
            {
                int len = fis.read(buf);
                if (len < 0)
                {
                    break;
                }
                os.write(buf, 0, len);
            }
        }
        catch (FileNotFoundException e)
        {
            resp.setCode(404);
            os.write("404 File Not Found".getBytes());
        }
        os.close();
    }

    public static String htmlEscape(CharSequence str, boolean escapeNewlines)
    {
        StringBuffer buf = new StringBuffer();

        int len = str.length();
        for (int i = 0; i < len; i++)
        {
            char c = str.charAt(i);
            switch (c)
            {
            case '<':
                buf.append("&lt;");
                break;
            case '>':
                buf.append("&gt;");
                break;
            case '\"':
                buf.append("&quot;");
                break;
            case '\'':
                buf.append("&#039;");
                break;
            case '\\':
                buf.append("&#092;");
                break;
            case '&':
                buf.append("&amp;");
                break;
            case ' ':
                buf.append("&nbsp;");
                break;
            case '\t':
                buf.append("&nbsp;&nbsp;&nbsp;&nbsp;");
                break;
            case '\n':
                if (escapeNewlines)
                {
                    buf.append("<br>\n");
                }
                break;
            default:
                buf.append(c);
                break;
            }
        }

        return buf.toString();
    }
}
