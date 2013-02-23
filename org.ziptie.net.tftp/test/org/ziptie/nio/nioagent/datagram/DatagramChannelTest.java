package org.ziptie.nio.nioagent.datagram;

import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.DatagramChannel;
import java.util.Arrays;

import junit.framework.TestCase;

/**
 * Minimalist "tests" of the nio DatagramChannel.  Used as a basis for the test of the DatagramChannel attachments. 
 *
 */
public class DatagramChannelTest extends TestCase
{
    // -- members
    private InetSocketAddress svrBindAddr;
    private DatagramChannel svrBindChan;
    private DatagramChannel clientChan;
    private ByteBuffer src;
    private ByteBuffer dst;
    private int sz;
    private byte data;

    // -- public methods
    public void testDatagramChannel() throws Exception
    {
        svrBindChan.send(src, svrBindAddr);
        receiveAndTestMembers();
    }

    public void testClientDatagramChannel() throws Exception
    {
        clientChan.connect(svrBindAddr);
        clientChan.write(src);
        receiveAndTestMembers();
    }

    public void testHandshake() throws Exception
    {
        // client sends initial packet to server bind address
        byte initData = 0x22;
        clientChan.send(ByteBuffer.wrap(new byte[] { initData }), svrBindAddr);

        // server receives initial packet
        ByteBuffer svrInitBuf = ByteBuffer.wrap(new byte[1]);
        SocketAddress clientAddr = receiveAndTest(svrBindChan, svrInitBuf, svrInitBuf.capacity(), initData);

        // server creates data channel
        DatagramChannel svrDataChan = DatagramChannel.open();
        svrDataChan.configureBlocking(false);
        svrDataChan.connect(clientAddr);
        byte ackData = 0x32;
        svrDataChan.write(ByteBuffer.wrap(new byte[] { ackData }));

        // client recieves ack
        ByteBuffer clientAckBuf = ByteBuffer.wrap(new byte[1]);
        SocketAddress svrDataAddr = receiveAndTest(clientChan, clientAckBuf, clientAckBuf.capacity(), ackData);

        // client sends data
        clientChan.connect(svrDataAddr);
        byte dataData = 0x42;
        clientChan.write(ByteBuffer.wrap(new byte[] { dataData }));

        // server receives data
        ByteBuffer svrDataBuf = ByteBuffer.wrap(new byte[1]);
        receiveAndTest(svrDataChan, svrDataBuf, svrDataBuf.capacity(), dataData);

    }

    // -- protected methods
    @Override
    protected void setUp() throws Exception
    {
        svrBindAddr = new InetSocketAddress("localhost", 10987);
        svrBindChan = DatagramChannel.open();
        svrBindChan.configureBlocking(false);
        svrBindChan.socket().bind(svrBindAddr);
        clientChan = DatagramChannel.open();
        clientChan.configureBlocking(false);
        setUpShared();
    }

    @Override
    protected void tearDown() throws Exception
    {
        clientChan.close();
        svrBindChan.close();
    }

    // -- package private methods
    void setUpWithChannels(DatagramChannel dataChan, DatagramChannel client)
    {
        svrBindChan = dataChan;
        clientChan = client;
        svrBindAddr = (InetSocketAddress) svrBindChan.socket().getLocalSocketAddress();
        setUpShared();
    }

    // -- private methods
    private void setUpShared()
    {
        sz = 512;
        byte[] srcArr = new byte[sz];
        data = (byte) 0x22;
        Arrays.fill(srcArr, data);
        src = ByteBuffer.wrap(srcArr);
        byte[] dstArr = new byte[sz];
        dst = ByteBuffer.wrap(dstArr);
    }

    private void receiveAndTestMembers() throws Exception
    {
        receiveAndTest(svrBindChan, dst, sz, data);
    }

    private static SocketAddress receiveAndTest(DatagramChannel chan, ByteBuffer buf, int size, byte expectedData) throws Exception
    {
        SocketAddress recAddr = chan.receive(buf);
        assertNotNull(recAddr);
        assertFalse(0 == buf.position());
        buf.flip();

        for (int i = 0; i < size; i++)
        {
            assertEquals(expectedData, buf.get());
        }

        return recAddr;
    }

}
