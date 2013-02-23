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

package org.ziptie.net.sim.repository;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

/**
 * Interface into the recording repository
 */
public class RecordingRepository
{
    private static final Logger LOG = Logger.getLogger(RecordingRepository.class);

    private Connection conn;

    /**
     * Opens a connection to the recording repository.
     * @throws Exception
     */
    public RecordingRepository(String driver, String url, String username, String password) throws Exception
    {
        Class.forName(driver);
        conn = DriverManager.getConnection(url, username, password);
    }

    /**
     * Closes the connection to the repository.
     */
    public void close()
    {
        try
        {
            conn.close();
        }
        catch (SQLException e)
        {
            LOG.warn("Error closing connection!", e);
        }
    }

    /**
     * Downloads and saves recordings to the 'recordings' directory.
     * <p>(returns: {@link List}&lt;{@link File}&gt;)
     * @param directory The path on the local filesystem to download the recordings to.
     * @param where The where clause.
     * @return A List of Files for the new recordings 
     * @throws IOException
     */
    public List download(File directory, String where) throws Exception
    {
        String query = "SELECT r.filename, r.file " + "FROM recordings as r ";

        if (where != null && where.length() > 0)
        {
            query += "WHERE " + where + " ";
        }

        Statement stmt = null;
        try
        {
            stmt = conn.createStatement();
            ResultSet result = stmt.executeQuery(query);

            List ret = new ArrayList();
            byte[] bbuf = new byte[2048];
            while (result.next())
            {
                String filename = result.getString("r.filename");
                if (filename == null || filename.length() == 0)
                {
                    LOG.info("Recording has no filename, skipping download.");
                    continue;
                }
                InputStream is = new BufferedInputStream(result.getBinaryStream("r.file"));

                File file = new File(directory, filename);
                FileOutputStream fos = new FileOutputStream(file);
                ret.add(file);
                for (int len; (len = is.read(bbuf)) > 0;)
                {
                    fos.write(bbuf, 0, len);
                }
                fos.close();
                is.close();
            }
            return ret;
        }
        finally
        {
            if (stmt != null)
            {
                try
                {
                    stmt.close();
                }
                catch (SQLException e1)
                {
                    LOG.warn("Error closing statement!", e1);
                }
            }
        }

    }
}
