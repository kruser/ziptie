package org.ziptie.nio.nioagent.datagram.tftp;

public interface BlockNumber
{

    boolean isCurrent(int dataBlockNum);

    void next();

    void invalidate();

    int getValue();

}
