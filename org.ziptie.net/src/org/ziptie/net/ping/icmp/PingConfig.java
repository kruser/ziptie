/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2005
 *
 *   $Author: rkruse $
 *     $Date: 2008/06/04 02:27:37 $
 * $Revision: 1.4 $
 *  $Source: /usr/local/cvsroot/org.ziptie.net/src/org/ziptie/net/ping/icmp/PingConfig.java,v $
 */

package org.ziptie.net.ping.icmp;

import org.ziptie.common.OsTypes;

/**
 * PingSyntaxConfig provides a configuration for ping commands and arguements on RedHat Linux, Windows Server and
 * Solaris.
 */
public class PingConfig
{
    private String command;
    private String timeoutFlag;
    private String sizeFlag;
    private String countFlag;
    private OsTypes os = OsTypes.Unknown;

    /**
     * 
     */
    public PingConfig()
    {

    }

    /**
     * @return Returns the os.
     */
    public OsTypes getOs()
    {
        return os;
    }

    /**
     * @param os The os to set.
     */
    public void setOs(OsTypes os)
    {
        this.os = os;
    }

    /**
     * @return Returns the command.
     */
    public String getCommand()
    {
        return command;
    }

    /**
     * @param command The command to set.
     */
    public void setCommand(String command)
    {
        this.command = command;
    }

    /**
     * @return Returns the countFlag.
     */
    public String getCountFlag()
    {
        return countFlag;
    }

    /**
     * @param countFlag The countFlag to set.
     */
    public void setCountFlag(String countFlag)
    {
        this.countFlag = countFlag;
    }

    /**
     * @return Returns the sizeFlag.
     */
    public String getSizeFlag()
    {
        return sizeFlag;
    }

    /**
     * @param sizeFlag The sizeFlag to set.
     */
    public void setSizeFlag(String sizeFlag)
    {
        this.sizeFlag = sizeFlag;
    }

    /**
     * @return Returns the timeoutFlag.
     */
    public String getTimeoutFlag()
    {
        return timeoutFlag;
    }

    /**
     * @param timeoutFlag The timeoutFlag to set.
     */
    public void setTimeoutFlag(String timeoutFlag)
    {
        this.timeoutFlag = timeoutFlag;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode()
    {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((command == null) ? 0 : command.hashCode());
        result = prime * result + ((countFlag == null) ? 0 : countFlag.hashCode());
        result = prime * result + ((sizeFlag == null) ? 0 : sizeFlag.hashCode());
        result = prime * result + ((timeoutFlag == null) ? 0 : timeoutFlag.hashCode());
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
        final PingConfig other = (PingConfig) obj;
        if (command == null)
        {
            if (other.command != null)
            {
                return false;
            }
        }
        else if (!command.equals(other.command))
        {
            return false;
        }
        if (countFlag == null)
        {
            if (other.countFlag != null)
            {
                return false;
            }
        }
        else if (!countFlag.equals(other.countFlag))
        {
            return false;
        }
        if (sizeFlag == null)
        {
            if (other.sizeFlag != null)
            {
                return false;
            }
        }
        else if (!sizeFlag.equals(other.sizeFlag))
        {
            return false;
        }
        if (timeoutFlag == null)
        {
            if (other.timeoutFlag != null)
            {
                return false;
            }
        }
        else if (!timeoutFlag.equals(other.timeoutFlag))
        {
            return false;
        }
        return true;
    }

    /**
     * {@inheritDoc}
     */
    @SuppressWarnings("nls")
    @Override
    public String toString()
    {
        return command + " " + countFlag + " " + sizeFlag + " " + timeoutFlag;
    }
}
