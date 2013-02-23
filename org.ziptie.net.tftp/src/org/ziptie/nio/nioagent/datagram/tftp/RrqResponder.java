package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;

public interface RrqResponder
{
    BinaryCodec respondToRrq(InetSocketAddress local, InetSocketAddress remote, String filename, String mode, int blksize, int timeout, byte[] data,
            Int dataLen, Bool terminate);

}
