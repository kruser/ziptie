package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.nioagent.CodecResult;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;


/**
 * Decodes a byte buffer that is known to be a TFTP ACK packet into a set of
 * easy-to-use fields that represent the packet.  Analyzes the contents of those
 * fields and produces a response in the form of an appropriate TFTP DATA
 * packet.  Encodes the reponse packet into an outbound byte buffer.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class AckCodecImpl implements BinaryCodec, PacketConstants
{

    // -- fields
    AckResponder ackResponder;
    ILogger logger;

    // -- constructors
    private AckCodecImpl()
    {
        // do nothing
    }

    // -- public methods
    public static BinaryCodec create(final AckResponder responder, final ILogger logger)
    {
        AckCodecImpl impl = new AckCodecImpl();
        impl.ackResponder = responder;
        impl.logger = logger;
        return impl;
    }

    public CodecResult decodeEncode(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
    {
        final CodecResult tuple;
        if (OPCODE_ACK == in[1])
        {
            tuple = decodeEncodeAck(local, remote, in, inLen, out);
        }
        else
        {
            tuple = new CodecResult(0, false, true, 0);
        }
        return tuple;
    }

    // -- private methods
    private static byte highOrder(int value)
    {
        return (byte) ((value >>> 8) & 0xFF);
    }

    private static byte lowOrder(int value)
    {
        return (byte) (value & 0xFF);
    }

    private CodecResult decodeEncodeAck(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
    {
        // prepare protocol input params
        int ackBlockNum = CodecUtils.unsignedShortToInt(in[2], in[3]);
        logger.debug("Received ack with block number " + ackBlockNum + ".");
        Int dataBlockNum = new Int(0);
        Int dataLen = new Int(0);
        Bool terminate = new Bool(false);
        Bool ignore = new Bool(false);
        // invoke protocol method
        ackResponder.respondToAck(local, remote, ackBlockNum, dataBlockNum, out, dataLen, terminate, ignore);
        final int outLen;
        if (!terminate.value && !ignore.value)
        {
            // prepare codec output params
            out[0] = 0x00;
            out[1] = OPCODE_DATA;
            out[2] = highOrder(dataBlockNum.value);
            out[3] = lowOrder(dataBlockNum.value);
            outLen = 4 + dataLen.value;
            logger.debug("Sending data with block number " + dataBlockNum + ".");
        }
        else
        {
            outLen = 0;
        }
        return new CodecResult(outLen, terminate.value, ignore.value, 0);
    }

}
