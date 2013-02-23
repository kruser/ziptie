/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2008
 */

package org.ziptie.zap.security.internal;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

/**
 * Security Activator that manages the SecurityPermissions extension point
 */
public class SecurityActivator implements BundleActivator
{
    private static Logger logger = Logger.getLogger(SecurityActivator.class);
    private static final String EXTENSION_POINT_ID = "SecurityPermissions"; //$NON-NLS-1$
    private static final String EXTENSION_NAMESPACE = "org.ziptie.zap.security"; //$NON-NLS-1$
    private static SecurityActivator theOneTrueActivator;
    private List<String> globalPermissions;

    /** {@inheritDoc} */
    public void start(BundleContext arg0) throws Exception
    {
        theOneTrueActivator = this;
        loadPermissions();
    }

    /** {@inheritDoc} */
    public void stop(BundleContext arg0) throws Exception
    {
        globalPermissions = null;
        theOneTrueActivator = null;
    }

    /**
     * @return the tracked list of global permissions
     */
    public static List<String> getGlobalPermissions()
    {
        return theOneTrueActivator.globalPermissions;
    }

    @SuppressWarnings("nls")
    private void loadPermissions()
    {
        IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();

        globalPermissions = new ArrayList<String>();

        IConfigurationElement[] configElements = extensionRegistry.getConfigurationElementsFor(EXTENSION_NAMESPACE
                + '.' + EXTENSION_POINT_ID);
        for (IConfigurationElement permissionElement : configElements)
        {
            String permId = permissionElement.getAttribute("id");
            String displayString = permissionElement.getAttribute("display");
            logger.trace(String.format("Perm: %s", permId));
            globalPermissions.add(String.format("%s=%s", permId, displayString));
        }
    }
}
