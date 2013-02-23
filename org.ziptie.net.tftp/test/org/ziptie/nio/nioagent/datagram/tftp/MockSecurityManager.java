package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.SocketAddress;

import org.ziptie.nio.nioagent.datagram.tftp.SecurityManager;

public class MockSecurityManager implements SecurityManager
{

    public boolean denyRead(SocketAddress remote, String filename, String mode)
    {
        return false;
    }

    public boolean denyWrite(SocketAddress remote, String filename, String mode)
    {
        return false;
    }

}
