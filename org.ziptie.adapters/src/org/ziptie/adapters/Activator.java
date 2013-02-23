package org.ziptie.adapters;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.LinkedList;
import java.util.List;

import org.apache.log4j.Logger;
import org.eclipse.osgi.framework.internal.core.BundleURLConnection;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.ziptie.perl.PerlPoolManager;

/**
 * Lifecycle class for the adapters bundle.
 */
@SuppressWarnings( { "restriction", "nls" })
public class Activator implements BundleActivator
{
    private static final String WINDOWS = "indows"; //$NON-NLS-1$
    private static final String OS;

    private static Activator instance;
    private BundleContext context;
    private ServiceReference poolServiceRef;

    // static initializer
    static
    {
        String osName = System.getProperty("os.name");
        if ("Mac OS X".equals(osName))
        {
            OS = "macosx";
        }
        else if (osName.contains(WINDOWS))
        {
            OS = "windows";
        }
        else if (osName.contains("inux"))
        {
            OS = "linux";
        }
        else if (osName.contains("SunOS") || osName.contains("olaris"))
        {
            OS = "solaris";
        }
        else
        {
            OS = osName;
        }
    }

    /** {@inheritDoc} */
    public void start(BundleContext ctxt) throws Exception
    {
        if (instance != null)
        {
            throw new IllegalStateException(ctxt.getBundle().getSymbolicName() + " already running!");
        }
        instance = this;

        context = ctxt;

        String path = null;
        URL entry = ctxt.getBundle().getEntry("/bin/" + OS);
        if (entry != null)
        {
            URLConnection connection = entry.openConnection();
            if (connection instanceof BundleURLConnection)
            {
                URL fileURL = ((BundleURLConnection) connection).getFileURL();
                String escapedURL = fileURL.toExternalForm().replace(" ", "%20");
                URI uri = URI.create(escapedURL);
                path = new File(uri).getAbsolutePath();
            }
        }

        if (path == null)
        {
            throw new RuntimeException("Unable to start bundle due to inability to obtain absolute bundle path.");
        }

        // This code sets the executable bit on the plink file in both Linux and Mac OS X
        //
        if (!OS.contains(WINDOWS))
        {
            List<String> cmds = new LinkedList<String>();
            cmds.add("sh");
            cmds.add("-c");
            cmds.add("chmod +x " + path.replace(" ", "\\ ") + File.separator + "*");

            ProcessBuilder pb = new ProcessBuilder(cmds);
            Process process = pb.start();
            int rc = process.waitFor();
            if (rc != 0)
            {
                Logger.getLogger(getClass()).warn("chmod of plink executable returned " + rc);
            }
        }

        Bundle bundle = Activator.getInstance().getContext().getBundle();
        URL url = bundle.getEntry("scripts/invoke.pl");
        if (url == null)
        {
            throw new RuntimeException("invoke.pl could not be found!");
        }

        poolServiceRef = ctxt.getServiceReference(PerlPoolManager.class.getName());
        PerlPoolManager pool = (PerlPoolManager) ctxt.getService(poolServiceRef);

        AdapterInvokerElf.setInvoker(url);
        AdapterInvokerElf.setPerlPoolManager(pool);

        IANAProtocolNumbers.load(bundle);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext ctxt) throws Exception
    {
        instance = null;
        ctxt.ungetService(poolServiceRef);
    }

    /**
     * Gets the bundle's context.
     * @return The context
     */
    public BundleContext getContext()
    {
        return context;
    }

    /**
     * Gets the singleton instance.
     * @return The instance.
     */
    public static Activator getInstance()
    {
        return instance;
    }
}
