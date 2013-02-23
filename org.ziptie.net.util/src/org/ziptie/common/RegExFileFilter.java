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

package org.ziptie.common;

import java.io.File;
import java.io.FilenameFilter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

/**
 * 
 * RegExFileFilter
 */
public class RegExFileFilter implements FilenameFilter
{
    private String strRegEx;

    /**
     * default constructor
     *
     */
    public RegExFileFilter()
    {
        strRegEx = ".*";
    }

    /**
     * 
     * @param strRegEx a specific regex
     */
    public RegExFileFilter(String strRegEx)
    {
        this.strRegEx = strRegEx;
    }

    /**
     * {@inheritDoc}
     */
    public boolean accept(File dir, String strFilename)
    {
        try
        {
            Pattern pattern = Pattern.compile(strRegEx, Pattern.MULTILINE);
            Matcher matcher = pattern.matcher(strFilename);

            if (matcher.find())
            {
                return true;
            }
        }
        catch (PatternSyntaxException pse)
        {
            throw new RuntimeException(pse);
        }
        return false;
    }

    /**
     * 
     * @param strText text to match
     * @param strRegEx a regex to use
     * @return true if there is a match
     */
    public static boolean matches(String strText, String strRegEx)
    {
        try
        {
            Pattern pattern = Pattern.compile(strRegEx, Pattern.MULTILINE);
            Matcher matcher = pattern.matcher(strText);

            if (matcher.find())
            {
                return true;
            }
        }
        catch (PatternSyntaxException pse)
        {
            throw new RuntimeException(pse);
        }
        return false;
    }
}
