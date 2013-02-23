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
 */

package org.ziptie.server.hibernate.test;

import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.apache.log4j.Logger;
import org.ziptie.server.hibernate.IHibernateBundle;
import org.ziptie.server.hibernate.test.model.HelloWorld;

import java.rmi.RemoteException;
import java.util.List;

import junit.framework.TestCase;

/**
 * This class tests Hibernate bundle
 */
public class TestHibernateBundle extends TestCase
{
    private static Logger USER_LOG = Logger.getLogger(TestHibernateBundle.class);

    /**
     * Tests creating HelloWorld objects
     * @throws Exception If any exceptions occur
     */
    public void testHelloWorld() throws Exception
    {
        BundleContext bundleContext = TestAll.getBundleContext();

        ServiceReference testRef = bundleContext.getServiceReference(IHibernateBundle.class.getName());
        if (testRef == null)
        {
            USER_LOG.error("Service IHibernateBundle was not found.");
            return;
        }
        IHibernateBundle hbBundle = (IHibernateBundle) bundleContext.getService(testRef);

        try
        {
            // checking the amount of HelloWorld objects in the DB before saving
            List hwList = hbBundle.loadObjects(HelloWorld.class);

            int beforeAmount = hwList != null ? hwList.size() : 0;

            USER_LOG.info(String.format("There is/are %s HelloWorld object(s) before saving to the DB.", beforeAmount));

            // save HelloWorld objects to the DB
            HelloWorld hw = new HelloWorld();
            hw.setName("Hello World");

            hbBundle.beginTransaction();
            hbBundle.saveObject(hw);
            hbBundle.commitTransaction();

            // checking the amount of HelloWorld objects in the DB after saving
            hwList = hbBundle.loadObjects(HelloWorld.class);

            int afterAmount = hwList != null ? hwList.size() : 0;

            // a new record should be added to the DB
            assertEquals(beforeAmount + 1, afterAmount);

            USER_LOG.info(String.format("There is/are %s HelloWorld object(s) after saving to the DB.", afterAmount));
        }
        catch (RemoteException e)
        {
            USER_LOG.error("Exception while testing HelloWorld's operations with DB.", e);
            hbBundle.rollbackTransaction();
            throw e;
        }
    }
}
