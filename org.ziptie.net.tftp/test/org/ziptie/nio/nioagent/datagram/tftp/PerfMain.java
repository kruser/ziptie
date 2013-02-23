package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServer;
import org.ziptie.nio.nioagent.datagram.tftp.server.BasicTftpServer;


public class PerfMain implements SystemLogger.Injector
{
    // -- static fields
    private static final byte[] testPattern = new byte[] { 'c', 'h', 'r', 'i', 's', '_', 'l', 'e', 'a', 'k', '_' };
    private static final int numPatternRepetitions = 25000;

    // -- public methods
    public static void main(String[] args)
    {
        TftpServer server = BasicTftpServer.getInstance(logger);
        try
        {
            int numClients = Integer.parseInt(args[0]);
            logger.debug("Running perf test with " + numClients + " transfers.");
            FileGenerator gen = new FileGenerator("var/tftp", "perftest.txt", testPattern, numPatternRepetitions);
            server.start();
            ClientRunner clientRunner = new ClientRunner(numClients, "perftest.txt", gen);
            clientRunner.run();
        }
        catch (RuntimeException e)
        {
            logger.error("Faulure running PerfMain.", e);
            throw e;
        }
        finally
        {
            server.stop();
            ChannelSelectorImpl.getInstance(logger).stop();
        }
    }

}
