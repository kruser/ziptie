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
package org.ziptie.adaptertool;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.log4j.ConsoleAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

/**
 * Helper class for dealing with CLI input.
 */
public final class CliElf
{
    private CliElf()
    {
    }

    /**
     * Configure a basic log4j appender for the console.
     */
    @SuppressWarnings("nls")
    public static void setupLog4j()
    {
        Logger root = Logger.getRootLogger();
        root.addAppender(new ConsoleAppender(new PatternLayout("%d{ISO8601} %-5p: %X{metadata} %m%n"), ConsoleAppender.SYSTEM_ERR));
        root.setLevel(Level.INFO);
    }

    /**
     * Get the argument for <code>i</code> or exit the VM with an error.
     * @param args The argument list.
     * @param i The argument index.
     * @return The value of the argument.
     */
    public static String next(String[] args, int i)
    {
        if (args.length == i)
        {
            die("Invalid input for " + args[i - 1]); //$NON-NLS-1$
        }

        return args[i];
    }

    /**
     * Print <code>msg</code> and call {@link System#exit(int)}
     * @param msg The error message.
     */
    public static void die(String msg)
    {
        System.err.println(msg);
        System.exit(1);
    }

    /**
     * Prompt the user with <code>prompt</code> and return the result.
     * @param prompt The prompt.
     * @return The value the user enters.
     */
    public static String get(String prompt)
    {
        System.err.print(prompt);

        try
        {
            return new BufferedReader(new InputStreamReader(System.in)).readLine();
        }
        catch (IOException e)
        {
            e.printStackTrace();
            CliElf.die(e.getMessage());
            return null;
        }
    }

}
