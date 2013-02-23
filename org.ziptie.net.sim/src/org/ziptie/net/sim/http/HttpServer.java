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

package org.ziptie.net.sim.http;

import java.io.IOException;
import java.net.BindException;
import java.net.ServerSocket;

import org.apache.log4j.Logger;
import org.ziptie.net.sim.DeviceSimulator;

import simple.http.ProtocolHandler;
import simple.http.connect.Connection;
import simple.http.connect.ConnectionFactory;
import simple.http.load.LoaderEngine;
import simple.http.load.LoadingException;
import simple.http.serve.HandlerFactory;

/**
 * A simple HTTP Server which uses "Simple"
 */
public class HttpServer
{
    private static final Logger LOG = Logger.getLogger(HttpServer.class);

    public void start()
    {
        try
        {
            int port = 80;
            String strPort = DeviceSimulator.getProperty(DeviceSimulator.HTTP_PORT);
            if (strPort != null)
            {
                try
                {
                    port = Integer.parseInt(strPort);
                }
                catch (NumberFormatException e)
                {
                    LOG.warn("Invalid port number, using default (" + port + "): " + strPort, e);
                }
            }

            LoaderEngine engine = new LoaderEngine();
            engine.load("config", ConfigurationHttpService.class.getName());
            engine.load("state", StateHttpService.class.getName());

            engine.link("/state/*", "state");
            engine.link("/config/*", "config");
            engine.link("/", "config");

            ProtocolHandler handler = HandlerFactory.getInstance(engine);

            Connection connection = ConnectionFactory.getConnection(handler);
            connection.connect(new ServerSocket(port));
        }
        catch (BindException be)
        {
            LOG.warn("Unable to bind to address for the HTTP server.", be);
        }
        catch (IOException e)
        {
            LOG.error("Error starting HTTP server.", e);
        }
        catch (LoadingException e)
        {
            LOG.error("Error starting HTTP server.", e);
        }
    }
}
