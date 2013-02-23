/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.provider.devices;

import static org.ziptie.provider.devices.IDeviceResolutionScheme.ATTR_DEVICE_ID;
import static org.ziptie.provider.devices.IDeviceResolutionScheme.ATTR_IP_ADDRESS;
import static org.ziptie.provider.devices.IDeviceResolutionScheme.ATTR_IP_HIGH;
import static org.ziptie.provider.devices.IDeviceResolutionScheme.ATTR_IP_LOW;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.hibernate.Criteria;
import org.hibernate.ScrollMode;
import org.hibernate.ScrollableResults;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;

/**
 * Helper for resolving device sets.
 */
public final class DeviceResolutionElf
{
    private static final int DEFAULT_PAGE_SIZE = 250;

    private static final Logger LOGGER = Logger.getLogger(DeviceResolutionElf.class);

    private static HashMap<String, Scheme> schemes;
    private static ReentrantLock lock;

    static
    {
        lock = new ReentrantLock();
    }

    private DeviceResolutionElf()
    {
    }

    /**
     * Gets the set of devices described by <code>data</code> using the given scheme.
     * @param scheme The device resolution scheme
     * @param data The scheme specific data.
     * @return The devices.
     */
    public static List<ZDeviceLite> resolveDevices(String scheme, String data)
    {
        IDeviceResolutionScheme resolver = getResolutionScheme(scheme);

        LinkedList<ZDeviceLite> result = new LinkedList<ZDeviceLite>();
        PageData page = new PageData();
        page.setOffset(0);
        page.setPageSize(DEFAULT_PAGE_SIZE);

        do
        {
            page = resolver.resolve(scheme, data, page, null, false);
            Collections.addAll(result, page.getDevices());
            page.setOffset(page.getOffset() + page.getPageSize());
        }
        while (page.getTotal() > page.getOffset());

        return result;
    }

    /**
     * Retrieves the resolver for the given scheme.
     * @param scheme The scheme name.
     * @return A resolver instance.
     */
    public static IDeviceResolutionScheme getResolutionScheme(String scheme)
    {
        try
        {
            lock.lock();
            if (schemes == null)
            {
                schemes = new HashMap<String, Scheme>();
                IExtensionRegistry reg = Platform.getExtensionRegistry();
                IConfigurationElement[] configs = reg.getConfigurationElementsFor("org.ziptie.provider.devices.deviceResolutionScheme"); //$NON-NLS-1$
                for (IConfigurationElement configurationElement : configs)
                {
                    Scheme s = new Scheme(configurationElement);
                    schemes.put(s.getScheme(), s);
                }
            }

            Scheme instance = schemes.get(scheme);
            if (instance == null)
            {
                throw new IllegalArgumentException("Unrecognized device resolution scheme: " + scheme); //$NON-NLS-1$
            }

            return instance.getResolver();
        }
        finally
        {
            lock.unlock();
        }
    }

    /**
     * Populates a {@link PageData} with the results for the given criteria.
     * @param pageData The page to retrieve.
     * @param criteria The query.
     * @param sortColumn The sort column or <code>null</code>
     * @param descending <code>true</code> for descending sort, <code>false</code> otherwise.
     * @return The populated page.
     */
    public static PageData populatePageData(PageData pageData, Criteria criteria, String sortColumn, boolean descending)
    {
        if (LOGGER.isDebugEnabled())
        {
            LOGGER.debug("populatePageData from criteria: " + criteria.toString()); //$NON-NLS-1$
        }

        criteria.scroll(ScrollMode.SCROLL_INSENSITIVE);

        if (pageData.getOffset() == 0)
        {
            // Set the total result size into the page data.
            criteria.setProjection(Projections.count(ATTR_DEVICE_ID));
            Object uniqueResult = criteria.uniqueResult();
            if (uniqueResult instanceof Integer)
            {
                pageData.setTotal((Integer) uniqueResult);
            }
            else if (uniqueResult instanceof Long)
            {
                pageData.setTotal(((Long) uniqueResult).intValue());
            }
            else
            {
                pageData.setTotal(((BigInteger) uniqueResult).intValue());
            }

            criteria.setProjection(null);
        }

        if (sortColumn != null)
        {
            if (sortColumn.equals(ATTR_IP_ADDRESS))
            {
                criteria.addOrder(descending ? Order.desc(ATTR_IP_HIGH) : Order.asc(ATTR_IP_HIGH)).addOrder(
                                                                                                            descending ? Order.desc(ATTR_IP_LOW)
                                                                                                                    : Order.asc(ATTR_IP_LOW));
            }
            else
            {
                criteria.addOrder((descending ? Order.desc(sortColumn.trim()) : Order.asc(sortColumn.trim())));
            }
        }

        List<ZDeviceLite> list = new ArrayList<ZDeviceLite>();
        ScrollableResults scroll = criteria.scroll();
        while (scroll.next())
        {
            Object[] objects = scroll.get();
            list.add((ZDeviceLite) objects[0]);
        }
        scroll.close();

        pageData.setDevices(list.toArray(new ZDeviceLite[0]));

        return pageData;
    }

    /**
     * describes a scheme extension.
     */
    private static class Scheme
    {
        private IConfigurationElement config;
        private IDeviceResolutionScheme scheme;

        public Scheme(IConfigurationElement config)
        {
            this.config = config;
        }

        public String getScheme()
        {
            return config.getAttribute("scheme"); //$NON-NLS-1$
        }

        public IDeviceResolutionScheme getResolver()
        {
            if (scheme == null)
            {
                try
                {
                    scheme = (IDeviceResolutionScheme) config.createExecutableExtension("class"); //$NON-NLS-1$
                }
                catch (CoreException e)
                {
                    throw new RuntimeException(e);
                }
            }
            return scheme;
        }
    }
}
