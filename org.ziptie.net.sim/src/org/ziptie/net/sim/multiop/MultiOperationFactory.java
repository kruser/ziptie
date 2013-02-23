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

package org.ziptie.net.sim.multiop;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.ziptie.net.sim.config.WorkingConfig;
import org.ziptie.net.sim.exceptions.NoSuchFactoryException;
import org.ziptie.net.sim.exceptions.NoSuchOperationException;
import org.ziptie.net.sim.operations.IOperation;
import org.ziptie.net.sim.operations.IOperationFactory;
import org.ziptie.net.sim.operations.OperationManager;
import org.ziptie.net.sim.util.IpAddress;

/**
 * Factory which supports iteration of operations.  This allows for change scenarios where two consecutive backups run two different recordings.
 */
public class MultiOperationFactory implements IOperationFactory
{
    private static final Logger LOG = Logger.getLogger(MultiOperationFactory.class);

    public static final String PREFIX = "multi";

    /** {@link Map}&lt;{@link Long}, {@link Integer}&gt; */
    private Map cursors = new HashMap();

    /**
     * Hidden constructor.
     * @see #getInstance()
     */
    private MultiOperationFactory()
    {
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.operations.IOperationFactory#createOperation(org.ziptie.net.sim.config.WorkingConfig, org.ziptie.net.sim.util.IpAddress, org.ziptie.net.sim.util.IpAddress)
     */
    public IOperation createOperation(WorkingConfig config, IpAddress remoteIp, IpAddress localIp) throws NoSuchOperationException
    {
        URI[] uris = extractOperationUris(config.getOperationUri());
        if (uris.length == 0)
        {
            throw new NoSuchOperationException("Invalid multi URI, no operations specified. " + config.getOperationUri());
        }

        Long key = longify(localIp, remoteIp);
        int index = getCursor(key);
        try
        {
            if (index >= uris.length)
            {
                index = 0;
            }

            IOperationFactory factory = OperationManager.getInstance().getFactory(uris[index]);

            WorkingConfig wc = config.copy();
            wc.setOperationUri(uris[index]);

            // increment the cursor
            index++;
            setCursor(key, index < uris.length ? index : 0);

            return factory.createOperation(wc, remoteIp, localIp);
        }
        catch (NoSuchFactoryException e)
        {
            throw new NoSuchOperationException("Invalid operation: " + uris[index], e);
        }
    }

    public URI findFirstUri(URI op) throws NoSuchOperationException
    {
        URI[] uris = extractOperationUris(op);
        if (uris.length == 0)
        {
            throw new NoSuchOperationException("Invalid multi URI, no operations specified. " + op);
        }
        return uris[0];
    }

    /**
     * Splits the uri on semicolon (';') and returns an array of {@link URI}s containing each segment.
     * @param uri
     * @return
     */
    private URI[] extractOperationUris(URI uri)
    {
        String str = uri.getSchemeSpecificPart();
        String[] ops = str.split(";");
        List uris = new ArrayList();
        for (int i = 0; i < ops.length; i++)
        {
            ops[i] = ops[i].trim();
            if (ops[i].length() > 0)
            {
                try
                {
                    URI part = new URI(ops[i]);
                    if (part.getScheme().equals(PREFIX))
                    {
                        LOG.warn("Multi operations should not contain other multi operations! " + uri);
                    }
                    uris.add(part);
                }
                catch (URISyntaxException e)
                {
                    LOG.warn("Invalid URI: " + ops[i], e);
                }
            }
        }
        return (URI[]) uris.toArray(new URI[uris.size()]);
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.operations.IOperationFactory#enumerateSessions()
     */
    public Collection enumerateSessions()
    {
        return Collections.EMPTY_LIST;
    }

    /* (non-Javadoc)
     * @see org.ziptie.net.sim.operations.IOperationFactory#getPathPrefix()
     */
    public String getPathPrefix()
    {
        return PREFIX;
    }

    /**
     * Sets the current cursor location for the given key.
     * @see #longify(IpAddress, IpAddress)
     * @param key
     * @param value
     */
    private void setCursor(Long key, int value)
    {
        cursors.put(key, new Integer(value));
    }

    /**
     * Gets the current cursor location for the given key.
     * @see #longify(IpAddress, IpAddress)
     * @param key
     * @return
     */
    private int getCursor(Long key)
    {
        Integer cur = (Integer) cursors.get(key);
        if (cur == null)
        {
            return 0;
        }
        return cur.intValue();
    }

    /**
     * Convert two IpAddresses into a long value for easy reference.
     * @param local
     * @param remote
     * @return
     */
    private Long longify(IpAddress local, IpAddress remote)
    {
        return new Long(local.getIntValue() << 32 | remote.getIntValue());
    }

    /**
     * Resets the multi operation for the given connection so that the next connection will start at the begin of the sequence.
     * @param local
     * @param remote
     */
    public void resetCursor(IpAddress local, IpAddress remote)
    {
        setCursor(longify(local, remote), 0);
    }

    //////////////////////////////////////////////////////////
    // Factory method...
    //////////////////////////////////////////////////////////
    private static MultiOperationFactory instance;

    public static synchronized MultiOperationFactory getInstance()
    {
        if (instance == null)
        {
            instance = new MultiOperationFactory();
        }
        return instance;
    }
}
