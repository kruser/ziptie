package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.datagram.tftp.EventListener.RequestType;
import org.ziptie.nio.nioagent.datagram.tftp.EventListener.TftpMode;


/**
 * Responds to TFTP write requests (WRQ).  This class contains no state, so it
 * can be shared across all clients.  The main purpose of this class is to
 * create a DataConsumer for each client that will do something useful with the
 * bytes of data sent from the client to the server.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 */
public class WrqResponder implements PacketConstants
{

    // -- member fields
    private final DataConsumer.Factory factory;
    private final SecurityManager manager;
    private final EventListener listener;
    private final ILogger logger;

    // -- constructors
    public WrqResponder(final DataConsumer.Factory factory, final SecurityManager manager, final EventListener listener, final ILogger logger)
    {
        this.factory = factory;
        this.manager = manager;
        this.listener = listener;
        this.logger = logger;
    }

    // -- public methods
    public BinaryCodec respondToWrq(InetSocketAddress local, InetSocketAddress remote, String filename, String mode, Bool terminate)
    {
        terminate.value = manager.denyWrite(remote, filename, mode);
        final BinaryCodec dataCodec;
        if (!terminate.value)
        {
            dataCodec = DataCodecImpl.create(responder(filename), logger);
            listener.transferStarted(local, remote, RequestType.write, filename, TftpMode.valueOf(mode.toLowerCase()));
        }
        else
        {
            dataCodec = null;
        }
        return dataCodec;
    }

    // -- private methods
    private DataResponder responder(String filename)
    {
        return DataResponderImpl.create(factory.createConsumer(filename, logger), listener);
    }

}
