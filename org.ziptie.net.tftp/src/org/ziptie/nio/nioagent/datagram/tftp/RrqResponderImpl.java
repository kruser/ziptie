package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.datagram.tftp.EventListener.RequestType;
import org.ziptie.nio.nioagent.datagram.tftp.EventListener.TftpMode;

/**
 * Responds to TFTP RRQs from clients.  This class contains no state, so the
 * same instance can be shared between all clients.  The main role of this class
 * is to create a DataProducer (specific to each client) that will supply the
 * data for the data packets sent from the server to the client.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 */
public class RrqResponderImpl implements RrqResponder, PacketConstants
{

    // -- fields
    DataProducer.Factory factory;
    SecurityManager manager;
    EventListener listener;
    ILogger logger;
    int defaultTimeoutInterval;

    // -- constructors
    private RrqResponderImpl()
    {
        // do nothing
    }

    // -- public methods
    public static RrqResponder create(final DataProducer.Factory factory, final SecurityManager manager, final EventListener listener, final ILogger logger,
            final int defaultTimeoutInterval)
    {
        RrqResponderImpl impl = new RrqResponderImpl();
        impl.factory = factory;
        impl.manager = manager;
        impl.listener = listener;
        impl.logger = logger;
        impl.defaultTimeoutInterval = defaultTimeoutInterval;
        return impl;
    }

    public BinaryCodec respondToRrq(InetSocketAddress local, InetSocketAddress remote, String filename, String mode, int blksize, int timeout, byte[] data,
            Int dataLen, Bool terminate)
    {
        terminate.value = manager.denyRead(remote, filename, mode);
        final BinaryCodec serverAckCodec;
        if (!terminate.value)
        {
            AckResponder responder = AckResponderImpl.create(factory.createProducer(filename, blksize, logger), listener, FIRST_ACK_BLOCKNUM_SERVER);
            possiblyProduceData(blksize, timeout, responder, data, dataLen);
            serverAckCodec = AckCodecImpl.create(responder, logger);
            listener.transferStarted(local, remote, RequestType.read, filename, TftpMode.valueOf(mode.toLowerCase()));
        }
        else
        {
            serverAckCodec = null;
        }
        return serverAckCodec;
    }

    // -- package-private methods
    void possiblyProduceData(int blksize, int timeout, AckResponder responder, byte[] data, Int dataLen)
    {
        if (RequestUtils.areDefaultOptions(blksize, timeout, logger, defaultTimeoutInterval))
        {
            responder.produce(data, dataLen);
        }
    }

}
