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
 */

package org.ziptie.zap.bootstrap.internal;

import java.io.File;
import java.net.URI;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Calendar;
import java.util.TimeZone;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.eclipse.osgi.framework.console.CommandProvider;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;
import org.ziptie.crates.Crate;
import org.ziptie.crates.CrateException;
import org.ziptie.crates.CrateStarterElf;
import org.ziptie.crates.InstallLocation;

/**
 * OSGi bundle activator for the bootstrap bundle.
 */
public class Activator implements BundleActivator
{
    private static final String LIBRARY_PATH = "java.library.path"; //$NON-NLS-1$
    private static final String ADD_LIB_PATH = "ziptie.library.path.add"; //$NON-NLS-1$

    private static final int FORMAT_LEN = 13;
    private static final double ONE_THOUSAND_MILLIS = 1000.0;
    private static final String DIVIDER = Messages.Activator_divider;

    private static Logger LOGGER;
    private ServiceRegistration registration;

    /** {@inheritDoc} */
    public void start(final BundleContext context) throws Exception
    {
        TimeZone timeZone = TimeZone.getTimeZone(System.getProperty("org.ziptie.zap.timezone", "GMT+0")); //$NON-NLS-1$ //$NON-NLS-2$
        TimeZone.setDefault(timeZone);

        long start = System.currentTimeMillis();
        LOGGER = Logger.getLogger(Activator.class);

        checkExpiry();

        LOGGER.info(DIVIDER);
        LOGGER.info(Messages.Activator_serverStarting);
        LOGGER.info(DIVIDER);

        registration = context.registerService(CommandProvider.class.getName(), new DebugCommandProvider(), null);

        clearTmpDir();

        initSSL();
        setupLibraryPath();

        String arch = context.getProperty("osgi.arch"); //$NON-NLS-1$
        String os = context.getProperty("osgi.os"); //$NON-NLS-1$

        final InstallLocation install = new InstallLocation(new File("."), new File("crates"), os, null, arch); //$NON-NLS-1$//$NON-NLS-2$

        int errorCount;
        try
        {
            context.registerService(InstallLocation.class.getName(), install, null);
            errorCount = CrateStarterElf.activateBundles(context, install);
        }
        catch (CrateException e)
        {
            LOGGER.error("Unable to activate bundles.", e); //$NON-NLS-1$
            throw e;
        }

        Runtime.getRuntime().addShutdownHook(new Thread()
        {
            public void run()
            {
                try
                {
                    CrateStarterElf.stopBundles(context, install.getAllCrates().toArray(new Crate[0]));
                }
                catch (CrateException e)
                {
                    LOGGER.warn("Error stopping and uninstalling crates at shutdown.", e); //$NON-NLS-1$
                }
            }
        });

        Level level = (errorCount == 0 ? Level.INFO : Level.WARN);
        LOGGER.log(level, DIVIDER);
        double elapsedMillis = System.currentTimeMillis() - start;
        String elapsedSecs = String.format("%.1f Seconds      ", (elapsedMillis / ONE_THOUSAND_MILLIS)).substring(0, FORMAT_LEN); //$NON-NLS-1$
        LOGGER.log(level, Messages.bind(Messages.Activator_startupComplete, elapsedSecs));
        if (errorCount > 0)
        {
            String errors = String.format("%3d", errorCount); //$NON-NLS-1$
            LOGGER.log(level, Messages.bind(Messages.Activator_startupComplete_errorCount, errors));
        }
        LOGGER.log(level, DIVIDER);
    }

    /**
     * Delete all of the immediate children of java.io.tmpdir
     */
    private void clearTmpDir()
    {
        String tmpDir = System.getProperty("java.io.tmpdir"); //$NON-NLS-1$
        if (tmpDir != null)
        {
            File file = new File(tmpDir);
            File[] listFiles = file.listFiles();
            if (listFiles != null)
            {
                for (File tmp : listFiles)
                {
                    tmp.delete();
                }
            }
        }
    }

    /** {@inheritDoc} */
    public void stop(BundleContext context) throws Exception
    {
        registration.unregister();
        LOGGER = null;
    }

    private void setupLibraryPath()
    {
        String add = System.getProperty(ADD_LIB_PATH);
        if (add != null)
        {
            String path = System.getProperty(LIBRARY_PATH);
            if (path == null)
            {
                System.setProperty(LIBRARY_PATH, add);
            }
            else
            {
                System.setProperty(LIBRARY_PATH, add + File.pathSeparator + path);
            }
        }
    }

    private void initSSL()
    {
        TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager()
        {
            public void checkClientTrusted(X509Certificate[] arg0, String arg1) throws CertificateException
            {
            }

            public void checkServerTrusted(X509Certificate[] arg0, String arg1) throws CertificateException
            {
            }

            public X509Certificate[] getAcceptedIssuers()
            {
                return null;
            }
        }, };

        try
        {
            SSLContext sc = SSLContext.getInstance("SSL"); //$NON-NLS-1$
            sc.init(null, trustAllCerts, new java.security.SecureRandom());
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
            HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier()
            {
                public boolean verify(String arg0, SSLSession arg1)
                {
                    return true;
                }
            });
        }
        catch (Exception e)
        {
            LOGGER.error(Messages.Activator_unableToInitSslTrustManager, e);
        }
    }

    /**
     * This code was added for partners and equipment manufacturers who which to enforce an
     * expiration semantic on their re-packaged version of ZipTie.  This code is never used
     * by the "official" ZipTie open source release because we run without restriction.  It
     * provides a very "thin" expiration semantic which is controlled by a system property
     * ("expiry") that defines the number of days before expiration occurs, and a file
     * named "zef.dat" (ZipTie expiration file) which resides in the OSGi configuration area
     * and whose time-stamp is consulted as the "install date".  This means that a re-install
     * of the application will reset the expiration clock, hence our characterization as "thin".
     *
     * If the "expiry" file is deleted from the OSGi configuration area, the expire will
     * no longer occur.  And obviously, if the "expiry" system property is not defined the
     * expiration check does not occur.
     *
     * @throws Exception thrown if the expiration is reached.
     */
    private void checkExpiry() throws Exception
    {
        // Do not remove.  This code is unused by ZipTie in it's default configuration, but is used by integration partners.
        String configArea = System.getProperty("osgi.configuration.area").replace(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        Integer expiry = Integer.getInteger("expiry"); //$NON-NLS-1$
        if (expiry != null && configArea != null)
        {
            // When checking for "expiration" use the time-stamp of the "crates" directory
            File testFile = new File(new File(URI.create(configArea)), "zef.dat"); //$NON-NLS-1$
            Calendar now = Calendar.getInstance();
            Calendar then = Calendar.getInstance();
            if (testFile.isFile())
            {
                then.setTimeInMillis(testFile.lastModified());
            }

            now.add(Calendar.DATE, -(expiry.intValue()));
            if (now.after(then))
            {
                String message = String.format("Expiration time of %d days exceeded.", expiry); //$NON-NLS-1$
                LOGGER.fatal(message);
                throw new Exception(message);
            }
        }
    }
}
