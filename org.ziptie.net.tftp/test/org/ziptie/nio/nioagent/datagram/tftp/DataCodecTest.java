package org.ziptie.nio.nioagent.datagram.tftp;

import java.util.Arrays;

import org.ziptie.nio.common.ByteArrayUtils;
import org.ziptie.nio.common.Int;
import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.CodecResult;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.datagram.tftp.DataCodecImpl;

import junit.framework.TestCase;


public class DataCodecTest extends TestCase implements SystemLogger.Injector
{

    // -- members
    private BinaryCodec codec;

    // -- constructors    
    public DataCodecTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testDecodeEncode()
    {
        byte[] in = new byte[2048];
        Int inLen = new Int(0);
        ByteArrayUtils.append(new byte[] { 0x00, 0x03, 0x04, 0x01 }, in, inLen);
        byte[] data = new byte[512];
        Arrays.fill(data, (byte) 0x22);
        ByteArrayUtils.append(data, in, inLen);
        byte[] out = new byte[2048];
        CodecResult tuple = codec.decodeEncode(null, null, in, inLen.value, out);
        assertEquals(0x00, out[0]);
        assertEquals(0x04, out[1]);
        assertEquals(0x04, out[2]);
        assertEquals(0x01, out[3]);
        assertEquals(4, tuple.outLen());
    }

    // -- protected methods
    @Override
    protected void setUp() throws Exception
    {
        codec = DataCodecImpl.create(new MockDataResponder(), logger);
    }

}
