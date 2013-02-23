package org.ziptie.nio.nioagent.datagram.tftp;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.UnknownHostException;

import junit.framework.TestCase;

import org.apache.commons.net.tftp.TFTP;
import org.apache.commons.net.tftp.TFTPClient;
import org.ziptie.nio.common.ExceptionHandlerInjector;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.datagram.tftp.DataConsumer;
import org.ziptie.nio.nioagent.datagram.tftp.DataProducer;
import org.ziptie.nio.nioagent.datagram.tftp.EventListener;
import org.ziptie.nio.nioagent.datagram.tftp.PacketConstants;
import org.ziptie.nio.nioagent.datagram.tftp.SecurityManager;
import org.ziptie.nio.nioagent.datagram.tftp.TftpServer;
import org.ziptie.nio.nioagent.datagram.tftp.server.BasicTftpServer;


public class CommonsNetTest extends TestCase implements PacketConstants, SystemLogger.Injector, ExceptionHandlerInjector
{

    // -- static fields
    private static final int packetCount = 256;
    private static final int expectedLen = packetCount * DEFAULT_BLOCK_SIZE;
    private static final int testData = 'a';
    private static final String hostname = "localhost";

    // -- member fields
    private TftpServer server;
    private TFTPClient client;
    private volatile int numBytesConsumed = 0;
    private volatile int numErrors = 0;
    private volatile String firstErrorMsg = null;

    // -- constructors
    public CommonsNetTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testReceiveFile()
    {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        int numBytes = receiveFile(out);
        assertEquals(expectedLen, numBytes);
        byte[] buf = out.toByteArray();
        assertEquals(expectedLen, buf.length);
        for (int i = 0; i < buf.length; i++)
        {
            assertEquals("i=" + i, testData, buf[i]);
        }
    }

    public void testSendFile()
    {
        byte[] buf = new byte[expectedLen];
        for (int i = 0; i < buf.length; i++)
        {
            buf[i] = testData;
        }
        numBytesConsumed = 0;
        numErrors = 0;
        firstErrorMsg = null;
        sendFile(new ByteArrayInputStream(buf));
        if (0 < numErrors)
        {
            fail(firstErrorMsg);
        }
        assertEquals(expectedLen, numBytesConsumed);
    }

    // -- protected methods
    protected void setUp() throws Exception
    {
        server = BasicTftpServer.getInstance(logger);
        server.start();
        server.restart(consumerFactory(), producerFactory(), manager(), listener());
        client = new TFTPClient();
        client.open();

    }

    protected void tearDown() throws Exception
    {
        client.close();
        server.stop();
        ChannelSelectorImpl.getInstance(logger).stop();
    }

    // -- private methods
    private int receiveFile(OutputStream out)
    {
        String errorMsg = "Failed to receive file";
        try
        {
            return client.receiveFile("foo", TFTP.OCTET_MODE, out, hostname);
        }
        catch (UnknownHostException e)
        {
            throw exceptionHandler.handle(errorMsg, e);
        }
        catch (IOException e)
        {
            throw exceptionHandler.handle(errorMsg, e);
        }
    }

    private void sendFile(InputStream in)
    {
        String errorMsg = "Failed to send file";
        try
        {
            client.sendFile("bar", TFTP.OCTET_MODE, in, hostname);
        }
        catch (UnknownHostException e)
        {
            throw exceptionHandler.handle(errorMsg, e);
        }
        catch (IOException e)
        {
            throw exceptionHandler.handle(errorMsg, e);
        }
    }

    private EventListener listener()
    {
        return new MockEventListener();
    }

    private SecurityManager manager()
    {
        return new MockSecurityManager();
    }

    private DataProducer.Factory producerFactory()
    {
        return new DataProducer.Factory()
        {
            public DataProducer createProducer(String filename, final int blksize, final ILogger logger)
            {
                return new DataProducer()
                {
                    private int count = 0;

                    public void produce(int dataOff, byte[] data, Int dataLen)
                    {
                        if (packetCount > count)
                        {
                            for (int i = dataOff; i < dataOff + blksize; i++)
                            {
                                data[i] = testData;
                            }
                            dataLen.value = blksize;
                            count++;
                        }
                        else
                        {
                            dataLen.value = 0;
                        }
                    }
                };
            }
        };
    }

    private DataConsumer.Factory consumerFactory()
    {
        return new DataConsumer.Factory()
        {
            public DataConsumer createConsumer(String filename, final ILogger logger)
            {
                return new DataConsumer()
                {
                    public void consume(byte[] data, int dataOff, int dataLen, boolean isFinal)
                    {
                        if (4 != dataOff)
                        {
                            numErrors++;
                            if (null == firstErrorMsg)
                            {
                                firstErrorMsg = "dataOff=" + dataOff;
                            }
                        }
                        if (512 != dataLen)
                        {
                            numErrors++;
                            if (null == firstErrorMsg)
                            {
                                firstErrorMsg = "dataLen=" + dataLen;
                            }
                        }
                        for (int i = dataOff; i < dataOff + dataLen; i++)
                        {
                            if (testData != data[i])
                            {
                                numErrors++;
                                if (null == firstErrorMsg)
                                {
                                    firstErrorMsg = "i=" + i + " expected:<" + testData + "> but was:<" + data[i] + ">";
                                }
                            }
                        }
                        numBytesConsumed += dataLen;
                    }
                };
            }
        };
    }

}
