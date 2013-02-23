package org.ziptie.nio.nioagent.datagram.tftp;

import java.io.File;

import org.ziptie.nio.common.Int;
import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.datagram.tftp.DataProducer;
import org.ziptie.nio.nioagent.datagram.tftp.FileDataProducer;
import org.ziptie.nio.nioagent.datagram.tftp.PacketConstants;

import junit.framework.TestCase;


public class FileDataProducerTest extends TestCase implements PacketConstants, SystemLogger.Injector
{

    private File file;

    // -- constructors
    public FileDataProducerTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public final void testNothingLeftToProduce() throws Exception
    {
        file = new File("var/testNothingLeftToProduce");
        file.delete();
        file.createNewFile();
        DataProducer prod = FileDataProducer.create("var", file.getName(), DEFAULT_BLOCK_SIZE, logger);
        Int dataLen = new Int(0);
        prod.produce(0, new byte[0], dataLen);
        assertEquals(0, dataLen.value.intValue());
        prod.produce(0, new byte[0], dataLen);
        assertEquals(0, dataLen.value.intValue());
        file.delete();
    }

    // -- protected methods
    protected void setUp() throws Exception
    {

    }

    protected void tearDown() throws Exception
    {
        file.delete();
    }

}
