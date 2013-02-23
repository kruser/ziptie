package org.ziptie.provider.devices.internal;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;
import org.hibernate.metadata.ClassMetadata;
import org.hibernate.persister.entity.SingleTableEntityPersister;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Device resolver for tag queries.
 */
public class TagResolutionScheme extends BaseResolutionScheme implements IDeviceResolutionScheme
{
    /** {@inheritDoc} */
    public PageData resolve(String scheme, String tagExpression, PageData pageData, String sortColumn, boolean descending)
    {
        boolean own = TransactionElf.beginOrJoinTransaction();
        boolean success = false;
        try
        {
            PageData result;
            if (tagExpression.trim().length() == 0)
            {
                result = searchByNoTag(pageData, sortColumn, descending);
            }
            else if (tagExpression.indexOf("OR") > 0) //$NON-NLS-1$
            {
                result = searchByTagOr(tagExpression, pageData, sortColumn, descending);
            }
            else
            {
                result = searchByTagAnd(tagExpression, pageData, sortColumn, descending);
            }

            success = true;
            return result;
        }
        finally
        {
            if (own)
            {
                if (success)
                {
                    TransactionElf.commit();
                }
                else
                {
                    TransactionElf.rollback();
                }
            }
        }
    }

    @SuppressWarnings("nls")
    private PageData searchByTagOr(String tagExpression, PageData pageData, String sortColumn, boolean descending)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        // this from clause is shared by the select and count queries
        StringBuilder fromClause = new StringBuilder();
        fromClause.append("FROM device d, device_tag m, tag t ").append("WHERE m.device_id = d.device_id ").append("AND t.tag_id = m.tag_id AND ")
                  .append("t.tag_lower in (");
        String[] tags = tagExpression.split("OR");
        for (int i = 0; i < tags.length; i++)
        {
            fromClause.append("'").append(tags[i].toLowerCase().trim()).append("'");
            if (i + 1 != tags.length)
            {
                fromClause.append(",");
            }
        }
        fromClause.append(")");

        // only toString the builder once.
        String strFromClause = fromClause.toString();

        // Select the device IDs.
        Query query = session.createSQLQuery("SELECT d.device_id " + strFromClause).setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());

        List<?> deviceIds = query.list();
        if (deviceIds == null || deviceIds.isEmpty())
        {
            pageData.setDevices(new ZDeviceLite[0]);
            pageData.setTotal(0);

            return pageData;
        }

        if (pageData.getOffset() == 0)
        {
            // Set the total result size into the page data.
            query = session.createSQLQuery("SELECT count(d.device_id) " + strFromClause);
            pageData.setTotal(getCount(query));
        }

        // Load the device objects.
        Criteria criteria = session.createCriteria(ZDeviceLite.class).add(Restrictions.in(ATTR_DEVICE_ID, deviceIds));

        if (sortColumn != null)
        {
            criteria.addOrder((descending ? Order.desc(sortColumn.trim()) : Order.asc(sortColumn.trim())));
        }

        List<?> devices = criteria.list();

        pageData.setDevices(devices.toArray(new ZDeviceLite[0]));
        return pageData;
    }

    @SuppressWarnings("nls")
    private PageData searchByTagAnd(String tagExpression, PageData pageData, String sortColumn, boolean descending)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        // this from clause is shared by the select and count queries
        String fromClause = createFromClause(tagExpression);

        // Select the device IDs.
        Query query = session.createSQLQuery("SELECT s0.device_id " + fromClause).setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());

        List<?> deviceIds = query.list();
        if (deviceIds == null || deviceIds.isEmpty())
        {
            pageData.setDevices(new ZDeviceLite[0]);
            pageData.setTotal(0);

            return pageData;
        }

        if (pageData.getOffset() == 0)
        {
            // Set the total result size into the page data.
            query = session.createSQLQuery("SELECT count(s0.device_id) " + fromClause);
            pageData.setTotal(getCount(query));
        }

        // Load the device objects.
        Criteria criteria = session.createCriteria(ZDeviceLite.class).add(Restrictions.in(ATTR_DEVICE_ID, deviceIds));

        if (sortColumn != null)
        {
            criteria.addOrder((descending ? Order.desc(sortColumn.trim()) : Order.asc(sortColumn.trim())));
        }

        List<?> devices = criteria.list();

        pageData.setDevices(devices.toArray(new ZDeviceLite[0]));
        return pageData;
    }

    @SuppressWarnings("nls")
    private String createFromClause(String tagExpression)
    {
        StringBuilder fromClause = new StringBuilder();
        fromClause.append("FROM ");
        String[] tags = tagExpression.split(tagExpression.indexOf("AND") > 0 ? "AND" : " ");
        for (int i = 0; i < tags.length; i++)
        {
            fromClause.append(String.format("(SELECT device_id FROM device_tag dt, tag t WHERE t.tag_lower='%s' AND dt.tag_id=t.tag_id) AS s%d",
                                            tags[i].toLowerCase().trim(), i));
            if (i + 1 != tags.length)
            {
                fromClause.append(",");
            }
        }
        if (tags.length > 1)
        {
            fromClause.append(" WHERE ");
            for (int i = 0; i < tags.length - 1; i++)
            {
                fromClause.append(String.format("s0.device_id = s%d.device_id ", i + 1));
                if (i + 2 != tags.length)
                {
                    fromClause.append(" AND ");
                }
            }
        }
        return fromClause.toString();
    }

    @SuppressWarnings("nls")
    private PageData searchByNoTag(PageData pageData, String sortColumn, boolean descending)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        StringBuilder sortClause = new StringBuilder();
        StringBuilder fromClause = new StringBuilder();
        fromClause.append("FROM device d LEFT OUTER JOIN device_tag dt ON d.device_id=dt.device_id ").append("WHERE dt.device_id IS NULL");

        if (sortColumn != null)
        {
            ClassMetadata classMetadata = DeviceProviderActivator.getSessionFactory().getClassMetadata(ZDeviceLite.class);
            SingleTableEntityPersister step = (SingleTableEntityPersister) classMetadata;
            String[] propertyColumnNames = step.getPropertyColumnNames(sortColumn);
            if (propertyColumnNames != null && propertyColumnNames.length > 0)
            {
                sortClause.append(" ORDER BY ").append(propertyColumnNames[0]).append(descending ? " DESC" : " ASC");
            }
        }

        Query query = session.createSQLQuery("SELECT d.device_id " + fromClause + sortClause).setFirstResult(pageData.getOffset())
                             .setMaxResults(pageData.getPageSize());

        List<?> deviceIds = query.list();
        if (deviceIds == null || deviceIds.isEmpty())
        {
            pageData.setDevices(new ZDeviceLite[0]);
            pageData.setTotal(0);

            return pageData;
        }

        if (pageData.getOffset() == 0)
        {
            // Set the total result size into the page data.
            query = session.createSQLQuery("SELECT count(d.device_id) " + fromClause);
            pageData.setTotal(getCount(query));
        }

        // Load the device objects.
        Criteria criteria = session.createCriteria(ZDeviceLite.class).add(Restrictions.in(ATTR_DEVICE_ID, deviceIds));

        if (sortColumn != null)
        {
            criteria.addOrder((descending ? Order.desc(sortColumn.trim()) : Order.asc(sortColumn.trim())));
        }

        List<?> devices = criteria.list();

        pageData.setDevices(devices.toArray(new ZDeviceLite[0]));
        return pageData;
    }
}
