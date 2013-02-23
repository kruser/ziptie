package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.ILogger;

/**
 * A interface for the data consuming side of the TFTP connection.  Typically
 * TFTP implmentations will write received data to a file on the local
 * filesystem.  By using this interface this TFTP implementation can be extended
 * to write the data to any place imaginable.  
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 * @see DataProducer, FileDataConsumer
 */
public interface DataConsumer
{
    public void consume(byte[] data, int dataOff, int dataLen, boolean isFinal);

    public static interface Factory
    {
        public DataConsumer createConsumer(final String filename, final ILogger logger);
    }
}
