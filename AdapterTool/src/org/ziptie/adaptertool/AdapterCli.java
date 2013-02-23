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

import java.io.File;
import java.io.PrintStream;
import java.io.StringReader;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Set;

import org.ziptie.adapters.AdapterInvokerElf;
import org.ziptie.adaptertool.art.AdapterTestCli;
import org.ziptie.adaptertool.tools.ScriptToolCli;
import org.ziptie.addressing.NetworkAddressElf;
import org.ziptie.common.RegExUtilities;
import org.ziptie.net.utils.FileServerInfo;
import org.ziptie.perl.PerlPoolManager;

/**
 * Allows a user to invoke an adapter.
 */
public class AdapterCli
{
    private static final String LINUX = "linux"; //$NON-NLS-1$
    private static final String WINDOWS = "windows"; //$NON-NLS-1$
    private static final String MACOSX = "macosx"; //$NON-NLS-1$
    private static final String ADAPTER_LOG_DIR = "ADAPTER_LOG_DIR"; //$NON-NLS-1$
    private static final String ENABLE_RECORDING = "ENABLE_RECORDING"; //$NON-NLS-1$
    private static final String RECORDING_DIR = "RECORDING_DIR"; //$NON-NLS-1$

    private boolean noValidate;
    private String adapterId;

    private ConnectionPathBuilder connectionPathBuilder;

    private boolean enableRecording;
    private String adapterLoggingLevel;
    private boolean enableLoggingToFile;

    // instance init.
    {
        adapterLoggingLevel = AdapterConstants.DEBUG_LOGGING_LEVEL;
    }

    /**
     * default
     */
    public AdapterCli()
    {
        connectionPathBuilder = new ConnectionPathBuilder();
    }

    /**
     * Invoke the operation as specified by this instance.
     * @param zedOutput The output stream to write the ZED document to.
     */
    public void run(PrintStream zedOutput)
    {
        try
        {
            String input = connectionPathBuilder.getOperationInputXml();

            HashMap<String, String> env = new HashMap<String, String>();

            // Set the adapter logging level
            env.put(AdapterConstants.ADAPTER_LOGGING_LEVEL, getAdapterLoggingLevel());

            // Enable logging to a file if it has been specified
            if (isLoggingToFileEnabled())
            {
                env.put(AdapterConstants.ADAPTER_LOG_TO_FILE, "1"); //$NON-NLS-1$
                env.put(ADAPTER_LOG_DIR, new File(".").getCanonicalPath()); //$NON-NLS-1$
            }

            // Enable recording if desired
            if (isRecordingEnabled())
            {
                env.put(ENABLE_RECORDING, "1"); //$NON-NLS-1$

                env.put(RECORDING_DIR, new File(".").getCanonicalPath()); //$NON-NLS-1$
            }

            String output = AdapterInvokerElf.invoke(adapterId, connectionPathBuilder.getOperation().name(), input, env);
            zedOutput.println(output);

            if (!noValidate)
            {
                if (XmlValidateElf.validate(new StringReader(output), System.err))
                {
                    System.err.println(Messages.getString("AdapterCli.validatedSuccessfully")); //$NON-NLS-1$
                }
            }

            output = null;
            FileServerElf.shutDownServers();
        }
        catch (Exception e)
        {
            String message = e.getMessage();
            if (RegExUtilities.regexMatch(message, "Can't locate.+(Backup\\.pm in|object method)"))
            {
                System.err.println("\n****** Error ******\nAdapterTool found a perl compilation problem."
                                   + "\nYou may not have all of the necessary perl modules installed."
                                   + "\nRun 'perl perlcheck.pl' from the command line to verify.");
            }
            else
            {
                e.printStackTrace();
            }
        }
    }

    /**
     * Set the adapter to use.
     * @param adapterId The ID of the adapter.
     */
    public void setAdapterId(String adapterId)
    {
        this.adapterId = adapterId;
    }

    /**
     * Enable/disable validation.
     * @param b <code>true</code> if validation should be disabled.
     */
    public void setNoValidate(boolean b)
    {
        noValidate = b;
    }

    /**
     * Sets the adapter logging level to the desired logging level.  Validation is done against the desired logging
     * level to make sure that it is applicable.
     * 
     * @param desiredLoggingLevel The desired logging level.
     */
    public void setAdapterLoggingLevel(String desiredLoggingLevel)
    {
        // If the desired logging level is null or not a valid logging level, then default to the debug logging level
        if (desiredLoggingLevel == null
                || (!desiredLoggingLevel.equals(AdapterConstants.DEBUG_LOGGING_LEVEL) && !desiredLoggingLevel.equals(AdapterConstants.FATAL_LOGGING_LEVEL)))
        {
            adapterLoggingLevel = AdapterConstants.DEBUG_LOGGING_LEVEL;
        }
        else
        {
            adapterLoggingLevel = desiredLoggingLevel;
        }
    }

    /**
     * Retrieves the adapter logging level that has been set.
     * 
     * @return The adapter logging level.
     */
    public String getAdapterLoggingLevel()
    {
        return adapterLoggingLevel;
    }

    /**
     * Enables/disables the logging of adapter operations to a file.
     * 
     * @param enable Whether or not to enable logging to a file.
     */
    public void enableLoggingToFile(boolean enable)
    {
        enableLoggingToFile = enable;
    }

    /**
     * Determines whether or not the logging of adapter operations to a file is enabled.
     * 
     * @return Whether or not the logging of adapter operations to a file is enabled.
     */
    public boolean isLoggingToFileEnabled()
    {
        return enableLoggingToFile;
    }

    /**
     * Enables or disables the recording of device interactions that happen during an adapter operation.
     * 
     * @param enable Whether or not to enable recording of device interactions.
     */
    public void enableRecording(boolean enable)
    {
        enableRecording = enable;
    }

    /**
     * Returns whether or not device interaction recording is enabled.
     * 
     * @return Whether or not device interaction recording is enabled.
     */
    public boolean isRecordingEnabled()
    {
        return enableRecording;
    }

    /**
     * Main
     * @param args the command line arguments
     */
    public static void main(String[] args)
    {
        parseArgs(args);

        try
        {
            CliElf.setupLog4j();
            boolean printInputDocumentAndExit = false;

            AdapterInvokerElf.setInvoker(new File("scripts/invoke.pl").toURI().toURL()); //$NON-NLS-1$

            AtConfigElf.addToIncludePath(new File("scripts")); //$NON-NLS-1$
            System.setProperty("PERL_SYSTEM_PATH", "bin/" + getOS()); //$NON-NLS-1$ //$NON-NLS-2$

            AtConfigElf.loadSetup();

            // Create pool manager after loadSetup so that all the perl paths will already be setup.
            AdapterInvokerElf.setPerlPoolManager(new PerlPoolManager());

            AdapterCli cli = new AdapterCli();

            for (int i = 0; i < args.length; i++)
            {
                if (args[i].equals("-a")) //$NON-NLS-1$
                {
                    cli.setAdapterId(CliElf.next(args, ++i));
                }
                else if (args[i].equals("-o")) //$NON-NLS-1$
                {
                    Operation operation = Operation.valueOf(CliElf.next(args, ++i));
                    cli.connectionPathBuilder.setOperation(operation);
                    cli.setNoValidate(!(operation.equals(Operation.backup) || operation.equals(Operation.telemetry)));
                }
                else if (args[i].equals("-c")) //$NON-NLS-1$
                {
                    String cred = CliElf.next(args, ++i);
                    int ndx = cred.indexOf('=');
                    if (ndx < 1)
                    {
                        CliElf.die(Messages.getString("AdapterCli.invalidCredentialSpec")); //$NON-NLS-1$
                    }
                    cli.connectionPathBuilder.addCredential(cred.substring(0, ndx), cred.substring(ndx + 1));
                }
                else if (args[i].equals("-p")) //$NON-NLS-1$
                {
                    cli.connectionPathBuilder.setProtocolSet(CliElf.next(args, ++i));
                }
                else if (args[i].equals("-h")) //$NON-NLS-1$
                {
                    cli.connectionPathBuilder.setHost(CliElf.next(args, ++i));
                }
                else if (args[i].equals("-i")) //$NON-NLS-1$
                {
                    cli.connectionPathBuilder.setInputXmlFile(CliElf.next(args, ++i));
                }
                else if (args[i].equals("-x")) //$NON-NLS-1$
                {
                    printInputDocumentAndExit = true;
                }
                else if (args[i].equals("--novalidate")) //$NON-NLS-1$
                {
                    cli.setNoValidate(true);
                }
                else if (args[i].equals("-r")) //$NON-NLS-1$
                {
                    cli.enableRecording(true);
                }
                else if (args[i].equals("--logLevel")) //$NON-NLS-1$
                {
                    cli.setAdapterLoggingLevel(CliElf.next(args, ++i));
                }
                else if (args[i].equals("--logToFile")) //$NON-NLS-1$
                {
                    cli.enableLoggingToFile(true);
                }
                else
                {
                    System.err.println("Invalid option '" + args[i] + "'.  See 'adapterTool --help' for more information.");
                    System.exit(1);
                }
            }

            cli.connectionPathBuilder.buildConnectionPathXml();

            if (printInputDocumentAndExit)
            {
                LinkedList<FileServerInfo> servers = new LinkedList<FileServerInfo>();
                
                String host = cli.connectionPathBuilder.getHost();
                
                // Determine whether or not the host we are trying to connect to is a IPv4 or IPv6 compatible device
                boolean useIPv6 = (NetworkAddressElf.isValidIpAddress(host) && NetworkAddressElf.isIPv6AddressOrMask(host)) ? true : false;
                
                servers.add(FileServerElf.getTftpServerInfo(FileServerElf.getTftpServer(), useIPv6));
                // servers.add(cli.getFtpServerInfo(cli.getFtpServerConfig()));

                System.out.println(cli.connectionPathBuilder.createInputXml(servers));

                if (cli.connectionPathBuilder.getOperation().equals(Operation.restore))
                {
                    String path = cli.connectionPathBuilder.getRestoreFile().getOriginalFile().getAbsolutePath();
                    System.err.println(Messages.getString("AdapterCli.restoreFileWarning") + path); //$NON-NLS-1$
                }
                System.exit(0);
            }

            if (cli.adapterId == null)
            {
                cli.setAdapterId(AtConfigElf.chooseAdapter());
            }
            System.err.printf(Messages.getString("AdapterCli.executingOperation"), cli.connectionPathBuilder.getOperation(), cli.adapterId); //$NON-NLS-1$
            cli.run(System.out);
        }
        catch (Throwable t)
        {
            t.printStackTrace();
        }
    }

    private static void parseArgs(String[] args)
    {
        if (args.length == 0)
        {
            return;
        }

        int offset = getSubArgOffset(args);

        String first = args[offset - 1];
        String[] dargs = new String[args.length - offset];
        System.arraycopy(args, offset, dargs, 0, dargs.length);

        if (first.equals("--discover")) //$NON-NLS-1$
        {
            DiscoverCli.main(dargs);
        }
        else if (first.equals("--tool")) //$NON-NLS-1$
        {
            ScriptToolCli.main(dargs);
        }
        else if (first.equals("--create")) //$NON-NLS-1$
        {
            CreateAdapter.main(dargs);
        }
        else if (first.equals("--list")) //$NON-NLS-1$
        {
            listAdapters();
        }
        else if (first.equals("--init")) //$NON-NLS-1$
        {
            init();
        }
        else if (first.equals("--crate")) //$NON-NLS-1$
        {
            CrateAdapters.main(dargs);
        }
        else if (first.equals("--test")) //$NON-NLS-1$
        {
            AdapterTestCli.main(dargs);
        }
        else if (first.equals("--help")) //$NON-NLS-1$
        {
            displayUsage();
        }
        else if (first.equals("--version")) //$NON-NLS-1$
        {
            showVersion();
        }
        else
        {
            return;
        }

        System.exit(1);
    }

    private static int getSubArgOffset(String[] args)
    {
        if (args[0].equals("-debug")) //$NON-NLS-1$
        {
            return 2;
        }
        return 1;
    }

    private static void init()
    {
        try
        {
            AtConfigElf.runSetup();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
    }

    private static void listAdapters()
    {
        try
        {
            CliElf.setupLog4j();
            AtConfigElf.loadSetup();

            Set<String> set = AtConfigElf.getAdapterService().getAllAdapterIDs();
            String[] ids = set.toArray(new String[set.size()]);
            Arrays.sort(ids, String.CASE_INSENSITIVE_ORDER);

            for (String id : ids)
            {
                System.err.println(id);
            }
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
    }
    
    private static void showVersion()
    {
        System.out.println(Messages.getString("AdapterCli.version") + AdapterCli.class.getPackage().getImplementationVersion()); //$NON-NLS-1$
    }

    private static void displayUsage()
    {
        showVersion();
        System.out.println();
        System.out.println(Messages.getString("AdapterCli.usage")); //$NON-NLS-1$
    }

    /**
     * Get the OS
     * @return the name of the OS
     */
    public static String getOS()
    {
        String os = System.getProperty("os.name"); //$NON-NLS-1$
        if ("Mac OS X".equals(os)) //$NON-NLS-1$
        {
            os = MACOSX;
        }
        // Normalize any version of Windows into "windows"
        else if (os.contains("indows")) //$NON-NLS-1$
        {
            os = WINDOWS;
        }
        // Normalize any version of Linux into "linux"
        else if (os.contains("inux")) //$NON-NLS-1$
        {
            os = LINUX;
        }
        return os;
    }

}
