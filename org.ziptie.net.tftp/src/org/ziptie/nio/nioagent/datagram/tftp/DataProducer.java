package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;

/**
 * An interface for data producers.  The typical operation of a TFTP client or
 * server is to produce data from files on the filesystem, but this interface
 * allows the TFTP implementation to be extended to produce data from any number
 * of sources. 
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public interface DataProducer
{
    /**
     * If nothing left to produce, must set dataLen.value to 0.
     */
    public void produce(int dataOff, byte[] data, Int dataLen);

    public static interface Factory
    {
        public DataProducer createProducer(final String filename, final int blockSize, final ILogger logger);
    }

}
