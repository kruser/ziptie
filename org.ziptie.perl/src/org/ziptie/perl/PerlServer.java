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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;

import org.apache.log4j.Logger;

/**
 * This class encapsulates a Perl process and it's associated I/O streams. <br>
 * <br>
 *
 * When this class is instantiated, it launches a Perl script called PerlServer.pl.
 * This script reads "commands" issued from this class via it's STDIN stream.
 * It then executes those commands, and responds via the STDOUT stream. <br>
 * <br>
 *
 * The commands that this class can send to PerlServer.pl are:
 *
 * <pre>
 *     === eval
 *     === env
 *     === arg
 * </pre>
 *
 * This class also sends a Perl script to execute to PerlServer.pl via STDIN. Any line
 * that is not prefaced with "===" is considered by PerlServer.pl to be a line that
 * should be concatentated to the script it is going to execute. Typically, this class
 * with send the script through STDIN, followed by a "=== eval" command to request
 * PerlServer.pl to evaluate the script. <br>
 * <br>
 *
 * "=== eval" - Evaluate the script that has been "accumulated" this far. The
 *              script and ARGV arguments are cleared after evaluation. <br>
 * "=== env"  - Define an environment variable. Has the form "=== env name=value". <br>
 * "=== arg"  - Append an "argument" to ARGV. Has the form "=== arg ThisIsAnArgument". <br>
 * <br>
 *
 * When the PerlServer.pl class responds to a command to "eval" a script, it responds
 * via STDOUT with one of three values:
 *
 * <pre>
 *     === ps ok
 *     === ps error
 *     === ps exit
 * </pre>
 *
 * Both "=== ps ok" and "=== ps error" are followed by additional lines of output detail,
 * ending in a line with "=== ps end" by itself on the line. If, for* example, the script
 * calls 'die' or otherwise has an error (syntax error, division by zero, etc.) then
 * PerlServer.pl will return "=== ps error" followed by the 'die' message or error detail.
 * If the script terminates normally, then "=== ps ok" is returned followed by the value
 * of the last evaluated expression in the script. Currently, this value is ignored. If
 * the script calls 'exit', then PerlServer.pl traps the exit call and returns "=== ps exit"
 * along with the numeric value of the exit call. <br>
 * <br>
 *
 * NOTE: BSF does not currently use or have a dependency on LOG4J. Consequently, this
 * package employs it's own very rudimentary logging to STDERR based on a DEBUG level that
 * varies from 0 (off) to 3 (detailed).
 */
@SuppressWarnings({ "nls", "unchecked" })
public class PerlServer
{
    private static final Logger LOGGER = Logger.getLogger(PerlServer.class);

    private static final String PATH = "PATH";
    private static final int HIGH_USE_COUNT = 1000000;
    private static final int SLEEP_DELAY_MS = 30;
    private static final int DEBUG_LEVEL1 = 1;
    private static final int DEBUG_LEVEL2 = 2;
    private static final int DEBUG_LEVEL3 = 3;

    /** A debug level flag.  See the list of properties in the class documentation */
    private static int DEBUG;

    private static Boolean isUnix;

    /** The handle to Perl process associated with this PerlServer */
    private Process perlProcess;

    /** The STDOUT and STDERR streams (merged) of the Perl process */
    private BufferedReader perlStdOut;
    /** The STDIN stream of the Perl process.  We write to this. */
    private BufferedWriter perlStdIn;

    /** A aimestamp of the last time this PerlServer was used to eval() */
    private long lastUseTime;
    /** A count of the number of times this PerlServer was used to eval() */
    private int useCount;

    private PerlServerConfig config;

    /**
     * Package-scoped constructor. This method launches a Perl executable, which is used to 'eval' scripts.
     *
     * @param config the path and launch configuration for this server
     * @throws PerlException if an error occurs during construction ;)
     */
    public PerlServer(PerlServerConfig config) throws PerlException
    {
        this.config = config;

        // Seed with current time, otherwise we might be ejected from the pool
        // even before we're used.
        lastUseTime = System.currentTimeMillis();

        boolean success = false;
        try
        {
            // This synchronization avoids a strange Windows bug, in which sometimes processes are spawned
            // with a null environment (even though one is passed in) when many exec() calls are made
            // simultaneously.
            synchronized (PerlServer.class)
            {
                ProcessBuilder processBuilder = new ProcessBuilder(config.getLaunchCommands());
                processBuilder.environment().put(isUnix() ? PATH : "Path", config.getSystemPath());
                processBuilder.environment().put("__DEBUG", String.valueOf(DEBUG));
                processBuilder.redirectErrorStream(true);

                // make sure the directory where perl is executed from is set as the working directory on the process,
                // otherwise shared librairies won't get found.
                if (System.getProperty(PerlServerConfig.PERL_EXECUTABLE_PATH) != null)
                {
                    processBuilder.directory(new File(System.getProperty(PerlServerConfig.PERL_EXECUTABLE_PATH)));
                }

                perlProcess = processBuilder.start();

                // Note: the implementation of the InputStream returned by Java5 is Buffered, so
                // we do not need to wrap it with our own buffered stream.
                perlStdOut = new BufferedReader(new InputStreamReader(perlProcess.getInputStream()));
                perlStdIn = new BufferedWriter(new OutputStreamWriter(perlProcess.getOutputStream()));
            }

            success = checkSuccessfulLaunch();
            if (!success)
            {
                throw new PerlException("Unable to spawn perl process: launch check failed.");
            }
        }
        catch (InterruptedException ie)
        {
            // We must re-raise the interrupt, because catching resets the interrupted status
            Thread.currentThread().interrupt();
            throw new PerlException(ie.getMessage(), ie);
        }
        catch (IOException io)
        {
            useCount = HIGH_USE_COUNT;
            throw new PerlException("Unable to spawn perl process", io);
        }
        finally
        {
            // if we didn't launch successfully, make sure the process doesn't survive
            if (!success && perlStdOut != null && perlStdIn != null)
            {
                terminate();
            }
        }
    }

    // =====================================================================
    //                   P U B L I C    M E T H O D S
    // =====================================================================

    protected void finalize()
    {
        terminate();
    }

    // =====================================================================
    //                   P A C K A G E    M E T H O D S
    // =====================================================================

    /**
     * Terminate the PerlServer, i.e. kill it's underlying process
     *
     */
    public void terminate()
    {
        // We have a big cascading try..finally chain because everything
        // here must execute in order to reliably kill a Perl process.
        try
        {
            try
            {
                // Shutdown it's input stream, this should cause our PerlServer.pl to exit
                perlStdIn.close();
            }
            finally
            {
                try
                {
                    // Shoot it in the head
                    perlProcess.destroy();
                }
                finally
                {
                    // Shutdown our output stream, just to ensure all of our handles are closed
                    perlStdOut.close();
                }
            }
        }
        catch (IOException io)
        {
            return;
        }
    }

    /**
     * Evaluate a Perl script.
     *
     * @param script the script to evaluate.
     * @param args the command line arguments to the script
     * @param env the environmental parameters for the script
     * @param out A writer that the stdout of the script will be writen to.
     * @return the result code
     * @throws PerlException if there is an error running the script.
     */
    public int eval(String script, String[] args, String[] env, Writer out) throws PerlException
    {
        try
        {
            logDebug(DEBUG_LEVEL3, this, script);

            for (int i = 0; args != null && i < args.length; i++)
            {
                perlStdIn.write("=== arg ");
                perlStdIn.write(Base64.encodeBytes(args[i].getBytes(), Base64.DONT_BREAK_LINES));
                perlStdIn.write("\n");
            }

            for (int i = 0; env != null && i < env.length; i++)
            {
                perlStdIn.write("=== env ");
                perlStdIn.write(env[i]);
                perlStdIn.write("\n");
            }

            perlStdIn.write(script);

            perlStdIn.write("\n=== exec\n");
            perlStdIn.flush();

            ++useCount;
            lastUseTime = System.currentTimeMillis();

            return readResponse(new PrintWriter(out, true));
        }
        catch (InterruptedException ie)
        {
            // We must re-raise the interrupt, because catching resets the interrupted status
            Thread.currentThread().interrupt();
            throw new PerlException(ie.getMessage(), ie);
        }
        catch (IOException io)
        {
            // This should not happen if things are healthy. Set the useCount to max int value
            // to ensure this PerlServer is not used again.
            logDebug(DEBUG_LEVEL1, this, "Use Count: " + useCount);

            useCount = HIGH_USE_COUNT;
            throw new PerlException(io.getMessage() + " for PerlServer (" + System.identityHashCode(this) + ")", io);
        }
    }

    /**
     * Get the number of times this PerlServer has been used for eval()
     *
     * @return the number of times this server has been used
     */
    int getUseCount()
    {
        return useCount;
    }

    /**
     * Mutator to set the use count of this PerlServer instance. Can be used to 'accelerate' the useCount
     * of the PerlServer to ensure that it is not recyled in a pool.
     *
     * @param newUseCount the new use count
     */
    void setUseCount(int newUseCount)
    {
        useCount = newUseCount;
    }

    /**
     * Tests whether the underlying Perl process has exited (or died).
     *
     * @return true if the process is still alive, false otherwise
     */
    public boolean isAlive()
    {
        try
        {
            perlProcess.exitValue();
            return false;
        }
        catch (IllegalThreadStateException itse)
        {
            // This is thrown if the process is NOT DEAD.  This is Sun documented behavior,
            // not some weird side-effect we're relying on.
            return true;
        }
    }

    /**
     * Get the last time this PerlServer was used to evaluate a script.  The time
     * is in milliseconds since midnight January 1, 1970.
     *
     * @return the last time this PerlServer was used
     */
    long getLastUseTime()
    {
        return lastUseTime;
    }

    // =====================================================================
    //                  P R I V A T E    M E T H O D S
    // =====================================================================

    /**
     * This method is called by eval() and reads the response from an evaluated script as sent by PerlServer.pl.
     * There is a conversation protocol between this class and the spawned Perl process that is documented in
     * the JavaDoc for this class.
     *
     * @return the exit code from the eval()'uated Perl script, or 0
     * @throws PerlException if there is an error reported from the perl server.
     * @throws IOException If there is an error reading.
     * @throws InterruptedException if the thread is interrupted.
     */
    private int readResponse(PrintWriter internalOutput) throws PerlException, IOException, InterruptedException
    {
        StringWriter errWriter = new StringWriter();
        Thread thisThread = Thread.currentThread();
        boolean processOutDone = false;
        boolean errorDuringProcessing = false;
        int ret = 0;

        // Read STDOUT from Perl process. This is how it "handshakes" with us.
        while (!thisThread.isInterrupted() && !processOutDone)
        {
            String line = readLine(0);
            if (line == null)
            {
                ret = -1;
                break;
            }

            logDebug(DEBUG_LEVEL2, this, line);

            // If the line begins with '=== ps' is is part of the PerlServer.pl
            // response, otherwise it's just regular STDOUT output from the script
            // being eval()'uated and is ignored.
            if (line.startsWith("=== ps"))
            {
                if (line.startsWith("=== ps error"))
                {
                    errorDuringProcessing = true;
                }
                else if (line.startsWith("=== ps exit"))
                {
                    errorDuringProcessing = false;
                    try
                    {
                        ret = Integer.parseInt(line.substring("=== ps exit ".length()));
                    }
                    catch (NumberFormatException nfe)
                    {
                        ret = 0;
                    }
                    processOutDone = true;
                    continue;
                }
                else if (line.startsWith("=== ps end"))
                {
                    processOutDone = true;
                    continue;
                }
                else if (line.startsWith("=== ps log"))
                {
                    // Handle a log message being sent.  All log messages are expected to be Base64 encoded
                    int start = "=== ps log ".length();

                    // Grab the Base64 encoded log
                    String encodedLogMessage = line.substring(start);
                    byte[] decodedBytes = Base64.decode(encodedLogMessage);
                    String decodedLogMessage = new String(decodedBytes);

                    // Split the log messages at any newline so that they can be printed out on
                    // their own line by log4j
                    String[] logMessages = decodedLogMessage.split("\n");
                    for (String logMessage : logMessages)
                    {
                        try
                        {
                            LOGGER.info(logMessage);
                        }
                        catch (Throwable t)
                        {
                            t.printStackTrace();
                        }
                    }
                }
            }
            else
            {
                if (errorDuringProcessing)
                {
                    errWriter.write(line);
                    errWriter.write('\n');
                }
                else if (internalOutput != null)
                {
                    internalOutput.println(line);
                }
            }
        }

        if (errorDuringProcessing)
        {
            logDebug(DEBUG_LEVEL2, this, ">>>>" + errWriter.toString());

            throw new PerlException(errWriter.toString());
        }

        return ret;
    }

    /**
     * This is called immediately after launching a new Perl process, and tries to read
     * a "=== pong" message sent by the spawned Perl process.  If we haven't recieved it after
     * a certainly number of retries we assume the launch failed for some reason.
     *
     * @return true if the launch was successful, false otherwise
     * @throws IOException thrown if an IO error is encountered
     * @throws InterruptedException thrown if this thread is interrupted waiting to read the handshake
     */
    private boolean checkSuccessfulLaunch() throws IOException, InterruptedException
    {
        // Try to read the handshake from the PerlServer.pl.  In this case
        // each 'try' of CHECK_SUCCESSFUL_MAX_RETRIES takes 30ms.  So if
        // CHECK_SUCCESSFUL_MAX_RETRIES is 15, the readLine() call will
        // attempt to read a response for 450ms.
        String line = readLine(config.getCheckSuccessfulMaxRetries());

        if (line == null)
        {
            logDebug(DEBUG_LEVEL1, this, "Timeout encountered waiting for launch ACK after " + (SLEEP_DELAY_MS * config.getCheckSuccessfulMaxRetries()) + "ms");
        }

        return ("=== pong".equals(line));
    }

    /**
     * This method implements an interruptable readLine using blocking-IO streams. Unfortunately, there is
     * no way for us to get a non-blocking input stream from the launched Perl process, and the blocking
     * stream we have is not interruptable when calling a normal read() method. So this method uses an
     * 'availability test' to poll the input stream. In order to not "spin" and consume all the CPU, if there
     * was no available data at poll-time then we sleep for 30ms.  The loop will exit if our thread was
     * interrupted.
     *
     * @param maxTries if maxTries is a positive number we will make only 'maxTries' number of successive
     *            unsuccessful polling attempts before we exit. If maxTries is zero or negative, it is not used.
     * @return returns the string read from the inputstream, or null if an unexpected condition occurred.
     *
     * @throws IOException thrown if an error occurs reading the inputstream
     * @throws InterruptedException
     */
    private String readLine(int maxTries) throws IOException, InterruptedException
    {
        Thread thisThread = Thread.currentThread();
        int tries = 0;

        while (!thisThread.isInterrupted() && isAlive())
        {
            boolean ready = perlStdOut.ready();
            if (!ready)
            {
                if (maxTries > 0 && tries++ > maxTries)
                {
                    break;
                }

                // otherwise
                Thread.sleep(SLEEP_DELAY_MS);
                continue;
            }
            // We got data, reset tries
            tries = 0;

            return perlStdOut.readLine();
        }

        return null;
    }

    /**
     * Determine if we're running on a flavor of UN*X.
     *
     * @return true if we're on UNIX, false otherwise.
     */
    private static synchronized boolean isUnix()
    {
        if (isUnix == null)
        {
            String os = System.getProperty("os.name");
            if (os.equalsIgnoreCase("sunos") || os.equalsIgnoreCase("solaris") || os.equalsIgnoreCase("linux") || os.equalsIgnoreCase("mac os x"))
            {
                isUnix = Boolean.TRUE;
            }
            else
            {
                isUnix = Boolean.FALSE;
            }
        }
        return isUnix.booleanValue();
    }

    /**
     * A utility logging method that reduces code clutter by avoiding code like...
     *
     * if (DEBUG >= debuglevel)
     * {
     *     System.err.println("something");
     * }
     *
     * ... sprinkled all over the code.
     *
     * @param debugLevel the debug level required before the message will appear
     * @param perlServer a PerlServer instance, or null
     * @param message a text message to "log" (print)
     */
    private void logDebug(int debugLevel, PerlServer perlServer, String message)
    {
        if (DEBUG >= debugLevel)
        {
            System.err.printf("(%d) %d: %s: %08d: %s\n", System.identityHashCode(this), System.nanoTime(), Thread.currentThread().getName(),
                              (perlServer != null ? System.identityHashCode(perlServer) : 0), message);
        }
    }

    /**
     * @return the standard 'in' stream of this Perl process (suitable for
     * writing to the Perl process' stdin)
     */
    public BufferedWriter getPerlStdIn()
    {
        return perlStdIn;
    }

    /**
     * @return the standard 'out' stream of this Perl process (suitable for
     * reading the Perl process' stdout)
     */
    public BufferedReader getPerlStdOut()
    {
        return perlStdOut;
    }
}
