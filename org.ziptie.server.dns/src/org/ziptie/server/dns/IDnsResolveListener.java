package org.ziptie.server.dns;

/**
 * Listener that will be called back on DNS resolution completion.
 */
public interface IDnsResolveListener
{
    /**
     * Resolution has completed.
     * @param name The resolved DNS name or <code>null</code> if the address could not be resolved. 
     */
    void resolvedName(String name);
}
