package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;

import org.ziptie.nio.common.Bool;
import org.ziptie.nio.common.Int;


public class AckResponderImpl implements AckResponder, PacketConstants
{

    // -- member fields
    public DataProducer dataProducer;
    public EventListener eventListener;
    public BlockNumber blockNumber;
    public int filesize;
    public int lastDataLen;

    // -- constructors
    private AckResponderImpl()
    {
        // do nothing
    }

    // -- public methods
    public static AckResponder create(DataProducer producer, EventListener listener, int firstAckBlocknum)
    {
        AckResponderImpl ackResponderImpl = new AckResponderImpl();
        ackResponderImpl.init(producer, listener, firstAckBlocknum);
        return ackResponderImpl;
    }

    public void produce(byte[] data, Int dataLen)
    {
        dataProducer.produce(DATA_OFFSET, data, dataLen);
        lastDataLen = dataLen.value;
        filesize += dataLen.value;
    }

    public void respondToAck(InetSocketAddress local, InetSocketAddress remote, int ackBlockNum, Int dataBlockNum, byte[] data, Int dataLen, Bool terminate,
                             Bool ignore)
    {
        if (blockNumber.isCurrent(ackBlockNum))
        {
            if (DEFAULT_BLOCK_SIZE > lastDataLen)
            {
                // terminate
                dataLen.value = 0;
                terminate.value = true;
                ignore.value = false;
                lastDataLen = 0;
                blockNumber.invalidate();
                eventListener.transferComplete(local, remote, filesize);
            }
            else
            {
                // send next data
                produce(data, dataLen);
                blockNumber.next();
                dataBlockNum.value = blockNumber.getValue();
                terminate.value = false;
                ignore.value = false;
            }
        }
        else
        {
            // wrong block number -- ignore and continue
            dataLen.value = 0;
            terminate.value = false;
            ignore.value = true;
        }
    }

    // -- private methods
    private void init(DataProducer producer, EventListener listener, int firstAckBlocknum)
    {
        dataProducer = producer;
        eventListener = listener;
        blockNumber = BlockNumberImpl.create(firstAckBlocknum);
        lastDataLen = 512;
        filesize = 0;
    }
}
