package org.ziptie.adaptertool.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.jar.Attributes;
import java.util.jar.Manifest;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.ziptie.adaptertool.AdapterCli;
import org.ziptie.adaptertool.AdapterConstants;
import org.ziptie.adaptertool.AtConfigElf;
import org.ziptie.adaptertool.CliElf;
import org.ziptie.adaptertool.ConnectionPathBuilder;
import org.ziptie.adaptertool.FileServerElf;
import org.ziptie.adaptertool.Messages;
import org.ziptie.perl.PerlException;
import org.ziptie.perl.PerlPoolManager;
import org.ziptie.perl.PerlServer;
import org.ziptie.protocols.ProtocolNames;

/**
 * Runs a script tool 
 * ScriptToolCli
 */
public class ScriptToolCli
{
    private static final String WHITESPACE = "\\s+"; //$NON-NLS-1$
    private static final String SCRIPT_NAME = "script.name"; //$NON-NLS-1$
    private static final String DEVICES_SELECTED = "devices.selected"; //$NON-NLS-1$
    private static final String TOOL_ARG_REGEX = "\\{(\\S+)\\}"; //$NON-NLS-1$
    private static final String INPUT_PROP = "input."; //$NON-NLS-1$
    private static final String CONNECTION_PATH = "connectionPath"; //$NON-NLS-1$
    private List<ScriptTool> tools;
    private Properties scriptParameters;
    private ScriptTool chosenTool;
    private boolean printProperties;

    /**
     * default
     */
    public ScriptToolCli()
    {
        scriptParameters = new Properties();
    }

    /**
     * @param args the args
     */
    public static void main(String[] args)
    {
        try
        {
            CliElf.setupLog4j();
            AtConfigElf.loadSetup();
            System.setProperty("PERL_SYSTEM_PATH", "bin/" + AdapterCli.getOS()); //$NON-NLS-1$ //$NON-NLS-2$
            AtConfigElf.addToIncludePath(new File("scripts")); //$NON-NLS-1$

            boolean runDebugger = false;

            ScriptToolCli scriptToolCli = new ScriptToolCli();
            for (int i = 0; i < args.length; i++)
            {
                if (args[i].equals("-p")) //$NON-NLS-1$
                {
                    scriptToolCli.printProperties = true;
                }
                else if (args[i].equals("-i")) //$NON-NLS-1$
                {
                    File propertiesFile = new File(CliElf.next(args, ++i));
                    if (propertiesFile.exists())
                    {
                        scriptToolCli.scriptParameters.load(new FileInputStream(propertiesFile));
                        scriptToolCli.startServers();
                    }
                    else
                    {
                        System.err.printf(Messages.getString("ScriptToolCli.badInputFile"), propertiesFile); //$NON-NLS-1$
                        System.exit(0);
                    }
                }
                else if (args[i].equals("-c")) //$NON-NLS-1$
                {
                    new ToolCreationWizard().runWizard();
                    System.exit(0);
                }
                else if (args[i].equals("-d")) //$NON-NLS-1$
                {
                    runDebugger = true;
                }
            }

            scriptToolCli.run(runDebugger);
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    /**
     * Start FTP or TFTP where necessary
     * @throws Exception 
     */
    private void startServers() throws Exception
    {
        String connectionPathXml = scriptParameters.getProperty(CONNECTION_PATH);
        if (connectionPathXml != null)
        {
            if (connectionPathXml.contains("\"" + ProtocolNames.TFTP.name() + "\""))
            {
                FileServerElf.startTftpd(false);
            }
            if (connectionPathXml.contains("\"" + ProtocolNames.FTP.name() + "\""))
            {
                FileServerElf.startFtpd(false);
            }
        }
    }

    private void run(boolean debug)
    {
        try
        {
            tools = new ArrayList<ScriptTool>();
            loadAvailableScriptTools();
            startInteractiveMenu();
            if (debug)
            {
                debug();
            }
            else
            {
                runPerl();
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            System.exit(0);
        }
    }

    @SuppressWarnings("nls")
    private void debug()
    {
        String[] args = formatParameters();
        String[] perlIncludes = System.getProperty("PERL_INC", ".").split(File.pathSeparator);

        System.out.println("=================");
        System.out.print("perl -d");
        for (String inc : perlIncludes)
        {
            System.out.print(" -I");
            System.out.print(inc);
        }

        System.out.print(" \"");
        System.out.print(chosenTool.getPerlScript().getAbsolutePath());
        System.out.print("\"");
        for (String arg : args)
        {
            System.out.print(" \"");
            System.out.print(arg.replaceAll("\"", "\\\\\\\""));
            System.out.print("\"");
        }
        System.out.println();
    }

    /**
     * Run the Perl script
     * @param tool 
     * @throws PerlException on error
     */
    private void runPerl() throws PerlException
    {
        PerlPoolManager perlPoolManager = new PerlPoolManager();

        PerlServer server = perlPoolManager.getPerlServer();
        try
        {
            String[] env = new String[1];
            env[0] = AdapterConstants.ADAPTER_LOGGING_LEVEL + "=" + AdapterConstants.DEBUG_LOGGING_LEVEL; //$NON-NLS-1$

            String[] args = formatParameters();

            StringWriter internalWriter = new StringWriter();

            server.eval(fileToString(chosenTool.getPerlScript()), args, env, internalWriter);

            System.out.print(internalWriter.toString());
        }
        finally
        {
            perlPoolManager.returnPerlServer(server);
            perlPoolManager.shutdown();
        }
    }

    /**
     * Read the contents of a file
     * @param perlScript
     * @return the contents of the file as a string
     */
    private String fileToString(File perlScript)
    {
        try
        {
            InputStream is = new FileInputStream(perlScript);
            Reader reader = new InputStreamReader(is);
            StringBuilder sb = new StringBuilder();
            char[] cbuf = new char[1024];
            while (true)
            {
                int rc = reader.read(cbuf);
                if (rc <= 0)
                {
                    break;
                }
                sb.append(cbuf, 0, rc);
            }
            is.close();
            return sb.toString();
        }
        catch (IOException io)
        {
            return ""; //$NON-NLS-1$
        }
    }

    /**
     * Format all of the variables into an array of string args
     * @return
     */
    private String[] formatParameters()
    {
        ArrayList<String> parameters = new ArrayList<String>();
        String scriptCommand = chosenTool.getProperties().getProperty(SCRIPT_NAME);
        Pattern pattern = Pattern.compile(TOOL_ARG_REGEX);

        System.err.println(Messages.getString("ScriptToolCli.runningCommand")); //$NON-NLS-1$
        String[] split = scriptCommand.split(WHITESPACE);
        System.err.print(split[0] + " "); //$NON-NLS-1$
        for (int i = 1; i < split.length; i++)
        {
            Matcher matcher = pattern.matcher(split[i]);
            if (matcher.find())
            {
                String varName = matcher.group(1);
                if (varName.equals(DEVICES_SELECTED))
                {
                    String deviceProperties = chosenTool.getProperties().getProperty(DEVICES_SELECTED);
                    String[] splitDeviceProperties = deviceProperties.split("\\s+"); //$NON-NLS-1$
                    boolean keepGoing = true;
                    int deviceInstance = 0;
                    while (keepGoing)
                    {
                        for (int j = 0; j < splitDeviceProperties.length; j++)
                        {
                            String prop = splitDeviceProperties[j].replaceAll("\\{|\\}", ""); //$NON-NLS-1$ //$NON-NLS-2$
                            String propertyName = prop + "." + deviceInstance; //$NON-NLS-1$
                            String resolvedVar = scriptParameters.getProperty(propertyName);
                            if (resolvedVar != null)
                            {
                                System.err.print(resolvedVar + " "); //$NON-NLS-1$
                                parameters.add(resolvedVar);
                            }
                            else
                            {
                                keepGoing = false;
                                break;
                            }
                        }
                        deviceInstance++;
                    }
                }
                else
                {
                    String resolvedVar = scriptParameters.getProperty(varName);
                    if (resolvedVar != null)
                    {
                        String resolvedArg = split[i].replace(matcher.group(), resolvedVar);
                        System.err.print(resolvedArg + " "); //$NON-NLS-1$
                        parameters.add(resolvedArg);
                    }
                }
            }
        }
        System.err.println();
        return parameters.toArray(new String[0]);
    }

    /**
     * To be called after everything is loaded, this method will provide the interactive menu to the user.
     *
     */
    private void startInteractiveMenu()
    {
        if (tools.size() == 0)
        {
            System.err.println(Messages.getString("ScriptToolCli.noTools")); //$NON-NLS-1$
            System.exit(0);
        }
        else
        {
            String selection = chooseTool();
            getInputArgs(selection);
        }
    }

    /**
     * Get the input arguments for the tool at the provided selection point
     * @param selection the selected tool number
     */
    private void getInputArgs(String selection)
    {
        try
        {
            chosenTool = tools.get(Integer.parseInt(selection));
            if (chosenTool != null)
            {
                // only gather input if there aren't previously setup properties
                if (scriptParameters.size() == 0)
                {
                    Properties toolProps = populateUserArgs();
                    populateZiptieArgs(toolProps);

                    if (printProperties)
                    {
                        scriptParameters.store(System.out, ""); //$NON-NLS-1$
                        System.exit(1);
                    }
                }
            }
            else
            {
                System.err.println(Messages.getString("ScriptToolCli.invalidSelection")); //$NON-NLS-1$
            }
        }
        catch (NumberFormatException e)
        {
            System.err.println(Messages.getString("ScriptToolCli.invalidSelection")); //$NON-NLS-1$
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * @param toolProps
     */
    private void populateZiptieArgs(Properties toolProps)
    {
        System.err.println(Messages.getString("ScriptToolCli.parametersFromZiptie")); //$NON-NLS-1$
        String scriptCommand = toolProps.getProperty(SCRIPT_NAME);
        Pattern pattern = Pattern.compile(TOOL_ARG_REGEX);
        Matcher matcher = pattern.matcher(scriptCommand);
        while (matcher.find())
        {
            String scriptArg = matcher.group(1);
            if (scriptArg.equals(CONNECTION_PATH)) //$NON-NLS-1$
            {
                ConnectionPathBuilder connectionPathBuilder = new ConnectionPathBuilder();
                connectionPathBuilder.buildConnectionPathXml();
                String connectionPathXml = connectionPathBuilder.getOperationInputXml();
                scriptParameters.put(scriptArg, connectionPathXml);
            }
            else if (scriptArg.equals(DEVICES_SELECTED))
            {
                int deviceCount = 0;
                boolean keepGoing = true;
                while (keepGoing)
                {
                    System.err.printf(Messages.getString("ScriptToolCli.deviceSelected"), deviceCount + 1); //$NON-NLS-1$
                    populateDeviceSelectedArgs(toolProps, deviceCount);
                    String yesOrNo = CliElf.get(Messages.getString("ScriptToolCli.anotherDevice")); //$NON-NLS-1$
                    keepGoing = yesOrNo.matches("(?i)y|yes|true"); //$NON-NLS-1$
                    deviceCount++;
                }
            }
            else if (!scriptArg.startsWith(INPUT_PROP))
            {
                String answer = CliElf.get(scriptArg + ": "); //$NON-NLS-1$
                scriptParameters.put(scriptArg, answer);
            }
        }
    }

    /**
     * Populate properties for a single device, and name each property with the provided deviceCount.
     * @param toolProps the properties for the tool
     * @param deviceCount the current device count
     */
    private void populateDeviceSelectedArgs(Properties toolProps, int deviceCount)
    {
        String selectionArgs = toolProps.getProperty(DEVICES_SELECTED);
        Pattern pattern = Pattern.compile(TOOL_ARG_REGEX);
        Matcher matcher = pattern.matcher(selectionArgs);
        while (matcher.find())
        {
            String scriptArg = matcher.group(1);
            if (scriptArg.equals(CONNECTION_PATH)) //$NON-NLS-1$
            {
                ConnectionPathBuilder connectionPathBuilder = new ConnectionPathBuilder();
                connectionPathBuilder.buildConnectionPathXml();
                String connectionPathXml = connectionPathBuilder.getOperationInputXml();
                scriptParameters.put(scriptArg + "." + deviceCount, connectionPathXml); //$NON-NLS-1$
            }
            else if (!scriptArg.startsWith(INPUT_PROP))
            {
                String answer = CliElf.get(scriptArg + ": "); //$NON-NLS-1$
                scriptParameters.put(scriptArg + "." + deviceCount, answer); //$NON-NLS-1$
            }
        }
    }

    /**
     * @return
     */
    private Properties populateUserArgs()
    {
        Properties toolProps = chosenTool.getProperties();
        int i = 0;
        boolean printedHeader = false;
        while (true)
        {
            String input = toolProps.getProperty(INPUT_PROP + i);
            if (input != null)
            {
                if (!printedHeader)
                {
                    System.err.println(Messages.getString("ScriptToolCli.scriptParameters")); //$NON-NLS-1$
                    printedHeader = true;
                }
                String answer = CliElf.get(toolProps.getProperty(INPUT_PROP + i + ".label") + ": "); //$NON-NLS-1$//$NON-NLS-2$
                if (answer.length() > 0)
                {
                    scriptParameters.put(INPUT_PROP + input, answer);
                }
            }
            else
            {
                break;
            }
            i++;
        }
        return toolProps;
    }

    /**
     * Choose a tool from the available tools
     * @return
     */
    private String chooseTool()
    {
        System.err.println(Messages.getString("ScriptToolCli.availableTools")); //$NON-NLS-1$
        for (int i = 0; i < tools.size(); i++)
        {
            ScriptTool tool = tools.get(i);
            System.err.printf(" %2d: %s\n", i, tool.getToolName()); //$NON-NLS-1$
        }
        String selection = CliElf.get(Messages.getString("ScriptToolCli.selectTool")); //$NON-NLS-1$
        return selection;
    }

    /**
     * Finds script tools
     * @throws IOException 
     *
     */
    private void loadAvailableScriptTools() throws IOException
    {
        File toolsDir = AtConfigElf.getToolsDir();
        File[] files = toolsDir.listFiles();
        for (int i = 0; i < files.length; i++)
        {
            File manifest = new File(files[i], AtConfigElf.MANIFEST);
            if (manifest.exists())
            {
                FileInputStream in = new FileInputStream(manifest);
                try
                {
                    Manifest mf = new Manifest(in);
                    Attributes attrs = mf.getMainAttributes();
                    String toolsDirProp = attrs.getValue("ZTool-Directory"); //$NON-NLS-1$
                    if (toolsDirProp != null)
                    {
                        loadAvailableTools(new File(files[i], toolsDirProp));
                    }
                }
                finally
                {
                    in.close();
                }
            }
        }
    }

    /**
     * Loads all tools inside the given directory.
     *  
     * @param file a folder containing script tools
     * @throws IOException if there was an error reading the properties
     */
    private void loadAvailableTools(File scriptsDirectory) throws IOException
    {
        String[] toolsProperties = scriptsDirectory.list(new PropertiesFilter());
        for (int i = 0; i < toolsProperties.length; i++)
        {
            Properties props = new Properties();
            props.load(new FileInputStream(new File(scriptsDirectory, toolsProperties[i])));

            String nameProp = props.getProperty("script.name"); //$NON-NLS-1$
            if (nameProp == null)
            {
                System.err.println("The script.name property must be defined in each tool from " + scriptsDirectory);
                System.exit(0);
            }
            String perlScriptName = nameProp.split(WHITESPACE)[0];
            ScriptTool tool = new ScriptTool(props, new File(scriptsDirectory, perlScriptName));
            tools.add(tool);
        }
    }

}
