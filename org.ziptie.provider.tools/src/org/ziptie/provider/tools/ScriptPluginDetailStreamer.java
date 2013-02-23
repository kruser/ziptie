package org.ziptie.provider.tools;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Criteria;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Restrictions;
import org.ziptie.provider.tools.internal.PluginsActivator;
import org.ziptie.zap.jta.TransactionElf;

/**
 * ScriptPluginDetailStreamer
 */
public class ScriptPluginDetailStreamer implements IPluginDetailStreamer
{
    private static final String HTTP_RECORD_ID = "recordId"; //$NON-NLS-1$

    /** {@inheritDoc} */
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
    {
        String recordId = req.getParameter(HTTP_RECORD_ID);

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

        try
        {
            Session session = PluginsActivator.getSessionFactory().getCurrentSession();
            Criteria criteria = session.createCriteria(ToolRunDetails.class);
            criteria.add(Restrictions.idEq(Integer.valueOf(recordId)));
            ToolRunDetails uniqueResult = (ToolRunDetails) criteria.uniqueResult();

            String details = uniqueResult.getDetails();
            if (details != null)
            {
                resp.setHeader("Content-type", "text/plain"); //$NON-NLS-1$ //$NON-NLS-2$
                PrintWriter writer = resp.getWriter();
                writer.print(details);
            }
        }
        finally
        {
            if (ownTransaction)
            {
                TransactionElf.commit();
            }
        }
    }
}
