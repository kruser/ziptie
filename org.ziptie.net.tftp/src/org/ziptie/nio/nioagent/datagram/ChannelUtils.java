package org.ziptie.nio.nioagent.datagram;

import java.io.IOException;
import java.nio.channels.DatagramChannel;

import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.nioagent.WrapperException;


/**
 * Static utility methods for DatagramChannels.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class ChannelUtils
{
    // -- constructors
    private ChannelUtils()
    {
        // do nothing
    }

    // -- public methods
    public static DatagramChannel openInit(ILogger logger)
    {
        DatagramChannel chan = open(logger);
        init(chan, logger);
        return chan;
    }

    public static void close(DatagramChannel chan, ILogger logger)
    {
        try
        {
            chan.close();
        }
        catch (IOException e)
        {
            logger.error("Failed to close datagram channel.");
            throw new WrapperException(e);
        }
    }

    // -- private methods
    private static DatagramChannel open(ILogger logger)
    {
        try
        {
            return DatagramChannel.open();
        }
        catch (IOException e)
        {
            logger.error("Failed to open datagram channel.");
            throw new WrapperException(e);
        }
    }

    private static void init(DatagramChannel chan, ILogger logger)
    {
        try
        {
            chan.configureBlocking(false);
            chan.socket().setReuseAddress(true);
        }
        catch (IOException e)
        {
            logger.error("Failed to initialize data channel.");
            close(chan, logger);
            throw new WrapperException(e);
        }
    }
}
