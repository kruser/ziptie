package org.ziptie.provider.security.internal;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.spec.SecretKeySpec;

import org.ziptie.provider.security.License;

/**
 * LicenseElf
 */
@SuppressWarnings("nls")
public final class LicenseElf
{
    private static final String PASS_PHRASE = "ZipTiePassPhrase";
    private static final String ALGORITHM = "Blowfish";
    private static License license;

    /**
     * Private default constructor
     */
    private LicenseElf()
    {
        // private constructor
    }

    public synchronized static License loadLicense()
    {
        if (license != null)
        {
            return license;
        }

        try
        {
            SecretKeySpec secretKeySpec = new SecretKeySpec(PASS_PHRASE.getBytes(), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, secretKeySpec);
            InputStream is = new FileInputStream("osgi-config/security/license.enc");
            CipherInputStream cis = new CipherInputStream(is, cipher);

            int offset = 0;
            byte[] bytes = new byte[2048];
            while (true)
            {
                int rc = cis.read(bytes, offset, bytes.length - offset);
                if (rc == -1)
                {
                    break;
                }
                offset += rc;
            }
            is.close();
            cis.close();

            Properties licenseProps = new Properties();
            licenseProps.loadFromXML(new ByteArrayInputStream(bytes, 0, offset));

            license = new License(licenseProps);
            return license;
        }
        catch (Exception e)
        {
            throw new RuntimeException("Unable to load license file.", e);
        }
    }
}
