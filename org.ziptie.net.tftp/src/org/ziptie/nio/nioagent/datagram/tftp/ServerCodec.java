package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.ByteArrayUtils;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.CodecResult;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;

/**
 * TFTP codec and protocol implementation for server-specific packet types.  The
 * TFTP RRQ and WRQ request packets are only ever received and processed by the
 * server.  Upon receiving one of these requests the server needs to fire up
 * either a DataCodec (for RRQ) or a ServerAckCodec (for WRQ).
 * ServerDatagramAttachment is handed a Factory with which it creates a new
 * instance of ServerCodec for each request.  This is needed to initialize the
 * state of the DataCodec and/or ServerAckCodec.  The RrqResponder and
 * WrqResponder contain no state, so a single instance of each is shared across
 * all client connections.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 */
public class ServerCodec implements BinaryCodec, PacketConstants
{

    // -- member fields
    private final RrqResponder rrqResponder;
    private final WrqResponder wrqResponder;
    private final ILogger logger;
    private final int defaultTimeoutInterval;
    private BinaryCodec dataCodec;
    private BinaryCodec ackCodec;

    // -- constructors
    public ServerCodec(final WrqResponder wrqResp, final RrqResponder rrqResp, final ILogger logger, final int defaultTimeoutInterval)
    {
        wrqResponder = wrqResp;
        rrqResponder = rrqResp;
        this.logger = logger;
        this.defaultTimeoutInterval = defaultTimeoutInterval;
        dataCodec = null;
        ackCodec = null;
    }

    // -- public methods
    public CodecResult decodeEncode(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
    {
        final CodecResult tuple;
        switch (in[1]) {
        case OPCODE_RRQ:
            tuple = decodeEncodeRrq(local, remote, in, inLen, out);
            break;
        case OPCODE_WRQ:
            tuple = decodeEncodeWrq(local, remote, in, inLen, out);
            break;
        case OPCODE_DATA:
            if (null != dataCodec)
            {
                tuple = dataCodec.decodeEncode(local, remote, in, inLen, out);
                break;
            }
        case OPCODE_ACK:
            if (null != ackCodec)
            {
                tuple = ackCodec.decodeEncode(local, remote, in, inLen, out);
                break;
            }
        default:
            tuple = new CodecResult(0, false, true, 0);
            break;
        }
        return tuple;
    }

    // -- private methods
    private CodecResult decodeEncodeRrq(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
    {
        // prepare protocol input params
        StringBuffer filename = new StringBuffer();
        StringBuffer mode = new StringBuffer();
        Int blksize = new Int(0);
        Int timeout = new Int(0);
        RequestCodecUtils.decodeRequest(in, inLen, filename, mode, defaultTimeoutInterval, blksize, timeout, logger);
        logger.debug("Fullfilling read request for " + filename + ".");
        Int dataLen = new Int(0);
        Bool terminate = new Bool(false);
        ackCodec = rrqResponder.respondToRrq(local, remote, filename.toString(), mode.toString(), blksize.value, timeout.value, out, dataLen, terminate);
        Int outLen = new Int(0);
        possiblyEncodeResponseToRrq(terminate.value, blksize.value, timeout.value, dataLen.value, out, outLen);
        return new CodecResult(outLen.value, terminate.value, false, timeout.value * 1000L);
    }

    private CodecResult decodeEncodeWrq(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
    {
        // prepare protocol input params
        StringBuffer filename = new StringBuffer();
        StringBuffer mode = new StringBuffer();
        Int blksize = new Int(0);
        Int timeout = new Int(0);
        RequestCodecUtils.decodeRequest(in, inLen, filename, mode, defaultTimeoutInterval, blksize, timeout, logger);
        logger.debug("Fullfilling write request for " + filename + ".");
        Bool terminate = new Bool(false);
        dataCodec = wrqResponder.respondToWrq(local, remote, filename.toString(), mode.toString(), terminate);
        Int outLen = new Int(0);
        possiblyEncodeResponseToWrq(terminate.value, blksize.value, timeout.value, out, outLen);
        return new CodecResult(outLen.value, terminate.value, false, timeout.value * 1000L);
    }

    private static void possiblyAppendOption(String option, int defaultValue, int value, byte[] out, Int outLen)
    {
        if (defaultValue != value)
        {
            ByteArrayUtils.ntStringAndAppend(option, out, outLen);
            ByteArrayUtils.ntNumberAndAppend(value, out, outLen);
        }
    }

    private void encodeOack(int blksize, int timeout, byte[] out, Int outLen)
    {
        out[0] = 0x00;
        out[1] = OPCODE_OACK;
        outLen.value = 2;
        possiblyAppendOption(OPTION_BLKSIZE, DEFAULT_BLOCK_SIZE, blksize, out, outLen);
        possiblyAppendOption(OPTION_TIMEOUT, defaultTimeoutInterval, timeout, out, outLen);
        logger.debug("Sending oack.");
    }

    private void encodeData(int dataLen, byte[] out, Int outLen)
    {
        out[0] = 0x00;
        out[1] = OPCODE_DATA;
        out[2] = 0x00;
        out[3] = 0x01;
        outLen.value = 4 + dataLen;
        logger.debug("Sending data with block number 1.");
    }

    private void encodeResponseToRrq(int blksize, int timeout, int dataLen, byte[] out, Int outLen)
    {
        if (RequestUtils.areDefaultOptions(blksize, timeout, logger, defaultTimeoutInterval))
        {
            encodeData(dataLen, out, outLen);
        }
        else
        {
            encodeOack(blksize, timeout, out, outLen);
        }
    }

    private void possiblyEncodeResponseToRrq(boolean terminate, int blksize, int timeout, int dataLen, byte[] out, Int outLen)
    {
        if (!terminate)
        {
            encodeResponseToRrq(blksize, timeout, dataLen, out, outLen);
        }
    }

    private void encodeAck(byte[] out, Int outLen)
    {
        out[0] = 0x00;
        out[1] = OPCODE_ACK;
        out[2] = 0x00;
        out[3] = 0x00;
        outLen.value = 4;
        logger.debug("Sending ack with block number 0.");
    }

    private void encodeResponseToWrq(int blksize, int timeout, byte[] out, Int outLen)
    {
        if (RequestUtils.areDefaultOptions(blksize, timeout, logger, defaultTimeoutInterval))
        {
            encodeAck(out, outLen);
        }
        else
        {
            encodeOack(blksize, timeout, out, outLen);
        }
    }

    private void possiblyEncodeResponseToWrq(boolean terminate, int blksize, int timeout, byte[] out, Int outLen)
    {
        if (!terminate)
        {
            encodeResponseToWrq(blksize, timeout, out, outLen);
        }
    }

    // -- inner classes
    public static class Factory implements BinaryCodec.Factory<ServerCodec>
    {
        // -- member fields
        private final WrqResponder wrq;
        private final RrqResponder rrq;
        private final ILogger logger;
        private final int defaultTimeoutInterval;

        public Factory(final DataConsumer.Factory consumerFactory, final DataProducer.Factory producerFactory, final SecurityManager manager,
                final EventListener listener, final ILogger logger, final int defaultTimeoutInterval)
        {
            this.logger = logger;
            this.wrq = new WrqResponder(consumerFactory, manager, listener, logger);
            this.rrq = RrqResponderImpl.create(producerFactory, manager, listener, logger, defaultTimeoutInterval);
            this.defaultTimeoutInterval = defaultTimeoutInterval;
        }

        public ServerCodec createBinaryCodec()
        {
            return new ServerCodec(wrq, rrq, logger, defaultTimeoutInterval);
        }
    }

}
