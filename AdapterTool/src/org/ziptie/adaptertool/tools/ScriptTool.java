package org.ziptie.adaptertool.tools;

import java.io.File;
import java.util.Properties;

/**
 * Contains the script properties and the file reference
 * 
 * ScriptTool
 */
public class ScriptTool
{
    private Properties properties;
    private File perlScript;

    /**
     * Build a ScriptTool reference
     * 
     * @param properties the props of the tools
     * @param perlScript a reference to the Perl script
     */
    public ScriptTool(Properties properties, File perlScript)
    {
        this.properties = properties;
        this.perlScript = perlScript;
    }

    /**
     * Get the displayable name of this tool.
     * 
     * @return the name
     */
    public String getToolName()
    {
        return properties.getProperty("menu.label");
    }

    /**
     * @return the perlScript
     */
    public File getPerlScript()
    {
        return perlScript;
    }

    /**
     * @param perlScript the perlScript to set
     */
    public void setPerlScript(File perlScript)
    {
        this.perlScript = perlScript;
    }

    /**
     * @return the properties
     */
    public Properties getProperties()
    {
        return properties;
    }

    /**
     * @param properties the properties to set
     */
    public void setProperties(Properties properties)
    {
        this.properties = properties;
    }
}
