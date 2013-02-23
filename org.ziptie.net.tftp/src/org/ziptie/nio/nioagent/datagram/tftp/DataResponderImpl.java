package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;


public class DataResponderImpl implements DataResponder, PacketConstants
{
    // -- member fields
    public DataConsumer dataConsumer;
    public EventListener eventListener;
    public BlockNumber blockNumber;
    public int filesize;

    // -- constructors
    private DataResponderImpl()
    {
        // do nothing
    }

    // -- public methods
    public static DataResponder create(DataConsumer consumer, EventListener listener)
    {
        DataResponderImpl dataResponderImpl = new DataResponderImpl();
        dataResponderImpl.init(consumer, listener);
        return dataResponderImpl;
    }

    public void respondToData(InetSocketAddress local, InetSocketAddress remote, int dataBlockNum, byte[] data, int dataLen, Bool ignore)
    {
        if (blockNumber.isCurrent(dataBlockNum))
        {
            boolean isLastData = DEFAULT_BLOCK_SIZE > dataLen;
            dataConsumer.consume(data, DATA_OFFSET, dataLen, isLastData);
            filesize += dataLen;
            ignore.value = false;
            blockNumber.next();
            if (isLastData)
            {
                blockNumber.invalidate();
                eventListener.transferComplete(local, remote, filesize);
            }
        }
        else
        {
            ignore.value = true;
        }
    }

    // -- private methods
    private void init(DataConsumer consumer, EventListener listener)
    {
        dataConsumer = consumer;
        eventListener = listener;
        filesize = 0;
        blockNumber = BlockNumberImpl.create(1);
    }

}
