package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.ziptie.nio.common.AddressPair;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.datagram.tftp.BasicSecurity;
import org.ziptie.nio.nioagent.datagram.tftp.DataConsumer;
import org.ziptie.nio.nioagent.datagram.tftp.DataProducer;
import org.ziptie.nio.nioagent.datagram.tftp.EventListener;
import org.ziptie.nio.nioagent.datagram.tftp.SecurityManager;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServer;
import org.ziptie.nio.nioagent.datagram.tftp.server.BasicTftpServer;

import junit.framework.TestCase;


public class EventTest extends TestCase implements SystemLogger.Injector
{

    // -- static fields
    private static final int len = 512;

    // -- member fields
    private TftpServer server;
    private MockEventListener listener;

    // -- constructors
    public EventTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testEvent()
    {
        listener.assertAllComplete();
        ClientRunner runner = new ClientRunner(50, "event_test.txt");
        runner.run();
        sleep(1000);
        listener.assertAllComplete();
    }

    // -- protected methods
    protected void setUp() throws Exception
    {
        listener = new MockEventListener();
        server = BasicTftpServer.getInstance(logger);
        server.restart(consumerFactory(), producerFactory(), manager(), listener);
    }

    protected void tearDown() throws Exception
    {
        server.stop();
    }

    // -- private methods

    private DataConsumer.Factory consumerFactory()
    {
        return new StdoutConsumer.Factory();
    }

    private DataProducer.Factory producerFactory()
    {
        return new MemoryProducer.Factory();
    }

    private SecurityManager manager()
    {
        return new BasicSecurity();
    }

    private static void sleep(long msecs)
    {
        try
        {
            Thread.sleep(msecs);
        }
        catch (InterruptedException e)
        {
            // do nothing
        }
    }

    // -- inner classes

    static class StdoutConsumer implements DataConsumer
    {

        public void consume(byte[] data, int dataOff, int dataLen, boolean isFinal)
        {
            ByteBuffer buf = ByteBuffer.allocate(len);
            buf.put(data, dataOff, dataLen);
            logger.debug(Charset.defaultCharset().decode(buf).toString());
        }

        public void setFilename(String filename)
        {
            // do nothing
        }

        public static class Factory implements DataConsumer.Factory
        {

            public DataConsumer createConsumer(String filename, final ILogger logger)
            {
                return new StdoutConsumer();
            }

        }

    }

    static class MemoryProducer implements DataProducer
    {

        static byte[] src;

        int numProduced = 0;

        static
        {
            src = new byte[512];
            Arrays.fill(src, (byte) 'a');
        }

        public void produce(int dataOff, byte[] data, Int dataLen)
        {
            if (1 > numProduced)
            {
                System.arraycopy(src, 0, data, dataOff, len);
                dataLen.value = len;
            }
            else
            {
                dataLen.value = 0;
            }
            numProduced++;
        }

        public void setFilename(String filename)
        {
            // do nothing
        }

        public static class Factory implements DataProducer.Factory
        {

            public DataProducer createProducer(String filename, int blksize, final ILogger logger)
            {
                return new MemoryProducer();
            }

        }

    }

    private static class MockEventListener implements EventListener
    {
        private final Map<AddressPair, Long> startTimes = new HashMap<AddressPair, Long>();
        private int numStarted = 0;
        private int numComplete = 0;
        private int numFailed = 0;

        public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode)
        {
            logger.debug("Transfer started:");
            logger.debug("  local=" + local);
            logger.debug("  remote=" + remote);
            logger.debug("  requestType=" + requestType);
            logger.debug("  filename=" + filename);
            logger.debug("  mode=" + mode);
            putStartTime(new AddressPair(local, remote));
            numStarted++;
        }

        public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize)
        {
            logger.debug("Transfer complete:");
            logger.debug("  local=" + local);
            logger.debug("  remote=" + remote);
            double kb = filesize / 1024D;
            logger.debug("  filesize=" + kb + " kB");
            long duration = duration(new AddressPair(local, remote));
            logger.debug("  duration=" + duration + " s");
            logger.debug("  throughput=" + kb / duration + " kB/s");
            numComplete++;
        }

        public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message)
        {
            logger.debug("Transfer failed:");
            logger.debug("  local=" + local);
            logger.debug("  remote=" + remote);
            logger.debug("  message=" + message);
            numFailed++;
            startTimes.remove(new AddressPair(local, remote));
        }

        public void assertAllComplete()
        {
            assertEquals(numStarted, numComplete + numFailed);
            assertEquals(numStarted, numComplete);
        }

        private void putStartTime(AddressPair addrPair)
        {
            startTimes.put(addrPair, System.currentTimeMillis());
        }

        private long duration(AddressPair addrPair)
        {
            Long startTime = startTimes.remove(addrPair);
            if (null != startTime)
            {
                return System.currentTimeMillis() - startTime;
            }
            else
            {
                logger.debug("Couln't find start time for " + addrPair + ".");
                logger.debug("Start time map keys:");
                for (AddressPair key : startTimes.keySet())
                {
                    logger.debug("  " + key);
                }
                throw new RuntimeException("Couln't find start time for " + addrPair + ".");
            }
        }

    }

}
