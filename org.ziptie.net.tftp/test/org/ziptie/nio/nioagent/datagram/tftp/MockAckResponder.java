package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.datagram.tftp.AckResponder;
import org.ziptie.nio.nioagent.datagram.tftp.PacketConstants;

import junit.framework.Assert;


public class MockAckResponder implements AckResponder, PacketConstants
{

    public void respondToAck(InetSocketAddress local, InetSocketAddress remote, int ackBlockNum, Int dataBlockNum, byte[] data, Int dataLen, Bool terminate,
                             Bool ignore)
    {
        Assert.assertEquals(871, ackBlockNum);
        dataBlockNum.value = ackBlockNum + 1;
        dataLen.value = 512;
        for (int i = DATA_OFFSET; i < DATA_OFFSET + dataLen.value; i++)
        {
            data[i] = 0x22;
        }
        terminate.value = false;
        ignore.value = false;
    }

    public void produce(byte[] data, Int dataLen)
    {
        // do nothing
    }
}
