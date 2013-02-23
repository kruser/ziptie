package org.ziptie.provider.security;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;

/**
 * The license properties originate from a Java properties file in XML
 * format that look like this:
 * <pre>
 * &lt;?xml version="1.0" encoding="UTF-8"?>
 * &lt;!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
 * &lt;properties>
 *    &lt;comment>ZipTie License File&lt;/comment>
 *    &lt;entry key="organization">None&lt;/entry>
 *    &lt;entry key="expires">2020/01/01&lt;/entry>
 *    &lt;entry key="nodes">0&lt;/entry>
 * &lt;/properties>
 * </pre>
 */
public class License
{
    private int nodes;
    private Date expiration;
    private String organization;

    /**
     * Default constructor.
     */
    public License()
    {
        // Default constructor
    }

    /**
     * Construct from Properties.
     *
     * @param props a properties set
     */
    @SuppressWarnings("nls")
    public License(Properties props)
    {
        try
        {
            nodes = Integer.parseInt(props.getProperty("nodes", "0"));
            expiration = (new SimpleDateFormat("yyyy/MM/dd")).parse(props.getProperty("expires", "2020/01/01"));
            setOrganization(props.getProperty("organization", "None"));
        }
        catch (ParseException pe)
        {
            throw new RuntimeException("Unable to construct License.", pe);
        }
    }

    /**
     * Get the maximum supported node count.
     *
     * @return the maximum supported nodes
     */
    public int getNodes()
    {
        return nodes;
    }

    /**
     * Set the maximum supported node count.
     *
     * @param nodes
     */
    public void setNodes(int nodes)
    {
        this.nodes = nodes;
    }

    /**
     * Get the expiration date of the support license.
     *
     * @return the expiration date of support
     */
    public Date getExpiration()
    {
        return expiration;
    }

    /**
     * Set the expiration date of the support license.
     *
     * @param expiration the expiration date of support
     */
    public void setExpiration(Date expiration)
    {
        this.expiration = expiration;
    }

    /**
     * Get the organization the license is granted to.
     *
     * @return the name of the organization
     */
    public String getOrganization()
    {
        return organization;
    }

    /**
     * Set the organization the license is granted to.
     *
     * @param organization the name of the organization
     */
    public void setOrganization(String organization)
    {
        this.organization = organization;
    }
}
