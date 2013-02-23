package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.datagram.tftp.DataProducer;

public class MockDataProducer implements DataProducer
{

    private int length;

    public MockDataProducer()
    {
        length = 0;
    }

    public void setLength(int value)
    {
        length = value;
    }

    public void produce(int dataOff, byte[] data, Int dataLen)
    {
        dataLen.value = length;
    }

}
