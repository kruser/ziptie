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
 * Portions created by AlterPoint are Copyright (C) 2006,
 * AlterPoint, Inc. All Rights Reserved.
 */

package org.ziptie.provider.scheduler;

/**
 * SchedulerException
 */
public class SchedulerException extends java.rmi.RemoteException
{
    private static final long serialVersionUID = -4268956894104024684L;

    /**
     * Default constructor. 
     */
    public SchedulerException()
    {
        super();
    }

    /**
     * Construct an exception with the provided message and throwable.
     *
     * @param message a message
     * @param t a throwable
     */
    public SchedulerException(String message, Throwable t)
    {
        super(message, t);
    }

    /**
     * Constuct an exception with the provided message.
     *
     * @param message a message
     */
    public SchedulerException(String message)
    {
        super(message);
    }
}
