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

import org.hibernate.Criteria;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Restrictions;
import org.ziptie.provider.devices.DeviceResolutionElf;
import org.ziptie.provider.devices.IDeviceResolutionScheme;
import org.ziptie.provider.devices.PageData;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.zap.jta.TransactionElf;

/**
 * Resolve devices within a set of networks.
 */
public class NetworkResolutionScheme implements IDeviceResolutionScheme
{
    /** {@inheritDoc} */
    public PageData resolve(String scheme, String data, PageData page, String sortColumn, boolean descending)
    {
        String[] networks = data.split(","); //$NON-NLS-1$
        if (networks.length == 0)
        {
            page.setTotal(0);
            page.setDevices(new ZDeviceLite[0]);
            return page;
        }

        for (int i = 0; i < networks.length; i++)
        {
            networks[i] = networks[i].trim();
        }

        boolean success = false;
        boolean ownTransaction = TransactionElf.beginOrJoinTransaction();

        try
        {
            Session session = DeviceProviderActivator.getSessionFactory().getCurrentSession();

            Criteria criteria = session.createCriteria(ZDeviceLite.class)
                .add(Restrictions.in(ATTR_NETWORK, networks));

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
}
