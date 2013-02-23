package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.FileOut;
import org.ziptie.nio.common.ILogger;

/**
 * Implementation of the DataConsumer interface that writes bytes of data
 * received from the remote host to a file on the local filesystem.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class FileDataConsumer implements DataConsumer
{

    // -- member fields
    private final FileOut fileOut;

    // -- constructors
    public FileDataConsumer(final String dir, final String filename, final ILogger logger)
    {
        this.fileOut = new FileOut(dir, filename, logger);
    }

    // -- public methods
    public void consume(byte[] data, int dataOff, int dataLen, boolean isFinal)
    {
        fileOut.write(data, dataOff, dataLen);
        if (isFinal)
        {
            fileOut.close();
        }
    }

    // -- private methods

    // -- inner classes
    public static class Factory implements DataConsumer.Factory
    {

        private final String dir;

        public Factory(String dir)
        {
            this.dir = dir;
        }

        public DataConsumer createConsumer(final String filename, final ILogger logger)
        {
            return new FileDataConsumer(dir, filename, logger);
        }

    }

}
