/*
 * Alterpoint, Inc.
 * 
 * The contents of this source code are proprietary and confidential All code,
 * patterns, and comments are Copyright Alterpoint, Inc. 2003-2005
 * 
 * $Author: rkruse $ $Date: 2008/08/21 19:42:24 $ $Revision: 1.7 $ $Source:
 * /usr/local/cvsroot/NIL/src/com/alterpoint/net/ping/Pinger.java,v $
 */

package org.ziptie.net.ping.icmp;

import java.io.IOException;
import java.io.InputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.ziptie.addressing.IPAddress;

/**
 * Ping a single host
 */
@SuppressWarnings("nls")
public final class Pinger
{
    public static final int DEFAULT_TIMEOUT = 500;
    public static final int DEFAULT_BYTE_SIZE = 32;
    public static final int DEFAULT_COUNT = 3;
    public static final int THREADS_PER_PROCESSOR = 20;

    private static final int PROCESS_SUCCESSFUL = 0;
    private static final String ERROR_MESSAGE = "Could not call ping program ";
    private static final int NUMBER_OF_ARGS = 8;
    private static final int THOUSAND_MS = 1000;
    private static Pinger instance;
    private PingConfig pc;

    private Pinger()
    {
        PingConfigLoader configLoader;
        try
        {
            configLoader = new PingConfigLoader();
            pc = configLoader.getPingConfig();
        }
        catch (PingException e)
        {
            throw new RuntimeException("Unable to load ping config. " + e.getMessage(), e);
        }
    }

    /**
     * 
     * @return the singleton <code>Pinger</code>
     */
    public static Pinger getInstance()
    {
        if (instance == null)
        {
            instance = new Pinger();
        }
        return instance;

    }

    /**
     * This method runs the system specific "ping" program as defined in the
     * pingConfig.xml document. Attempts to use the
     * <code>InetAddress#isReachable(int)</code> method in Java 1.5.0 were made, but
     * scrapped since the rights needed to open a raw ICMP socket are not given
     * to the DA user account. Using the operating system's built-in ping
     * program takes care of all the necessary setUID work for us.
     * 
     * @param ipAddress The host to ping
     * @param timeout the number of milliseconds to wait before giving up
     * @param byteSize the size in bytes of the ping packet
     * @param count the number of pings to send out
     * @return true if any of the pings respond
     */
    public boolean ping(IPAddress ipAddress, int timeout, int byteSize, int count)
    {
        boolean result = false;
        try
        {
            switch (pc.getOs())
            {
            case Windows:
                result = runWindows(ipAddress, timeout, byteSize, count);
                break;
            case Linux:
                result = runLinux(ipAddress, timeout, byteSize, count);
                break;
            case Mac:
                result = runLinux(ipAddress, timeout, byteSize, count);
                break;
            case Solaris:
                result = runSolaris(ipAddress, timeout, byteSize, count);
                break;
            default:
                break;
            }
        }
        catch (PingException pe)
        {
            throw new RuntimeException(pe);
        }
        return result;
    }

    /**
     * Quick ping of an address
     * @param ipAddress the address to ping
     * @return true if the address is alive
     */
    public boolean ping(IPAddress ipAddress)
    {
        return ping(ipAddress, DEFAULT_TIMEOUT, DEFAULT_BYTE_SIZE, DEFAULT_COUNT);
    }

    private boolean runWindows(IPAddress ipAddress, int timeout, int byteSize, int count) throws PingException
    {
        String[] args = createArgs(timeout, byteSize, count, ipAddress);
        return runPingCommand(args, ipAddress);
    }

    private boolean runLinux(IPAddress ipAddress, int timeout, int byteSize, int count) throws PingException
    {
        // Redhat does timeouts in seconds, not milliseconds
        int to = timeout / THOUSAND_MS;
        if (to <= 0)
        {
            to = 1;
        }
        String[] args = createArgs(to, byteSize, count, ipAddress);
        return runPingCommand(args, ipAddress);
    }

    private boolean runSolaris(IPAddress ipAddress, int timeout, int byteSize, int count) throws PingException
    {
        // Solaris does timeouts in seconds, not milliseconds
        int to = timeout / THOUSAND_MS;
        if (to <= 0)
        {
            to = 1;
        }

        /*
         * This ping is for the solaris "ping -n -s" command
         */
        if (pc.getCommand().contains("-n"))
        {
            String[] pingCommand = new String[6];
            pingCommand[0] = pc.getCommand();
            pingCommand[1] = ipAddress.toString();
            pingCommand[2] = pc.getSizeFlag();
            pingCommand[3] = String.valueOf(byteSize);
            pingCommand[4] = pc.getCountFlag();
            pingCommand[5] = String.valueOf(count);
            return runPingCommand(pingCommand, ipAddress);
        }
        /*
         * This ping is for a straight ping which only accepts a timeout you
         * can't change the ping size or count here.
         */
        else
        {
            String[] pingCommand = new String[4];
            pingCommand[0] = pc.getCommand();
            pingCommand[1] = ipAddress.toString();
            pingCommand[2] = pc.getTimeoutFlag();
            pingCommand[3] = String.valueOf(to);
            return runPingCommand(pingCommand, ipAddress);
        }
    }

    /**
     * @param timeout
     * @param byteSize
     * @param count
     * @return
     */
    private String[] createArgs(int timeout, int byteSize, int count, IPAddress ipAddress)
    {
        String[] args = new String[NUMBER_OF_ARGS];
        args[0] = pc.getCommand();
        args[1] = pc.getCountFlag();
        args[2] = String.valueOf(count);
        args[3] = pc.getTimeoutFlag();
        args[4] = String.valueOf(timeout);
        args[5] = pc.getSizeFlag();
        args[6] = String.valueOf(byteSize);
        args[7] = ipAddress.toString();
        return args;
    }

    /**
     * @param pingCommand
     * @return
     * @throws IOException
     * @throws InterruptedException
     */
    private boolean runPingCommand(String[] pingCommand, IPAddress ipAddress) throws PingException
    {
        try
        {
            ProcessBuilder procBuilder = new ProcessBuilder(pingCommand);
            procBuilder.redirectErrorStream(true);
            Process process = procBuilder.start();
            StringBuilder pingOutput = new StringBuilder();
            InputStream in = null;

            try
            {
                in = process.getInputStream();
                int c;
                while ((c = in.read()) != -1)
                {
                    pingOutput.append((char) c);
                }
                int exitCode = process.waitFor();
                if (exitCode == PROCESS_SUCCESSFUL)
                {
                    return analyzeResponse(pingOutput.toString(), ipAddress);
                }
                else
                {
                    return false;
                }
            }
            finally
            {
                if (in != null)
                {
                    in.close();
                }
                process.destroy();
            }

        }
        catch (IOException io)
        {
            throw new PingException(ERROR_MESSAGE + pc.getCommand(), io);
        }
        catch (InterruptedException ie)
        {
            throw new PingException(ERROR_MESSAGE + pc.getCommand(), ie);
        }
    }

    /**
     * If there are any other IPv4 addresses in the response the consider this a bad response.  
     * For example, if you ping a broadcast address, and a host on the subnet responds, we don't care.
     * @param pingOutput the output of the ping command
     * @param ipAddress The IP that was pinged
     * @return true if the response is good.
     */
    private boolean analyzeResponse(String pingOutput, IPAddress ipAddress)
    {
        if (!ipAddress.isVersion6())
        {
            String ip = ipAddress.toString();
            Pattern ipv4Pattern = Pattern.compile("(\\d{1,3}\\.){3}\\d{1,3}");
            Matcher matcher = ipv4Pattern.matcher(pingOutput);
            while (matcher.find())
            {
                String matchedIp = matcher.group();
                if (!ip.equals(matchedIp))
                {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * @return the pc
     */
    public PingConfig getPc()
    {
        return pc;
    }

    /**
     * @param pc the pc to set
     */
    public void setPc(PingConfig pc)
    {
        this.pc = pc;
    }
}
