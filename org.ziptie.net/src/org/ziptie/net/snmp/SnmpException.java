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
 */
package org.ziptie.net.snmp;

/**
 * SnmpException
 */
public class SnmpException extends Exception
{
    /** <field description> */
    private static final long serialVersionUID = -7501235891969021795L;
    private SnmpError error = SnmpError.GENERAL;

    /**
     * @param error the type of error
     */
    public SnmpException(SnmpError error)
    {
        this.error = error;
    }

    /**
     * @return the error
     */
    public SnmpError getError()
    {
        return error;
    }

    /**
     * @param error the error to set
     */
    public void setError(SnmpError error)
    {
        this.error = error;
    }

    /**
     * Types of errors
     * SnmpError
     */
    public enum SnmpError
    {
        TIMEOUT,
        GENERAL,
    }

}
