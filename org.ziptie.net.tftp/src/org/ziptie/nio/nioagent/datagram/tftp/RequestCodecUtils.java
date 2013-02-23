package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.ByteArrayUtils;
import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.Int;

/**
 * Static utility methods for decoding TFTP request packets (both RRQ and WRQ).
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class RequestCodecUtils implements PacketConstants
{
    // -- constructors
    private RequestCodecUtils()
    {
        // do nothing
    }

    // -- public methods    
    public static void decodeRequest(byte[] in, int inLen, StringBuffer filename, StringBuffer mode, int defaultTimeoutInterval, Int blksize, Int timeout,
            ILogger logger)
    {
        Int inPos = new Int(2);
        ByteArrayUtils.nextNtString(in, inLen, inPos, filename);
        ByteArrayUtils.nextNtString(in, inLen, inPos, mode);
        blksize.value = DEFAULT_BLOCK_SIZE;
        timeout.value = defaultTimeoutInterval;
        decodeOptions(in, inLen, inPos, blksize, timeout);
    }

    // -- private methods
    private static int parseInt(String string)
    {
        try
        {
            return Integer.parseInt(string);
        }
        catch (NumberFormatException e)
        {
            return DEFAULT_BLOCK_SIZE;
        }
    }

    private static void decodeValue(byte[] buf, int len, Int pos, Int value)
    {
        StringBuffer valueField = new StringBuffer();
        ByteArrayUtils.nextNtString(buf, len, pos, valueField);
        value.value = parseInt(valueField.toString());
    }

    private static void decodeOption(String option, byte[] buf, int len, Int pos, Int blksize, Int timeout)
    {
        if ("blksize".equalsIgnoreCase(option))
        {
            decodeValue(buf, len, pos, blksize);
        }
        else if ("timeout".equalsIgnoreCase(option))
        {
            decodeValue(buf, len, pos, timeout);
        }
        else
        {
            decodeValue(buf, len, pos, new Int(0));
        }
    }

    private static void decodeOptions(byte[] buf, int len, Int pos, Int blksize, Int timeout)
    {
        while (len > pos.value)
        {
            StringBuffer option = new StringBuffer();
            ByteArrayUtils.nextNtString(buf, len, pos, option);
            decodeOption(option.toString(), buf, len, pos, blksize, timeout);
        }
    }

}
