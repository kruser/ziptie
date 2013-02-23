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
package org.ziptie.provider.adapters;

/**
 * Describes the basic information about an adapter.
 */
public class AdapterLite
{
    private String adapterId;
    private String shortName;
    private String description;
    private String restoreValidationRegex;

    /**
     * Create an empty instance.
     */
    public AdapterLite()
    {
    }

    /**
     * Create a populated instance.
     * @param adapterId The adapter ID
     * @param shortName The brief description for an adapter (25 characters or less).
     * @param description The user friendly description.
     */
    public AdapterLite(String adapterId, String shortName, String description)
    {
        this.adapterId = adapterId;
        this.shortName = shortName;
        this.description = description;
    }

    /**
     * Gets the adapter ID.  This should be the perl module name.
     * @return The adapter id.
     */
    public String getAdapterId()
    {
        return adapterId;
    }

    /**
     * Gets the short name.  This is a brief description for the adapter (25 characters or less).
     * @return The short name.
     */
    public String getShortName()
    {
        return shortName;
    }

    /**
     * Gets the user friendly description of this adapter.
     * @return A user friendly description.
     */
    public String getDescription()
    {
        return description;
    }

    /**
     * Sets the adapter ID.
     * @param adapterId The id.
     */
    public void setAdapterId(String adapterId)
    {
        this.adapterId = adapterId;
    }

    /**
     * Sets the short name.  This is a brief description for the adapter (25 characters or less).
     * @param shortName The short name.
     */
    public void setShortName(String shortName)
    {
        this.shortName = shortName;
    }

    /**
     * Sets the adapter description.
     * @param description the description.
     */
    public void setDescription(String description)
    {
        this.description = description;
    }

    /**
     * Gets the regular expression that can be used to validate whether or not a device configuration
     * can be restored.
     * 
     * @return A validation regular expression.
     */
    public String getRestoreValidationRegex()
    {
        return restoreValidationRegex;
    }

    /**
     * Sets the regular expression that can be used to validate whether or not a device configuration
     * can be restored.
     * 
     * @param regex A validation regular expression.
     */
    public void setRestoreValidationRegex(String regex)
    {
        this.restoreValidationRegex = regex;
    }
}
