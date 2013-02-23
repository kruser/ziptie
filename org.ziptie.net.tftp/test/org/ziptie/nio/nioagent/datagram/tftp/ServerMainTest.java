package org.ziptie.nio.nioagent.datagram.tftp;

import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.nioagent.ChannelSelectorImpl;
import org.ziptie.nio.nioagent.datagram.tftp.ServerMain;
import org.ziptie.nio.nioagent.datagram.tftp.server.BasicTftpServer;

import junit.framework.TestCase;


public class ServerMainTest extends TestCase implements SystemLogger.Injector
{

    // -- constructors
    public ServerMainTest(String arg0)
    {
        super(arg0);
    }

    // -- public methods
    public void testServerMain()
    {
        ServerMain.main(new String[] {});
        BasicTftpServer.getInstance(logger).stop();
        ChannelSelectorImpl.getInstance(logger).stop();
    }

}
