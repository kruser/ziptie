package org.ziptie.nio.nioagent;

import java.nio.channels.Selector;

import org.ziptie.nio.nioagent.ChannelSelectorImpl;

public class ChannelSelectorAccessor
{
    public static Selector selector(ChannelSelectorImpl chanSelector)
    {
        return chanSelector.selector;
    }
}
