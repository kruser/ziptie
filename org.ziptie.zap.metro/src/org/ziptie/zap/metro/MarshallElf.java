package org.ziptie.zap.metro;

import java.io.StringWriter;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.PropertyException;

/**
 * MarshallElf.  Helps to serialize objects using JAXB.
 */
public final class MarshallElf
{
    /**
     * Private constructor
     */
    private MarshallElf()
    {
        // private constructor
    }

    /**
     * Create a JAXB string from an object.
     *
     * @param object the object to marshal
     * @return the marshalled object string
     */
    public static String createJaxbObjectString(Object object)
    {
        try
        {
            JAXBContext jc = JAXBContext.newInstance(object.getClass());
            Marshaller marshaller = jc.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FRAGMENT, true);
            StringWriter writer = new StringWriter();
            marshaller.marshal(object, writer);

            return writer.toString();
        }
        catch (PropertyException e)
        {
            throw new RuntimeException(e);
        }
        catch (JAXBException e)
        {
            throw new RuntimeException(e);
        }
    }
}
