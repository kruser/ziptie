package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.SocketAddress;

/**
 * A server security manager interface.  An implementation of this interface can
 * deny requests on the basis of remote socket address, filename and mode.  This
 * only applies to TFTP servers because clients do not receive request packets. 
 *  
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public interface SecurityManager
{
    public boolean denyRead(SocketAddress remote, String filename, String mode);

    public boolean denyWrite(SocketAddress remote, String filename, String mode);
}
