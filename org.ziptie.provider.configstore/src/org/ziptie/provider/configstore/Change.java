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
package org.ziptie.provider.configstore;

import java.util.Date;

/**
 * Change
 */
public class Change
{
    private String author;
    private String path;
    private String mimeType;
    private char type;
    private boolean isFile;
    private long size;
    private Date previousChange;

    /**
     * Default constructor.
     */
    public Change()
    {
        // default constructor
    }

    /**
     * Get the author of the change.
     *
     * @return the author
     */
    public String getAuthor()
    {
        return author;
    }

    /**
     * Set the author of the change.
     *
     * @param author the author
     */
    public void setAuthor(String author)
    {
        this.author = author;
    }

    /**
     * Get the path of the configuration file, including the
     * name of the configuration file itself.
     *
     * @return the path of the configuration file
     */
    public String getPath()
    {
        return path;
    }

    /**
     * Set the path of the configuration file, including the
     * name of the configuration file itself.
     *
     * @param path the path of the configuration file
     */
    public void setPath(String path)
    {
        this.path = path;
    }

    /**
     * Get the type of change.  This value is one of {A,U,D} representing
     * whether this change was an addition to the repository, an update
     * to an existing configuration, or a removal of a configuration.
     *
     * @return the type of change
     */
    public char getType()
    {
        return type;
    }

    /**
     * Set the type of change to the repository this was.  The value
     * should be one of {A,U,D}
     * 
     * @param c the type of change
     */
    public void setType(char c)
    {
        this.type = c;
    }

    /**
     * Get the mime-type of the configuration file represented by this change.
     *
     * @return the mime-type of the configuration
     */
    public String getMimeType()
    {
        return mimeType;
    }

    /**
     * Set the mime-type of the configuration file represented by this change.
     *
     * @param mimeType the mime-type
     */
    public void setMimeType(String mimeType)
    {
        this.mimeType = mimeType;
    }

    /**
     * Is this entry a directory or a file?
     *
     * @return true if the entry is a directory, false if a file
     */
    public boolean isFile()
    {
        return isFile;
    }

    /**
     * Set whether this entry is a directory or a file.
     *
     * @param isaFile true if the entry is a directory, false if a file
     */
    public void setFile(boolean isaFile)
    {
        this.isFile = isaFile;
    }

    /**
     * Get the size of the configuration this change represents.
     *
     * @return the size the size
     */
    public long getSize()
    {
        return size;
    }

    /**
     * Set the size of the configuration this change represents.
     *
     * @param size the size
     */
    public void setSize(long size)
    {
        this.size = size;
    }

    /**
     * Get the timestamp of the previous change for this configuration.
     *
     * @return the timestamp of the previous change, or null
     */
    public Date getPreviousChange()
    {
        return previousChange;
    }

    /**
     * Set the timestamp of the previous change for this configuration.
     *
     * @param previousChange the timestamp of the previous change, or null
     */
    public void setPreviousChange(Date previousChange)
    {
        this.previousChange = previousChange;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return String.format("(%c,%s,%s,%s)", type, path, isFile, mimeType); //$NON-NLS-1$
    }
}
