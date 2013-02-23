package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.nioagent.datagram.tftp.DataResponder;
import org.ziptie.nio.nioagent.datagram.tftp.PacketConstants;

import junit.framework.Assert;


public class MockDataResponder implements DataResponder, PacketConstants
{

    public void respondToData(InetSocketAddress local, InetSocketAddress remote, int dataBlockNum, byte[] data, int dataLen, Bool ignore)
    {
        Assert.assertEquals(1025, dataBlockNum);

        for (int i = DATA_OFFSET; i < DATA_OFFSET + dataLen; i++)
        {
            Assert.assertEquals(0x22, data[i]);
        }
    }
}
