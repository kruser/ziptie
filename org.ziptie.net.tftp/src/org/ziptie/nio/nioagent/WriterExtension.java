package org.ziptie.nio.nioagent;

import java.nio.channels.SelectionKey;

public interface WriterExtension
{

    void notIgnored();

    void readyToWrite(long delay);

    void cancel();

    void successfulWrite(SelectionKey key);

}
