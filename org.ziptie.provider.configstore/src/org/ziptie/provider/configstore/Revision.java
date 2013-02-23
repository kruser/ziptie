package org.ziptie.provider.configstore;

/**
 * Revision
 */
public class Revision extends RevisionInfo
{
    private String content;

    /**
     * Default constructor.
     */
    public Revision()
    {
        // default constructor
    }

    /**
     * Get the contents of the configuration.  If the mime-type indicates that
     * it is a text type then the value returned is the raw text of the config,
     * otherwise it is a Base64 encoded binary.
     *
     * @return either raw text or a Base64 encoded binary 
     */
    public String getContent()
    {
        return content;
    }

    /**
     * Set the content of this revision.  Depending on the mime-type it could be
     * raw text or a Base64 encoded binary.
     *
     * @param content the content to set
     */
    public void setContent(String content)
    {
        this.content = content;
    }
}
