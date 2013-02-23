/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2008/04/03 03:05:00 $
 * $Revision: 1.2 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net.util/test/org/ziptie/addressing/CrazyAddressSetRunner.java,v $e
 */

package org.ziptie.addressing;

import java.util.Random;

/**
 * Used to test concurrency and the <code>AddressSet</code>
 * 
 * @author rkruse
 */
public class CrazyAddressSetRunner implements Runnable
{
    private static final int NUMBER_OF_ENTRIES = 100;
    private static final int MAX8BIT_VALUE = 255;

    private Random generator;
    private AddressSet addressSet;

    /**
     * Constructor.
     *
     * @param addressSet the address set to randomize
     */
    public CrazyAddressSetRunner(AddressSet addressSet)
    {
        this.addressSet = addressSet;
        this.generator = new Random();
    }

    /** {@inheritDoc} */
    public void run()
    {
        for (int j = 0; j < NUMBER_OF_ENTRIES; j++)
        {
            IPAddress randomIP = new IPAddress(generator.nextInt(MAX8BIT_VALUE) + "." + generator.nextInt(MAX8BIT_VALUE) + "."
                    + generator.nextInt(MAX8BIT_VALUE) + "." + generator.nextInt(MAX8BIT_VALUE));

            // Randomly add or iterate the addressSet
            int decision = generator.nextInt(2);
            if (decision == 1)
            {
                addressSet.add(randomIP);
            }
            else
            {
                addressSet.contains(randomIP);
            }
        }
    }
}

// -------------------------------------------------
// $Log: CrazyAddressSetRunner.java,v $
// Revision 1.2  2008/04/03 03:05:00  brettw
// Remove checkstyle warnings.
//
// Revision 1.1  2006/12/26 22:06:50  rkruse
// make the AddressSet thread-safe for use as a discovery cache.
//
// Revision 1.0 Dec 26, 2006 rkruse
// Initial revision
// --------------------------------------------------
