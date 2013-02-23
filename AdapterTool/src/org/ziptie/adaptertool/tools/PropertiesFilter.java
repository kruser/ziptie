package org.ziptie.adaptertool.tools;

import java.io.File;
import java.io.FilenameFilter;

/**
 * Filter for properties files
 */
public class PropertiesFilter implements FilenameFilter
{
    public static final String PROPERTIES_SUFFIX = ".properties";

    /**
     * {@inheritDoc}
     */
    public boolean accept(File dir, String name)
    {
        return name.endsWith(PROPERTIES_SUFFIX) && !name.contains("_");
    }

}
