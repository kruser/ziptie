package org.ziptie.server.dns;

/**
 * IDnsService
 */
public interface IDnsService
{
    /**
     * This method uses the non-blocking I/O DNS resolver to resolve a host
     * against a DNS.  The host provided can either be a symbolic DNS name
     * or an IP address.
     *
     * @param host a host name or IPv4 or IPv6 address
     * @param listener a callback listener that is called by the resolver
     *    when name resolution is complete
     */
    void resolveHost(String host, IDnsResolveListener listener);

    /**
     * This method uses the non-blocking I/O DNS resolver to resolve a
     * host name against a DNS.
     * 
     * @param hostname the symbolic name to resolve
     * @param listener a callback listener that is called by the resolver
     *    when name resolution is complete
     */
    void reverseDns(String hostname, IDnsResolveListener listener);
}
