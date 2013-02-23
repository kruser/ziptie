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

package org.ziptie.zap.jta;

import bitronix.tm.utils.CryptoEngine;

/**
 * Provides encryption/decryption using underlying transaction manager's own mechanism.
 * Useful for encrypting/decrypting database passwords.
 */
public class EncryptionUtil
{
    /**
     * Encrypts the given data. The encrypted result is Base64-encoded before it is returned.
     *
     * @param data the data to encrypt.
     * @return the Base64 encoded encrypted data prepended with the cipher used in curly brackets.
     * @throws Exception if any errors occur.
     */
    public static String encrypt(String data) throws Exception
    {
        return "{DES}" + CryptoEngine.crypt("DES", data);
    }

    /**
     * Decrypts the given base64-encoded encrypted data.
     *
     * @param data the Base64 encrypted data to decrypt prepended with the cipher used in curly brackets.
     * @return the decrypted data.
     * @throws Exception if any errors occur.
     */
    public static String decrypt(String data) throws Exception
    {
        return CryptoEngine.decrypt("DES", data);
    }
}

