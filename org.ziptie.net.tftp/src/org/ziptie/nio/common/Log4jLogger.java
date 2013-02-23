package org.ziptie.nio.common;

import org.apache.log4j.Logger;

public class Log4jLogger implements ILogger
{
    // -- member fields
    private final Logger logger;

    // -- constructors
    public Log4jLogger(String name)
    {
        logger = Logger.getLogger(name);
    }

    // public methods

    public void error(Object msg)
    {
        possiblyLog(org.apache.log4j.Level.ERROR, msg);
    }

    public void error(Object msg, Throwable t)
    {
        possiblyLog(org.apache.log4j.Level.ERROR, msg, t);
    }

    public void warn(Object msg)
    {
        possiblyLog(org.apache.log4j.Level.WARN, msg);
    }

    public void warn(Object msg, Throwable t)
    {
        possiblyLog(org.apache.log4j.Level.WARN, msg, t);
    }

    public void info(Object msg)
    {
        possiblyLog(org.apache.log4j.Level.INFO, msg);
    }

    public void info(Object msg, Throwable t)
    {
        possiblyLog(org.apache.log4j.Level.INFO, msg, t);
    }

    public void debug(Object msg)
    {
        possiblyLog(org.apache.log4j.Level.DEBUG, msg);
    }

    public void debug(Object msg, Throwable t)
    {
        possiblyLog(org.apache.log4j.Level.DEBUG, msg, t);
    }

    // -- private methods
    private void possiblyLog(org.apache.log4j.Level level, Object msg)
    {
        if (logger.isEnabledFor(level))
        {
            logger.log(level, msg);
        }
    }

    private void possiblyLog(org.apache.log4j.Level level, Object msg, Throwable t)
    {
        if (logger.isEnabledFor(level))
        {
            logger.log(level, msg, t);
        }
    }
}
