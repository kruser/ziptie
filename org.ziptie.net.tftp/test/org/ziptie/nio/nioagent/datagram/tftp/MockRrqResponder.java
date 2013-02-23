package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.datagram.tftp.PacketConstants;
import org.ziptie.nio.nioagent.datagram.tftp.RrqResponder;

import junit.framework.Assert;


public class MockRrqResponder implements RrqResponder, PacketConstants
{

    public BinaryCodec respondToRrq(InetSocketAddress local, InetSocketAddress remote, String filename, String mode, int blksize, int timeout, byte[] data,
                                    Int dataLen, Bool terminate)
    {
        Assert.assertEquals("foo", filename);
        Assert.assertEquals("bar", mode);
        dataLen.value = 512;

        for (int i = DATA_OFFSET; i < DATA_OFFSET + dataLen.value; i++)
        {
            data[i] = 0x22;
        }
        return null;
    }

}
