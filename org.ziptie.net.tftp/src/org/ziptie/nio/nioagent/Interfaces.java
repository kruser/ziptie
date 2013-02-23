package org.ziptie.nio.nioagent;

import java.net.InetSocketAddress;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;

public interface Interfaces
{
    /**
     * A binary codec that takes in a byte buffer, decodes it based of the packet
     * formats defined by the protocol, formulates a response based on the contents
     * of the packet, and encodes that response into an outbound byte buffer.
     */
    public interface BinaryCodec
    {
        public CodecResult decodeEncode(InetSocketAddress local, InetSocketAddress remote, byte[] in, int inLen, byte[] out);

        public interface Factory<T extends BinaryCodec>
        {
            T createBinaryCodec();
        }
    }

    public interface ChannelSelector
    {
        void start();

        void register(SelectableChannel chan, int op_write, KeyAttachment att);

        void stop();
    }

    public interface KeyAttachment
    {
        void control(SelectionKey key);
    }

    public interface ManagedThread
    {
        void start();

        void stop();
    }

}
