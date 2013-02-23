package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;
import java.util.LinkedList;
import java.util.List;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.common.ThreadUtils;
import org.ziptie.nio.nioagent.datagram.tftp.EventListener;
import org.ziptie.nio.nioagent.datagram.tftp.TftpClient;


public class ClientRunner implements SystemLogger.Injector
{

    // -- static fields
    private static final String clientDir = "var/tftpclient";

    // -- member fields
    private final int clientCount;
    private final String baseFilename;
    private final FileGenerator gen;
    private final TftpClient client;
    private final List<String> filenames;
    private int maxConcurrent;
    private volatile int curConcurrent;
    private volatile int finishedCount;
    private final EventListener finishedCallback;
    private volatile boolean stillTime;
    private Thread timeoutThr;

    // -- constructors
    public ClientRunner(int numClients, String serverFilename)
    {
        clientCount = numClients;
        baseFilename = serverFilename;
        gen = null;
        client = new TftpClient("localhost", clientDir, logger);
        filenames = new LinkedList<String>();
        maxConcurrent = 0;
        curConcurrent = 0;
        finishedCount = 0;
        finishedCallback = createFinishedCallback();
        stillTime = true;
        timeoutThr = null;
    }

    public ClientRunner(int numClients, String serverFilename, FileGenerator fGen)
    {
        clientCount = numClients;
        baseFilename = serverFilename;
        gen = fGen;
        client = new TftpClient("localhost", clientDir, logger);
        filenames = new LinkedList<String>();
        maxConcurrent = 0;
        curConcurrent = 0;
        finishedCount = 0;
        finishedCallback = createFinishedCallback();
        stillTime = true;
        timeoutThr = null;
    }

    // -- public methods
    public void run()
    {
        createClients();
        doFileGets();
        verifyFiles();
        printResults();
    }

    // -- private methods
    private EventListener createFinishedCallback()
    {
        return new EventListener()
        {
            public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize)
            {
                curConcurrent--;
                finishedCount++;
            }

            public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message)
            {
            }

            public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode)
            {
            }
        };
    }

    private void createClients()
    {
        for (int i = 0; i < clientCount; i++)
        {
            filenames.add("client" + i + "_" + baseFilename);
        }
    }

    private void doFileGets()
    {
        curConcurrent = 0;
        maxConcurrent = 0;
        long startTime = System.currentTimeMillis();
        for (String filename : filenames)
        {
            curConcurrent++;
            maxConcurrent = maxConcurrent < curConcurrent ? curConcurrent : maxConcurrent;
            client.fileGet(baseFilename, filename, finishedCallback);
        }
        startTimeoutThread();
        while (clientCount > finishedCount && stillTime)
        {
            ThreadUtils.sleep(500, logger);
        }
        long stopTime = System.currentTimeMillis();
        if (null != timeoutThr)
        {
            timeoutThr.interrupt();
        }
        if (!stillTime)
        {
            String msg = "Ran out of time. Finished " + finishedCount + " out of " + clientCount + ".";
            logger.error(msg);
            throw new RuntimeException(msg);
        }
        else
        {
            if (null != gen)
            {
                int filesize = gen.fileSize();
                double duration = (stopTime - startTime) / 1000D;
                double kbitsPerSecond = filesize * clientCount * 8D / 1000D / duration;
                logger.error(clientCount + " file transfers of " + filesize + " bytes each completed in " + duration + " seconds.");
                logger.error("That is a rate of " + kbitsPerSecond + " kbps.");
                if (6000 > kbitsPerSecond)
                {
                    throw new RuntimeException("Too slow.");
                }
            }
        }
    }

    private void verifyFiles()
    {
        if (null != gen)
        {
            logger.debug("Verifying contents of transferred files.");
            for (String filename : filenames)
            {
                gen.verifyFile(clientDir, filename, true);
            }
        }
    }

    private void printResults()
    {
        logger.error("Perf test complete. Max concurrent = " + maxConcurrent);
    }

    private void startTimeoutThread()
    {
        timeoutThr = new Thread(timeoutRunnable(), "ClientRunner Timeout");
        timeoutThr.setDaemon(true);
        stillTime = true;
        timeoutThr.start();
    }

    private Runnable timeoutRunnable()
    {
        return new Runnable()
        {
            public void run()
            {
                try
                {
                    Thread.sleep(Math.max(5000, clientCount * 20));
                }
                catch (InterruptedException e)
                {
                    logger.debug("Client runner time out thread was interrupted (normal operation).");
                    return;
                }
                logger.error("Client runner timed out!");
                stillTime = false;
            }
        };
    }

}
