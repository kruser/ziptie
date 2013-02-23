package org.ziptie.provider.devices.internal;

import static org.ziptie.provider.devices.DeviceResolutionElf.populatePageData;

import org.hibernate.Criteria;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Restrictions;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Device resolver for IP Address queries.
 */
public class IpAddressResolutionScheme implements IDeviceResolutionScheme
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
    private PageData cidrSearch(String networkAddress, PageData pageData, String sortColumn, boolean descending)
    {
        Long[] hiLoRange = NetworkAddressElf.getHiLoRange(networkAddress);

        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();
        Criteria criteria = session.createCriteria(ZDeviceLite.class).setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());

        if (hiLoRange[0] == null)
        {
            // If the HI word range is irrelevant this is either an IPv4 query, or a IPv6
            // query with a CIDR more than /63
            criteria.add(Restrictions.between(ATTR_IP_LOW, hiLoRange[2], hiLoRange[1]));
            // If its an IPv6 query and the range is in the lower word, then the high word
            // must be an exact match
            if (NetworkAddressElf.isIPv6AddressOrMask(networkAddress))
            {
                String[] ipAndCidr = networkAddress.split("/"); //$NON-NLS-1$
                long[] hiLo = NetworkAddressElf.getHiLo(ipAndCidr[0]);
                criteria.add(Restrictions.eq(ATTR_IP_HIGH, hiLo[0]));
            }
        }
        else
        {
            // If the HI word is relevant this is an IPv6 query where the CIDR is
            // less than /64
            criteria.add(Restrictions.between(ATTR_IP_HIGH, hiLoRange[1], hiLoRange[0]));
        }

        return populatePageData(pageData, criteria, sortColumn, descending);
    }

    /**
     * @param networkAddress
     * @param pageData
     * @param sortColumn
     * @param descending
     * @return
     */
    private PageData specificIpSearch(String networkAddress, PageData pageData, String sortColumn, boolean descending)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();
        Criteria criteria = session.createCriteria(ZDeviceLite.class).setFirstResult(pageData.getOffset()).setMaxResults(pageData.getPageSize());

        if (networkAddress != null && networkAddress.trim().length() > 0)
        {
            criteria.add(Restrictions.eq(ATTR_IP_ADDRESS, NetworkAddressElf.toDatabaseString(networkAddress.trim())));
        }

        return populatePageData(pageData, criteria, sortColumn, descending);
    }
}
