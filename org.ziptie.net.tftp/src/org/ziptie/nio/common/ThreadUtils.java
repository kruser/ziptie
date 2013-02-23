package org.ziptie.nio.common;

public class ThreadUtils
{
    // -- public methods
    public static void sleep(long msecs, ILogger logger)
    {
        try
        {
            Thread.sleep(msecs);
        }
        catch (InterruptedException e)
        {
            logger.debug("Sleep interrupted", e);
        }
    }

}
