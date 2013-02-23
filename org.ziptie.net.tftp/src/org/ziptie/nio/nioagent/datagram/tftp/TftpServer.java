package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.nioagent.datagram.tftp.DataConsumer.Factory;

public interface TftpServer
{
    void start();

    void restart(Factory factory, org.ziptie.nio.nioagent.datagram.tftp.DataProducer.Factory factory2, SecurityManager manager, EventListener listener);

    void stop();

    String getDirectory();

    String getIpAddress();

    int getPort();
    
    /**
     * Returns true if a file is required to exist before accepting a 'put'
     * 
     * @return the value
     */
    boolean isRequiredFileExists();
}
