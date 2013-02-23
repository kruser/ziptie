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

package org.ziptie.provider.scheduler.internal;

import java.sql.Connection;
import java.sql.SQLException;

import org.quartz.utils.ConnectionProvider;

/**
 * CustomConnectionProvider
 */
public class CustomConnectionProvider implements ConnectionProvider
{
    /**
     * Default constructor.
     */
    public CustomConnectionProvider()
    {
    }

    /** {@inheritDoc} */
    public Connection getConnection() throws SQLException
    {
        try
        {
            return SchedulerActivator.getDataSource().getConnection();
        }
        catch (Exception e)
        {
            throw new SQLException("Unable to obtain DataSource: " + e.getMessage()); //$NON-NLS-1$
        }
    }

    /** {@inheritDoc} */
    public void shutdown() throws SQLException
    {
    }
}
