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

import junit.framework.TestCase;
import junit.framework.TestSuite;
import org.osgi.framework.BundleContext;

/**
 * Runs all testcases (if any)
 */
public class TestAll extends TestCase
{
    private static BundleContext bundleContext;

    /**
     * Gets the BundleContext object
     * @return BundleContext
     */
    public static BundleContext getBundleContext()
    {
        return bundleContext;
    }

    /**
     * Sets the BundleContext
     * @param bundleContext BundleContext object
     */
    public static void setBundleContext(BundleContext bundleContext)
    {
        TestAll.bundleContext = bundleContext;
    }

    /**
     * Suite.
     *
     * @return the test suite
     */
    public static TestSuite suite()
    {
        TestSuite suite = new TestSuite();
        suite.addTestSuite(TestHibernateBundle.class);
        return suite;
    }
}
