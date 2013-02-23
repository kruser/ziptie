package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.datagram.tftp.AckResponder;
import org.ziptie.nio.nioagent.datagram.tftp.AckResponderImpl;
import org.ziptie.nio.nioagent.datagram.tftp.BlockNumberImpl;
import org.ziptie.nio.nioagent.datagram.tftp.PacketConstants;

import junit.framework.TestCase;


public class AckResponderTest extends TestCase implements PacketConstants
{

    // -- members
    private AckResponder ackResponder;
    protected Int dataBlockNum;
    protected byte[] data;
    protected Int dataLen;
    protected Bool terminate;
    protected Bool ignore;
    private MockDataProducer producer;

    // -- constructors
    public AckResponderTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testRespondToAckNormal() throws Exception
    {
        // ack for data packet in the middle of a transfer
        // should send data packet with len = 512
        int currentBlockNumber = 101;
        setCurrentBlockNumber(currentBlockNumber);
        setLastDataLen(512);
        producer.setLength(512);
        ackResponder.respondToAck(null, null, currentBlockNumber, dataBlockNum, data, dataLen, terminate, ignore);
        assertEquals(512, dataLen.value.intValue());
        assertFalse(terminate.value);
        assertFalse(ignore.value);
    }

    public void testRespondToAckLastData() throws Exception
    {
        // ack for last data packet
        // should terminate with 0 data len
        int currentBlockNumber = 101;
        setCurrentBlockNumber(currentBlockNumber);
        setLastDataLen(120);
        ackResponder.respondToAck(null, null, currentBlockNumber, dataBlockNum, data, dataLen, terminate, ignore);
        assertEquals(0, dataLen.value.intValue());
        assertTrue(terminate.value);
        assertFalse(ignore.value);
    }

    public void testRespondToAskLastData512() throws Exception
    {
        // ack for last data, last data len == 512
        // should send a final data packet with 0 len
        int currentBlockNumber = 101;
        setCurrentBlockNumber(currentBlockNumber);
        setLastDataLen(512);
        ackResponder.respondToAck(null, null, currentBlockNumber, dataBlockNum, data, dataLen, terminate, ignore);
        assertEquals(0, dataLen.value.intValue());
        assertFalse(terminate.value);
        assertFalse(ignore.value);
    }

    public void testRespondToAckForPreviousBlockNumber() throws Exception
    {
        // ack for previous block number should be silently ignored
        // the tftp transfer should continue
        int currentBlockNumber = 101;
        setCurrentBlockNumber(currentBlockNumber);
        ackResponder.respondToAck(null, null, currentBlockNumber - 1, dataBlockNum, new byte[] { 'a' }, dataLen, terminate, ignore);
        // assert that ack is silently ignored
        assertEquals(0, dataLen.value.intValue());
        assertFalse(terminate.value);
        assertTrue(ignore.value);
    }

    public void testRespondToAckFirstWrq() throws Exception
    {
        // first ack (from server) of a wrq
        // block number is 0, and client has not received previous data
        // should send data packet with len = 512
        producer.setLength(512);
        ackResponder.respondToAck(null, null, 0, dataBlockNum, data, dataLen, terminate, ignore);
        assertEquals(512, dataLen.value.intValue());
        assertFalse(terminate.value);
        assertFalse(ignore.value);
    }

    // -- protected methods
    protected void setUp() throws Exception
    {
        producer = new MockDataProducer();
        ackResponder = AckResponderImpl.create(producer, new MockEventListener(), FIRST_ACK_BLOCKNUM_CLIENT);
        dataBlockNum = new Int(0);
        data = new byte[2048];
        dataLen = new Int(0);
        terminate = new Bool(false);
        ignore = new Bool(false);
    }

    // -- private methods
    private AckResponderImpl ackResponderImpl()
    {
        return ((AckResponderImpl) ackResponder);
    }

    private void setCurrentBlockNumber(int currentBlockNumber)
    {
        ((BlockNumberImpl) ackResponderImpl().blockNumber).value = currentBlockNumber;
    }

    private void setLastDataLen(int i)
    {
        ackResponderImpl().lastDataLen = i;
    }

}
