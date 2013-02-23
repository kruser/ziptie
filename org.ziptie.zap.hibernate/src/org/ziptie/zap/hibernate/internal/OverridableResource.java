package org.ziptie.zap.hibernate.internal;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;

/**
 * An overridable resource representing a single 'resource' from the
 * PersistenceUnit extension point.
 */
class OverridableResource
{
    private URL resource;
    private Map<String, URL> dialectToResourceMap;

    OverridableResource(URL resource)
    {
        this.resource = resource;
    }

    URL getResource(String dialect)
    {
        URL rval = null;
        if (dialectToResourceMap != null)
        {
            rval = dialectToResourceMap.get(dialect);
        }

        if (rval == null)
        {
            rval = resource;
        }

        return rval;
    }

    void addOverride(String dialect, URL rsrc)
    {
        if (dialectToResourceMap == null)
        {
            dialectToResourceMap = new HashMap<String, URL>();
        }

        dialectToResourceMap.put(dialect, rsrc);
    }

    /** {@inheritDoc} for debugging */
    public String toString()
    {
        return "OverridableResource URL=" + resource + " dialectToResourceMap=" + dialectToResourceMap;
    }
}
