package org.ziptie.adaptertool.tools;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

import org.ziptie.adaptertool.AtConfigElf;

/**
 * Some statics around tools bundles
 * ToolBundleElf
 */
public final class ToolBundleElf
{

    /**
     * hidden
     */
    private ToolBundleElf()
    {
    }

    /**
     * 
     * Find script tool bundle directories
     * @return a list of bundle directories
     * @throws IOException if there is an error reading files
     */
    public static List<ScriptBundle> getScriptToolBundles() throws IOException
    {
        List<ScriptBundle> bundleList = new ArrayList<ScriptBundle>();
        File adapterDir = AtConfigElf.getAdapterDir();
        File[] files = adapterDir.listFiles();
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
                    String toolsDir = attrs.getValue("ZTool-Directory"); //$NON-NLS-1$
                    if (toolsDir != null)
                    {
                        bundleList.add(new ScriptBundle(files[i], toolsDir));
                    }
                }
                finally
                {
                    in.close();
                }
            }
        }
        return bundleList;
    }

}
