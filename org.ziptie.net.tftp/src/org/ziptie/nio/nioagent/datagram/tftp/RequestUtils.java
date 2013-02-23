package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.ILogger;

public class RequestUtils implements PacketConstants
{
    // -- constructors
    private RequestUtils()
    {
        // do nothing
    }

    // -- public methods
    public static boolean areDefaultOptions(int blksize, int timeout, final ILogger logger, int defaultTimeoutInterval)
    {
        return DEFAULT_BLOCK_SIZE == blksize && defaultTimeoutInterval == timeout;
    }

}
