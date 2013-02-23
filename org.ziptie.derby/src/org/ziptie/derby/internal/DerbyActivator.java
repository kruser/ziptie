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
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 */

package org.ziptie.derby.internal;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;

import org.apache.derby.drda.NetworkServerControl;
import org.apache.log4j.Logger;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

/**
 * DerbyActivator
 */
public class DerbyActivator implements BundleActivator
{
    private static Logger LOGGER = Logger.getLogger(DerbyActivator.class);

    private NetworkServerControl control;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        loadDatabaseProps();

        String databaseName = System.getProperty("database");
        if (databaseName != null && !"derby".equalsIgnoreCase(databaseName)) //$NON-NLS-1$
        {
            return;
        }

        LOGGER.info("Starting Apache Derby Server");

        String configRoot = System.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        String derbyConfig = configRoot + "derby/derby.properties"; //$NON-NLS-1$

        System.getProperties().load(URI.create(derbyConfig).toURL().openStream());

        control = new NetworkServerControl();
        control.start(new PrintWriter(System.out));
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        if (control != null)
        {
            LOGGER.info("Shutdown Apache Derby Server.");
            control.shutdown();
        }
    }

    // ----------------------------------------------------------------------
    //                    P R I V A T E   M E T H O D S
    // ----------------------------------------------------------------------

    /**
     * Load the database properties file into the System properties.
     *
     * @throws IOException thrown if there is an IO error
     */
    private void loadDatabaseProps() throws IOException
    {
        String configRoot = System.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        String dbConfig = configRoot + "database/db.properties"; //$NON-NLS-1$
        File dbConfigFile = new File(URI.create(dbConfig));
        if (dbConfigFile.isFile())
        {
            System.getProperties().load(new FileInputStream(dbConfigFile));
        }
        else
        {
            System.setProperty("database", "derby");
        }
    }
}
