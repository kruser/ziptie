package org.ziptie.provider.configstore;

/**
 * ConfigSearchTerm
 */
public class ConfigSearchTerm
{
    private String term;
    private int startOffset;
    private int endOffset;

    /**
     * Default constructor.
     */
    public ConfigSearchTerm()
    {
        // constructor
    }

    /**
     * Get the search term.
     *
     * @return the search term
     */
    public String getTerm()
    {
        return term;
    }

    /**
     * Set the search term.
     *
     * @param term the search term
     */
    public void setTerm(String term)
    {
        this.term = term;
    }

    /**
     * Get the start byte offset of the search term in the configuration.
     *
     * @return the start offset
     */
    public int getStartOffset()
    {
        return startOffset;
    }

    /**
     * Set the start byte offset of the search term i the configuration.
     *
     * @param startOffset the start offset
     */
    public void setStartOffset(int startOffset)
    {
        this.startOffset = startOffset;
    }

    /**
     * Get the end byte offset of the search term in the configuration.
     *
     * @return the end offset
     */
    public int getEndOffset()
    {
        return endOffset;
    }

    /**
     * Set the end byte offset of the search term in the configuration.
     *
     * @param endOffset the end offset
     */
    public void setEndOffset(int endOffset)
    {
        this.endOffset = endOffset;
    }
}
