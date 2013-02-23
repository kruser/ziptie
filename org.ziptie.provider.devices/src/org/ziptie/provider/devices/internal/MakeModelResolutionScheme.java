package org.ziptie.provider.devices.internal;

import static org.ziptie.provider.devices.DeviceResolutionElf.populatePageData;

import java.io.IOException;
import java.io.StringReader;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.MatchMode;
import org.hibernate.criterion.Restrictions;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

import au.com.bytecode.opencsv.CSVReader;

/**
 * Device resolver for Make/Model queries.
 */
public class MakeModelResolutionScheme implements IDeviceResolutionScheme
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

        String make = split[0];
        String model = (split.length > 1 ? split[1] : null);

        boolean own = TransactionElf.beginOrJoinTransaction();
        boolean success = false;
        try
        {
            PageData result = search(make, model, pageData, sortColumn, descending);
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

    private PageData search(String make, String model, PageData pageData, String sortColumn, boolean descending)
    {
        Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();
        Criteria criteria = session.createCriteria(ZDeviceLite.class)
                                   .add(Restrictions.eq("hardwareVendor", make)) //$NON-NLS-1$
                                   .setFirstResult(pageData.getOffset()).
                                   setMaxResults(pageData.getPageSize());

        if (model != null && model.trim().length() > 0)
        {
            String trimModel = model.trim();
            if (!trimModel.equals(WILDCARD))
            {
                if (trimModel.startsWith(WILDCARD))
                {
                    if (trimModel.endsWith(WILDCARD))
                    {
                        trimModel = trimModel.substring(1, trimModel.length() - 1).trim();
                        criteria.add(Restrictions.like(ATTR_MODEL, trimModel, MatchMode.ANYWHERE));
                    }
                    else
                    {
                        trimModel = trimModel.substring(1).trim();
                        criteria.add(Restrictions.ilike(ATTR_MODEL, trimModel, MatchMode.END));
                    }
                }
                else if (trimModel.endsWith(WILDCARD))
                {
                    trimModel = trimModel.substring(0, trimModel.length() - 1).trim();
                    criteria.add(Restrictions.ilike(ATTR_MODEL, trimModel, MatchMode.START));
                }
                else
                {
                    criteria.add(Restrictions.eq(ATTR_MODEL, trimModel));
                }
            }
        }

        return populatePageData(pageData, criteria, sortColumn, descending);
    }
}
