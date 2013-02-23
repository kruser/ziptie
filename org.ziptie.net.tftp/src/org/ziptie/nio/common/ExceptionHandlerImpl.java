/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2006
 *
 *   $Author: brettw $
 *     $Date: 2007/04/19 21:42:08 $
 * $Revision: 1.1 $
 *   $Source: /usr/local/cvsroot/org.ziptie.net.tftp/src/org/ziptie/nio/common/ExceptionHandlerImpl.java,v $
 */

package org.ziptie.nio.common;

import org.ziptie.nio.common.Interfaces.ExceptionHandler;
import org.ziptie.nio.nioagent.WrapperException;


public class ExceptionHandlerImpl implements ExceptionHandler
{
    // -- fields
    ILogger logger;

    // -- constructors
    private ExceptionHandlerImpl()
    {
        // do nothing
    }

    // -- public methods
    public static ExceptionHandler create(final ILogger logger)
    {
        ExceptionHandlerImpl impl = new ExceptionHandlerImpl();
        impl.logger = logger;
        return impl;
    }

    //    * ExceptionHandler
    public WrapperException handle(String msg, Exception e)
    {
        logger.error(msg, e);
        return new WrapperException(e);
    }

}

// -------------------------------------------------
// $Log: ExceptionHandlerImpl.java,v $
// Revision 1.1  2007/04/19 21:42:08  brettw
// Genesis for NIO TFTP server.
//
// Revision 1.1  2006/10/05 23:16:14  BEdwards
// initial commit
//
// Revision 1.2  2006/08/22 05:06:48  BEdwards
// add an interop test that uses apache commons net tftp client to receive and send files to the blackrat tftp server
//
// Revision 1.1  2006/08/21 15:48:06  BEdwards
// nail down the organization of the classes in the tftp package.  formerly the logical split was between a byte level codec and a field level protocol.  this worked when the server was simple, but once abstractions for DataConsumer, DataProducer, Security Manager, and EventListener were introduced things got really messy.  Now the codec/protocol classes are aligned with packet type ack, data, and a server codec that handles requests and delegates to an ack or data codec.  This makes things cleaner, most notably there are no extranious member fields that are null depending on the operation (file put or get).
//
// Revision 1.1  2006/08/18 18:49:01  BEdwards
// tests for yahoo fix (13651), plus test utility classes
//
// Revision 1.0 Aug 17, 2006 bedwards
// Initial revision
// --------------------------------------------------
