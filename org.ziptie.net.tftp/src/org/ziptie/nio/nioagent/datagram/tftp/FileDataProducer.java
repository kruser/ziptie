package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.FileIn;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;

/**
 * Implmentation of the DataProducer interface that reads bytes of data from a
 * file on the local filesystem.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class FileDataProducer implements DataProducer, PacketConstants
{

    // -- member fields
    FileIn fileIn;
    int blockSize;

    // -- constructors
    private FileDataProducer()
    {
        // do nothing
    }

    // -- public mehtods
    public static DataProducer create(final String dir, final String filename, final int blockSize, final ILogger logger)
    {
        FileDataProducer impl = new FileDataProducer();
        impl.fileIn = new FileIn(dir, filename, logger);
        impl.blockSize = blockSize;
        return impl;
    }

    public void produce(int dataOff, byte[] data, Int dataLen)
    {
        dataLen.value = 0;
        int numBytes = 0;
        do
        {
            numBytes = fileIn.read(data, dataOff + dataLen.value, blockSize - dataLen.value);
            dataLen.value = numBytes + dataLen.value.intValue();
        }
        while (0 < numBytes && blockSize > dataLen.value);
    }

    // -- inner classes
    public static class Factory implements DataProducer.Factory
    {
        private final String dir;

        public Factory(String dir)
        {
            this.dir = dir;
        }

        public DataProducer createProducer(final String filename, final int blockSize, final ILogger logger)
        {
            return create(dir, filename, blockSize, logger);
        }
    }
}
