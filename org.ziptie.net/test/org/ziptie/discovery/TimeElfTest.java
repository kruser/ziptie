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
package org.ziptie.discovery;

import java.util.Date;

import junit.framework.TestCase;

public class TimeElfTest extends TestCase
{
    /**
     * Tests the getDuration in MiscUtils.
     *
     */
    public void testDuration()
    {
        Date one = new Date(1000);
        Date two = new Date(86400000);
        String duration = TimeElf.getDuration(one, two);
        System.out.println("DURATION TEST: " + duration);
        assertEquals("23 hour(s), 59 minute(s), 59 second(s)", duration);

        two = new Date(1050);
        duration = TimeElf.getDuration(one, two);
        System.out.println("DURATION TEST: " + duration);
        assertEquals("< 1 second", duration);

        two = new Date(3603000);
        duration = TimeElf.getDuration(one, two);
        System.out.println("DURATION TEST: " + duration);
        assertEquals("1 hour(s), 2 second(s)", duration);

        two = new Date(172801000);
        duration = TimeElf.getDuration(one, two);
        System.out.println("DURATION TEST: " + duration);
        assertEquals("48 hour(s)", duration);
    }
}
