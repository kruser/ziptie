package org.ziptie.adaptertool.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import org.ziptie.adaptertool.AdapterConstants;
import org.ziptie.adaptertool.AtConfigElf;
import org.ziptie.adaptertool.CliElf;
import org.ziptie.adaptertool.Messages;
import org.ziptie.adaptertool.StringReplaceInputStream;

/**
 * Helps build a script tool
 * ToolCreationWizard
 */
public class ToolCreationWizard
{
    private static final String TYPE_SNMP = "2";

    private static final String TYPE_CLI = "1";

    private static final String CREATE_NEW_BUNDLE = TYPE_CLI;

    private String bundleName = "";
    private String toolTip = "";
    private String toolLabel = "";
    private String toolName = "";
    private String dependentAdapter = "";

    /**
     * run the wizard.
     */
    public void runWizard()
    {
        try
        {
            AtConfigElf.loadSetup();
            String answer = CliElf.get(Messages.getString("ScriptToolCli.createStepOne"));
            ScriptBundle toolsBundle = null;
            if (answer.equals(CREATE_NEW_BUNDLE))
            {
                toolsBundle = createNewBundle();
            }
            else
            {
                toolsBundle = chooseExistingBundle();
            }
            createNewTool(toolsBundle);
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * Create the new tool template inside the previously chosen bundle.
     * 
     * @param toolsBundle
     */
    private void createNewTool(ScriptBundle toolsBundle)
    {
        String toolType = CliElf.get(Messages.getString("ScriptToolCli.newToolType")).trim();
        System.err.println(Messages.getString("ScriptToolCli.newToolHeader"));
        toolLabel = CliElf.get(Messages.getString("ScriptToolCli.newToolDisplayName")).trim();
        toolTip = CliElf.get(Messages.getString("ScriptToolCli.newToolTooltip")).trim();
        toolName = formatName(toolLabel);
        if (toolType.equals(TYPE_CLI))
        {
            System.err.println(Messages.getString("ScriptToolCli.adapterForLogin"));
            dependentAdapter = AtConfigElf.chooseAdapter();
            copyTool("cli_template", toolName, toolsBundle);
        }
        else if (toolType.equals(TYPE_SNMP))
        {
            copyTool("snmp_template", toolName, toolsBundle);
        }
        else
        {
            copyTool("generic_template", toolName, toolsBundle);
        }
    }

    /**
     * Copy a specific type of tool template to its final home
     * @param toolType
     * @param formattedName
     * @param toolsBundle
     */
    private void copyTool(String toolType, String formattedName, ScriptBundle toolsBundle)
    {
        try
        {
            File scriptsFolder = new File(toolsBundle.getBundle(), toolsBundle.getScriptsFolderName());
            copy(new File("templates/newScriptTool" + File.separator + toolType + ".pl"), new File(scriptsFolder, formattedName + ".pl"));
            copy(new File("templates/newScriptTool" + File.separator + toolType + ".properties"), new File(scriptsFolder, formattedName + ".properties"));
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    /**
     * Make a display name like "Password Change" into 
     * a filename like "password_change".
     * 
     * @param toolName2
     * @return
     */
    private String formatName(String name)
    {
        String newName = name.toLowerCase().replaceAll("[^a-z0-9]", "");
        if (newName.length() > 20)
        {
            return newName.substring(0, 20);
        }
        else
        {
            return newName;
        }
    }

    /**
     * Create a new bundle
     * @throws IOException 
     */
    private ScriptBundle createNewBundle() throws IOException
    {
        bundleName = CliElf.get(Messages.getString("ScriptToolCli.newBundleName")).trim();
        File bundleDir = new File(AtConfigElf.getToolsDir(), bundleName);
        if (!bundleDir.isDirectory())
        {
            bundleDir.mkdir();
            copy(new File(AdapterConstants.TEMPLATE_BUNDLE), bundleDir); //$NON-NLS-1$
            new File(bundleDir, "scripts").mkdir();
        }
        return new ScriptBundle(bundleDir, "scripts");
    }

    private void copy(File from, File to) throws IOException
    {
        if (from.isDirectory())
        {
            System.err.printf(Messages.getString("CreateAdapter.creatingDirectory"), to.toString()); //$NON-NLS-1$
            to.mkdirs();

            File[] files = from.listFiles();
            if (files == null)
            {
                System.err.println(Messages.getString("CreateAdapter.noFilesToCopy") + from); //$NON-NLS-1$
                return;
            }

            for (File file : files)
            {
                copy(file, new File(to, file.getName()));
            }
        }
        else
        {
            // copy 'file' to directory 'to'
            String name = from.getName();

            System.err.printf(Messages.getString("CreateAdapter.copyingFile"), from.toString(), name); //$NON-NLS-1$

            File target = to;

            InputStream input = new FileInputStream(from);
            input = new StringReplaceInputStream(AdapterConstants.PROJECT_NAME, bundleName, input);
            input = new StringReplaceInputStream(AdapterConstants.BUNDLE_TYPE, "ZTool-Directory: scripts", input);
            input = new StringReplaceInputStream(AdapterConstants.DEPENDENT_ADAPTER, dependentAdapter, input);
            input = new StringReplaceInputStream(AdapterConstants.TOOL_NAME, toolName, input);
            input = new StringReplaceInputStream(AdapterConstants.TOOL_LABEL, toolLabel, input);
            input = new StringReplaceInputStream(AdapterConstants.TOOL_TOOLTIP, toolTip, input);

            FileOutputStream out = new FileOutputStream(target);
            byte[] buf = new byte[2048];
            int len;
            while ((len = input.read(buf)) > 0)
            {
                out.write(buf, 0, len);
            }

            input.close();
            out.close();
        }
    }

    /**
     * Allow the user to choose from the existing bundles.
     * @return the chosen ScriptBundle
     */
    private ScriptBundle chooseExistingBundle()
    {
        ScriptBundle bundleSelected = null;
        try
        {
            List<ScriptBundle> scriptToolBundles = ToolBundleElf.getScriptToolBundles();
            System.err.println(Messages.getString("ScriptToolCli.availableTools")); //$NON-NLS-1$
            for (int i = 0; i < scriptToolBundles.size(); i++)
            {
                ScriptBundle bundle = scriptToolBundles.get(i);
                System.err.printf(" %2d: %s\n", i, bundle.getBundle().getName()); //$NON-NLS-1$
            }
            int selection = Integer.parseInt(CliElf.get(Messages.getString("ScriptToolCli.selectToolBundle"))); //$NON-NLS-1$
            bundleSelected = scriptToolBundles.get(selection);
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
        catch (NumberFormatException e)
        {
            System.err.println(Messages.getString("ScriptToolCli.invalidSelection")); //$NON-NLS-1$
            System.exit(1);
        }
        return bundleSelected;
    }

    /**
     * Main for testing
     * @param args incoming
     */
    public static void main(String[] args)
    {
        new ToolCreationWizard().runWizard();
    }
}
