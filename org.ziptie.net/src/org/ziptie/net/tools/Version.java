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
 * Contributor(s): Dylan White (dylamite@ziptie.org)
 */

package org.ziptie.net.tools;

import java.util.Arrays;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * This class handle the conversion of a string version (such as software
 * version) to a canonical form so that <, > operators can be used on the
 * version.
 */
@SuppressWarnings("nls")
public class Version
{
    // -- Members
    private String textVersion;
    private String canonVersion;
    private String regex;

    /**
     * Public constructor which creates a new <code>Version</code> object with its text version,
     * canonical version, and regular expression attributes all set to empty ("") strings.
     */
    public Version()
    {
        textVersion = "";
        canonVersion = "";
        regex = "";
    }

    /**
     * Public constructor with takes a string version and regular expression. The regular expression
     * should be such that it should have groups (delimited by parentheses). The
     * purpose of the groups is to extract the different numerical parts of the
     * version and construct a canonical form (double) from the version string.
     * The first group is the entire match (and it is ignored). The second group
     * is the the numerical part before the decimal place. The rest of groups
     * are zero padded (to a maximum length of 4 for each group).
     * 
     * @param strTextVersion
     *            The text version string.
     * @param strRegex
     *            The regular expression pattern to be used to compute the
     *            canonical form of the version for <,>comparisons.
     */
    public Version(String strTextVersion, String strRegex)
    {
        textVersion = strTextVersion;
        regex = strRegex;
        canonVersion = computeCanonicalVersion();
    }

    /**
     * Retrieves the original text version string before any canonical computation has been performed on it.
     * 
     * @return The original text version string before any canonical computation has been performed on it.
     */
    public String getTextVersion()
    {
        return textVersion;
    }

    /**
     * Sets the text version string that will eventually have canonical computation has been performed on it.
     * 
     * @param strTextVersion A string representing the text version that will eventually have canonical computation has been performed on it.
     */
    public void setTextVersion(String strTextVersion)
    {
        textVersion = strTextVersion;
    }

    /**
     * Retrieves the regular expression string that is used to extract information from this <code>Version</code>
     * object's text version string and have canonical computation has been performed on it.
     * 
     * @return The regular expression string that is used to extract information from this <code>Version</code>
     * object's text version string and have canonical computation has been performed on it.
     */
    public String getRegEx()
    {
        return regex;
    }

    /**
     * Sets the regular expression string that will eventually be used to extract information from this <code>Version</code>
     * object's text version string and have canonical computation has been performed on it.
     * 
     * @param strRegex The regular expression string that will eventually be used to extract information from this <code>Version</code>
     * object's text version string and have canonical computation has been performed on it.
     */
    public void setRegEx(String strRegex)
    {
        regex = strRegex;
    }

    /**
     * Retrieves the canonical version string that was computed by the <code>computeCanonicalVersion()</code> method.
     * <p>
     * <p>
     * The canonical version is a decimal value of the version used to compare
     * versions to each other. For example, 12A is an earlier version than 12B,
     * but they can't be compared using math comparators, so they are translated
     * first and then compared.
     * 
     * @return The canonical version string that was computed by the <code>computeCanonicalVersion()</code> method.
     */
    public String getCanonicalVersion()
    {
        return canonVersion;
    }

    /**
     * Computes the canonical version of specified text version using a specified regular expression.
     * The regular expression should be such that it should have groups (delimited by parentheses). The
     * purpose of the groups is to extract the different numerical parts of the
     * version and construct a canonical form (double) from the version string.
     * The first group is the entire match (and it is ignored). The second group
     * is the the numerical part before the decimal place. The rest of groups
     * are zero padded (to a maximum length of 4 for each group).
     * 
     * @param strTextVersion String that will eventually have canonical computation has been performed on it.
     * @param strRegex String that will eventually be used to extract information from this <code>Version</code>
     * object's text version string and have canonical computation has been performed on it.
     * @return The canonical version of the specified text version string.
     */
    public String computeCanonicalVersion(String strTextVersion, String strRegex)
    {
        setTextVersion(strTextVersion);
        setRegEx(strRegex);
        return computeCanonicalVersion();
    }

    /**
     * Computes the canonical version of this <code>Version</code> object's text version using the regular expression
     * stored on this <code>Version</code> object. The regular expression should be such that it should have groups
     * (delimited by parentheses). The purpose of the groups is to extract the different numerical parts of the
     * version and construct a canonical form (double) from the version string. The first group is the entire match
     * (and it is ignored). The second group is the the numerical part before the decimal place. The rest of groups
     * are zero padded (to a maximum length of 4 for each group).
     * <p>
     * <p>
     * Running input regex against the string should return groups that fit in
     * the following categories:
     * <ul>
     * <li>null
     * <li>int (e.g. "12", "8")
     * <li>alpha (e.g. "a", "AA")
     * </ul>
     */
    public String computeCanonicalVersion()
    {
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(textVersion);
        boolean match = m.matches();
        final int maxGroups = 16;
        final int groupLength = 16;
        char[] canonChars = new char[maxGroups * groupLength];
        final char nullChar = '-';
        Arrays.fill(canonChars, nullChar);

        if (match)
        {
            int groupCount = Math.min(m.groupCount(), maxGroups);
            int offset = 0;

            // skip group 0, because it is the entire match
            for (int i = 1; i <= groupCount; i++)
            {
                char[] groupVal = new char[groupLength];
                Arrays.fill(groupVal, nullChar);
                String groupStr = m.group(i);
                if (groupStr != null && 0 < groupStr.length())
                {
                    groupStr.getChars(0, Math.min(groupStr.length(), groupVal.length), groupVal, 0);
                    if (groupVal.length > groupStr.length() && Character.isDigit(groupVal[0]))
                    {
                        // right align numbers
                        int numToShift = groupVal.length - groupStr.length();
                        System.arraycopy(groupVal, 0, groupVal, numToShift, groupVal.length - numToShift);
                        Arrays.fill(groupVal, 0, numToShift, nullChar);
                    }
                    System.arraycopy(groupVal, 0, canonChars, offset, groupVal.length);
                }
                offset += groupLength;
            }

        }

        return new String(canonChars);
    }

    /**
     * Determines whether or not another <code>Version</code> object is equal to this <code>Version</code> object.
     * Two <code>Version</code> objects are equal to each other if their text version, canonical version, and regular
     * expressions strings are all equal to each other.
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
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

        try
        {
            Version other = (Version) obj;

            boolean textVersionEquals = false;

            if (getTextVersion() != null)
            {
                textVersionEquals = getTextVersion().equals(other.getTextVersion());
            }
            else if (other.getTextVersion() == null)
            {
                textVersionEquals = true;
            }

            boolean regexEquals = false;

            if (getRegEx() != null)
            {
                regexEquals = getRegEx().equals(other.getRegEx());
            }
            else if (other.getRegEx() == null)
            {
                regexEquals = true;
            }

            boolean canonicalVersionEquals = getCanonicalVersion().equals(other.getCanonicalVersion());
            return textVersionEquals && regexEquals && canonicalVersionEquals;
        }
        catch (ClassCastException ex)
        {
            return false;
        }
    }

    /**
     * Generates an integer representation of this <code>Version</code> object by taking the hash code of the
     * string generated by the <code>toString()</code> method.
     * 
     * @see java.lang.Object#hashCode()
     */
    public int hashCode()
    {
        return toString().hashCode();
    }

    /**
     * Generates a string representation of this <code>Version</code> object.  This string will contain
     * the text version, canonical version, and regular expression associated with this <code>Version</code> object.
     * 
     * @see java.lang.Object#toString()
     */
    public String toString()
    {
        StringBuilder buffer = new StringBuilder();
        buffer.append("Text Version: ").append(textVersion).append('\n');
        buffer.append("Canonical Version: ").append(textVersion).append('\n');
        buffer.append("Regex: ").append(regex).append('\n');
        return buffer.toString();
    }
}

// -------------------------------------------------
// $Log: Version.java,v $
// Revision 1.1  2007/03/19 17:14:11  brettw
// New OSGi bundle for core network classes,
//
// Revision 1.1  2007/01/10 23:07:54  dwhite
// Added Version class to compute the canonical version of a given version string and the regular expression to extract the necessary information.
//
// Revision 1.0 Jan 10, 2007 dwhite
// Initial revision
// --------------------------------------------------
