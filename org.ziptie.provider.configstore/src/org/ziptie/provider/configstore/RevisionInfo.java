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
 * Copyright the ZipTie Project (www.ziptie.org)
 */

package org.ziptie.provider.configstore;

import java.io.File;
import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;
import javax.xml.bind.annotation.XmlTransient;

/**
 * RevisionInfo
 */
@Entity(name = "RevisionInfo")
@Table(name = "revisions")
@IdClass(RevisionInfo.RevisionInfoPk.class)
public class RevisionInfo
{
    @Id
    @Column(name = "association_id")
    private int associationId;

    @Id
    @Column(name = "revision_time")
    @Temporal(TemporalType.TIMESTAMP)
    private Date lastChanged;

    @Id
    @Column(name = "path")
    private String path;

    @Column(name = "author")
    private String author;

    @Column(name = "head")
    private boolean isHead;

    @Column(name = "mime_type")
    private String mimeType;

    @Column(name = "size")
    private int size;

    @Column(name = "type")
    private String type;

    @Column(name = "crc32")
    private long crc32;

    @Column(name = "prev_revision_time")
    @Temporal(TemporalType.TIMESTAMP)
    private Date pervChange;

    @Transient
    private File file;

    /**
     * Default constructor.
     */
    public RevisionInfo()
    {
        // default constructor
    }

    /**
     * @return the author
     */
    public String getAuthor()
    {
        return author;
    }

    /**
     * @param author the author to set
     */
    public void setAuthor(String author)
    {
        this.author = author;
    }

    /**
     * @return the lastChanged
     */
    public Date getLastChanged()
    {
        return lastChanged;
    }

    /**
     * @param lastChanged the lastChanged to set
     */
    public void setLastChanged(Date lastChanged)
    {
        this.lastChanged = lastChanged;
    }

    /**
     * Get the timestamp of the previous change for this configuration.
     *
     * @return the timestamp of the previous change, or null
     */
    public Date getPervChange()
    {
        return pervChange;
    }

    /**
     * Set the timestamp of the previous change for this configuration.
     *
     * @param pervChange the timestamp of the previous change, or null
     */
    public void setPervChange(Date pervChange)
    {
        this.pervChange = pervChange;
    }

    /**
     * @return the mimeType
     */
    public String getMimeType()
    {
        return mimeType;
    }

    /**
     * @param mimeType the mimeType to set
     */
    public void setMimeType(String mimeType)
    {
        this.mimeType = mimeType;
    }

    /**
     * @return the path
     */
    public String getPath()
    {
        return path;
    }

    /**
     * @param path the path to set
     */
    public void setPath(String path)
    {
        this.path = path;
    }

    /**
     * @return the size
     */
    public int getSize()
    {
        return size;
    }

    /**
     * @param size the size to set
     */
    public void setSize(int size)
    {
        this.size = size;
    }

    /**
     * Is this a head revision.
     *
     * @return true if a head revision, false otherwise
     */
    @XmlTransient
    public boolean isHead()
    {
        return isHead;
    }

    /**
     * Set this as a head revision.
     *
     * @param head true if a head revision, false otherwise
     */
    public void setHead(boolean head)
    {
        this.isHead = head;
    }

    /**
     * Get the type of revision.
     * <pre>
     *    A - addition
     *    M - modification
     *    D - deletion
     * </pre>
     * 
     * @return the type of revision
     */
    @XmlTransient
    public String getType()
    {
        return type;
    }

    /**
     * Set the type of revision.
     *
     * @param type the type of revision
     */
    public void setType(String type)
    {
        this.type = type;
    }

    /**
     * Get the temporary file storing this revision.
     *
     * @return the temp file
     */
    @XmlTransient
    public File getFile()
    {
        return file;
    }

    /**
     * Set the temporary file storing this revision.
     *
     * @param file the temp file
     */
    public void setFile(File file)
    {
        this.file = file;
    }

    /**
     * Get the association id.
     *
     * @return the association id
     */
    @XmlTransient
    public int getAssociationId()
    {
        return associationId;
    }

    /**
     * Set the association id.
     *
     * @param associationId the association id
     */
    public void setAssociationId(int associationId)
    {
        this.associationId = associationId;
    }

    /**
     * Get the CRC32 value of the revision.
     *
     * @return the CRC32 value
     */
    public long getCrc32()
    {
        return crc32;
    }

    /**
     * Set the CRC32 of the revision.
     *
     * @param crc32 the CRC32 value
     */
    public void setCrc32(long crc32)
    {
        this.crc32 = crc32;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        try
        {
            RevisionInfoPk other = (RevisionInfoPk) obj;
            return this.getAssociationId() == other.associationId && this.lastChanged.equals(other.lastChanged) && this.path.equals(other.path);
        }
        catch (ClassCastException cce)
        {
            return false;
        }
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return path.hashCode() ^ getAssociationId();
    }

    // ---------------------------------------------------------------
    //              JPA Primary Key class
    // ---------------------------------------------------------------

    /**
     * RevisionInfoPk - JPA Primary Key class
     */
    @Embeddable
    public static class RevisionInfoPk implements Serializable
    {
        private static final long serialVersionUID = -5639904871136428776L;

        @Column(name = "association_id")
        private int associationId;

        @Column(name = "revision_time")
        @Temporal(TemporalType.TIMESTAMP)
        private Date lastChanged;

        @Column(name = "path")
        private String path;

        /** {@inheritDoc} */
        @Override
        public boolean equals(Object obj)
        {
            try
            {
                RevisionInfoPk other = (RevisionInfoPk) obj;
                return this.associationId == other.associationId && this.lastChanged.equals(other.lastChanged) && this.path.equals(other.path);
            }
            catch (ClassCastException cce)
            {
                return false;
            }
        }

        /** {@inheritDoc} */
        @Override
        public int hashCode()
        {
            return path.hashCode() ^ associationId;
        }
    }
}
