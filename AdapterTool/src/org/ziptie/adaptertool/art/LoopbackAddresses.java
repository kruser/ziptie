package org.ziptie.adaptertool.art;

import java.util.LinkedList;
import java.util.List;

/**
 * Central access to a pool of loopback addresses.
 */
public final class LoopbackAddresses
{
    private static final List<String> ADDRESSES;
    private static int octet;

    static
    {
        ADDRESSES = new LinkedList<String>();
    }

    private LoopbackAddresses()
    {
    }

    /**
     * Acquire an unused loopback address.
     * @return The address.
     */
    public static synchronized String acquire()
    {
        if (ADDRESSES.isEmpty())
        {
            octet++;
            return "127.0.0." + octet; //$NON-NLS-1$
        }
        return ADDRESSES.remove(0);
    }

    /**
     * Releases the loopback address so that it can be acquired by others.
     * @param address The address to release.
     */
    public static synchronized void release(String address)
    {
        ADDRESSES.add(address);
    }
}
