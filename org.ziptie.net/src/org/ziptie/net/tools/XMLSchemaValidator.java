package org.ziptie.net.tools;

import java.io.File;
import java.io.IOException;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Source;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.w3c.dom.Node;
import org.xml.sax.SAXException;

/**
 * Validates an XML instance document against a schema.
 * XMLSchemaValidator
 */
@SuppressWarnings("nls")
public final class XMLSchemaValidator
{
    static final SchemaFactory SCHEMA_FACTORY = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
    static final DocumentBuilderFactory DOC_BUILDER_FACTORY = DocumentBuilderFactory.newInstance();

    /**
     * Private constructor for the <code>XMLSchemaValidator</code> class to disable support of a public default constructor.
     *
     */
    private XMLSchemaValidator()
    {
        // Does nothing.
    }

    /**
     * @param args instance and schema
     */
    public static void main(String[] args)
    {
        int status = 3;
        try
        {
            if (2 == args.length)
            {
                Result result = validate(args[0], args[1]);
                status = result.status;
                (0 == status ? System.out : System.err).println(result.message);
            }
            else
            {
                System.err.println("Useage: java -jar validate.jar <xml filename> <xsd filename>");
                status = 5;
            }
        }
        catch (RuntimeException e)
        {
            System.err.println(String.format("Error: %s", e.getMessage()));
            status = 2;
        }
        finally
        {
            System.exit(status);
        }
    }

    static Result validate(String xmlFilename, String xsdFilename)
    {
        String message = "No message";
        DOC_BUILDER_FACTORY.setNamespaceAware(true);
        int status = 4;
        try
        {
            validator(xsdFilename).validate(domSource(xmlFilename));
            message = "Validation succeeded";
            status = 0;
        }
        catch (SAXException e)
        {
            message = String.format("Validation failed: %s", e.getMessage());
            status = 1;
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
        return new Result(message, status);
    }

    /**
     * 
     * Result
     */
    static class Result
    {
        private final String message;
        private final int status;

        Result(final String message, final int status)
        {
            this.message = message;
            this.status = status;
        }
    }

    static Validator validator(String xsdFilename)
    {
        return schema(new StreamSource(new File(xsdFilename))).newValidator();
    }

    static Source domSource(String xmlFilename)
    {
        return new DOMSource(document(new File(xmlFilename)));
    }

    static Schema schema(StreamSource schemaFile)
    {
        try
        {
            return SCHEMA_FACTORY.newSchema(schemaFile);
        }
        catch (SAXException e)
        {
            throw new RuntimeException(e);
        }
    }

    static Node document(File xmlFile)
    {
        try
        {
            return DOC_BUILDER_FACTORY.newDocumentBuilder().parse(xmlFile);
        }
        catch (Exception e)
        {
            throw RuntimeException.class.isAssignableFrom(e.getClass()) ? (RuntimeException) e : new RuntimeException(e);
        }
    }
}
