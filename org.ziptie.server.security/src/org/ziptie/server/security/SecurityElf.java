package org.ziptie.server.security;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * SecurityElf
 */
public final class SecurityElf
{
    private static final String SALT = "ZiPtIE"; //$NON-NLS-1$

    private SecurityElf()
    {
        // private constructor
    }

    /**
     * Calculate MD5 of username:password:salt
     *
     * @param username the username
     * @param password the password
     * @return a HEX version of the MD5
     */
    public static String calcMD5(String username, String password)
    {
        try
        {
            MessageDigest digest = MessageDigest.getInstance("MD5"); //$NON-NLS-1$

            digest.update(String.format("%s:%s:%s", username, password, SALT).getBytes()); //$NON-NLS-1$
            byte[] md5sum = digest.digest();
            BigInteger bigInt = new BigInteger(1, md5sum);
            return bigInt.toString(16);
        }
        catch (NoSuchAlgorithmException e)
        {
            throw new RuntimeException(e);
        }
    }

}
