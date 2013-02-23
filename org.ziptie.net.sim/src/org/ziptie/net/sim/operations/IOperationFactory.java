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

import java.net.URI;
import java.util.Collection;

import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.util.IpAddress;

/**
 * Interface into session factories.
 * A session factory returns IInteractionSession for a given name.
 */
public interface IOperationFactory
{
    /**
     * Creates a new IOperation for the given uri.
     * @param config The WorkingConfig to use for the duration of this operation
     * @param remoteIp The remote IP that this operation will run against.
     * @param localIp The local IP that this operation will run with.
     * @return A new IOperation
     * @throws NoSuchOperationException If the operation does not exist
     */
    public IOperation createOperation(WorkingConfig config, IpAddress remoteIp, IpAddress localIp) throws NoSuchOperationException;

    /**
     * These names do not contain the prefixes which would map them back to this factory.
     * <p>Returns a Collection&lt;{@link URI}&gt;
     * @see IOperationFactory#getPathPrefix()
     * @return A Collection of Identifiers for available sessions.
     */
    public Collection enumerateSessions();

    /**
     * This will get the prefix for a session reference.
     * <p>The prefix is what denotes which SessionFactory to use.
     * <p><i>(For a recording this would return "recording" as in "recording://such/andsuch.record)</i>
     * @return The string which should prefix a session reference for configuration.
     */
    public String getPathPrefix();
}
