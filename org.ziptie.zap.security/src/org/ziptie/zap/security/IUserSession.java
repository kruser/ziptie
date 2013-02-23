package org.ziptie.zap.security;

import java.io.Serializable;
import java.security.Principal;
import java.util.Locale;
import java.util.Map;

/**
 * IUserSession
 */
public interface IUserSession extends Map<String, Serializable>
{
    /**
     * Get the Principal associated with this session.
     *
     * @return the Principal associated with this session
     */
    Principal getPrincipal();

    /**
     * Set the Principal for this session.
     *
     * @param principal the principal
     */
    void setPrincipal(Principal principal);

    /**
     * Get the locale that the user is running in (as of the last
     * server request).
     *
     * @return the Locale for the user who owns this session
     */
    Locale getLocale();

    /**
     * @param permissionName the name of a system permission, i.e., one returned by
     * PermissionTracker.getAvailablePermissions()
     * 
     * @return true if the user involved with this session has the indicated permission
     */
    boolean checkHasPermission(String permissionName);

    /**
     * Invalidate this user's session.
     */
    void invalidate();
}
