package org.ziptie.nio.nioagent.datagram.tftp;

/**
 * Abstracts the block number state machine which is used by both DATA and ACK
 * codecs.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 *
 */
public class BlockNumberImpl implements BlockNumber
{

    // -- members
    public int value;
    public boolean isValid;

    // -- constructors
    private BlockNumberImpl()
    {
        // do nothing
    }

    // -- public methods
    public static BlockNumber create(int initialValue)
    {
        BlockNumberImpl blockNumberImpl = new BlockNumberImpl();
        blockNumberImpl.init(initialValue);
        return blockNumberImpl;
    }

    public boolean isCurrent(int other)
    {
        if (isValid)
        {
            if (other == value)
            {
                return true;
            }
            else if (other == 0 && value == 1)
            {
                /*
                 * TFTP clients can ack with blknum=0.  This
                 * is unusual, so we handle it as a case here and 
                 * not the default, which is blknum=1.
                 */
                value = 0;
                return true;
            }
        }
        return false;
    }

    public void next()
    {
        if (isValid)
        {
            value = 65535 == value ? 0 : value + 1;
        }
    }

    public int getValue()
    {
        if (isValid)
        {
            return value;
        }
        throw new RuntimeException("Cannot get value of invalid block number.");
    }

    public void invalidate()
    {
        isValid = false;
    }

    // -- private methods
    private void init(int initialValue)
    {
        value = initialValue;
        isValid = true;
    }

}
