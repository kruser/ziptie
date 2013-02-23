package org.ziptie.nio.common;

import org.ziptie.nio.common.ExceptionHandlerImpl;
import org.ziptie.nio.common.SystemLogger;
import org.ziptie.nio.common.Interfaces.ExceptionHandler;

public interface ExceptionHandlerInjector extends SystemLogger.Injector
{
    ExceptionHandler exceptionHandler = ExceptionHandlerImpl.create(logger);
}
