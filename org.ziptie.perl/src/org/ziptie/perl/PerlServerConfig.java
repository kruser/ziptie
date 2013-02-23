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

package org.ziptie.perl;

import java.io.File;
import java.util.ArrayList;

import org.apache.log4j.Logger;

/**

 */
@SuppressWarnings({ "nls", "unchecked" })
public class PerlServerConfig
{
    //CHECKSTYLE:OFF
    private static final Logger logger = Logger.getLogger(PerlServerConfig.class);

    public static final String PERL_SERVER_PL = "PerlServer.pl";
    public static final String PERL_INC = "PERL_INC";
    public static final String PERL_SYSTEM_PATH = "PERL_SYSTEM_PATH";
    public static final String PERL_EXECUTABLE_PATH = "PERL_EXECUTABLE_PATH";
    public static final String PATH = "PATH";

    private static final int ONE_THOUSAND_MILLIS = 1000;
    private static final int SLEEP_DELAY_MS = 30;

    private String systemPath;
    private ArrayList launchCommands;
    private int checkSuccessfulMaxRetries;

    /**
     * Static initializer for this class. Only runs once per classloader.
     */
    public PerlServerConfig()
    {
        Integer perlHandshakeSeconds = Integer.getInteger("perlHandshakeSeconds", 2);
        checkSuccessfulMaxRetries = (perlHandshakeSeconds.intValue() * ONE_THOUSAND_MILLIS) / SLEEP_DELAY_MS;

        // Grab the PATH environment variable to pass into Perl
        String realSystemPath = (System.getenv(PATH) != null ? System.getenv(PATH) : "");

        // Grab the PERL_SYSTEM_PATH environment variable, which will have an additional paths that need to be
        // available to Perl when searching the PATH environment variable.
        String perlSystemPath = (System.getProperty(PERL_SYSTEM_PATH) != null ? System.getProperty(PERL_SYSTEM_PATH) : "");

        // Grab the PERL_EXECUTABLE_PATH environment variable, to find out where perl is installed.
        String perlExecutable = (System.getProperty(PERL_EXECUTABLE_PATH) != null ? System.getProperty(PERL_EXECUTABLE_PATH) : "");

        // The path environment variable to be made avaiable to Perl is a combination of the real system path
        // and the addition paths specified within various bundles
        systemPath = realSystemPath + File.pathSeparator + perlSystemPath + File.pathSeparator + perlExecutable;

        if (perlExecutable.length() != 0)
        {
            perlExecutable += File.separator;
        }

        perlExecutable += "perl";

        String[] perlIncludes = System.getProperty(PERL_INC, ".").split(File.pathSeparator);
        String perlServer = System.getProperty("PERL_SERVER");

        if (perlServer == null)
        {
            // Find PerlServer.pl in the include path
            for (String path : perlIncludes)
            {
                File file = new File(path + File.separator + PERL_SERVER_PL);

                if (file.exists())
                {
                    perlServer = path;
                    break;
                }
            }
        }

        launchCommands = new ArrayList();
        launchCommands.add(perlExecutable);
        launchCommands.add("-I.");

        for (String path : perlIncludes)
        {
            launchCommands.add("-I" + path);
        }

        launchCommands.add(perlServer + File.separatorChar + PERL_SERVER_PL);

        logger.trace(String.format("PERL EXECUTABLE=%s\n", perlExecutable));
        logger.trace(String.format("PERL INCLUDES=%s\n", System.getProperty(PERL_INC, ".")));
        logger.trace(String.format("PERL SERVER=%s\n", perlServer));
        logger.trace(String.format("SYSTEM PATH=%s\n", systemPath));
        logger.trace(String.format("perlHandshakeSeconds=%d\n", perlHandshakeSeconds));
    }

    public int getCheckSuccessfulMaxRetries()
    {
        return checkSuccessfulMaxRetries;
    }

    public ArrayList getLaunchCommands()
    {
        return launchCommands;
    }

    public String getSystemPath()
    {
        return systemPath;
    }
}
