package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.nioagent.datagram.tftp.DataConsumer;

public class MockDataConsumer implements DataConsumer
{

    public void consume(byte[] data, int dataOff, int dataLen, boolean isFinal)
    {
    }

    public static class Factory implements DataConsumer.Factory
    {
        public DataConsumer createConsumer(String filename, final ILogger logger)
        {
            return new MockDataConsumer();
        }
    }

}
