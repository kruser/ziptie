package org.ziptie.nio.nioagent.datagram.tftp;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.DatagramChannel;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.WrapperException;
import org.ziptie.nio.nioagent.datagram.ChannelUtils;

import junit.framework.Assert;


public class TftpTestClient implements SystemLogger.Injector
{
    private final DatagramChannel chan;
    private final SocketAddress target;

    public TftpTestClient()
    {
        chan = ChannelUtils.openInit(logger);
        target = new InetSocketAddress("localhost", 69);
    }

    public void sendRrq()
    {
        File file = new File("var/tftp/a");
        createFile(file);
        fillFile(file);
        sendRequest(new byte[] { 0x00, 0x01, 'a', 0x00, 'o', 'c', 't', 'e', 't', 0x00 });
    }

    public void sendWrq()
    {
        sendRequest(new byte[] { 0x00, 0x02, 'b', 0x00, 'o', 'c', 't', 'e', 't', 0x00 });
    }

    public void sendData()
    {
        byte[] header = new byte[] { 0x00, 0x03, 0x00, 0x01 };
        byte[] dataArr = new byte[516];
        System.arraycopy(header, 0, dataArr, 0, 4);
        writePacket(dataArr);
    }

    public void sendAck()
    {
        writePacket(new byte[] { 0x00, 0x04, 0x00, 0x01 });
    }

    public void assertReceiveExactlyOne()
    {
        int numReceived = 0;
        for (int i = 0; i < 2; i++)
        {
            numReceived += receiveNextDatagram() ? 1 : 0;
        }
        Assert.assertEquals(1, numReceived);
    }

    public void assertClosed()
    {
        Assert.assertFalse(receiveNextDatagram());
        ChannelUtils.close(chan, logger);
    }

    private boolean receiveNextDatagram()
    {
        ByteBuffer dst = ByteBuffer.wrap(new byte[2048]);
        InetSocketAddress remote = receive(dst);
        if (!chan.isConnected())
        {
            connect(chan, remote);
        }
        return null != remote && dst.position() > 0;
    }

    private InetSocketAddress receive(ByteBuffer dst)
    {
        try
        {
            return (InetSocketAddress) chan.receive(dst);
        }
        catch (IOException e)
        {
            logger.error("Failed to receive. ", e);
            throw new WrapperException(e);
        }
    }

    private void connect(DatagramChannel chan, SocketAddress remote)
    {
        try
        {
            chan.connect(remote);
        }
        catch (IOException e)
        {
            logger.error("Failed to connect to channel. ", e);
            throw new WrapperException(e);
        }
    }

    private void createFile(File file)
    {
        try
        {
            file.createNewFile();
        }
        catch (IOException e)
        {
            logger.error("Failed to create file.", e);
            throw new WrapperException(e);
        }
    }

    private void fillFile(File file)
    {
        BufferedWriter writer = new BufferedWriter(fileWriter(file));
        for (int i = 0; i < 1024; i++)
        {
            try
            {
                writer.write("I found you, Ms New Booty.");
            }
            catch (IOException e)
            {
                logger.error("Faile to write. ", e);
                close(writer);
                throw new WrapperException(e);
            }
        }
        close(writer);
    }

    private void close(BufferedWriter writer)
    {
        try
        {
            writer.close();
        }
        catch (IOException e)
        {
            logger.error("Failed to close. ", e);
            throw new WrapperException(e);
        }

    }

    private FileWriter fileWriter(File file)
    {
        try
        {
            return new FileWriter(file);
        }
        catch (IOException e)
        {
            logger.error("Failed to create file writer.", e);
            throw new WrapperException(e);
        }
    }

    private void sendRequest(byte[] packet)
    {
        send(chan, ByteBuffer.wrap(packet), target);
    }

    private void writePacket(byte[] packet)
    {
        try
        {
            chan.write(ByteBuffer.wrap(packet));
        }
        catch (IOException e)
        {
            logger.error("Failed to write. ", e);
            throw new WrapperException(e);
        }
    }

    private void send(DatagramChannel chan, ByteBuffer src, SocketAddress target)
    {
        try
        {
            chan.send(src, target);
        }
        catch (IOException e)
        {
            logger.error("Failed to send. ", e);
            throw new WrapperException(e);
        }
    }

}
