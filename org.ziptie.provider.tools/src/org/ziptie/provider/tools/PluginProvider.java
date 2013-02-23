package org.ziptie.provider.tools;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.ProjectionList;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.hibernate.transform.Transformers;
import org.ziptie.provider.scheduler.ExecutionData;
import org.ziptie.provider.tools.internal.PluginsActivator;

/**
 * ToolsProvider
 */
public class PluginProvider implements IPluginProvider
{
    private static final String EXECUTION_ID = "executionId"; //$NON-NLS-1$

    private String repositoryRoot;

    /**
     * Default constructor.
     */
    public PluginProvider()
    {
        repositoryRoot = ScriptBindingElf.getFilestoreRoot();
    }

    /** {@inheritDoc} */
    public List<PluginDescriptor> getPluginDescriptors()
    {
        ArrayList<PluginDescriptor> list = new ArrayList<PluginDescriptor>();

        List<IPluginManager> pluginManagers = PluginsActivator.getPluginManagers();
        for (IPluginManager manager : pluginManagers)
        {
            Set<PluginDescriptor> pluginDescriptors = manager.getPluginDescriptors();
            if (pluginDescriptors != null)
            {
                list.addAll(pluginDescriptors);
            }
        }

        return list;
    }

    /** {@inheritDoc} */
    @SuppressWarnings({ "unchecked" })
    public List<ToolRunDetails> getExecutionDetails(int executionId)
    {
        Session session = PluginsActivator.getSessionFactory().getCurrentSession();

        // Use projections to avoid loading Blob.  There is no lazy load on an
        // individual property in Hibernate -- only on collections one-to-X relationships.
        // The forums recommended this approach.  Note that there is a bug in Hibernate
        // that we are working around here -- but NOT MAPPING the executionId property
        // with an 'alias'.  Trying to do so seems to yield an invalid query from
        // Hibernate.  This means we have to set the executionId on the objects
        // manually after retrieval.  Gross.
        Criteria criteria = session.createCriteria(ToolRunDetails.class)
            .add(Restrictions.eq(EXECUTION_ID, executionId));
        ProjectionList projList = Projections.projectionList();
        projList.add(Projections.property("id"), "id") //$NON-NLS-1$ //$NON-NLS-2$
                .add(Projections.property(EXECUTION_ID))
                .add(Projections.property("device"), "device") //$NON-NLS-1$ //$NON-NLS-2$
                .add(Projections.property("error"), "error") //$NON-NLS-1$ //$NON-NLS-2$
                .add(Projections.property("gridData"), "gridData") //$NON-NLS-1$ //$NON-NLS-2$
                .add(Projections.property("startTime"), "startTime") //$NON-NLS-1$ //$NON-NLS-2$
                .add(Projections.property("endTime"), "endTime"); //$NON-NLS-1$ //$NON-NLS-2$
        criteria.setProjection(projList);
        criteria.setResultTransformer(Transformers.aliasToBean(ToolRunDetails.class));
        List<ToolRunDetails> list = criteria.list();

        for (ToolRunDetails details : list)
        {
            details.setExecutionId(executionId);
        }

        return list;
    }

    /** {@inheritDoc} */
    public PluginExecRecord getExecutionRecord(int executionId)
    {
        Session session = PluginsActivator.getSessionFactory().getCurrentSession();

        ExecutionData tmp = new ExecutionData();
        tmp.setId(executionId);

        Criteria criteria = session.createCriteria(PluginExecRecord.class).add(Restrictions.eq("executionData", tmp)); //$NON-NLS-1$
        Object uniqueResult = criteria.uniqueResult();

        return (PluginExecRecord) uniqueResult;
    }

    /** {@inheritDoc} */
    public List<String> getFileStoreEntries(String basePath)
    {
        ArrayList<String> entries = new ArrayList<String>();
        if (!basePath.startsWith("/") || basePath.contains("..")) //$NON-NLS-1$ //$NON-NLS-2$
        {
            return entries;
        }

        File file = new File(repositoryRoot + basePath);
        if (file.isDirectory() && file.exists())
        {
            for (File dirFile : file.listFiles())
            {
                entries.add(dirFile.getName() + (dirFile.isDirectory() ? "/" : "")); //$NON-NLS-1$ //$NON-NLS-2$
            }
        }

        return entries;
    }
}
