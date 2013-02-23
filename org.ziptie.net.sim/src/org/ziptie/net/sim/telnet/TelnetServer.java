/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim.telnet;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;

import org.apache.log4j.Logger;
import org.ziptie.net.sim.DeviceSimulator;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.exceptions.NoSuchProtocolSessionException;
import org.ziptie.net.sim.operations.IOperation;
import org.ziptie.net.sim.operations.MediarySession;
import org.ziptie.net.sim.operations.OperationManager;
import org.ziptie.net.sim.util.IpAddress;

/**
 * A Simple Telnet Server
 */
public class TelnetServer
{
    private static final Logger LOG = Logger.getLogger(TelnetServer.class);

    private TelnetThreadPool threadPool = TelnetThreadPool.getInstance();

    public void start()
    {
        int telnetPort = 23;
        int telnetWithHandshakePort = 8023;

        String strPort = DeviceSimulator.getProperty(DeviceSimulator.TELNET_PORT);
        if (strPort != null)
        {
            try
            {
                telnetPort = Integer.parseInt(strPort);
            }
            catch (NumberFormatException e)
            {
                LOG.warn("Invalid telnet port, using default (" + telnetPort + "): " + strPort, e);
            }
        }
        strPort = DeviceSimulator.getProperty(DeviceSimulator.TELNET_HANDSHAKE_PORT);
        if (strPort != null)
        {
            try
            {
                telnetWithHandshakePort = Integer.parseInt(strPort);
            }
            catch (NumberFormatException e)
            {
                LOG.warn("Invalid telnet handshake port, using default (" + telnetWithHandshakePort + "): " + strPort, e);
            }
        }

        startListener(telnetPort, new IAccepter()
        {
            private ByteBuffer byteBuffer = ByteBuffer.allocateDirect(2048);

            public void accept(Selector selector, SocketChannel channel) throws IOException
            {
                Socket socket = channel.socket();

                InetAddress localInetAddress = socket.getLocalAddress();

                IpAddress localIpAddress = IpAddress.getIpAddress(localInetAddress, localInetAddress.getHostAddress());
                IpAddress remoteIpAddress = IpAddress.getIpAddress(socket.getInetAddress(), null);

                try
                {
                    IOperation op = OperationManager.getInstance().getCurrentOperation(null, localIpAddress, remoteIpAddress);
                    ITelnetSession session = (ITelnetSession) op.getProtocolSession(ITelnetSession.PROTOCOL_NAME);

                    channel.configureBlocking(false);
                    SelectionKey key = channel.register(selector, SelectionKey.OP_READ);

                    TelnetOutputHandler handler = new TelnetOutputHandler(key);
                    threadPool.open(session, handler);

                    key.attach(new Attachment(session, handler));
                }
                catch (NoSuchOperationException e)
                {
                    LOG.error("Error starting session.", e);
                    cleanUp(socket);
                }
                catch (NoSuchProtocolSessionException e)
                {
                    LOG.error("Error starting session.", e);
                    cleanUp(socket);
                }
            }

            public void read(Selector selector, SelectionKey key) throws IOException
            {
                Attachment attachment = (Attachment) key.attachment();

                SocketChannel channel = (SocketChannel) key.channel();
                int count = channel.read(byteBuffer);
                if (count > 0)
                {
                    byteBuffer.flip();
                    byte[] data = new byte[count];
                    byteBuffer.get(data, 0, count);

                    threadPool.input(attachment.session, data);
                }
                else if (count < 0)
                {
                    // Telnet Session closed

                    attachment.session.close();
                    key.channel().close();
                }
                byteBuffer.clear();
            }
        });
        LOG.info("TelnetServer started.");

        startListener(telnetWithHandshakePort, new IAccepter()
        {
            private ByteBuffer byteBuffer = ByteBuffer.allocateDirect(2048);

            public void accept(Selector selector, SocketChannel channel) throws IOException
            {
                channel.configureBlocking(false);
                SelectionKey key = channel.register(selector, SelectionKey.OP_READ);

                Socket socket = channel.socket();
                IpAddress localIpAddress = new IpAddress(socket.getLocalAddress());
                IpAddress remoteIpAddress = new IpAddress(socket.getInetAddress());

                key.attach(new MediarySession(localIpAddress, remoteIpAddress));
            }

            public void read(Selector selector, SelectionKey key) throws IOException
            {
                Object attachment = key.attachment();

                SocketChannel channel = (SocketChannel) key.channel();
                int count = channel.read(byteBuffer);
                if (count > 0)
                {
                    byteBuffer.flip();
                    byte[] data = new byte[count];
                    byteBuffer.get(data, 0, count);

                    if (attachment instanceof Attachment)
                    {
                        threadPool.input(((Attachment) attachment).session, data);
                    }
                    else if (attachment instanceof MediarySession)
                    {
                        MediarySession mediarySession = (MediarySession) attachment;
                        if (mediarySession.append(data))
                        {
                            try
                            {
                                IOperation operation = mediarySession.getOperation();
                                ITelnetSession telnetSession = (ITelnetSession) operation.getProtocolSession(ITelnetSession.PROTOCOL_NAME);

                                TelnetOutputHandler handler = new TelnetOutputHandler(key);
                                threadPool.open(telnetSession, handler);

                                key.attach(new Attachment(telnetSession, handler));
                            }
                            catch (NoSuchProtocolSessionException e)
                            {
                                LOG.error("There is no telnet session for this operation.", e);
                                channel.close();
                            }
                            catch (IOException e)
                            {
                                LOG.error("An error occured getting the operation.", e);
                                channel.close();
                            }
                            catch (NoSuchOperationException e)
                            {
                                LOG.error("Could not get operation.", e);
                                channel.close();
                            }
                        }
                    }
                }
                else if (count < 0)
                {
                    if (attachment instanceof Attachment)
                    {
                        ((Attachment) attachment).session.close();
                    }

                    key.channel().close();
                }
                byteBuffer.clear();
            }
        });
        LOG.info("HandshakeTelnetServer started.");
    }

    private void cleanUp(Socket sock)
    {
        try
        {
            sock.close();
        }
        catch (IOException ioe)
        {
            LOG.warn("Error occured while closing socket!", ioe);
        }
    }

    private void startListener(final int port, final IAccepter accepter)
    {
        Thread serverThread = new Thread("Sim-TelnetServer-" + port)
        {
            public void run()
            {
                SelectionKey key = null;
                try
                {
                    ServerSocketChannel ss = ServerSocketChannel.open();
                    Selector selector = Selector.open();

                    ss.socket().setReuseAddress(true);
                    ss.socket().setSoTimeout(0);
                    ss.socket().bind(new InetSocketAddress(port));
                    ss.configureBlocking(false);
                    ss.register(selector, SelectionKey.OP_ACCEPT);

                    while (!Thread.currentThread().isInterrupted())
                    {
                        selector.select(500);
                        Iterator it = selector.selectedKeys().iterator();
                        while (it.hasNext())
                        {
                            key = (SelectionKey) it.next();
                            try
                            {
                                if (key.isAcceptable())
                                {
                                    ServerSocketChannel sock = (ServerSocketChannel) key.channel();
                                    SocketChannel channel = sock.accept();

                                    accepter.accept(selector, channel);
                                }
                                else if (key.isReadable())
                                {
                                    if (((SocketChannel) key.channel()).isConnected())
                                    {
                                        accepter.read(selector, key);
                                    }
                                    else
                                    {
                                        LOG.warn("Closing leftover channel.");
                                        key.channel().close();
                                    }
                                }
                                else if (key.isWritable())
                                {
                                    SocketChannel channel = (SocketChannel) key.channel();
                                    if (channel.isConnected())
                                    {
                                        Attachment attachment = (Attachment) key.attachment();
                                        attachment.handler.writeAvailable();
                                    }
                                    else
                                    {
                                        LOG.warn("Closing leftover channel.");
                                        key.channel().close();
                                    }
                                }
                            }
                            catch (IOException e)
                            {
                                LOG.error("IOException caught while handling connection.", e);
                                key.cancel();
                            }
                            catch (Throwable t)
                            {
                                LOG.error("Unhandled throwable caught in telnet-server.", t);
                                key.cancel();
                            }
                            finally
                            {
                                it.remove();
                            }
                        }
                    }
                }
                catch (IOException e)
                {
                    LOG.error("Error creating telnet server socket!", e);
                    if (key != null)
                    {
                        key.cancel();
                    }
                }
            }
        };
        serverThread.start();
    }

    private class Attachment
    {
        int negotiationHits;
        boolean echo;
        ITelnetSession session;
        TelnetOutputHandler handler;

        Attachment(ITelnetSession session, TelnetOutputHandler handler)
        {
            this.session = session;
            this.handler = handler;
        }
    }

    private interface IAccepter
    {
        void accept(Selector selector, SocketChannel channel) throws IOException;

        void read(Selector selector, SelectionKey key) throws IOException;
    }
}
