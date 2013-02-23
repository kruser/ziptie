package org.ziptie.nio.nioagent;

import java.io.IOException;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.spi.AbstractSelectionKey;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.WrapperException;


public class MockKey extends AbstractSelectionKey implements SystemLogger.Injector
{
    // -- members
    private final SelectableChannel channel;
    private int interestOps;

    // -- constructors
    public MockKey(SelectableChannel channel)
    {
        this.channel = channel;
        interestOps = SelectionKey.OP_READ;
    }

    // -- public methods
    @Override
    public SelectableChannel channel()
    {
        return channel;
    }

    @Override
    public SelectionKey interestOps(int arg0)
    {
        interestOps = arg0;
        return this;
    }

    @Override
    public int interestOps()
    {
        return interestOps;
    }

    @Override
    public Selector selector()
    {
        try
        {
            return Selector.open();
        }
        catch (IOException e)
        {
            logger.error("Failed to open selector. ", e);
            throw new WrapperException(e);
        }
    }

    @Override
    public int readyOps()
    {
        return interestOps;
    }

}
