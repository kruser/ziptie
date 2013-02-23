package org.ziptie.nio.nioagent.datagram.tftp;

import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.channels.DatagramChannel;
import java.nio.channels.SelectionKey;

import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.ChannelWriter;
import org.ziptie.nio.nioagent.RetransmitExtension;
import org.ziptie.nio.nioagent.SharedBuffer;
import org.ziptie.nio.nioagent.Interfaces.BinaryCodec;
import org.ziptie.nio.nioagent.Interfaces.ChannelSelector;
import org.ziptie.nio.nioagent.datagram.ChannelUtils;
import org.ziptie.nio.nioagent.datagram.ClientDatagramAttachment;

/**
 * A TFTP client based on the NIO agent framework.
 * 
 * @author Brian Edwards (bedwards@alterpoint.com)
 */
public class TftpClient implements PacketConstants
{

    // -- fields
    private final ILogger logger;
    private final long retransmitDelay;
    private final int maxRetransmits;
    private final SocketAddress serverAddr;
    private final String localDirName;
    private final byte[] outArr;
    private int outLen;
    private final Integer bufferSize;

    // -- constructors
    public TftpClient(final String serverName, final String localDirectoryName, final ILogger logger, final int retransmitDelay, final Integer maxRetransmits,
            final Integer bufferSize)
    {
        this.logger = logger;
        this.retransmitDelay = retransmitDelay;
        this.maxRetransmits = maxRetransmits == null ? 3 : maxRetransmits;
        this.serverAddr = new InetSocketAddress(serverName, 69);
        this.localDirName = localDirectoryName;
        this.outArr = SharedBuffer.getOutboundBuffer(logger, bufferSize).createByteArray();
        this.outLen = 0;
        this.bufferSize = bufferSize;
    }

    // -- public methods
    public void fileGet(String serverFilename, String clientFilename)
    {
        DatagramChannel chan = ChannelUtils.openInit(logger);
        fileOp(serverFilename, OPCODE_RRQ, DataCodecImpl.create(dataResponder(clientFilename, new ClientListener(chan, logger)), logger), chan);
    }

    public void fileGet(String serverFilename, String clientFilename, EventListener listener)
    {
        DatagramChannel chan = ChannelUtils.openInit(logger);
        fileOp(serverFilename, OPCODE_RRQ, DataCodecImpl.create(dataResponder(clientFilename, new WrapperListener(chan, listener, logger)), logger), chan);
    }

    public void filePut(String serverFilename, String clientFilename)
    {
        DatagramChannel chan = ChannelUtils.openInit(logger);
        fileOp(serverFilename, OPCODE_WRQ, AckCodecImpl.create(ackResponder(clientFilename, chan), logger), chan);
    }

    // -- private methods
    private DataResponder dataResponder(String clientFilename, EventListener listener)
    {
        return DataResponderImpl.create(new FileDataConsumer(localDirName, clientFilename, logger), listener);
    }

    private AckResponder ackResponder(String clientFilename, DatagramChannel chan)
    {
        return AckResponderImpl.create(FileDataProducer.create(localDirName, clientFilename, DEFAULT_BLOCK_SIZE, logger), new ClientListener(chan, logger),
                FIRST_ACK_BLOCKNUM_CLIENT);
    }

    private void fileOp(String filename, byte opcode, BinaryCodec codec, DatagramChannel chan)
    {
        createRequest(opcode, filename);
        ChannelWriter cWriter = new ChannelWriter(codec, RetransmitExtension.create(retransmitDelay, maxRetransmits, logger), logger, bufferSize);
        ClientDatagramAttachment att = new ClientDatagramAttachment(outArr, outLen, serverAddr, cWriter, logger, bufferSize);
        ChannelSelector channelSelector = ChannelSelectorImpl.getInstance(logger);
        channelSelector.start();
        channelSelector.register(chan, SelectionKey.OP_WRITE, att);
    }

    private void createRequest(byte op, String filename)
    {
        outArr[0] = 0x00;
        outArr[1] = op;
        int filenameOffset = 2;
        int outPos;
        for (outPos = filenameOffset; outPos < filename.length() + filenameOffset; outPos++)
        {
            outArr[outPos] = (byte) filename.charAt(outPos - filenameOffset);
        }
        outArr[outPos] = 0x00;
        outPos++;
        byte[] octet = "octet\00".getBytes();
        System.arraycopy(octet, 0, outArr, outPos, octet.length);
        outLen = outPos + octet.length;
    }

    // -- inner classes
    private static class ClientListener implements EventListener
    {
        private final DatagramChannel chan;
        private final ILogger logger;

        public ClientListener(final DatagramChannel chan, final ILogger logger)
        {
            this.chan = chan;
            this.logger = logger;
        }

        public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize)
        {
            //            ChannelUtils.close(chan);
        }

        public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message)
        {
            ChannelUtils.close(chan, logger);
        }

        public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode)
        {

        }

    }

    private static class WrapperListener extends ClientListener
    {
        private final EventListener wrappedListener;

        public WrapperListener(final DatagramChannel chan, final EventListener listener, final ILogger logger)
        {
            super(chan, logger);
            this.wrappedListener = listener;
        }

        public void transferComplete(InetSocketAddress local, InetSocketAddress remote, int filesize)
        {
            super.transferComplete(local, remote, filesize);
            wrappedListener.transferComplete(local, remote, filesize);
        }

        public void transferFailed(InetSocketAddress local, InetSocketAddress remote, String message)
        {
            super.transferFailed(local, remote, message);
            wrappedListener.transferFailed(local, remote, message);
        }

        public void transferStarted(InetSocketAddress local, InetSocketAddress remote, RequestType requestType, String filename, TftpMode mode)
        {
            super.transferStarted(local, remote, requestType, filename, mode);
            wrappedListener.transferStarted(local, remote, requestType, filename, mode);
        }

    }

}
