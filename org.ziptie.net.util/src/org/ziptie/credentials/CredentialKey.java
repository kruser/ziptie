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

package org.ziptie.credentials;

/**
 * A <code>CredentialKey</code> object should be provided to the
 * <code>CredentialsManager</code> which will help the UI when determining
 * which credentials should be displayed for a user to populate.
 * 
 * @author rkruse
 */
public class CredentialKey
{
    private String keyName = "";

    private String displayName = "";

    private boolean displayAsPassword;

    private boolean staticCred;

    /**
     * Default constructor needed for any web services to utilize the <code>CredentialKey</code> class.
     */
    public CredentialKey()
    {
        // Do nothing
    }

    /**
     * Create a <code>CredentialKey</code> object based on a number of
     * required fields.
     * 
     * @param keyName
     *            the internal name of the credential. E.g 'username'
     * @param displayName
     *            how a UI should display this credential. E.g. 'Device
     *            Username'
     * @param displayAsPassword
     *            should a UI hide and confirm the value of this credential like
     *            it is a password
     * @param staticCred
     *            when overwriting credentials on a user basis, credentials set
     *            as static should be left the same.
     */
    public CredentialKey(String keyName, String displayName, boolean displayAsPassword, boolean staticCred)
    {
        this.keyName = keyName;
        this.displayName = displayName;
        this.displayAsPassword = displayAsPassword;
        this.staticCred = staticCred;
    }

    /**
     * @return Returns the displayAsPassword.
     */
    public boolean isDisplayAsPassword()
    {
        return displayAsPassword;
    }

    /**
     * @param displayAsPassword
     *            The displayAsPassword to set.
     */
    public void setDisplayAsPassword(boolean displayAsPassword)
    {
        this.displayAsPassword = displayAsPassword;
    }

    /**
     * @return Returns the displayName.
     */
    public String getDisplayName()
    {
        return displayName;
    }

    /**
     * @param displayName
     *            The displayName to set.
     */
    public void setDisplayName(String displayName)
    {
        this.displayName = displayName;
    }

    /**
     * @return Returns the keyName.
     */
    public String getKeyName()
    {
        return keyName;
    }

    /**
     * @param keyName
     *            The keyName to set.
     */
    public void setKeyName(String keyName)
    {
        this.keyName = keyName;
    }

    /**
     * @return Returns the staticCred.
     */
    public boolean isStaticCred()
    {
        return staticCred;
    }

    /**
     * @param staticCred
     *            The staticCred to set.
     */
    public void setStaticCred(boolean staticCred)
    {
        this.staticCred = staticCred;
    }
}
