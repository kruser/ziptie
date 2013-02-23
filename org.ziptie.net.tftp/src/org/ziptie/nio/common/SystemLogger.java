/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/04/19 21:42:08 $
 * $Revision: 1.1 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net.tftp/src/org/ziptie/nio/common/SystemLogger.java,v $
 */

package org.ziptie.nio.common;

import java.io.PrintStream;

public class SystemLogger implements ILogger
{

    // -- static fields
    private static final PrintStream err = System.err;
    private static final PrintStream out = System.out;
    private static final Level loggerLevel = Level.ERROR;

    // -- constructors
    public SystemLogger()
    {
        // do nothing
    }

    // -- public methods
    public void error(Object msg)
    {
        printIfEnabled(Level.ERROR, err, msg);
    }

    public void error(Object msg, Throwable t)
    {
        printIfEnabled(Level.ERROR, err, concatMsgE(msg, t));
    }

    public void warn(Object msg)
    {
        printIfEnabled(Level.WARN, err, msg);
    }

    public void warn(Object msg, Throwable t)
    {
        printIfEnabled(Level.WARN, err, concatMsgE(msg, t));
    }

    public void info(Object msg)
    {
        printIfEnabled(Level.INFO, out, msg);
    }

    public void info(Object msg, Throwable t)
    {
        printIfEnabled(Level.INFO, out, concatMsgE(msg, t));
    }

    public void debug(Object msg)
    {
        printIfEnabled(Level.DEBUG, out, msg);
    }

    public void debug(Object msg, Throwable t)
    {
        printIfEnabled(Level.DEBUG, out, concatMsgE(msg, t));
    }

    // -- private methods
    private static void print(PrintStream stream, Object msg)
    {
        stream.println(msg);
        stream.flush();
    }

    private static String concatLevelMsg(Level level, Object msg)
    {
        return "[" + level + "] " + msg;
    }

    private static boolean isEnabled(Level level)
    {
        return 1 > loggerLevel.compareTo(level);
    }

    private static void printIfEnabled(Level level, PrintStream stream, Object msg)
    {
        if (isEnabled(level))
        {
            print(stream, concatLevelMsg(level, msg));
        }
    }

    private static String concatMsgE(Object msg, Throwable t)
    {
        String concatedMsg = msg + " " + t + "\n";
        for (StackTraceElement elem : t.getStackTrace())
        {
            concatedMsg += "  " + elem + "\n";
        }
        return concatedMsg;
    }

    // inner classes
    public static interface Injector
    {
        public static final ILogger logger = new SystemLogger();
    }

}

// -------------------------------------------------
// $Log: SystemLogger.java,v $
// Revision 1.1  2007/04/19 21:42:08  brettw
// Genesis for NIO TFTP server.
//
// Revision 1.2  2006/11/06 21:08:21  BEdwards
// use throwable instead of exception
//
// Revision 1.1  2006/10/05 23:16:14  BEdwards
// initial commit
//
// Revision 1.3  2006/09/11 17:32:45  BEdwards
// lazy evaluation of hex dump when logging debug messages
//
// Revision 1.2  2006/08/22 03:26:06  BEdwards
// collapse injectors into parent classes file.  synch up common classes with latest changes in blackrat
//
// Revision 1.1  2006/08/18 18:49:01  BEdwards
// tests for yahoo fix (13651), plus test utility classes
//
// Revision 1.0 Aug 17, 2006 bedwards
// Initial revision
// --------------------------------------------------
