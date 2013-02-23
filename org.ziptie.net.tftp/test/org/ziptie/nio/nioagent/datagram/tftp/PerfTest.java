package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.Interfaces.ChannelSelector;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServer;
import org.ziptie.nio.nioagent.datagram.tftp.server.BasicTftpServer;

import junit.framework.TestCase;


public class PerfTest extends TestCase implements SystemLogger.Injector
{
    // -- static fields
    private static final byte[] testPattern = new byte[] { 'g', 'o', '_', 'g', 'a', 't', 'o', 'r', 's', '!', '_' };
    private static final int numPatternRepetitions = 1000;

    // -- public methods
    public void testPerf() throws Exception
    {

        ChannelSelector channelSelector = ChannelSelectorImpl.getInstance(logger);
        channelSelector.stop();
        channelSelector.start();
        int numClients = 200;
        logger.debug("Running perf test with " + numClients + " transfers.");
        FileGenerator gen = new FileGenerator("var/tftp", "perftest.txt", testPattern, numPatternRepetitions);
        TftpServer server = BasicTftpServer.getInstance(logger);
        server.start();
        ClientRunner clientRunner = new ClientRunner(numClients, "perftest.txt", gen);
        clientRunner.run();
        server.stop();
        channelSelector.stop();
    }

}
