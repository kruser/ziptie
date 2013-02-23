package org.ziptie.zap.security;

/**
 * IUserSessionListener
 */
public interface IUserSessionListener
{
    /**
     * Called when a user's session is created.
     *
     * @param session the IUserSession
     */
    void sessionCreated(IUserSession session);

    /**
     * Called when a user's session is destroyed through some action such
     * as logout or session expiration.
     *
     * @param session the IUserSession that is being destroyed
     */
    void sessionDestroyed(IUserSession session);
}
