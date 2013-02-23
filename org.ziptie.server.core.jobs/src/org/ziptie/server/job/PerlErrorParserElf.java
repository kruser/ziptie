/*
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 * 
 * The Original Code is Ziptie Client Framework.
 * 
 * The Initial Developer of the Original Code is AlterPoint.
 * Portions created by AlterPoint are Copyright (C) 2007,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s): Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.server.job;

import java.io.IOException;

import javax.xml.soap.SOAPFault;
import javax.xml.ws.soap.SOAPFaultException;

import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.ziptie.server.job.AdapterException.ErrorCode;

import sun.misc.BASE64Decoder;

/**
 * The {@link PerlErrorParserElf} class provides the functionality for parsing a exception that is assumed to have
 * been caught from a failed Perl process.  The parsing determines if the error acquired from Perl is representative
 * of any of the number of error codes/messages specified within the contents of the {@link PerlErrorParserElf} class.
 * These error codes/messages should match all of the exported error codes/messages that exist within the
 * <code>ZipTie::Logger</code> Perl module.  It is assumed that any error message containing one of these special
 * error codes should be considered more special than others and they will be filtered into their own unique exceptions.
 * 
 * @author Dylan White (dylamite@ziptie.org)
 */
@SuppressWarnings("nls")
public final class PerlErrorParserElf
{
    /** Hidden constructor. */
    private PerlErrorParserElf()
    {
        // do nothing
    }

    /**
     * Parses the error message contents of a specified {@link Exception} object that is assumed to have been
     * generated from a failed Perl process and attempts to construct a more defined {@link Exception} object
     * that better describes the nature of the error message.  The parsing determines if the exception is representative
     * of any of the number of error codes/messages specified within the contents of the {@link PerlErrorParserElf}
     * class.  It is assumed that any error message containing one of these special error codes/messages should be
     * considered more special than others and they will be filtered into their own unique exceptions.
     * 
     * @param errorMessage The error message that is assumed to have been generated from a failed Perl process.
     * 
     * @return If it is determined that a more defined exception could be used to describe the nature of the error
     * message, then an instance of that exception will be returned.  Otherwise, <code>null</code> will be returned.
     */
    public static AdapterException parse(String errorMessage)
    {
        if (errorMessage.contains("Backup.pm in @INC"))
        {
            StringBuilder sb = new StringBuilder();
            sb.append("Likely missing Perl module dependency.  ").append("Please run 'perlcheck.pl' located ")
              .append("in the root of your server installation to identify missing modules.\n\n").append(errorMessage);
            return new AdapterException(ErrorCode.PERL_ERROR, sb.toString());
        }
        for (ErrorCode errorCode : ErrorCode.values())
        {
            // Special case for FTP
            if (errorCode == ErrorCode.FTP_ERROR)
            {
                // Make sure that the error message contains the contents of FTP_ERROR
                // and NOT TFTP_ERROR
                if (!errorMessage.contains(ErrorCode.TFTP_ERROR.name()) && errorMessage.contains(ErrorCode.FTP_ERROR.name()))
                {
                    return new AdapterException(errorCode, errorMessage);
                }
            }
            else if (errorMessage.contains(errorCode.name()))
            {
                return new AdapterException(errorCode, errorMessage);
            }
        }

        return null;
    }

    /**
     * Get the message contents of this fault.
     * @param e The fault exception
     * @return The decoded message.
     */
    public static String getMessage(Exception e)
    {
        String msg = e.getMessage();
        String detail = msg;

        if (e instanceof SOAPFaultException)
        {
            SOAPFault fault = ((SOAPFaultException) e).getFault();
            NodeList zMsg = fault.getElementsByTagName("z:msg");
            if (zMsg != null && zMsg.getLength() > 0)
            {
                Node item = zMsg.item(0);
                detail = item.getTextContent();
            }
        }
        else
        {
            msg = "";
        }

        if (!detail.startsWith("Base64:"))
        {
            return detail;
        }

        try
        {
            StringBuilder sb = new StringBuilder(msg);
            sb.append('\n').append(new String(new BASE64Decoder().decodeBuffer(detail.substring(7))));
            return sb.toString();
        }
        catch (IOException e1)
        {
            throw new RuntimeException(e1);
        }
    }

    /**
     * Retrieves the error code string that is associated with the specified {@link Throwable} object.
     * If no error code is mapped to the exception, then the generic error code string is returned.
     * 
     * @param throwable The exception that is internally mapped to a particular error code.
     * @return The error code associated with the exception if it is mapped internally; otherwise, the generic error
     * error code is returned.
     */
    public static ErrorCode getErrorCodeFromException(Throwable throwable)
    {
        if (throwable instanceof AdapterException)
        {
            return ((AdapterException) throwable).getErrorCode();
        }
        return ErrorCode.FAILURE;
    }
}
