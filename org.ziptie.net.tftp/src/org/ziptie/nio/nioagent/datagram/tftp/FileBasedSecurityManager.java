package org.ziptie.nio.nioagent.datagram.tftp;

import java.io.File;
import java.net.SocketAddress;

/**
 * This implementation of the {@link SecurityManager} requires 
 * that a file exist on the filesystem before allowing a write request.
 * This makes it so that remote users wouldn't be able to fill
 * the tftp filesystem.
 * 
 * @author rkruse
 */
public class FileBasedSecurityManager implements SecurityManager
{
    private String tftpRootDir;
    
    /**
     * Create an instance
     * @param tftpRootDir the tftp directory
     */
    public FileBasedSecurityManager(String tftpRootDir)
    {
        this.tftpRootDir = tftpRootDir + File.separator;
    }

    // -- public methods
    public boolean denyRead(SocketAddress remote, String filename, String mode)
    {
        return denyMode(mode);
    }

    public boolean denyWrite(SocketAddress remote, String filename, String mode)
    {
        File newWrite = new File(tftpRootDir + filename);
        if (!newWrite.exists())
        {
           return true; 
        }
        return denyMode(mode);
    }

    // -- private methods
    private boolean denyMode(String mode)
    {
        return !("octet".equalsIgnoreCase(mode) || "netascii".equalsIgnoreCase(mode));
    }
}
