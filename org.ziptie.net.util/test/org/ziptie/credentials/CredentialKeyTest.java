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

import junit.framework.TestCase;

/**
 * Tests out the functionality of the <code>CredentialKey</code> class
 * @author rkruse
 */
public class CredentialKeyTest extends TestCase
{
    public void testNewKey()
    {
        CredentialKey key = new CredentialKey("username", "Device Username", true, true);
        assertNotNull(key);
        
        assertEquals("username", key.getKeyName());
        assertEquals("Device Username", key.getDisplayName());
        assertTrue(key.isStaticCred());
        assertTrue(key.isDisplayAsPassword());
    }
    
    public void testSetters()
    {
        CredentialKey key = new CredentialKey("username", "Device Username", false, false);
        
        assertFalse(key.isDisplayAsPassword());
        key.setDisplayAsPassword(true);
        assertTrue(key.isDisplayAsPassword());
        
        key.setDisplayName("word up");
        assertEquals("word up", key.getDisplayName());
        
        key.setKeyName("word");
        assertEquals("word", key.getKeyName());
        
        assertFalse(key.isStaticCred());
        key.setStaticCred(true);
        assertTrue(key.isStaticCred());
    }
}


// -------------------------------------------------
// $Log: CredentialKeyTest.java
// $Revision 1.1  Oct 23, 2006 rkruse
// $Code Templates
// $
// --------------------------------------------------