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
 * Portions created by AlterPoint are Copyright (C) 2008,
 * AlterPoint, Inc. All Rights Reserved.
 * 
 * Contributor(s):
 */
package org.ziptie.adaptertool.art;

import java.io.File;
import java.io.FileOutputStream;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.apache.log4j.Logger;
import org.ziptie.adapters.AdapterInvokerElf;
import org.ziptie.adaptertool.AdapterCli;
import org.ziptie.adaptertool.AtConfigElf;
import org.ziptie.adaptertool.CliElf;
import org.ziptie.adaptertool.FileServerElf;
import org.ziptie.net.sim.DeviceSimulator;
import org.ziptie.net.utils.FileServerInfo;
import org.ziptie.perl.PerlPoolManager;

/**
 * CLI for running an adapter test suite.
 */
@SuppressWarnings("nls")
public class AdapterTestCli
{
    private static final long SIXTEEN_HOURS_IN_SECONDS = 16 * 60 * 60;

    private static FileServerInfo ftpServer;
    private static FileServerInfo tftpServer;

    private ExecutorService pool;
    private Results results;
    private File outputFile;
    private int threadCount = 8;

    /**
     * Create the runner
     * @throws SQLException one derby error 
     */
    public AdapterTestCli() throws SQLException
    {
        results = new Results();
    }

    /**
     * Set the number of concurrent tests to run.
     * @param count the number of threads.
     */
    public void setThreadCount(int count)
    {
        threadCount = count;
    }

    /**
     * Set the file to write the output HTML to.
     * @param outputFile The output file.
     */
    public void setOutputFile(File outputFile)
    {
        this.outputFile = outputFile;
    }

    /**
     * Run all the tests within the given directory.
     * @param file The file or directory to walk.
     */
    public void runTests(File file)
    {
        if (pool == null)
        {
            pool = Executors.newFixedThreadPool(threadCount);
        }

        String name = file.getName();
        if (file.isFile() && name.endsWith(".test"))
        {
            pool.submit(new ArtTest(results, file));
        }
        else if (file.isDirectory() && !name.equals("CVS"))
        {
            File[] files = file.listFiles();
            if (files == null)
            {
                return;
            }

            for (File f : files)
            {
                runTests(f);
            }
        }
    }

    /**
     * Wait for all the tests to complete.
     */
    public void waitForCompletion()
    {
        try
        {
            pool.shutdown();
            pool.awaitTermination(SIXTEEN_HOURS_IN_SECONDS, TimeUnit.SECONDS); // 16 hours (TimeUnit.HOURS is not available in java 1.5)

            Logger.getLogger(getClass()).info("Building report");
            if (outputFile != null)
            {
                FileOutputStream out = new FileOutputStream(outputFile);
                try
                {
                    results.write(out);
                }
                finally
                {
                    out.close();
                }
            }
            else
            {
                results.write(System.out);
            }

            results.close();
            System.out.println();
        }
        catch (Throwable e)
        {
            throw new RuntimeException(e);
        }
    }

    /**
     * Setup the servers.
     * @throws Exception on error.
     */
    public static void prepare() throws Exception
    {
        Properties props = new Properties();
        props.setProperty("http.port", "30080");
        props.setProperty("telnet.port", "23");
        props.setProperty("telnet.handshake.port", "8023");
        props.setProperty("telnet.pool.count", "5");
        props.setProperty("logging.storeState", "false");

        DeviceSimulator sim = new DeviceSimulator(props);
        sim.start();

        ftpServer = FileServerElf.startFtpd(false);
        tftpServer = FileServerElf.startTftpd(false);
    }

    /**
     * Get the FTP server instance description.
     * @return The FTP server info
     */
    public static FileServerInfo getFtpServer()
    {
        return ftpServer;
    }

    /**
     * Get the TFTP server instance description.
     * @return The TFTP server info.
     */
    public static FileServerInfo getTftpServer()
    {
        return tftpServer;
    }

    /**
     * CLI Main.
     * @param args command line arguments.
     */
    public static void main(String[] args)
    {
        try
        {
            CliElf.setupLog4j();

            AdapterInvokerElf.setInvoker(new File("scripts/invoke.pl").toURI().toURL()); //$NON-NLS-1$
            AtConfigElf.addToIncludePath(new File("scripts")); //$NON-NLS-1$
            System.setProperty("PERL_SYSTEM_PATH", "bin/" + AdapterCli.getOS()); //$NON-NLS-1$ //$NON-NLS-2$

            AtConfigElf.loadSetup();

            AdapterInvokerElf.setPerlPoolManager(new PerlPoolManager());

            prepare();

            AdapterTestCli cli = new AdapterTestCli();

            for (int i = 0; i < args.length; i++)
            {
                if (args[i].equals("-o"))
                {
                    cli.setOutputFile(new File(CliElf.next(args, ++i)));
                }
                else if (args[i].equals("-t"))
                {
                    cli.setThreadCount(Integer.parseInt(CliElf.next(args, ++i)));
                }
                else
                {
                    cli.runTests(new File(args[i]));
                }
            }

            cli.waitForCompletion();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
        finally
        {
            FileServerElf.shutDownServers();
        }
    }
}
