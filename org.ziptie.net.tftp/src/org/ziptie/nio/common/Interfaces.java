package org.ziptie.nio.common;

import org.ziptie.nio.nioagent.WrapperException;

public interface Interfaces
{
    public interface ExceptionHandler
    {
        WrapperException handle(String msg, Exception e);
    }
}
