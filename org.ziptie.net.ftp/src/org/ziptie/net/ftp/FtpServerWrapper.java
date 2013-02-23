package org.ziptie.net.ftp;

import org.apache.ftpserver.FtpServer;
import org.apache.ftpserver.interfaces.IFtpConfig;

/**
 * FtpServerWrapper.
 *
 * Wrap the Apache FTP Server just so we can name the stupid thread.
 */
public class FtpServerWrapper extends FtpServer
{
    /**
     * Constructor.
     * 
     * @param ftpConfig an ftp server configuration
     */
    public FtpServerWrapper(IFtpConfig ftpConfig)
    {
        super(ftpConfig);
    }

    /** {@inheritDoc} */
    @Override
    public void run()
    {
        Thread.currentThread().setName("Apache FTP Server");
        super.run();
    }
}
