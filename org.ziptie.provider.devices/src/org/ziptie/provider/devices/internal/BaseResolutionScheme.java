package org.ziptie.provider.devices.internal;

import java.math.BigInteger;

import org.hibernate.Query;

/**
 * BaseResolutionScheme
 */
public abstract class BaseResolutionScheme
{
    /**
     * Get the count from the supplied count query.
     *
     * @param query the count query
     * @return the count
     */
    protected int getCount(Query query)
    {
        Object uniqueResult = query.uniqueResult();
        if (uniqueResult instanceof Integer)
        {
            return (Integer) uniqueResult;
        }
        else if (uniqueResult instanceof Long)
        {
            return ((Long) uniqueResult).intValue();
        }
        else
        {
            return ((BigInteger) uniqueResult).intValue();
        }
    }
}
