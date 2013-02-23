package org.ziptie.nio.nioagent;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.Pipe;
import java.nio.channels.SelectionKey;
import java.nio.channels.Pipe.SinkChannel;
import java.nio.channels.Pipe.SourceChannel;
import java.util.Arrays;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelWriter;
import org.ziptie.nio.nioagent.RetransmitExtension;
import org.ziptie.nio.nioagent.SharedBuffer;
import org.ziptie.nio.nioagent.WrapperException;

import junit.framework.TestCase;


public class ChannelWriterTest extends TestCase implements SystemLogger.Injector
{

    // -- Members
    private final byte byteValue = 0x22;
    private ChannelWriter writer;
    private SinkChannel sink;
    private SourceChannel source;
    private byte[] input;
    private byte[] output;

    public static void main(String[] args)
    {
        junit.textui.TestRunner.run(ChannelWriterTest.class);
    }

    // -- Constructors
    public ChannelWriterTest(String arg0)
    {
        super(arg0);
    }

    protected void setUp() throws Exception
    {
        Pipe pipe = Pipe.open();
        sink = pipe.sink();
        sink.configureBlocking(false);
        source = pipe.source();
        source.configureBlocking(false);
        output = SharedBuffer.getOutboundBuffer(logger).createByteArray();
        input = SharedBuffer.getInboundBuffer(logger).createByteArray();
    }

    protected void tearDown() throws Exception
    {
        sink.close();
        source.close();
    }

    public final void testChannelWriter() throws IOException
    {
        writer = new ChannelWriter(new FillerCodec(byteValue), RetransmitExtension.create(500, 0, logger), logger);
        SelectionKey key = new MockKey(sink);
        Arrays.fill(input, byteValue);
        writer.direct(key, null, null, input, 0);
        while (key.isWritable())
        {
            writer.write(key);
        }
        SharedBuffer.getOutboundBuffer(logger).use(new MockUser());
        for (int i = 0; i < output.length; i++)
        {
            assertTrue(byteValue == output[i]);
        }
    }

    public void testChannelWriterTwice() throws Exception
    {
        testChannelWriter();

        ChannelWriterTest test2 = new ChannelWriterTest("test2");
        test2.setUp();
        test2.testChannelWriter();
        test2.tearDown();
    }

    private class MockUser implements SharedBuffer.User
    {
        public void use(ByteBuffer buf)
        {
            try
            {
                source.read(buf);
            }
            catch (IOException e)
            {
                logger.error("Error reading source.", e);
                throw new WrapperException(e);
            }
            buf.flip();
            buf.get(output, 0, buf.capacity());
        }
    }

}
