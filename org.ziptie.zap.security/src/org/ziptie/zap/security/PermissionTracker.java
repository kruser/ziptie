/* Alterpoint, Inc.
 *
 * The contents of this source code are proprietary and confidential
 * All code, patterns, and comments are Copyright Alterpoint, Inc. 2003-2008
 */

package org.ziptie.zap.security;

import java.util.List;

import org.ziptie.zap.security.internal.SecurityActivator;

/**
 * Track the SecurityPermission extension point for all currently registered permissions.
 */
public final class PermissionTracker
{
    private PermissionTracker()
    {
    }

    /**
     * @return the list of permissions as registered through the SecurityPermission extension point
     */
    public static List<String> getAvailablePermissions()
    {
        return SecurityActivator.getGlobalPermissions();
    }
}

