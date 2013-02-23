package org.ziptie.server.security;

import java.util.List;

import org.ziptie.zap.security.ISecurityService;

/**
 * ISecurityServiceEx
 */
public interface ISecurityServiceEx extends ISecurityService
{
    /**
     * Creates a one time use authentication token that can be used in lieu of a username and password.
     * The token will become invalid after a reasonably short period. (like 30 minutes)
     * @param user The user to create the authentication token for or <code>null</code> to use the current user.
     *             This must be <code>null</code> if there is a current user session on the thread as a user can
     *             not get a token for another user.  Only the system may get arbitrary users' tokens.
     * @return The token in the form of "&lt;user&gt;@&lt;temp-password&gt;"
     */
    String createAuthenticationToken(String user);

    /**
     * Validates whether the specified one time use authentication token is still valid.
     *
     * @param token the one time use token to validate
     * @return true if valid, false otherwise
     */
    boolean validateAuthenticationToken(String token);

    /**
     * Get/create the ZPrincipal object for the supplied username.  Null is
     * returned if the user does not exist.
     *
     * @param username the name of the user
     * @return the ZPrincipal object for the user
     */
    ZPrincipal getZPrincipal(String username);

    /**
     * Get all permissions defined for the system.
     *
     * @return a list of permissions defined for the system
     */
    List<String> getAvailablePermissions();
}
