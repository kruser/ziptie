package org.ziptie.nio.nioagent.datagram.tftp;

/**
 * Static utility methods for codecs.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class CodecUtils
{
    /**
     * Converts two bytes to an integer
     * @param b0 the high order byte
     * @param b1 the low order byte 
     * @return an int representing the unsigned short
     */
    public static final int unsignedShortToInt(byte b0, byte b1)
    {
        int i = 0;
        i |= b0 & 0xFF;
        i <<= 8;
        i |= b1 & 0xFF;
        return i;
    }

}
