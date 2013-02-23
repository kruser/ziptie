package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;


public interface DataResponder
{
    void respondToData(InetSocketAddress local, InetSocketAddress remote, int dataBlockNum, byte[] data, int dataLen, Bool ignore);
}
