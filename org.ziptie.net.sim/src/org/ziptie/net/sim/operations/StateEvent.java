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
 * Contributor(s):
 */

package org.ziptie.net.sim.operations;

/**
 * An event used with {@link IStateListener}s.
 */
public class StateEvent
{
    public static final String CONNECTED = "connected";
    public static final String DISCONNECTED = "disconnected";
    public static final String INPUT = "input";
    public static final String OUTPUT = "output";
    public static final String ERROR = "error";
    public static final String INFO = "info";

    private IOperation source;
    private String type;
    private CharSequence message;
    private Throwable throwable;

    public StateEvent(IOperation source, String type, CharSequence message)
    {
        this.source = source;
        this.type = type;
        this.message = message;
    }

    public StateEvent(IOperation source, String type, CharSequence message, Throwable t)
    {
        this.source = source;
        this.type = type;
        this.message = message;
        this.throwable = t;
    }

    /**
     * @return Returns the type.
     */
    public String getType()
    {
        return type;
    }

    /**
     * @return Returns the message.
     */
    public CharSequence getMessage()
    {
        return message;
    }

    /**
     * @return Returns the source.
     */
    public IOperation getSource()
    {
        return source;
    }

    /**
     * @return the target throwable or <code>null</code> if none exists
     */
    public Throwable getThrowable()
    {
        return throwable;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    public String toString()
    {
        return "{" + source + ", " + type + ": " + message + "}";
    }
}
