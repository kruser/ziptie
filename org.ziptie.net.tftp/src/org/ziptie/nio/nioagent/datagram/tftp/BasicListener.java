package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

public class BasicListener implements EventListener
{

    // -- public methods

    //    * EventListener
    public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize)
    {
        // do nothing
    }

    public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message)
    {
        // do nothing
    }

    public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode)
    {
        // do nothing
    }

}
