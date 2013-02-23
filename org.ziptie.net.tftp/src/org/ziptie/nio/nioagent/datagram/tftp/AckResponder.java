package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.Int;


public interface AckResponder
{

    void respondToAck(InetSocketAddress local, InetSocketAddress remote, int ackBlockNum, Int dataBlockNum, byte[] data, Int dataLen, Bool terminate,
                      Bool ignore);

    void produce(byte[] data, Int dataLen);

}
