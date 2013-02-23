package org.ziptie.nio.nioagent.datagram.tftp;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.DatagramChannel;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.WrapperException;
import org.ziptie.nio.nioagent.Interfaces.ChannelSelector;
import org.ziptie.nio.nioagent.datagram.ChannelUtils;


public class Perf2Client implements SystemLogger.Injector
{
    // -- static fields
    private static final byte[] testPattern = new byte[] { 'c', 'h', 'r', 'i', 's', '_', 'l', 'e', 'a', 'k', '_' };
    private static int numPatternRepetitions;

    // -- public methods
    public static void main(String[] args)
    {
        ChannelSelector channelSelector = ChannelSelectorImpl.getInstance(logger);
        try
        {
            int numClients = Integer.parseInt(args[0]);
            numPatternRepetitions = Integer.parseInt(args[1]);
            logger.debug("Running perf2 test with " + numClients + " transfers.");
            String filename = "perftest2.txt";
            FileGenerator gen = new FileGenerator("var/tftp", filename, testPattern, numPatternRepetitions);
            ClientRunner clientRunner = new ClientRunner(numClients, filename, gen);
            clientRunner.run();
        }
        catch (RuntimeException e)
        {
            logger.error("Caught runtime exception in main.", e);
            throw e;
        }
        finally
        {
            stopServer();
            channelSelector.stop();
        }
    }

    private static void stopServer()
    {
        DatagramChannel chan = ChannelUtils.openInit(logger);
        sendStopSignal(chan, ByteBuffer.wrap(new byte[] { 0x79 }), new InetSocketAddress("localhost", 50000));
        ChannelUtils.close(chan, logger);
    }

    private static void sendStopSignal(DatagramChannel chan, ByteBuffer src, SocketAddress target)
    {
        try
        {
            chan.send(src, target);
        }
        catch (IOException e)
        {
            logger.error("Failed sending stop signal. ", e);
            throw new WrapperException(e);
        }
    }
}
