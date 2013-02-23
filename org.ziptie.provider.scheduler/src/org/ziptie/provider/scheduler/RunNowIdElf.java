package org.ziptie.provider.scheduler;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.transaction.Transaction;

import org.ziptie.provider.scheduler.internal.SchedulerActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * ExecutionIdElf
 */
public final class RunNowIdElf
{
    private static final int INITIAL_VALUE = 1000;

    private RunNowIdElf()
    {
        // private constructor
    }

    /**
     * Generate an execution id.  This method assumes there is already an enclosing transaction.
     *
     * @return a new execution id
     * @throws SQLException throws if there was an exception generating the execution id
     */
    public static int getExecutionId() throws SQLException
    {
        int id = INITIAL_VALUE;

        Transaction transaction = TransactionElf.suspend();

        try
        {
            // New transaction
            TransactionElf.beginOrJoinTransaction();
            try
            {
                Connection connection = SchedulerActivator.getDataSource().getConnection();
                Statement stmt = connection.createStatement();
                ResultSet resultSet = stmt.executeQuery("SELECT seq_value FROM persistent_key_gen WHERE seq_name='RunNow_seq'");

                String sql = null;
                if (resultSet.next())
                {
                    id = resultSet.getInt(1);
                    sql = "UPDATE persistent_key_gen SET seq_value=" + (id + 1) + " WHERE seq_name='RunNow_seq'";
                }
                else
                {
                    sql = "INSERT INTO persistent_key_gen(seq_name, seq_value) VALUES ('RunNow_seq', " + (id + 1) + ")";
                }
                resultSet.close();

                stmt.executeUpdate(sql);
                stmt.close();
                TransactionElf.commit();
                connection.close();

                return id;
            }
            catch (SQLException e)
            {
                TransactionElf.rollback();
                throw e;
            }
        }
        finally
        {
            TransactionElf.resume(transaction);
        }
    }
}
