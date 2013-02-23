package org.ziptie.zap.security;

import java.util.List;

import javax.servlet.http.HttpSession;


/**
 * ISecurityService
 */
public interface ISecurityService
{
    /**
     * Associate the user and HttpSession with the current thread.
     *
     * @param session the principal's HttpSession
     * @return the user session
     */
    IUserSession associateSession(HttpSession session);

    /**
     * Disassociate the user from the current thread.
     */
    void disassociateSession();

    /**
     * Get the thread-local session for the user executing on the current
     * thread.
     *
     * @return the IUserSession object
     */
    IUserSession getUserSession();

    /**
     * Register a session listener.
     *
     * @param listener the session listener
     */
    void registerUserSessionListener(IUserSessionListener listener);

    /**
     * Unregister a session listener.
     *
     * @param listener the session listener
     */
    void unregisterUserSessionListener(IUserSessionListener listener);

    /**
     * @return the list of global permission names
     */
    List<String> getAvailablePermissions();
}
