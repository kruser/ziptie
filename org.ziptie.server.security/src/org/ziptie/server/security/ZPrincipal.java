package org.ziptie.server.security;

import java.io.Serializable;
import java.security.Principal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlTransient;


/**
 * ZPrincipal
 */
@Entity(name = "ZPrincipal")
@Table(name = "users")
public class ZPrincipal implements Principal, Serializable
{
    private static final long serialVersionUID = 9028283744542895150L;

    @Id
    @Column(name = "username")
    private String username;

    @Column(name = "md5password")
    private String md5pass;

    @Column(name = "fullname")
    private String fullName;

    @Column(name = "email")
    private String email;

    @ManyToOne(cascade = { })
    @JoinColumn(name = "role")
    private ZRole role;

    /**
     * Default constructor
     */
    public ZPrincipal()
    {
        // no arg constructor
    }

    /**
     * Constructor.
     *
     * @param username the username of this Principal
     * @param fullName the full name of the user (optional)
     * @param email the email address of the user (optional)
     * @param md5 the MD5 of the user's password 
     * @param role the role of the user
     */
    public ZPrincipal(String username, String fullName, String email, String md5, ZRole role)
    {
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.md5pass = md5;
        this.role = role;
    }

    /** {@inheritDoc} */
    public String getName()
    {
        return username;
    }

    /**
     * Set the username.
     *b
     * @param name the username
     */
    public void setName(String name)
    {
        this.username = name;
    }

    /**
     * Get the MD5 of the password for this user.
     *
     * @return the md5 password
     */
    @XmlTransient
    public String getMD5Password()
    {
        return md5pass;
    }

    /**
     * Set the MD5 password for this user.
     *
     * @param md5password the MD5 password
     */
    public void setMD5Password(String md5password)
    {
        this.md5pass = md5password;
    }

    /**
     * Get the role of the user.
     *
     * @return the role of the user
     */
    public ZRole getRole()
    {
        return role;
    }

    /**
     * Set the role of the user.
     *
     * @param role the role of the user
     */
    public void setRole(ZRole role)
    {
        this.role = role;
    }

    /**
     * Get the fullname of the user, if available.
     *
     * @return the fullname of the user, or null
     */
    public String getFullName()
    {
        return fullName;
    }

    /**
     * Set the full name of the user.
     *
     * @param fullName the user's full name
     */
    public void setFullName(String fullName)
    {
        this.fullName = fullName;
    }

    /**
     * Get the email address of the user.
     *
     * @return the email address
     */
    public String getEmail()
    {
        return email;
    }

    /**
     * Set the email address of the user.
     *
     * @param email the email address
     */
    public void setEmail(String email)
    {
        this.email = email;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj)
    {
        return obj != null && username.equals(obj.toString());
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode()
    {
        return username.hashCode();
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        return username;
    }
}
