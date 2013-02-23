package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.nioagent.datagram.tftp.EventListener;

public class MockEventListener implements EventListener
{

    public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize)
    {
    }

    public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message)
    {
    }

    public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode)
    {
    }

}
