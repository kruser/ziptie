package org.ziptie.server.dns;


/**
 * ResolvedHost
 */
public class ResolvedHost
{
    private String originalHost;
    private String resolvedName;
    private String resolvedIp;

    /**
     * Default constructor.        LookupAsynch.getDefaultResolver().setTimeout(10);  // 10 second timeout

     */
    public ResolvedHost()
    {
        
    }

    public ResolvedHost(String origHost, String name, String ip)
    {
        this.originalHost = origHost;
        this.resolvedName = name;
        this.resolvedIp = ip;
    }

    /**
     * @return
     */
    public String getOriginalHost()
    {
        return originalHost;
    }

    /**
     * @return
     */
    public String getResolvedName()
    {
        return resolvedName;
    }

    /**
     * @return
     */
    public String getResolvedIp()
    {
        return resolvedIp;
    }
}
