package org.ziptie.net.ftp;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;

import junit.framework.TestCase;

import org.apache.log4j.PropertyConfigurator;

public class ServerTest extends TestCase
{

    static
    {
        PropertyConfigurator.configure("log4j.properties");
    }

    public void testGet() throws IOException
    {
        String prefix = "test_get.";
        String inFile = prefix + "in";
        String outFile = prefix + "out";
        String contents = "Hello, world!";
        createFile(Server.getAdminUserHomeDirectory(), inFile, contents);
        File out = new File(outFile);
        if (out.exists())
        {
            assertTrue(out.delete());
        }
        Client.copy(String.format("ftp://admin:admin@localhost:%s/%s", Server.getPort(), inFile), outFile);
        verifyFile(outFile, contents);
    }

    public void testPut() throws IOException
    {
        String prefix = "test_put.";
        String inFile = prefix + "in";
        String outFile = prefix + "out";
        String contents = "foobar";
        createFile(null, inFile, contents);
        File out = new File(outFile);
        if (out.exists())
        {
            assertTrue(out.delete());
        }
        Client.copy(inFile, String.format("ftp://admin:admin@localhost:%s/%s", Server.getPort(), outFile));
        verifyFile(Server.getAdminUserHomeDirectory() + "/" + outFile, contents);
    }

    @Override
    public void setUp() throws FileNotFoundException
    {
        Server.start(new File("res/conf/ftpd.properties").toURI());
    }

    @Override
    public void tearDown()
    {
        Server.stop();
    }

    private static void createFile(String dir, String name, String contents) throws IOException
    {
        Writer writer = new FileWriter(new File(dir, name));
        writer.write(contents);
        writer.close();
    }

    private static void verifyFile(String outFile, String expected) throws IOException
    {
        Reader reader = new FileReader(new File(outFile));
        String actual = "";
        while (reader.ready())
        {
            actual += (char) reader.read();
        }
        reader.close();
        assertEquals(expected, actual);
    }

}
