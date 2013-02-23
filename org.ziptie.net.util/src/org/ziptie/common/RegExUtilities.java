package org.ziptie.common;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;


/**
 * RegExUtilities
 */
public final class RegExUtilities
{
    private static final char[] META_CHARACTERS = { '\\', '^', '.', '$', '|', '(', ')', '[', ']', '*', '+', '?', ':' };

    /**
     * Private constructor for the <code>RegExUtilities</code> class to disable support of a public default constructor.
     *
     */
    private RegExUtilities()
    {
        // Does nothing.
    }

    /**
     * @param inputString the input string to transform
     * @return a proper regex
     */
    public static String transformStringToRE(String inputString)
    {
        if (inputString == null)
        {
            return null;
        }

        if (inputString.equals(""))
        {
            return inputString;
        }

        StringBuffer strBuffer = new StringBuffer(inputString);
        for (int iMetaChar = 0; iMetaChar < META_CHARACTERS.length; iMetaChar++)
        {
            char metaChar = META_CHARACTERS[iMetaChar];
            int iLoc = 0;
            while (iLoc < strBuffer.length())
            {
                iLoc = strBuffer.toString().indexOf(metaChar, iLoc);
                if (iLoc < 0)
                {
                    break;
                }
                strBuffer.insert(iLoc, "\\");
                iLoc += 2;
            }
        }
        return strBuffer.toString();
    }

    /**
     * MatcherFunctor
     */
    private static interface MatcherFunctor<T>
    {
        T invoke(Matcher matcher);
    }

    private static <T> T processPattern(final String textToMatch, final String regex, T defaultReturnValue, final MatcherFunctor<T> functor)
    {
        try
        {
            return functor.invoke(Pattern.compile(regex).matcher(textToMatch));
        }
        catch (PatternSyntaxException pse)
        {
            return defaultReturnValue;
        }
    }

    /**
     * Uses Java.util.regex matcher for seeing if the given string is matched by the given regex. Returns true if there is a match,
     * returns false if there is no match or if a PatternSyntaxException was caught due to a poorly constructed
     * regular expression.
     * 
     * @param textToMatch incoming text
     * @param regex the regex to match on 
     * @return true if there was a match
     */
    public static boolean regexMatch(final String textToMatch, final String regex)
    {
        return processPattern(textToMatch, regex, false, new MatcherFunctor<Boolean>()
        {
            public Boolean invoke(Matcher matcher)
            {
                return matcher.find();
            }
        });
    }

    /**
     * Returns the index within this string of the rightmost occurrence of the specified regex. If the regex is not found
     * then -1 is returned.
     *
     * @param textToMatch the text
     * @param regex the regex to match on
     * @return the index int of the last match 
     */
    public static int regexLastIndexOf(final String textToMatch, final String regex)
    {
        return lastIndexOf(textToMatch, regex, -1);
    }

    private static int lastIndexOf(final String textToMatch, final String regex, final int defaultReturnValue)
    {
        return processPattern(textToMatch, regex, defaultReturnValue, new MatcherFunctor<Integer>()
        {
            public Integer invoke(Matcher matcher)
            {
                int lastIndex = defaultReturnValue;
                while (matcher.find())
                {
                    lastIndex = matcher.start();
                    matcher.region(1 + lastIndex, textToMatch.length());
                }

                return lastIndex;
            }
        });
    }

}

