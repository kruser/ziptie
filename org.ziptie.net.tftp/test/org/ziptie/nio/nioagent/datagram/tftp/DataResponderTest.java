package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.nioagent.datagram.tftp.BlockNumberImpl;
import org.ziptie.nio.nioagent.datagram.tftp.DataResponder;
import org.ziptie.nio.nioagent.datagram.tftp.DataResponderImpl;

import junit.framework.TestCase;


public class DataResponderTest extends TestCase
{

    // -- members
    private DataResponder dataResponder;
    private byte[] data;
    private Bool ignore;

    // -- constructors    
    public DataResponderTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testRespondToDataNormal() throws Exception
    {
        // data for next block number in middle of transfer
        // respond with ack
        int currentBlockNumber = 101;
        setCurrentBlockNumber(currentBlockNumber);
        dataResponder.respondToData(null, null, currentBlockNumber, data, 512, ignore);
        assertFalse(ignore.value);
    }

    public void testRespondToDataForPreviousBlockNumber() throws Exception
    {
        // data for current (most recently acked) block number
        // silently ignore and continue
        int currentBlockNumber = 101;
        setCurrentBlockNumber(currentBlockNumber);
        dataResponder.respondToData(null, null, currentBlockNumber - 1, data, 512, ignore);
        assertTrue(ignore.value);
    }

    // -- protected methods
    protected void setUp() throws Exception
    {
        dataResponder = DataResponderImpl.create(new MockDataConsumer(), new MockEventListener());
        data = new byte[2048];
        ignore = new Bool(false);
    }

    // -- private methods
    private void setCurrentBlockNumber(int currentBlockNumber)
    {
        ((BlockNumberImpl) ((DataResponderImpl) dataResponder).blockNumber).value = currentBlockNumber;
    }
}
