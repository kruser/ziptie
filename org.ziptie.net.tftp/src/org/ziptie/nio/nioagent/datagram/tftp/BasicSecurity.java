package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.SocketAddress;

/**
 * Implementation of security manager that denies packets if the mode field does
 * not equal octet.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class BasicSecurity implements SecurityManager
{

    // -- public methods
    public boolean denyRead(SocketAddress remote, String filename, String mode)
    {
        return denyMode(mode);
    }

    public boolean denyWrite(SocketAddress remote, String filename, String mode)
    {
        return denyMode(mode);
    }

    // -- private methods
    private boolean denyMode(String mode)
    {
        return !("octet".equalsIgnoreCase(mode) || "netascii".equalsIgnoreCase(mode));
    }
}
