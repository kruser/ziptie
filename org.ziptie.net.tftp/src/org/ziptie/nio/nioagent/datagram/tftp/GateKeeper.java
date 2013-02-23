package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.util.HashMap;
import java.util.Map;

import org.ziptie.nio.common.AddressPair;
import org.ziptie.nio.common.ILogger;


public class GateKeeper implements EventListener, SecurityManager
{
    // -- fields
    private static GateKeeper instance = null;
    Map<String, TransferState> transferStates = new HashMap<String, TransferState>();
    Map<AddressPair, String> filenames = new HashMap<AddressPair, String>();
    ILogger logger;

    // -- constructors
    private GateKeeper()
    {
        // do nothing
    }

    // -- public methods
    public synchronized static GateKeeper getInstance(final ILogger logger)
    {
        if (null == instance)
        {
            instance = new GateKeeper();
            instance.logger = logger;
        }
        return instance;
    }

    public void scheduleFileTransfer(String filename)
    {
        transferStates.put(scrub(filename), TransferState.SCHEDULED);
    }

    public TransferState getTransferState(String filename)
    {
        final TransferState state;
        if (transferStates.containsKey(scrub(filename)))
        {
            state = transferStates.get(scrub(filename));
            if (TransferState.COMPLETED == state)
            {
                transferStates.remove(scrub(filename));
            }
        }
        else
        {
            state = TransferState.COMPLETED;
        }
        return state;
    }

    //    * EventListener
    public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize)
    {
        logger.debug("TFTP transfer complete for " + remote + " (filesize = " + filesize + "kB). ");
        finished(local, remote);
    }

    public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message)
    {
        logger.error("TFTP transfer failed for " + remote + ". " + message);
        finished(local, remote);
    }

    public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode)
    {
        filenames.put(new AddressPair(local, remote), scrub(filename));
        transferStates.put(filenames.get(new AddressPair(local, remote)), TransferState.IN_PROGRESS);
    }

    //    * SecurityManager
    public boolean denyRead(SocketAddress remote, String filename, String mode)
    {
        return deny(filename);
    }

    public boolean denyWrite(SocketAddress remote, String filename, String mode)
    {
        return deny(filename);
    }

    private boolean deny(String filename)
    {
        return !transferStates.containsKey(scrub(filename));
    }

    private static String scrub(String filename)
    {
        return filename.replaceFirst("^\\D+", "");
    }

    // -- private methods
    private void finished(InetSocketAddress local, InetSocketAddress remote)
    {
        transferStates.put(filenames.get(new AddressPair(local, remote)), TransferState.COMPLETED);
        filenames.remove(new AddressPair(local, remote));
    }

    // -- inner classes
    public enum TransferState
    {
        SCHEDULED,
        IN_PROGRESS,
        COMPLETED,
    }
}
