package org.ziptie.provider.devices.internal;

import static org.ziptie.provider.devices.DeviceResolutionElf.populatePageData;

import java.util.List;

import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Device resolver for IP Address queries.
 */
public class InterfaceIpResolutionScheme extends BaseResolutionScheme implements IDeviceResolutionScheme
{
    /** {@inheritDoc} */
    public PageData resolve(String scheme, String networkAddress, PageData pageData, String sortColumn, boolean descending)
    {
        boolean own = TransactionElf.beginOrJoinTransaction();
        boolean success = false;
        try
        {
            PageData result;

            if (networkAddress.indexOf('/') > 0)
            {
                result = cidrSearch(networkAddress.trim(), pageData, sortColumn, descending);
            }
            else
            {
                if (networkAddress.length() > 0 && !NetworkAddressElf.isValidAddress(networkAddress))
                {
                    result = new PageData();
                }
                else
                {
                    result = specificIpSearch(networkAddress, pageData, sortColumn, descending);
                }
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

    /**
     * @param networkAddress
     * @param pageData
     * @param sortColumn
     * @param descending
     * @return
     */
    @SuppressWarnings("nls")
    private PageData cidrSearch(String networkAddress, PageData pageData, String sortColumn, boolean descending)
    {
        Long[] hiLoRange = NetworkAddressElf.getHiLoRange(networkAddress);

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

        StringBuilder fromClause = new StringBuilder(beginFromClause());
        if (hiLoRange[0] == null)
        {
            // If the HI word range is irrelevant this is either an IPv4 query, or a IPv6
            // query with a CIDR more than /63
            if (NetworkAddressElf.isIPv6AddressOrMask(networkAddress))
            {
                // If its an IPv6 query and the range is in the lower word, then the high word
                // must be an exact match
                String[] ipAndCidr = networkAddress.split("/"); //$NON-NLS-1$
                long[] hiLo = NetworkAddressElf.getHiLo(ipAndCidr[0]);
                fromClause.append(String.format("WHERE ((d.ip_low BETWEEN %d AND %d AND d.ip_high=%d ) OR (i.ip_low BETWEEN %d AND %d AND i.ip_high=%d))",
                                                hiLoRange[2], hiLoRange[1], hiLo[0], hiLoRange[2], hiLoRange[1], hiLo[0]));
            }
            else
            {
                fromClause.append(String.format("WHERE ((d.ip_low BETWEEN %d AND %d) OR (i.ip_low BETWEEN %d AND %d))", hiLoRange[2], hiLoRange[1],
                                                hiLoRange[2], hiLoRange[1]));
            }
        }
        else
        {
            // If the HI word is relevant this is an IPv6 query where the CIDR is
            // less than /64
            fromClause.append(String.format("WHERE ((d.ip_high BETWEEN %d AND %d ) OR (i.ip_high BETWEEN %d AND %d))", hiLoRange[1], hiLoRange[0],
                                            hiLoRange[1], hiLoRange[0]));
        }
        return runQuery(pageData, sortColumn, descending, session, fromClause.toString());
    }

    /**
     * @param networkAddress
     * @param pageData
     * @param sortColumn
     * @param descending
     * @return
     */
    @SuppressWarnings("nls")
    private PageData specificIpSearch(String networkAddress, PageData pageData, String sortColumn, boolean descending)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();
        String databaseIp = NetworkAddressElf.toDatabaseString(networkAddress.trim());

        if (networkAddress != null && networkAddress.trim().length() > 0)
        {
            String fromClause = String.format(beginFromClause() + "WHERE (d.ip_address='%s' OR i.ip_address='%s')", databaseIp, databaseIp);
            return runQuery(pageData, sortColumn, descending, session, fromClause);
        }
        else
        {
            Criteria criteria = session.createCriteria(ZDeviceLite.class).setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());

            if (networkAddress != null && networkAddress.trim().length() > 0)
            {
                criteria.add(Restrictions.eq(ATTR_IP_ADDRESS, NetworkAddressElf.toDatabaseString(networkAddress.trim())));
            }

            return populatePageData(pageData, criteria, sortColumn, descending);
        }
    }

    @SuppressWarnings("nls")
    private PageData runQuery(PageData pageData, String sortColumn, boolean descending, Session session, String fromClause)
    {
        String queryText = "SELECT DISTINCT d.device_id " + fromClause;

        Query query = session.createSQLQuery(queryText).setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());
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
            query = session.createSQLQuery("SELECT count(DISTINCT d.device_id) " + fromClause);
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

    /**
     * Returns the first part of the FROM clause
     * @return
     */
    @SuppressWarnings("nls")
    private String beginFromClause()
    {
        return "FROM device d LEFT OUTER JOIN device_interface_ips i on d.device_id=i.device_id ";
    }
}
