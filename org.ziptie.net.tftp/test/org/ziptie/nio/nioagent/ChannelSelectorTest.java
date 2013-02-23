/**
 * 
 */
package org.ziptie.nio.nioagent;

import java.io.IOException;
import java.nio.channels.Pipe;
import java.nio.channels.SelectionKey;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.ManagedThreadImpl;
import org.ziptie.nio.nioagent.Interfaces.KeyAttachment;

import junit.framework.TestCase;


/**
 * @author bedwards
 * 
 */
public class ChannelSelectorTest extends TestCase implements SystemLogger.Injector
{

    // -- member fields
    private ChannelSelectorImpl channelSelectorImpl;

    // -- constructors
    public ChannelSelectorTest(String arg0)
    {
        super(arg0);
    }

    // -- protected methods
    protected void setUp() throws Exception
    {
        channelSelectorImpl = (ChannelSelectorImpl) ChannelSelectorImpl.getInstance(logger);
    }

    public final void testChannelSelector() throws InterruptedException, IOException, IllegalAccessException, NoSuchFieldException
    {
        assertNotNull(channelSelectorImpl);
        channelSelectorImpl.stop();
        channelSelectorImpl.start();
        assertRunning(channelSelectorImpl);

        assertNoneRegistered(channelSelectorImpl);
        channelSelectorImpl.register(Pipe.open().sink().configureBlocking(false), SelectionKey.OP_WRITE, new MockAttachment());
        Thread.sleep(500);
        assertSomeRegistered(channelSelectorImpl);

        assertRunning(channelSelectorImpl);
        channelSelectorImpl.stop();
        assertStopped(channelSelectorImpl);
    }

    // -- private methods
    private Thread getThread(ChannelSelectorImpl selector) throws IllegalAccessException, NoSuchFieldException
    {
        return ((ManagedThreadImpl) channelSelectorImpl.managedThread).thread;
    }

    private void assertRunning(ChannelSelectorImpl selector) throws IllegalAccessException, NoSuchFieldException
    {
        assertNotNull(getThread(selector));
    }

    private void assertStopped(ChannelSelectorImpl selector) throws IllegalAccessException, NoSuchFieldException
    {
        assertNull(getThread(selector));
    }

    private void assertEmptyKeySetIs(boolean bool, ChannelSelectorImpl cSelector) throws IllegalAccessException, NoSuchFieldException
    {
        assertEquals(bool, channelSelectorImpl.selector.keys().isEmpty());
    }

    private void assertNoneRegistered(ChannelSelectorImpl cSelector) throws IllegalAccessException, NoSuchFieldException
    {
        assertEmptyKeySetIs(true, cSelector);
    }

    private void assertSomeRegistered(ChannelSelectorImpl cSelector) throws IllegalAccessException, NoSuchFieldException
    {
        assertEmptyKeySetIs(false, cSelector);
    }

    // -- inner classes
    private static class MockAttachment implements KeyAttachment
    {

        public void control(SelectionKey key)
        {
            key.interestOps(0);
        }

    }

}
