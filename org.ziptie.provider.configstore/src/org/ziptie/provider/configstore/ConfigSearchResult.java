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
package org.ziptie.provider.configstore;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * ConfigSearchResult
 */
public class ConfigSearchResult
{
    private String ipAddress;
    private String managedNetwork;
    private String path;
    private String mimeType;
    private Date lastChanged;
    private List<ConfigSearchTerm> terms;

    /**
     * Default constructor.
     */
    public ConfigSearchResult()
    {
        setTerms(new ArrayList<ConfigSearchTerm>());
    }

    /**
     * @return the ipAddress
     */
    public String getIpAddress()
    {
        return ipAddress;
    }

    /**
     * @param ipAddress the ipAddress to set
     */
    public void setIpAddress(String ipAddress)
    {
        this.ipAddress = ipAddress;
    }

    /**
     * @return the lastChanged
     */
    public Date getLastChanged()
    {
        return lastChanged;
    }

    /**
     * @param lastChanged the lastChanged to set
     */
    public void setLastChanged(Date lastChanged)
    {
        this.lastChanged = lastChanged;
    }

    /**
     * @return the managedNetwork
     */
    public String getManagedNetwork()
    {
        return managedNetwork;
    }

    /**
     * @param managedNetwork the managedNetwork to set
     */
    public void setManagedNetwork(String managedNetwork)
    {
        this.managedNetwork = managedNetwork;
    }

    /**
     * @return the path
     */
    public String getPath()
    {
        return path;
    }

    /**
     * @param path the path to set
     */
    public void setPath(String path)
    {
        this.path = path;
    }

    /**
     * @return the mimeType
     */
    public String getMimeType()
    {
        return mimeType;
    }

    /**
     * @param mimeType the mimeType to set
     */
    public void setMimeType(String mimeType)
    {
        this.mimeType = mimeType;
    }

    /**
     * Set the list of matching search terms.
     *
     * @param terms the list of matching search terms
     */
    public void setTerms(List<ConfigSearchTerm> terms)
    {
        this.terms = terms;
    }

    /**
     * Get the list of matching search terms.
     *
     * @return the list of matching terms
     */
    public List<ConfigSearchTerm> getTerms()
    {
        return terms;
    }
}
