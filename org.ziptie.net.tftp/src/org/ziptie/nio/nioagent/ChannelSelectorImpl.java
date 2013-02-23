package org.ziptie.nio.nioagent;

import java.io.IOException;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import org.ziptie.nio.common.ILogger;
import org.ziptie.nio.common.tuple.Triple;
import org.ziptie.nio.nioagent.Interfaces.ChannelSelector;
import org.ziptie.nio.nioagent.Interfaces.KeyAttachment;
import org.ziptie.nio.nioagent.Interfaces.ManagedThread;


public class ChannelSelectorImpl implements ChannelSelector
{

    // -- fields
    private static ChannelSelectorImpl instance = null;
    BlockingQueue<Registrant> registrants;
    List<Registrant> registantsSnapshot;
    int numKeys;
    Selector selector;
    ManagedThread managedThread;
    ILogger logger;

    // -- constructors
    private ChannelSelectorImpl()
    {
        // do nothing
    }

    // -- public methods
    public synchronized static ChannelSelector getInstance(final ILogger logger)
    {
        if (null == instance)
        {
            instance = new ChannelSelectorImpl();
            instance.logger = logger;
            instance.registrants = new LinkedBlockingQueue<Registrant>();
            instance.registantsSnapshot = new LinkedList<Registrant>();
            instance.numKeys = 0;
            instance.possiblyOpenSelector();
            instance.managedThread = ManagedThreadImpl.createAndStart(instance.selectorRunnable(), "Selector");
        }
        return instance;
    }

    public void start()
    {
        possiblyOpenSelector();
        managedThread.start();
    }

    public void stop()
    {
        managedThread.stop();
        closeSelector();
    }

    public void register(SelectableChannel channel, int ops, KeyAttachment att)
    {
        putRegistrant(new Registrant(channel, ops, att));
        selector.wakeup();
    }

    // -- package-private methods
    void possiblyOpenSelector()
    {
        if (null == selector || !selector.isOpen())
        {
            openSelector();
        }
    }

    void openSelector()
    {
        try
        {
            selector = Selector.open();
            logger.debug("Opened selector.");
        }
        catch (IOException e)
        {
            throw new WrapperException(e);
        }
    }

    void putRegistrant(Registrant reg)
    {
        try
        {
            registrants.put(reg);
        }
        catch (InterruptedException e)
        {
            logger.error("Failed to put registrant on registrants queue.");
            throw new WrapperException(e);
        }
    }

    Runnable selectorRunnable()
    {
        return new Runnable()
        {
            public void run()
            {
                doSelectorSteps();
            }
        };
    }

    void doSelectorSteps()
    {
        try
        {
            processRegistrations();
            selectKeys();
            processSelectedKeys();
        }
        catch (WrapperException e)
        {
            logger.debug("Caught exception doing selector steps.", e);
        }
        catch (RuntimeException e)
        {
            // do nothing
        }
    }

    void processRegistrations()
    {
        registrants.drainTo(registantsSnapshot);
        for (Registrant registrant : registantsSnapshot)
        {
            registerChannel(registrant);
        }
        registantsSnapshot.clear();
    }

    void registerChannel(Registrant registrant)
    {
        try
        {
            registrant.channel().register(selector, registrant.ops(), registrant.att());
        }
        catch (ClosedChannelException e)
        {
            logger.error("Failed to register channel.", e);
        }
    }

    void selectKeys()
    {
        try
        {
            numKeys = selector.select();
        }
        catch (IOException e)
        {
            logger.error("Failed to select keys.", e);
        }
    }

    void processSelectedKeys()
    {
        if (0 < numKeys)
        {
            Set<SelectionKey> selectedKeys = selector.selectedKeys();
            for (SelectionKey key : selectedKeys)
            {
                control((KeyAttachment) key.attachment(), key);
            }
            selectedKeys.clear();
        }
    }

    void control(KeyAttachment att, SelectionKey key)
    {
        try
        {
            att.control(key);
        }
        catch (Exception e)
        {
            logger.debug("Caught exception controlling key.", e);
        }
    }

    void closeSelector()
    {
        try
        {
            selector.close();
        }
        catch (IOException e)
        {
            logger.error("Failed to close selector.", e);
        }
    }

    // -- inner classes
    private static class Registrant extends Triple<SelectableChannel, Integer, KeyAttachment>
    {
        Registrant(final SelectableChannel channel, final int ops, final KeyAttachment att)
        {
            super(channel, ops, att);
        }

        SelectableChannel channel()
        {
            return a;
        }

        int ops()
        {
            return b;
        }

        KeyAttachment att()
        {
            return c;
        }
    }

}
