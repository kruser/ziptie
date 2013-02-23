package org.ziptie.provider.tools;

import java.io.StringWriter;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import org.apache.log4j.Logger;
import org.ziptie.perl.PerlException;
import org.ziptie.perl.PerlPoolManager;
import org.ziptie.perl.PerlServer;
import org.ziptie.provider.devices.ZDeviceLite;
import org.ziptie.provider.tools.internal.PluginsActivator;
import org.ziptie.server.dispatcher.ITask;
import org.ziptie.server.dispatcher.Outcome;
import org.ziptie.server.job.AdapterException;
import org.ziptie.server.job.PerlErrorParserElf;
import org.ziptie.zap.jta.TransactionElf;
import org.ziptie.zap.web.IWebService;

/**
 * ScriptToolTask
 */
public class ScriptToolTask implements ITask
{
    private static final Logger LOGGER = Logger.getLogger(ScriptToolTask.class);

    private static final String ADAPTER_LOGGING_LEVEL = "ADAPTER_LOGGING_LEVEL"; //$NON-NLS-1$

    private List<ZDeviceLite> devices;
    private ZDeviceLite device;
    private String toolScript;
    private String toolName;
    private ZToolProperties toolProperties;
    private Properties inputProperties;
    private StringBuilder resultSB;
    private Date startTime;
    private Date endTime;

    private String username;

    // Instance initializer
    {
        resultSB = new StringBuilder();
    }

    /**
     * @param deviceLites The device to execute against.
     * @param toolName The name of the tool.
     * @param toolScript The script to run.
     * @param toolProperties The properties that define the tool.
     * @param inputProperties The properties to pass into the tool
     * @param username The username of the user that this task belongs to
     */
    public ScriptToolTask(ZDeviceLite deviceLites, String toolName, String toolScript, ZToolProperties toolProperties, Properties inputProperties,
            String username)
    {
        this.device = deviceLites;
        this.toolName = toolName;
        this.toolScript = toolScript;
        this.toolProperties = toolProperties;
        this.inputProperties = inputProperties;
        this.username = username;
    }

    /**
     * @param deviceLites The devices to execute against.
     * @param toolName The name of the tool.
     * @param toolScript The script to run.
     * @param toolProperties The properties that define the tool.
     * @param inputProperties The properties to pass into the tool
     * @param username The username of the user that this task belongs to
     */
    public ScriptToolTask(List<ZDeviceLite> deviceLites, String toolName, String toolScript, ZToolProperties toolProperties, Properties inputProperties,
            String username)
    {
        this.devices = deviceLites;
        this.toolName = toolName;
        this.toolScript = toolScript;
        this.toolProperties = toolProperties;
        this.inputProperties = inputProperties;
        this.username = username;
    }

    /** {@inheritDoc} */
    /** {@inheritDoc} */
    public Outcome execute() throws Exception
    {
        // We OWN this transaction.
        TransactionElf.beginOrJoinTransaction();

        startTime = new Date();
        try
        {
            if (toolProperties.getMode() == ZToolProperties.ToolMode.COMBINED)
            {
                // Remove any devices that have a null adapter ID
                Iterator<ZDeviceLite> iter = devices.iterator();
                while (iter.hasNext())
                {
                    if (iter.next().getAdapterId() == null)
                    {
                        iter.remove();
                    }
                }

                // Test to see if tool about to be executed supports all of the devices
                if (!ScriptBindingElf.isToolSupportedForDevices(devices, toolProperties))
                {
                    LOGGER.warn("Script tool '" + toolProperties.getToolName() + "' is not supported for all selected devices!");
                    return Outcome.FAILURE;
                }
            }
            else
            {
                if (device.getAdapterId() == null)
                {
                    throw new IllegalStateException("No adapter specified."); //$NON-NLS-1$
                }

                // Test to see if tool about to be executed supports the device
                if (!ScriptBindingElf.isToolSupportedForDevice(device, toolProperties))
                {
                    LOGGER.warn("Script tool '" + toolProperties.getToolName() + "' is not supported for selected device!");
                    return Outcome.FAILURE;
                }
            }

            return runPerl();
        }
        finally
        {
            endTime = new Date();
            TransactionElf.commit();
        }
    }

    /**
     * Get the device this tool ran against, or null if this tool ran against
     * multiple devices for a single script (i.e. "combined mode").
     *
     * @return a ZDeviceLite object, or <code>null</code>
     */
    public ZDeviceLite getDevice()
    {
        return device;
    }

    /**
     * Get the list of devices this tool ran against if this was a "combined mode"
     * tool, otherwise return <code>null</code>.
     *
     * @return a list of ZDeviceLite objects, or <code>null</code> if not a combined mode execution.
     */
    public List<ZDeviceLite> getDevices()
    {
        return devices;
    }

    /** {@inheritDoc} */
    public Object getLockObject()
    {
        return device;
    }

    /**
     * Get the string result (script output) of the execution of this task.
     *
     * @return the output from execution of the script
     */
    public String getResultString()
    {
        return resultSB.toString();
    }

    /**
     * Get the start time of the task.
     *
     * @return the task start time
     */
    public Date getStartTime()
    {
        return startTime;
    }

    /**
     * Get the end time of the task.
     *
     * @return the task end time
     */
    public Date getEndTime()
    {
        return endTime;
    }

    /** {@inheritDoc} */
    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        sb.append(toolName).append(" for ").append(device != null ? device : "multiple devdeviceices"); //$NON-NLS-1$ //$NON-NLS-2$
        return sb.toString();
    }

    //-----------------------------------------------------------------------
    //                     P R I V A T E   M E T H O D S
    //-----------------------------------------------------------------------

    /**
     * Executes the perl script.
     *
     * @throws Exception on error 
     */
    private Outcome runPerl() throws Exception
    {
        PerlPoolManager pool = PluginsActivator.getPerlPoolManager();
        PerlServer server = pool.getPerlServer();
        try
        {
            String[] env = new String[2];
            env[0] = ADAPTER_LOGGING_LEVEL + "=0"; //$NON-NLS-1$
            env[1] = "ZIPTIE_AUTHENTICATION=" + createAuthenticationString(); //$NON-NLS-1$

            String[] args = formatParameters();

            StringWriter internalWriter = new StringWriter();

            server.eval(toolScript, args, env, internalWriter);

            resultSB.append(internalWriter.toString());

            return Outcome.SUCCESS;
        }
        catch (PerlException e)
        {
            LOGGER.debug("Exception running script.", e); //$NON-NLS-1$

            String message = PerlErrorParserElf.getMessage(e);
            resultSB.append(message);

            // Parse out the remote exception into a more useful exception.  This is done by analyzing the error
            // thrown from Perl and creating an Exception that is mapped to it
            AdapterException adapterException = PerlErrorParserElf.parse(message);
            if (adapterException == null)
            {
                throw new Exception(message, e);
            }

            throw adapterException;
        }
        finally
        {
            pool.returnPerlServer(server);
        }
    }

    private String createAuthenticationString() throws UnknownHostException
    {
        String token = PluginsActivator.getSecurityService().createAuthenticationToken(username);

        IWebService webService = PluginsActivator.getWebService();

        int port = webService.getPort(IWebService.PRIMARY_CONNECTOR);
        String host = webService.getHost(IWebService.PRIMARY_CONNECTOR);
        String scheme = webService.getScheme(IWebService.PRIMARY_CONNECTOR);

        if (host == null)
        {
            host = InetAddress.getLocalHost().getHostAddress();
        }
        return String.format("%s://%s@%s:%d/server/", scheme, token, host, port); //$NON-NLS-1$        
    }

    /**
     * 
     * @return
     */
    private String[] formatParameters()
    {
        ArrayList<String> parameters = new ArrayList<String>();

        String[] split = toolProperties.getScriptParamString().split(" "); //$NON-NLS-1$
        for (String format : split)
        {
            if (toolProperties.getMode() == ZToolProperties.ToolMode.COMBINED)
            {
                String devicesSelectedReplacement = toolProperties.getProperty("devices.selected"); //$NON-NLS-1$
                List<String> bindings = ScriptBindingElf.bindProperties(devices, inputProperties, format, devicesSelectedReplacement);
                parameters.addAll(bindings);
            }
            else
            {
                String binding = ScriptBindingElf.bindProperties(device, inputProperties, format);
                parameters.add(binding);
            }
        }

        return parameters.toArray(new String[0]);
    }
}
