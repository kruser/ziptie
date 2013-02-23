package org.ziptie.nio.nioagent;

import java.net.InetSocketAddress;
import java.util.Arrays;

import org.ziptie.nio.nioagent.CodecResult;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;


public class FillerCodec implements BinaryCodec
{

    // -- members
    private byte byteValue;

    // -- constructors
    public FillerCodec(byte byteValue)
    {
        this.byteValue = byteValue;
    }

    // -- public methods
    public CodecResult decodeEncode(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out)
    {
        Arrays.fill(out, byteValue);
        return new CodecResult(out.length, false, false, 0);
    }

}
