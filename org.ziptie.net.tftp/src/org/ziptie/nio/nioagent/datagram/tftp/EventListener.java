package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

/**
 * A TFTP file transfer even listener.  Classes that implement this interface
 * allow a user class to receive callbacks when predefined events occur.  The
 * user thread can correlate multiple events by matching up the local and remote
 * socket addresses.  The event listener can be used to calculate statistics of 
 * a transfer (e.g. throughput) or all transfers (concurrent sessions and
 * aggregate throughput).  It is important to note that these callbacks are
 * processed on the NIO selector thread, so implementations of this interface
 * must either return quickly from each method call, or place the necessary
 * information on a concurrent queue for long-running processing by another
 * thread.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public interface EventListener
{

    public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode);

    public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize);

    public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message);

    public static enum RequestType
    {
        read,
        write,
    }

    public static enum TftpMode
    {
        octet,
        netascii,
    }

}
