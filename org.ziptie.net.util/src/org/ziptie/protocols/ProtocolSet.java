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
 * 
 * Contributor(s):
 */

package org.ziptie.protocols;

import java.io.Serializable;
import java.util.Set;
import java.util.TreeSet;

/**
 * Container of <code>Protocol</code> objects
 * 
 * @author rkruse
 */
public class ProtocolSet implements Serializable
{
    public static final String DELIMITER = "-";

    private static final String NULL = "NULL";
    private static final long serialVersionUID = -2578037982620562634L;
    private static final int UNSAVED_ID = -1;

    private Set<Protocol> protocols;
    private long protocolConfigId = UNSAVED_ID;
    private long id = UNSAVED_ID;

    /**
     * Default constructor needed for any web services to utilize the <code>ProtocolSet</code> class.
     */
    public ProtocolSet()
    {
        this.protocols = new TreeSet<Protocol>();
    }

    /**
     * 
     * @param protocols
     */
    public ProtocolSet(Set<Protocol> protocols)
    {
        this.protocols = protocols;
    }

    /**
     * 
     * @return
     */
    public Set<Protocol> getProtocols()
    {
        return protocols;
    }

    /**
     * 
     * @param protocol
     */
    public void addProtocol(Protocol protocol)
    {
        protocols.add(protocol);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString()
    {
        return getName();
    }

    /**
     * Prints out detailed information similar to {@link #getName()} but with
     * some inline parameters.
     * 
     * @return the detailed information
     */
    public String detailedInfo()
    {
        StringBuilder buffer = new StringBuilder();
        if (protocols != null)
        {
            int counter = 0;
            for (Protocol protocol : protocols)
            {
                if (counter > 0)
                {
                    buffer.append(DELIMITER);
                }

                if (protocol != null && protocol.getName() != null)
                {
                    buffer.append(protocol.getName());
                    String versionString = protocol.getProperty(ProtocolConstants.VERSION);
                    if (versionString != null)
                    {
                        buffer.append("(" + versionString);
                        String cipherString = protocol.getProperty(ProtocolConstants.CIPHER);
                        if (cipherString != null)
                        {
                            buffer.append("|" + cipherString);
                        }
                        buffer.append(")");
                    }
                }
                else
                {
                    buffer.append(NULL);
                }
                counter++;
            }
        }
        return buffer.toString();
    }

    /**
     * 
     * @return the name of this protocol set
     */
    public String getName()
    {
        StringBuilder buffer = new StringBuilder();

        if (protocols != null)
        {
            int counter = 0;
            for (Protocol protocol : protocols)
            {
                if (counter > 0)
                {
                    buffer.append(DELIMITER);
                }

                if (protocol != null && protocol.getName() != null)
                {
                    buffer.append(protocol.getName());
                }
                else
                {
                    buffer.append(NULL);
                }
                counter++;
            }
        }

        return buffer.toString();
    }

    /**
     * 
     * @param protocols the protocols
     */
    public void setProtocols(Set<Protocol> protocols)
    {
        this.protocols = protocols;
    }

    /**
     * The protocolConfig that these are generated from will set this ID field
     * to be used in persistence.
     * 
     * @return the protocolConfigId
     */
    public long getProtocolConfigId()
    {
        return protocolConfigId;
    }

    /**
     * The protocolConfig that these are generated from will set this ID field
     * to be used in persistence.
     * 
     * @param protocolConfigId the protocolConfigId to set
     */
    public void setProtocolConfigId(long protocolConfigId)
    {
        this.protocolConfigId = protocolConfigId;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (id ^ (id >>> 32));
        return result;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object obj)
    {
        if (this == obj)
        {
            return true;
        }
        if (obj == null)
        {
            return false;
        }
        if (getClass() != obj.getClass())
        {
            return false;
        }
        final ProtocolSet other = (ProtocolSet) obj;
        if ((id > UNSAVED_ID) && other.getId() > UNSAVED_ID)
        {
            return (id == other.getId());
        }
        else
        {
            if (id != other.getId())
            {
                return false;
            }
            if (protocols == null)
            {
                if (other.protocols != null)
                {
                    return false;
                }
            }
            else if (!protocols.equals(other.protocols))
            {
                return false;
            }
            return true;
        }
    }

    /**
     * @return Returns the id.
     */
    public long getId()
    {
        return id;
    }

    /**
     * @param id The id to set.
     */
    public void setId(long id)
    {
        this.id = id;
    }
}
