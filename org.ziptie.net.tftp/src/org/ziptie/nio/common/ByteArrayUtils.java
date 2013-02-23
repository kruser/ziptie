package org.ziptie.nio.common;

public class ByteArrayUtils
{

    // -- public methods
    public static void append(byte[] src, byte[] dst, Int dstLen)
    {
        System.arraycopy(src, 0, dst, dstLen.value, src.length);
        dstLen.value = src.length + dstLen.value.intValue();
    }

    public static void ntStringAndAppend(String string, byte[] dst, Int dstLen)
    {
        append((string + '\00').getBytes(), dst, dstLen);
    }

    public static void ntNumberAndAppend(int number, byte[] dst, Int dstLen)
    {
        ntStringAndAppend(new Integer(number).toString(), dst, dstLen);
    }

    public static void nextNtString(byte[] buf, int len, Int pos, StringBuffer string)
    {
        for (int i = pos.value; i < len; i++)
        {
            if (0x00 == buf[i])
            {
                pos.value = i + 1;
                break;
            }
            string.append((char) buf[i]);
        }
    }

    public static void nextNtNumber(byte[] buf, int len, Int pos, Int number)
    {
        StringBuffer string = new StringBuffer();
        nextNtString(buf, len, pos, string);
        number.value = Integer.parseInt(string.toString());
    }

}
