/* Alterpoint, Inc.
*
* The contents of this source code are proprietary and confidential
* All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2005
*
*   $Author: lbayer $
*     $Date: 2007/04/03 23:51:09 $
* $Revision: 1.3 $
*  $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/net/ping/icmp/PingException.java,v $
*/

package org.ziptie.net.ping.icmp;

/**
 * 
 */
public class PingException extends Exception
{

    /**
     * 
     */
    private static final long serialVersionUID = -6395726805276550716L;

    /**
     * 
     * @param message the message
     */
    public PingException(String message)
    {
        super(message);
    }

    /**
     * @param message the message
     * @param cause the cause
     */
    public PingException(String message, Throwable cause)
    {
        super(message, cause);
    }

    /**
     * @param cause the cause
     */
    public PingException(Throwable cause)
    {
        super(cause);
    }

}
