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
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */

package org.ziptie.net.sim.config;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.util.Iterator;

import junit.framework.TestCase;

import org.ziptie.net.sim.util.CharSequenceInputStream;

/**
 * Test the configuration components.
 */
public class ConfigurationTest extends TestCase
{
    public void testLoadConfig() throws Exception
    {
        ConfigurationService service = ConfigurationService.getInstance();

        Configuration config = service.findConfigurationFile(ConfigurationService.DEFAULT_CONFIG);
        Configuration config2 = service.findConfiguration(null);

        assertSame(config, config2);

        try
        {
            service.findConfigurationFile("Non-exsistent config");
            fail("find should have thrown!");
        }
        catch (FileNotFoundException e)
        {

        }

        // test to make sure a generated config can be loaded

        config = service.generateEpitomizingConfiguration(new IpSubnet("127.1.0.0/255.255.255.0"));
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        config.toXml(baos);
        String strConfig = baos.toString();

        config2 = service.loadConfiguration(null, new CharSequenceInputStream(strConfig));

        IIpMapping[] mappings = config.getMappings();
        IIpMapping[] mappings2 = config2.getMappings();

        assertEquals(mappings.length, mappings2.length);

        for (int i = 0; i < mappings.length; i++)
        {
            assertEquals(mappings[i], mappings2[i]);
            assertEquals(mappings[i].getOperation(), mappings2[i].getOperation());
        }

        service.saveConfiguration("anewconfig.xml", strConfig);

        config2 = service.findConfigurationFile("anewconfig.xml");
        mappings = config.getMappings();
        mappings2 = config2.getMappings();

        assertEquals(mappings.length, mappings2.length);

        for (int i = 0; i < mappings.length; i++)
        {
            assertEquals(mappings[i], mappings2[i]);
            assertEquals(mappings[i].getOperation(), mappings2[i].getOperation());
        }
    }

    /**
     * 
     */
    public void testIpMappings()
    {
        // 100.100.1.0 (used with range)
        int iip = (100 << 24) | (100 << 16) | (1 << 8) | (0);

        IpAddressMapping ip = new IpAddressMapping("127.0.0.1");
        IpSubnet subnet = new IpSubnet("127.0.0.0/255.255.255.0");

        IpRange range = new IpRange(new IpAddressMapping(iip), new IpAddressMapping("100.100.25.255"));

        assertEquals(ip, new IpAddressMapping("127.0.0.1"));
        assertEquals(subnet, new IpSubnet("127.0.0.0/255.255.255.0"));
        assertEquals(range, new IpRange(new IpAddressMapping("100.100.1.0"), new IpAddressMapping("100.100.25.255")));

        assertTrue(subnet.contains(ip));
        for (int i = 0; i < 256; i++)
        {
            IpAddressMapping address = new IpAddressMapping("127.0.0." + i);
            assertTrue(subnet.contains(address));
            assertFalse(range.contains(address));
        }

        Iterator iter = subnet.iterator();
        while (iter.hasNext())
        {
            IpAddressMapping next = (IpAddressMapping) iter.next();
            assertTrue(subnet.contains(next));

            assertFalse("Invalid IP Address: " + next, (next.getIntValue() & 0xFF) == 0);
        }

        /*
         * Test the range object and the intValue compare of ip addresses
         */

        for (int i = 1; i < 26; i++)
        {
            iip++;
            for (int j = 1; j < 256; j++)
            {
                IpAddressMapping address = new IpAddressMapping("100.100." + i + "." + j);
                assertEquals(address.getIntValue(), iip);
                assertTrue(range.contains(address));

                assertFalse(subnet.contains(address));

                iip++;
            }
        }

        iter = range.iterator();
        while (iter.hasNext())
        {
            IpAddressMapping next = (IpAddressMapping) iter.next();
            assertTrue("range: " + range + "\nip:" + next, range.contains(next));
            assertFalse("Invalid IP Address: " + next, (next.getIntValue() & 0xFF) == 0);
        }

        iter = ip.iterator();
        assertTrue(iter.hasNext());
        IpAddressMapping ip2 = (IpAddressMapping) iter.next();

        assertEquals(ip, ip2);
        assertFalse(iter.hasNext());
    }
}
