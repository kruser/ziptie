package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.datagram.tftp.WrqResponder;

import junit.framework.Assert;


public class MockWrqResponder extends WrqResponder
{
    public MockWrqResponder()
    {
        super(null, null, null, null);
    }

    @Override
    public BinaryCodec respondToWrq(InetSocketAddress local, InetSocketAddress remote, String filename, String mode, Bool terminate)
    {
        Assert.assertEquals("foo", filename);
        Assert.assertEquals("bar", mode);
        return null;
    }
}
