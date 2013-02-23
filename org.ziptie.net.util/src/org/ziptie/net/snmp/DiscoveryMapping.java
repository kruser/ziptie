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

/**
 * DiscoveryMapping contains information that allows you to determine the adapterId given details of a discovery.
 * @author rkruse
 */
public class DiscoveryMapping
{
    private String adapterId;
    private Pattern pattern;
    private DiscoverySource source;

    /**
     * Create a mapping with to the provided adapter.
     *  
     * @param adapterId the ID of the adapter
     * @param source identifies what data to parse
     */
    public DiscoveryMapping(String adapterId, DiscoverySource source)
    {
        this.adapterId = adapterId;
        this.source = source;
    }

    /**
     * DiscoverySource
     */
    public enum DiscoverySource
    {
        sysDescr, sysOid, sysName,
    }

    /**
     * @return the adapterId
     */
    public String getAdapterId()
    {
        return adapterId;
    }

    /**
     * @return the source
     */
    public DiscoverySource getSource()
    {
        return source;
    }

    /**
     * @return the pattern
     */
    public Pattern getPattern()
    {
        return pattern;
    }

    /**
     * @param pattern the pattern to set
     */
    public void setPattern(Pattern pattern)
    {
        this.pattern = pattern;
    }
}
