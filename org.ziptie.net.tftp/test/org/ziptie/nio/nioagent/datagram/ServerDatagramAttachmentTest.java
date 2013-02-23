package org.ziptie.nio.nioagent.datagram;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.DatagramChannel;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.spi.AbstractSelectionKey;
import java.util.Arrays;
import java.util.Set;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.CodecResult;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.datagram.ServerDatagramAttachment;

import junit.framework.TestCase;


public class ServerDatagramAttachmentTest extends TestCase implements SystemLogger.Injector
{

    // -- members
    private InetSocketAddress addr;
    private DatagramChannel chan;
    private ByteBuffer src;
    private int sz;
    private byte data;
    private boolean ranCodec;
    private SelectionKey key;
    private Selector selector;

    // -- public methods    

    public void testServerDatagramAttachment() throws Exception
    {
        DatagramChannel clientChan = DatagramChannel.open();
        clientChan.send(src, addr);

        assertFalse(ranCodec);
        assertEquals(0, key.selector().keys().size());

        ServerDatagramAttachment.create(codecFactory(), 5, 3, logger).control(key);

        assertTrue(ranCodec);
        Set<SelectionKey> keys = key.selector().keys();
        assertEquals(1, keys.size());

        // test the DatagramChannel produced by the ServerDatagramAttachment
        DatagramChannel dataChan = (DatagramChannel) keys.iterator().next().channel();
        DatagramChannelTest chanTest = new DatagramChannelTest();
        chanTest.setUpWithChannels(dataChan, clientChan);
        chanTest.testClientDatagramChannel();
        chanTest.tearDown();
    }

    public void testNoData() throws Exception
    {
        try
        {
            ServerDatagramAttachment.create(noDataFactory(), 5, 3, logger).control(key);
            fail("Should have caught a runtime exception.");
        }
        catch (RuntimeException e)
        {
            assertEquals("Client socket address is null and buffer is empty after receiving from server channel.", e.getMessage());
        }
    }

    // -- protected methods
    @Override
    protected void setUp() throws Exception
    {
        addr = new InetSocketAddress("localhost", 10987);
        chan = DatagramChannel.open();
        chan.configureBlocking(false);
        chan.socket().bind(addr);
        sz = 512;
        byte[] srcArr = new byte[sz];
        data = (byte) 0x22;
        Arrays.fill(srcArr, data);
        src = ByteBuffer.wrap(srcArr);
        ranCodec = false;
        key = createKey();
        try
        {
            selector = Selector.open();
        }
        catch (IOException e)
        {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void tearDown() throws Exception
    {
        chan.close();
        ranCodec = false;
    }

    // -- private methods

    private SelectionKey createKey()
    {
        return new AbstractSelectionKey()
        {

            @Override
            public SelectableChannel channel()
            {
                return chan;
            }

            @Override
            public int interestOps()
            {
                return SelectionKey.OP_READ;
            }

            @Override
            public SelectionKey interestOps(int ops)
            {
                return this;
            }

            @Override
            public int readyOps()
            {
                return SelectionKey.OP_READ;
            }

            @Override
            public Selector selector()
            {
                return selector;
            }
        };
    }

    private BinaryCodec.Factory codecFactory()
    {
        return new BinaryCodec.Factory()
        {
            public BinaryCodec createBinaryCodec()
            {
                return new BinaryCodec()
                {
                    public CodecResult decodeEncode(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
                    {
                        assertEquals(sz, inLen);
                        for (int i = 0; i < inLen; i++)
                        {
                            assertEquals(data, in[0]);
                        }
                        ranCodec = true;
                        return new CodecResult(0, false, false, 0);
                    }
                };
            }
        };
    }

    private BinaryCodec.Factory noDataFactory()
    {
        return new BinaryCodec.Factory()
        {
            public BinaryCodec createBinaryCodec()
            {
                return new BinaryCodec()
                {
                    public CodecResult decodeEncode(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
                    {
                        fail("No data, should not call decodeEncode.");
                        return null;
                    }
                };
            }
        };
    }

}
