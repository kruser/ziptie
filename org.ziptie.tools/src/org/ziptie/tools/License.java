package org.ziptie.tools;

import java.io.FileInputStream;
import java.io.FileOutputStream;

import javax.crypto.Cipher;
import javax.crypto.CipherOutputStream;
import javax.crypto.spec.SecretKeySpec;

/**
 * License
 */
@SuppressWarnings("nls")
public class License
{
    private static final String PASS_PHRASE = "ZipTiePassPhrase";
    private static final String ALGORITHM = "Blowfish";

    /**
     * @param args
     */
    public static void main(String[] args)
    {
        try
        {
            FileInputStream fis = new FileInputStream("license.xml");
            FileOutputStream fos = new FileOutputStream("license.enc");

            SecretKeySpec secretKeySpec = new SecretKeySpec(PASS_PHRASE.getBytes(), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec);
            CipherOutputStream cos = new CipherOutputStream(fos, cipher);

            byte[] bytes = new byte[1024];
            while (true)
            {
                int rc = fis.read(bytes);
                if (rc == -1)
                {
                    break;
                }
                cos.write(bytes, 0, rc);
            }
            fis.close();
            cos.flush();
            cos.close();

            System.out.println("License file encrypted.\n");
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

}
