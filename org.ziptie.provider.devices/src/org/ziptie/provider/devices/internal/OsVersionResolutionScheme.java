package org.ziptie.provider.devices.internal;

import static org.ziptie.provider.devices.DeviceResolutionElf.populatePageData;

import java.io.IOException;
import java.io.StringReader;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;
import org.ziptie.net.adapters.AdapterMetadata;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ServerDeviceElf;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

import au.com.bytecode.opencsv.CSVReader;

/**
 * Device resolver for OS Version queries.
 */
public class OsVersionResolutionScheme implements IDeviceResolutionScheme
{
    /** {@inheritDoc} */
    public PageData resolve(String scheme, String data, PageData pageData, String sortColumn, boolean descending)
    {
        CSVReader reader = new CSVReader(new StringReader(data));
        String[] split;
        try
        {
            split = reader.readNext();
        }
        catch (IOException e)
        {
            // reading from a string should never fail.
            throw new RuntimeException(e);
        }
        String osType = split[0];
        String operator = (split.length > 1 ? split[1] : null);
        String version = (split.length > 2 ? split[2] : null);

        boolean own = TransactionElf.beginOrJoinTransaction();
        boolean success = false;
        try
        {
            PageData result = search(osType, operator, version, pageData, sortColumn, descending);
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

    private PageData search(String osType, String operator, String version, PageData pageData, String sortColumn, boolean descending)
    {

        AdapterMetadata adapterMetadata = DeviceProviderActivator.getAdapterService().getAdapterMetadata(osType);
        if (adapterMetadata != null)
        {
            Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();
            Criteria criteria = session.createCriteria(ZDeviceLite.class)
                .setFirstResult(pageData.getOffset())
                .setMaxResults(pageData.getPageSize());

            criteria.add(Restrictions.eq(ATTR_ADAPTER_ID, osType));
            if (version != null && version.trim().length() > 0)
            {
                String canonicalVersion = ServerDeviceElf.computeCononicalVersion(version, adapterMetadata.getSoftwareVersionRegEx());
                if (">".equals(operator)) //$NON-NLS-1$
                {
                    criteria.add(Restrictions.gt(ATTR_CANONICAL_OS_VERSION, canonicalVersion));
                }
                else if ("<".equals(operator)) //$NON-NLS-1$
                {
                    criteria.add(Restrictions.lt(ATTR_CANONICAL_OS_VERSION, canonicalVersion));
                }
                else if ("=".equals(operator)) //$NON-NLS-1$
                {
                    criteria.add(Restrictions.eq(ATTR_CANONICAL_OS_VERSION, canonicalVersion));
                }
                else if ("<=".equals(operator)) //$NON-NLS-1$
                {
                    criteria.add(Restrictions.le(ATTR_CANONICAL_OS_VERSION, canonicalVersion));
                }
                else if (">=".equals(operator)) //$NON-NLS-1$
                {
                    criteria.add(Restrictions.ge(ATTR_CANONICAL_OS_VERSION, canonicalVersion));
                }
                else
                {
                    throw new RuntimeException(String.format("Invalid operator '%s'supplied to search method.", operator)); //$NON-NLS-1$
                }
            }

            return populatePageData(pageData, criteria, sortColumn, descending);
        }

        return new PageData();
    }
}
