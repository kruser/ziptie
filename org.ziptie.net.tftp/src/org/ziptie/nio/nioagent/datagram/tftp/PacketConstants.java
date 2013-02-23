package org.ziptie.nio.nioagent.datagram.tftp;

/**
 * TFTP packet constants.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public interface PacketConstants
{

    // -- opcodes
    public static final byte OPCODE_RRQ = 1;
    public static final byte OPCODE_WRQ = 2;
    public static final byte OPCODE_DATA = 3;
    public static final byte OPCODE_ACK = 4;
    public static final byte OPCODE_ERROR = 5;
    public static final byte OPCODE_OACK = 6;

    // -- initial ack blocknums
    public static final int FIRST_ACK_BLOCKNUM_SERVER = 1;
    public static final int FIRST_ACK_BLOCKNUM_CLIENT = 0;

    // -- error codes
    public static final int ERROR_CODE_FILE_NOT_FOUND = 1;

    // -- options
    public static final String OPTION_BLKSIZE = "blksize";
    public static final String OPTION_TIMEOUT = "timeout";

    // -- misc
    public static final int DATA_OFFSET = 4;
    public static final int DEFAULT_BLOCK_SIZE = 512;

}
