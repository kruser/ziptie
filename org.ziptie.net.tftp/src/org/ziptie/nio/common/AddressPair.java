package org.ziptie.nio.common;

import java.net.SocketAddress;

import org.ziptie.nio.common.tuple.Pair;


public class AddressPair extends Pair<SocketAddress, SocketAddress>
{

    public AddressPair(SocketAddress local, SocketAddress remote)
    {
        super(local, remote);
    }

    public SocketAddress local()
    {
        return a;
    }

    public SocketAddress remote()
    {
        return b;
    }

}
