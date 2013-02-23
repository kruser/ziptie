package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.CodecResult;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.datagram.tftp.AckCodecImpl;

import junit.framework.TestCase;


public class AckCodecTest extends TestCase implements SystemLogger.Injector
{

    // -- members
    private BinaryCodec codec;

    // -- constructors    
    public AckCodecTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testDecodeEncode()
    {
        byte[] ack = new byte[] { 0x00, 0x04, 0x03, 0x67 };
        byte[] out = new byte[2048];
        CodecResult tuple = codec.decodeEncode(null, null, ack, ack.length, out);
        assertEquals(0x00, out[0]);
        assertEquals(0x03, out[1]);
        assertEquals(0x03, out[2]);
        assertEquals(0x68, out[3]);
        assertEquals(516, tuple.outLen());
        for (int i = 4; i < tuple.outLen(); i++)
        {
            assertEquals(0x22, out[i]);
        }
    }

    // -- protected methods
    @Override
    protected void setUp() throws Exception
    {
        codec = AckCodecImpl.create(new MockAckResponder(), logger);
    }

}
