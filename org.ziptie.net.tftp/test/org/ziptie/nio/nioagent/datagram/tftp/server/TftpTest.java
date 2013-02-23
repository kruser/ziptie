package org.ziptie.nio.nioagent.datagram.tftp.server;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.nio.channels.DatagramChannel;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.WrapperException;
import org.ziptie.nio.nioagent.datagram.tftp.FileGenerator;
import org.ziptie.nio.nioagent.datagram.tftp.TftpClient;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServer;
import org.ziptie.nio.nioagent.datagram.tftp.server.BasicTftpServer;

import junit.framework.TestCase;


public class TftpTest extends TestCase implements SystemLogger.Injector
{

    // -- member fields
    private TftpServer tftpServer;
    private String varDir;
    private String serverDir;
    private String clientDir;
    private byte[] testPattern;
    private int numPatternRepetitions;

    // -- constructors
    public TftpTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testSimpleFileGet()
    {
        doFileGet("hello.txt");
    }

    public void testFileGet()
    {
        String filename = "filegetlargefile.test";
        FileGenerator gen = new FileGenerator(serverDir, filename, testPattern, numPatternRepetitions);
        doFileGet(filename);
        gen.verifyFile(clientDir, filename, true);
    }

    public void testFilePut()
    {
        String filename = "fileput.test";
        FileGenerator gen = new FileGenerator(clientDir, filename, testPattern, numPatternRepetitions);
        doFilePut(filename);
        gen.verifyFile(serverDir, filename, true);
    }

    public void xtestFileNotFound()
    {
        BasicTftpServer tftpServerImpl = (BasicTftpServer) BasicTftpServer.getInstance(logger);
        assertNull(tftpServerImpl.datagramChannel);
        ((TftpServer) tftpServerImpl).start();
        assertTrue(tftpServerImpl.datagramChannel.isOpen());

        String filename = "non-existent.txt";
        File clientFile = file(serverDir, filename);
        if (clientFile.exists())
        {
            assertTrue(clientFile.delete());
        }
        assertFalse(clientFile.exists());

        TftpClient client = new TftpClient("localhost", varDir + "/tftpclient", logger);
        client.fileGet(filename, filename);

        sleep(500);

        // TODO bedwards - assert that error packet is received and client closes     

    }

    // -- protected methods
    protected void setUp()
    {
        tftpServer = BasicTftpServer.getInstance(logger);
        assertServerStopped();
        tftpServer.start();
        assertServerRunning();

        varDir = "var";
        serverDir = varDir + "/tftp/";
        clientDir = varDir + "/tftpclient";

        testPattern = "blackrat".getBytes();
        numPatternRepetitions = 65;
    }

    protected void tearDown()
    {
        assertServerRunning();
        tftpServer.stop();
        assertServerStopped();
        ChannelSelectorImpl.getInstance(logger).stop();
    }

    // -- private methods
    private static void sleep(long msecs)
    {
        try
        {
            Thread.sleep(msecs);
        }
        catch (InterruptedException e)
        {
            logger.debug("Sleep interrupted.", e);
        }
    }

    private static File file(String dir, String filename)
    {
        return new File(dir + "/" + filename);
    }

    private static void contents(File file, StringBuffer contents)
    {
        BufferedReader reader = new BufferedReader(createFileReader(file));
        read(reader, contents);
    }

    private static FileReader createFileReader(File file)
    {
        try
        {
            return new FileReader(file);
        }
        catch (FileNotFoundException e)
        {
            logger.error("Failed to create file reader.", e);
            throw new WrapperException(e);
        }
    }

    private static void read(BufferedReader reader, StringBuffer contents)
    {
        try
        {
            while (reader.ready())
            {
                contents.append(reader.readLine());
            }
        }
        catch (IOException e)
        {
            close(reader);
            logger.error("Failed to read with reader.", e);
            throw new WrapperException(e);
        }
    }

    private static void close(BufferedReader reader)
    {
        try
        {
            reader.close();
        }
        catch (IOException e)
        {
            logger.debug("Failed to close buffered reader.", e);
        }
    }

    private DatagramChannel chan()
    {
        return ((BasicTftpServer) tftpServer).datagramChannel;
    }

    private void assertServerRunning()
    {

        assertNotNull(chan());
        assertTrue(chan().isOpen());
    }

    private void assertServerStopped()
    {
        assertTrue(null == chan() || !chan().isOpen());
    }

    private void doFileGet(String filename)
    {
        File targetFile = file(clientDir, filename);
        deleteTargetFile(targetFile);
        TftpClient client = new TftpClient("localhost", clientDir, logger);
        client.fileGet(filename, filename);
        verifyTransfer(targetFile, serverDir);
    }

    private void doFilePut(String filename)
    {
        File targetFile = file(serverDir, filename);
        deleteTargetFile(targetFile);
        TftpClient client = new TftpClient("localhost", clientDir, logger);
        client.filePut(filename, filename);
        verifyTransfer(targetFile, clientDir);
    }

    private static void deleteTargetFile(File targetFile)
    {
        if (targetFile.exists())
        {
            assertTrue(targetFile.delete());
        }

        assertFalse(targetFile.exists());
    }

    private static void verifyTransfer(File targetFile, String sourceDir)
    {
        sleep(750);
        assertTrue(targetFile.exists());
        StringBuffer sourceContents = new StringBuffer();
        contents(file(sourceDir, targetFile.getName()), sourceContents);
        StringBuffer targetContents = new StringBuffer();
        contents(targetFile, targetContents);
        String srcStr = sourceContents.toString();
        String tgtStr = targetContents.toString();
        logger.debug("src lastIndexOf tgt=" + srcStr.lastIndexOf(tgtStr));
        logger.debug("tgt lastIndexOf src=" + tgtStr.lastIndexOf(srcStr));
        assertEquals(srcStr, tgtStr);
    }

}
