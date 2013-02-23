package org.ziptie.net.utils;

/**
 * The <code>FileServerInfo</code> represents a simple container to hold basic information about a file server.
 * This information includes:
 * <ul>
 * <li>The name of the protocol that the file server utilizes for transferring files, such as "TFTP" or "FTP"
 * <li>The IP address of the machine running the file server.  If the file server is running locally and bound to an interface,
 * one should use the local IP address.
 * <li>The port value that the file server is bound to and that communication to and from it happens over.
 * <li>The absolute file path to the root directory of the file server.  The only caveat of this all is that it is assumed that
 * the root directory specified can be accessible by the machine running ZipTie.  This means that either the file server must be
 * running on the same machine, or there must be a mapping to the directory located on the local file system.  If the latter is
 * the case, then the root directory should be this mapped directory.
 * </ul>
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
@SuppressWarnings("nls")
public class FileServerInfo
{
    private String protocolName;
    private String ip;
    private int port;
    private String rootDir;

    /**
     * Default constructor for the <code>FileServerInfo<code> class.  Creates a new instance and initalizes the default
     * value of all the parameters.
     */
    public FileServerInfo()
    {
        protocolName = "";
        ip = "";
        port = -1;
        rootDir = "";
    }

    /**
     * Constructor for the <code>FileServerInfo</code> class.  Creates a new instance and initializes its members with
     * the specified parameter.
     * 
     * @param protocolName The name of the protocol that the file server utilizes.
     * @param ip The IP address of the machine that is running the file server.
     * @param port The port value that the file server is bound to and that communication to and from it happens over.
     * @param rootDir The absolute file path to the root directory of the file server.
     */
    public FileServerInfo(String protocolName, String ip, int port, String rootDir)
    {
        setProtocolName(protocolName);
        setIp(ip);
        setPort(port);
        setRootDir(rootDir);
    }

    /**
     * Retrieves the name of the protocol that the file server utilizes.
     * 
     * @return The name of the protocol that the file server utilizes.
     */
    public String getProtocolName()
    {
        return protocolName;
    }

    /**
     * Stores the name of the protocol that the file server utilizes.
     * 
     * @param protocolName The name of the protocol that the file server utilizes.
     */
    public void setProtocolName(String protocolName)
    {
        this.protocolName = protocolName != null ? protocolName : "";
    }

    /**
     * Retrieves the IP address of the machine that is running the file server.
     * 
     * @return The IP address of the machine that is running the file server.
     */
    public String getIp()
    {
        return ip;
    }

    /**
     * Stores the specified string as the IP address of the machine that is running the file server.
     * 
     * @param ip The IP address of the machine that is running the file server.
     */
    public void setIp(String ip)
    {
        this.ip = ip != null ? ip : "";
    }

    /**
     * Retrieves the port value that the file server is bound to and that communication to and from it happens over.
     * 
     * @return The port value that the file server is bound to and that communication to and from it happens over.
     */
    public int getPort()
    {
        return port;
    }

    /**
     * Stores the specified int as the port value that the file server is bound to and that communication to and from
     * it happens over.
     * 
     * @param port The port value that the file server is bound to and that communication to and from
     * it happens over.
     */
    public void setPort(int port)
    {
        this.port = port;
    }

    /**
     * Retrieves the absolute file path to the root directory of the file server.  The only caveat of this all is that it is
     * assumed that the root directory specified can be accessible by the machine running ZipTie.  This means that either the
     * file server must be running on the same machine, or there must be a mapping to the directory located on the local file
     * system.  If the latter is the case, then the root directory should be this mapped directory.
     * 
     * @return The absolute file path to the root directory of the file server.
     */
    public String getRootDir()
    {
        return rootDir;
    }

    /**
     * Stores the absolute file path to the root directory of the file server.  The only caveat of this all is that it is
     * assumed that the root directory specified can be accessible by the machine running ZipTie.  This means that either the
     * file server must be running on the same machine, or there must be a mapping to the directory located on the local file
     * system.  If the latter is the case, then the root directory should be this mapped directory.
     * 
     * @param rootDir The absolute file path to the root directory of the file server.
     */
    public void setRootDir(String rootDir)
    {
        this.rootDir = rootDir != null ? rootDir : "";
    }
}
