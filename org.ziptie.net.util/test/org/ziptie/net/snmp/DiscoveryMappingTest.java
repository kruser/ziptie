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
 */
package org.ziptie.net.snmp;

import java.util.regex.Pattern;

import org.ziptie.net.snmp.DiscoveryMapping;
import org.ziptie.net.snmp.DiscoveryMapping.DiscoverySource;

import junit.framework.TestCase;

/**
 * DiscoveryMappingTest for {@link DiscoveryMapping}
 */
public class DiscoveryMappingTest extends TestCase
{
    DiscoveryMapping mapping;
    protected void setUp()
    {
        mapping = new DiscoveryMapping("IOS", DiscoverySource.sysDescr); 
    }
    
    public void testConstructorAttributes()
    {
       assertEquals("sysDescr", mapping.getSource().name());
       assertEquals("IOS", mapping.getAdapterId());
    }
    
    public void testRegexFlags()
    {
       assertNull(mapping.getPattern());
       mapping.setPattern(Pattern.compile("test"));
       assertEquals("test", mapping.getPattern().pattern());
    }
}
