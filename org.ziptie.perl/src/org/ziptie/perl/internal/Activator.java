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
package org.ziptie.perl.internal;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.Logger;
import org.eclipse.osgi.framework.internal.core.BundleURLConnection;
import org.osgi.framework.Bundle;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.BundleEvent;
import org.osgi.framework.ServiceRegistration;
import org.osgi.framework.SynchronousBundleListener;
import org.ziptie.perl.PerlPoolManager;

/**
 * Activator for the Perl Server Pool.  This sets up the System properties to contain
 * the Perl include path &etc.  It also registers as a bundle listener
 * so that it can adjust the Perl path as bundles come and go in the
 * OSGi environment.  Any 'installed' bundle is considered game, and if
 * it declares the necessary Manifest Perl extension the System properties
 * are adjusted.
 * 
 *  We use SynchronousBundleListener so to prevent funky race conditions
 *  that occur when a bunch of bundles are being installed/uninstalled.
 */
@SuppressWarnings({ "nls", "restriction" })
public class Activator implements BundleActivator, SynchronousBundleListener
{
    private static final String LINUX = "linux";
    private static final String WINDOWS = "windows";
    private static final String MACOSX = "macosx";
    private static final String SOLARIS = "solaris";

    private static final String PERL_INC = "PERL_INC";
    private static final String BUNDLE_HEADER_PERL_INC = "Perl-Include";
    private static final String PERL_SYSTEM_PATH = "PERL_SYSTEM_PATH";
    private static final String BUNDLE_HEADER_PERL_SYSTEM_PATH = "Perl-System-Path";

    //CHECKSTYLE:OFF
    private static final Logger logger = Logger.getLogger(Activator.class);

    private BundleContext bundleContext;
    private PerlPoolManager theOneTruePerlPoolManager;

    private Map<String, String> origPaths;
    private ServiceRegistration registration;
    private Thread shutdownHook;

    /** {@inheritDoc} */
    public void start(BundleContext context) throws Exception
    {
        this.bundleContext = context;

        origPaths = new HashMap<String, String>();
        origPaths.put(PERL_SYSTEM_PATH, System.getProperty(PERL_SYSTEM_PATH, "."));
        origPaths.put(PERL_INC, System.getProperty(PERL_INC, "."));

        theOneTruePerlPoolManager = new PerlPoolManager();

        resetPerlPath();

        registration = context.registerService(PerlPoolManager.class.getName(), theOneTruePerlPoolManager, null);

        bundleContext.addBundleListener(this);

        // Add a JVM shutdown hook to kill all perl processes
        shutdownHook = new Thread("PerlEngine Shutdown Hook") //$NON-NLS-1$
        {
            @Override
            public void run()
            {
                theOneTruePerlPoolManager.shutdown();
            }
        };
        Runtime.getRuntime().addShutdownHook(shutdownHook);
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        bundleContext.removeBundleListener(this);

        registration.unregister();
        theOneTruePerlPoolManager.shutdown();
    }

    private void resetPerlPath() throws Exception
    {
        String perlIncl = assemblePath(bundleContext, PERL_INC, BUNDLE_HEADER_PERL_INC);
        String perlSystem = assemblePath(bundleContext, PERL_SYSTEM_PATH, BUNDLE_HEADER_PERL_SYSTEM_PATH);

        System.setProperty(PERL_INC, perlIncl);
        System.setProperty(PERL_SYSTEM_PATH, perlSystem);

        logger.trace("resetting Perl include path to " + perlIncl);
        logger.trace("resetting Perl system path to " + perlSystem);

        if (theOneTruePerlPoolManager != null)
        {
            theOneTruePerlPoolManager.flush();
        }
    }

    private String assemblePath(BundleContext context, String envVar, String bundleHeader) throws Exception
    {
        String os = getOS();

        String oldProp = origPaths.get(envVar);
        if (oldProp.trim().length() == 0)
        {
            oldProp = ".";
        }

        StringBuilder value = new StringBuilder(oldProp);

        Bundle[] bundles = context.getBundles();
        for (Bundle bundle : bundles)
        {
            if (bundle.getState() != Bundle.UNINSTALLED)
            {
                Dictionary<?, ?> headers = bundle.getHeaders();
                Object object = headers.get(bundleHeader);
                if (object instanceof String)
                {
                    String path = (String) object;
                    path = (".".equals(path) ? "" : path.replaceAll("\\{os\\}", os));

                    URL entry = bundle.getEntry(path);
                    if (entry == null)
                    {
                        continue;
                    }

                    URLConnection connection = entry.openConnection();
                    if (connection instanceof BundleURLConnection)
                    {
                        URL fileURL = ((BundleURLConnection) connection).getFileURL();
                        String escapedURL = fileURL.toExternalForm().replace(" ", "%20");
                        URI uri = URI.create(escapedURL);
                        path = new File(uri).getAbsolutePath();
                        if (WINDOWS.equals(os))
                        {
                            path = path.replaceAll("\\/", "\\");
                        }
                        value.append(File.pathSeparator).append(path);
                    }
                }
            }
        }

        return value.toString();
    }

    private String getOS()
    {
        String os = System.getProperty("os.name");
        if ("Mac OS X".equals(os))
        {
            os = MACOSX;
        }
        // Normalize any version of Windows into "windows"
        else if (os.contains("indows"))
        {
            os = WINDOWS;
        }
        // Normalize any version of Linux into "linux"
        else if (os.contains("inux"))
        {
            os = LINUX;
        }
        // Normalize any version of Solaris into "solaris"
        else if (os.equalsIgnoreCase("sunos") || os.contains("olari"))
        {
            os = SOLARIS;
        }
        return os;
    }

    /**{@inheritDoc}*/
    public void bundleChanged(BundleEvent event)
    {
        try
        {
            if (event.getType() == BundleEvent.RESOLVED || event.getType() == BundleEvent.UNRESOLVED)
            {
                Bundle bundle = event.getBundle();

                Dictionary<?, ?> headers = bundle.getHeaders();
                Object o1 = headers.get(BUNDLE_HEADER_PERL_INC);
                Object o2 = headers.get(BUNDLE_HEADER_PERL_SYSTEM_PATH);
                if (o1 != null || o2 != null)
                {
                    resetPerlPath();
                }
            }
        }
        catch (Exception ex)
        {
            logger.warn("bundle change event failed to reset Perl path", ex);
        }
    }
}
