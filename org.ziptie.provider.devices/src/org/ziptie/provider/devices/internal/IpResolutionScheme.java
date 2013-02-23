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
package org.ziptie.provider.devices.internal;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Restrictions;
import org.ziptie.addressing.IPAddress;
import org.ziptie.provider.devices.DeviceResolutionElf;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.Messages;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Resolves a CSV of IP addresses to devices.
 */
public class IpResolutionScheme implements IDeviceResolutionScheme
{
    private static final Logger LOGGER = Logger.getLogger(IpResolutionScheme.class);

    /** {@inheritDoc} */
    public PageData resolve(String scheme, String data, PageData page, String sortColumn, boolean descending)
    {
        Map<String, List<String>> networksAndIps = parseData(data);

        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();
        boolean success = false;

        try
        {
            Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

            Criterion crit = null;

            for (Entry<String, List<String>> entry : networksAndIps.entrySet())
            {
                List<String> ips = entry.getValue();
                if (ips.isEmpty())
                {
                    continue;
                }

                Criterion net = Restrictions.eq(ATTR_NETWORK, entry.getKey());
                Criterion ip = Restrictions.in(ATTR_IP_ADDRESS, ips);
                Criterion and = Restrictions.and(net, ip);

                if (crit == null)
                {
                    crit = and;
                }
                else
                {
                    crit = Restrictions.or(crit, and);
                }
            }

            Criteria criteria = session.createCriteria(ZDeviceLite.class)
                .add(crit)
                .setMaxResults(page.getPageSize())
                .setFirstResult(page.getOffset());

            PageData result = DeviceResolutionElf.populatePageData(page, criteria, sortColumn, descending);

            success = true;

            return result;
        }
        finally
        {
            if (ownTransaction)
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

    private Map<String, List<String>> parseData(String data)
    {
        String defaultNetwork = DeviceProviderActivator.getNetworksProvider().getDefaultManagedNetwork().getName();

        Map<String, List<String>> networksAndIps = new HashMap<String, List<String>>();

        String[] ipAddresses = data.split(","); //$NON-NLS-1$
        for (String ipAddress : ipAddresses)
        {
            String[] addrAndNetwork = ipAddress.split("@"); //$NON-NLS-1$

            String network = addrAndNetwork.length == 1 ? defaultNetwork : addrAndNetwork[1];
            List<String> net = networksAndIps.get(network);
            if (net == null)
            {
                net = new LinkedList<String>();
                networksAndIps.put(network, net);
            }
            try
            {
                net.add(new IPAddress(addrAndNetwork[0]).toDatabaseString());
            }
            catch (IllegalArgumentException e)
            {
                LOGGER.error(Messages.bind(Messages.IpResolutionScheme_invalidAddress, addrAndNetwork[0]), e);
            }
        }
        return networksAndIps;
    }
}
