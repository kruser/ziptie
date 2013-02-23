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
package org.ziptie.adapters;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.ziptie.perl.PerlException;
import org.ziptie.perl.PerlPoolManager;
import org.ziptie.perl.PerlServer;

/**
 * Provides the ability to invoke a perl adapter.
 */
public final class AdapterInvokerElf
{
    private static final int BUFFER_SIZE = 2048;

    private static URL invoker;

    private static PerlPoolManager perlPoolManager;

    /** Hidden constructor. */
    private AdapterInvokerElf()
    {
        // do nothing
    }

    /**
     * Set the URL to the invoker script to be used.
     * @param url The URL to "invoke.pl"
     */
    public static void setInvoker(URL url)
    {
        invoker = url;
    }

    /**
     * Set the perl pool manager to use.
     * @param manager the perl server pool
     */
    public static void setPerlPoolManager(PerlPoolManager manager)
    {
        perlPoolManager = manager;
    }

    /**
     * Invokes an adapter using the invoke.pl script.
     * @param adapterId The adapter to invoke.
     * @param method The method to invoke (ie: backup)
     * @param input The input xml.
     * @param additionalEnv Any additional environment variables to use during the invocation of the adapter operation.
     * If this is set to null or is empty, then no additional environment variables will be added.
     * 
     * @return The script's output.
     * @throws InvocationTargetException On error.
     */
    public static String invoke(String adapterId, String method, String input, HashMap<String, String> additionalEnv) throws InvocationTargetException
    {
        Logger logger = Logger.getLogger(AdapterInvokerElf.class);
        String name = adapterId + '#' + method;
        logger.debug("Invoking " + name); //$NON-NLS-1$

        if (adapterId == null)
        {
            throw new IllegalArgumentException("adapter cannot be null"); //$NON-NLS-1$
        }

        if (name == null)
        {
            throw new IllegalArgumentException("name cannot be null"); //$NON-NLS-1$
        }

        if (input == null)
        {
            throw new IllegalArgumentException("input cannot be null"); //$NON-NLS-1$
        }

        try
        {

            List<String> additionalEnvArray = new ArrayList<String>();

            // Set up additional environment variables
            if (additionalEnv != null && additionalEnv.size() > 0)
            {
                // For each key-value pair from the environment variable hash, generate a string
                // that can be registered with the Perl Server
                for (Map.Entry<String, String> keyValuePair : additionalEnv.entrySet())
                {
                    String envVarString = keyValuePair.getKey() + '=' + keyValuePair.getValue();
                    additionalEnvArray.add(envVarString);
                }
            }

            String[] args = new String[] { adapterId, method, "-x", input }; //$NON-NLS-1$

            StringWriter internalWriter = new StringWriter();

            PerlServer server = perlPoolManager.getPerlServer();
            try
            {
                server.eval(getScript(), args, additionalEnvArray.toArray(new String[additionalEnvArray.size()]), internalWriter);
            }
            finally
            {
                perlPoolManager.returnPerlServer(server);
            }

            logger.debug("Script " + name + " exited"); //$NON-NLS-1$//$NON-NLS-2$

            return internalWriter.toString();
        }
        catch (PerlException e)
        {
            throw getException(e);
        }
        catch (IOException e)
        {
            throw new InvocationTargetException(e, "[PERL_ERROR] Error loading script."); //$NON-NLS-1$
        }
    }

    private static InvocationTargetException getException(PerlException e)
    {
        if (e.getMessage().contains("Unable to spawn perl process")) //$NON-NLS-1$
        {
            return new InvocationTargetException(e, "[PERL_ERROR] " + e.getMessage()); //$NON-NLS-1$
        }

        return new InvocationTargetException(e, e.getMessage());
    }

    private static String getScript() throws IOException
    {
        if (invoker == null)
        {
            throw new IllegalStateException("invoke.pl location is not defined"); //$NON-NLS-1$
        }

        InputStream in = null;
        try
        {
            in = invoker.openStream();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buf = new byte[BUFFER_SIZE];
            int len = 0;
            while ((len = in.read(buf)) > 0)
            {
                baos.write(buf, 0, len);
            }

            return baos.toString();
        }
        finally
        {
            if (in != null)
            {
                try
                {
                    in.close();
                }
                catch (IOException e)
                {
                    Logger.getLogger(AdapterInvokerElf.class).warn("Unable to close stream.", e); //$NON-NLS-1$
                }
            }
        }
    }
}
