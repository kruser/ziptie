package org.ziptie.server.birt.internal;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import org.eclipse.birt.report.data.oda.jdbc.OdaJdbcDriver;
import org.eclipse.datatools.connectivity.oda.IConnection;
import org.eclipse.datatools.connectivity.oda.OdaException;

/**
 * ZJdbcDriver
 */
public class ZJdbcDriver extends OdaJdbcDriver
{
    /**
     * Default Constructor
     */
    public ZJdbcDriver()
    {
        super();
    }

    /** {@inheritDoc} */
    @Override
    public IConnection getConnection(String connectionClassName) throws OdaException
    {
        return new ZBirtConnection();
    }

    /**
     * ZBirtConnection
     */
    private class ZBirtConnection extends org.eclipse.birt.report.data.oda.jdbc.Connection
    {
        /** {@inheritDoc} */
        public void open(Properties connProperties) throws OdaException
        {
            try
            {
                Connection connection = BirtActivator.getDataSource().getConnection();
                super.jdbcConn = connection;
            }
            catch (SQLException se)
            {
                throw new OdaException(se);
            }
        }

        /** {@inheritDoc} */
        public void close() throws OdaException
        {
            if (jdbcConn == null)
            {
                return;
            }

            try
            {
                jdbcConn.close();
            }
            catch (SQLException se)
            {
                throw new OdaException(se);
            }
        }
    }
}
