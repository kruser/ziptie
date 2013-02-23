package org.ziptie.adaptertool.art;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URI;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPathExpressionException;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.helpers.XMLReaderFactory;
import org.ziptie.adapters.AdapterInvokerElf;
import org.ziptie.adaptertool.XmlValidateElf;
import org.ziptie.adaptertool.art.Results.Type;
import org.ziptie.common.XPathElf;
import org.ziptie.net.sim.config.Configuration;
import org.ziptie.net.sim.config.ConfigurationService;
import org.ziptie.net.sim.config.IpAddressMapping;
import org.ziptie.net.sim.encoding.Base64;

import com.topologi.diffx.algorithm.DiffXFitopsy;
import com.topologi.diffx.config.DiffXConfig;
import com.topologi.diffx.event.DiffXEvent;
import com.topologi.diffx.format.DiffXFormatter;
import com.topologi.diffx.load.SAXRecorder;
import com.topologi.diffx.sequence.EventSequence;

/**
 * defines a test
 */
@SuppressWarnings("nls")
public class ArtTest extends DefaultHandler implements Runnable
{
    private static final Logger LOGGER = Logger.getLogger(ArtTest.class);

    private String ip;
    private String input;

    private List<String> xpaths;
    private File test;
    private File baselineOutput;

    private String adapterId;
    private String operation;

    private Results results;

    private File recording;

    static
    {
        try
        {
            SAXRecorder.setXMLReaderClass(XMLReaderFactory.createXMLReader().getClass().getName());
        }
        catch (SAXException e)
        {
            throw new RuntimeException("Unable to create default xml reader.", e);
        }
    }

    public ArtTest(Results results, File test)
    {
        this.results = results;
        this.test = test;
    }

    private boolean parse() throws IOException, SAXException, ParserConfigurationException
    {
        if (!test.isFile())
        {
            return false;
        }

        Map<String, String> props = new HashMap<String, String>();

        BufferedReader reader = new BufferedReader(new FileReader(test));
        try
        {
            String line;
            while ((line = reader.readLine()) != null)
            {
                line = line.trim();
                if (line.length() == 0)
                {
                    break;
                }

                String[] pair = line.split("=", 2);
                props.put(pair[0].trim(), pair[1].trim());
            }

            xpaths = new LinkedList<String>();
            while ((line = reader.readLine()) != null)
            {
                xpaths.add(line.trim());
            }
        }
        finally
        {
            reader.close();
        }

        String inputFile = props.get("input");
        if (inputFile != null)
        {
            input = read(new File(test.getParentFile(), inputFile));
        }

        String outputFile = props.get("output");
        if (outputFile != null)
        {
            baselineOutput = new File(test.getParentFile(), outputFile);
        }

        String recordingFile = props.get("recording");
        if (recordingFile != null)
        {
            File file = new File(test.getParentFile(), recordingFile);
            if (file.isFile())
            {
                recording = file;
            }
            else
            {
                recording = new File(recordingFile);
            }

            loadFromRecording(recording);
        }
        else
        {
            ip = props.get("device");
            adapterId = props.get("adapter");
            operation = props.get("operation");
            if (operation == null)
            {
                operation = "backup";
            }
        }
        return true;
    }

    private void loadFromRecording(File file) throws ParserConfigurationException, SAXException, IOException
    {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setAttribute("http://apache.org/xml/features/dom/defer-node-expansion", Boolean.FALSE);
        DocumentBuilder builder = factory.newDocumentBuilder();

        Document doc = builder.parse(file);
        Element root = doc.getDocumentElement();
        adapterId = root.getAttribute("adapterId");
        operation = root.getAttribute("operationName");

        ip = LoopbackAddresses.acquire();
        try
        {
            Element elem = (Element) XPathElf.selectSingleNode(root, "connectionPath");
            Document operationInput = builder.newDocument();
            Element rootElem = operationInput.createElement("operationInputXML");
            operationInput.appendChild(rootElem);

            operationInput.adoptNode(elem);
            rootElem.appendChild(elem);

            elem.setAttribute("host", ip);

            NodeList credentials = XPathElf.selectNodeList(elem, "credentials/credential");
            for (int i = 0; i < credentials.getLength(); i++)
            {
                Element credential = (Element) credentials.item(i);
                String value = credential.getAttribute("value");
                String decoded = Base64.decodeToString(value);
                credential.setAttribute("value", decoded);
            }

            Element fs = (Element) XPathElf.selectSingleNode(elem, "fileServers/fileServer[@protocol='TFTP']");
            if (fs != null)
            {
                fs.setAttribute("ip", AdapterTestCli.getTftpServer().getIp());
                fs.setAttribute("rootDir", AdapterTestCli.getTftpServer().getRootDir());
                fs.setAttribute("port", String.valueOf(AdapterTestCli.getTftpServer().getPort()));
            }

            fs = (Element) XPathElf.selectSingleNode(elem, "fileServers/fileServer[@protocol='FTP']");
            if (fs != null)
            {
                fs.setAttribute("ip", AdapterTestCli.getFtpServer().getIp());
                fs.setAttribute("rootDir", AdapterTestCli.getFtpServer().getRootDir());
                fs.setAttribute("port", String.valueOf(AdapterTestCli.getFtpServer().getPort()));
            }

            StringWriter writer = new StringWriter();
            TransformerFactory stf = SAXTransformerFactory.newInstance();
            Transformer transformer = stf.newTransformer();
            transformer.transform(new DOMSource(operationInput), new StreamResult(writer));
            input = writer.toString();
        }
        catch (XPathExpressionException e)
        {
            throw new RuntimeException(e);
        }
        catch (TransformerConfigurationException e)
        {
            throw new RuntimeException(e);
        }
        catch (TransformerFactoryConfigurationError e)
        {
            throw new RuntimeException(e);
        }
        catch (TransformerException e)
        {
            throw new RuntimeException(e);
        }
    }

    private String read(File file) throws IOException
    {
        StringBuilder sb = new StringBuilder();
        FileReader r = new FileReader(file);
        try
        {
            char[] buf = new char[2048];
            int len;
            while ((len = r.read(buf)) > 0)
            {
                sb.append(buf, 0, len);
            }

            return sb.toString();
        }
        finally
        {
            r.close();
        }
    }

    /** {@inheritDoc} */
    public void run()
    {
        try
        {
            doRun();
        }
        finally
        {
            if (recording != null && ip != null)
            {
                LoopbackAddresses.release(ip);
            }
        }
    }

    public void doRun()
    {
        try
        {
            if (!parse())
            {
                return;
            }
        }
        catch (Throwable e)
        {
            LOGGER.error("Error parsing " + test.toString(), e);
            int id = results.addTest(test.toString(), "Unknown Adapter", 0);
            results.addError(id, Type.GENERAL, e);
            return;
        }

        int id = results.addTest(test.toString(), adapterId, xpaths.size());

        Configuration config = null;
        try
        {
            LOGGER.info("Beginning backup for " + test.toString() + " | Using IP: " + ip);
            if (recording != null)
            {
                ConfigurationService cs = ConfigurationService.getInstance();
                config = cs.findConfigurationFile(ConfigurationService.DEFAULT_CONFIG);
                IpAddressMapping mapping = new IpAddressMapping(ip);
                mapping.setOperation(new URI("recording:" + recording.getAbsolutePath().replace('\\', '/')));
                config.addMapping(mapping);
            }

            String output = AdapterInvokerElf.invoke(adapterId, operation, input, new HashMap<String, String>());

            LOGGER.info("Validating ZED for " + test.toString());

            boolean valid = XmlValidateElf.validate(results, id, new StringReader(output), xpaths);

            if (valid && baselineOutput != null)
            {
                LOGGER.info("Performing baseline compare for " + test.toString());
                SAXRecorder sr = new SAXRecorder();
                EventSequence seq1 = sr.process(baselineOutput);
                EventSequence seq2 = sr.process(output);
                
                Formatter formatter = new Formatter();
                DiffXFitopsy df = new DiffXFitopsy(seq1, seq2);
                df.process(formatter);
    
                for (String delete : formatter.getDeletes())
                {
                    results.addError(id, Type.BASELINE, delete);
                }
            }

            LOGGER.info("Complete for " + test.toString());
        }
        catch (Throwable e)
        {
            results.addError(id, Type.GENERAL, e);
            LOGGER.error("Error running " + test.toString(), e);
        }
        finally
        {
            if (config != null)
            {
                config.invalidateIp(ip);
            }
        }
    }

    private class Formatter implements DiffXFormatter
    {
        private List<String> deletes = new LinkedList<String>();

        public List<String> getDeletes()
        {
            return deletes;
        }

        public void delete(DiffXEvent e) throws IOException, IllegalStateException
        {
            // TODO lbayer: add context to message.
            deletes.add("Missing node: " + e.toXML());
        }

        public void format(DiffXEvent e) throws IOException, IllegalStateException
        {
        }

        public void insert(DiffXEvent e) throws IOException, IllegalStateException
        {
        }

        public void setConfig(DiffXConfig config)
        {
        }
    }
}
