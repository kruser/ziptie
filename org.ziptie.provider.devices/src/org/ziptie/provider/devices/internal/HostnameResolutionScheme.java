package org.ziptie.provider.devices.internal;

import static org.ziptie.provider.devices.DeviceResolutionElf.populatePageData;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.MatchMode;
import org.hibernate.criterion.Restrictions;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Device resolver for host-name queries.
 */
public class HostnameResolutionScheme implements IDeviceResolutionScheme
{
    /** {@inheritDoc} */
    public PageData resolve(String scheme, String hostname, PageData pageData, String sortColumn, boolean descending)
    {
        boolean own = TransactionElf.beginOrJoinTransaction();
        boolean success = false;
        try
        {
            PageData result = search(hostname, pageData, sortColumn, descending);
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

    private PageData search(String hostname, PageData pageData, String sortColumn, boolean descending)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();
        Criteria criteria = session.createCriteria(ZDeviceLite.class)
            .setFirstResult(pageData.getOffset())
            .setMaxResults(pageData.getPageSize());

        if (!hostname.equals(WILDCARD))
        {
            if (hostname.startsWith(WILDCARD))
            {
                if (hostname.endsWith(WILDCARD))
                {
                    String host = hostname.substring(1, hostname.length() - 1).trim();
                    criteria.add(Restrictions.ilike(ATTR_HOSTNAME, host, MatchMode.ANYWHERE));
                }
                else
                {
                    String host = hostname.substring(1).trim();
                    criteria.add(Restrictions.ilike(ATTR_HOSTNAME, host, MatchMode.END));
                }
            }
            else if (hostname.endsWith(WILDCARD))
            {
                String host = hostname.substring(0, hostname.length() - 1).trim();
                criteria.add(Restrictions.ilike(ATTR_HOSTNAME, host, MatchMode.START));
            }
            else if (hostname.trim().length() > 0)
            {
                criteria.add(Restrictions.eq(ATTR_HOSTNAME, hostname));
            }
        }

        return populatePageData(pageData, criteria, sortColumn, descending);
    }
}
