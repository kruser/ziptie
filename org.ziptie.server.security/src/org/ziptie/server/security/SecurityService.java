package org.ziptie.server.security;

import java.rmi.dgc.VMID;
import java.security.Principal;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.apache.log4j.Logger;
import org.hibernate.classic.Session;
import org.ziptie.server.security.internal.SecurityActivator;
import org.ziptie.zap.jta.TransactionElf;
import org.ziptie.zap.security.IUserSession;
import org.ziptie.zap.security.IUserSessionListener;
import org.ziptie.zap.security.PermissionTracker;
import org.ziptie.zap.web.IWebService;

/**
 * SecurityService
 */
public class SecurityService implements ISecurityServiceEx
{
    private static final Logger LOGGER = Logger.getLogger(SecurityService.class);

    /** Special permission only possessed by 'admin' users.  Expands into all
     * available permissions.
     */
    private static final String ORG_ZIPTIE_ACCESS_ALL = "org.ziptie.access.all"; //$NON-NLS-1$

    /** This is the maximum duration that a one time use authentication token can be valid. */
    private static final int TOKEN_SUNSET_MILLIS = 1800000; // 30 minutes

    private static final ThreadLocal<IUserSession> SESSION_MAP;

    private Map<String, ZPrincipal> principalMap;
    private Lock lock;

    private Set<IUserSessionListener> sessionListeners;
    private SessionListener sessionListener;

    /** The set of one time use passwords associated with their expiration time */
    private Map<String, Long> oneTimeUseTokens;

    static
    {
        SESSION_MAP = new ThreadLocal<IUserSession>();
    }

    /**
     * Default constructor.
     *
     * @throws Exception thrown if there is an error during construction.
     */
    public SecurityService() throws Exception
    {
        sessionListeners = new HashSet<IUserSessionListener>();

        oneTimeUseTokens = new HashMap<String, Long>();
        lock = new ReentrantLock();

        sessionListener = new SessionListener();

        principalMap = new ConcurrentHashMap<String, ZPrincipal>();
    }

    /** {@inheritDoc} */
    public ZPrincipal getZPrincipal(String username)
    {
        synchronized (principalMap)
        {
            if (principalMap.containsKey(username))
            {
                return principalMap.get(username);
            }

            ZPrincipal principal = null;
            boolean owner = TransactionElf.beginOrJoinTransaction();
            try
            {
                Session session = SecurityActivator.getSessionFactory().getCurrentSession();
                principal = (ZPrincipal) session.get(ZPrincipal.class, username);
                if (principal != null)
                {
                    // Expand ORG_ZIPTIE_ACCESS_ALL permission into all available permissions.
                    if (principal.getRole().hasPermission(ORG_ZIPTIE_ACCESS_ALL))
                    {
                        session.setReadOnly(principal.getRole(), true);
                        Set<String> permissions = new HashSet<String>();
                        for (String perm : getAvailablePermissions())
                        {
                            String[] split = perm.split("="); //$NON-NLS-1$
                            permissions.add(split[0]);
                        }
                        principal.getRole().setPermissionSet(permissions);
                    }
                    principalMap.put(username, principal);
                }
            }
            finally
            {
                if (owner)
                {
                    TransactionElf.commit();
                }
            }

            return principal;
        }
    }

    /** {@inheritDoc} */
    public IUserSession getUserSession()
    {
        return SESSION_MAP.get();
    }

    /** {@inheritDoc} */
    public String createAuthenticationToken(String user)
    {
        String username;

        IUserSession session = getUserSession();
        if (session == null)
        {
            if (user == null)
            {
                throw new IllegalStateException("Must specify a user when there is no current session."); //$NON-NLS-1$
            }

            username = user;
        }
        else
        {
            if (user != null)
            {
                throw new IllegalStateException("Cannot specify a user when there is a current session."); //$NON-NLS-1$
            }

            username = session.getPrincipal().getName();
        }

        String password = new VMID().toString();

        long now = System.currentTimeMillis();
        long sunset = now + TOKEN_SUNSET_MILLIS;

        String token = username + ':' + SecurityElf.calcMD5(username, password);

        lock.lock();
        try
        {
            // remove expired tokens
            Iterator<Long> iter = oneTimeUseTokens.values().iterator();
            while (iter.hasNext())
            {
                Long elem = iter.next();
                if (elem < now)
                {
                    iter.remove();
                }
            }

            // add our token.
            oneTimeUseTokens.put(token, sunset);
        }
        finally
        {
            lock.unlock();
        }

        return token;
    }

    /** {@inheritDoc} */
    public boolean validateAuthenticationToken(String token)
    {
        Long sunset = oneTimeUseTokens.get(token);
        if (sunset != null && System.currentTimeMillis() < sunset)
        {
            return true;
        }

        return false;
    }

    /** {@inheritDoc} */
    public IUserSession associateSession(HttpSession session)
    {
        ZUserSession zsession = new ZUserSession(session);
        SESSION_MAP.set(zsession);

        return zsession;
    }

    /** {@inheritDoc} */
    public void disassociateSession()
    {
        SESSION_MAP.remove();
    }

    /** {@inheritDoc} */
    public void registerUserSessionListener(IUserSessionListener listener)
    {
        if (sessionListeners.size() == 0)
        {
            IWebService webService = SecurityActivator.getWebService();
            webService.registerSessionListener(sessionListener);
        }

        sessionListeners.add(listener);
    }

    /** {@inheritDoc} */
    public void unregisterUserSessionListener(IUserSessionListener listener)
    {
        sessionListeners.remove(listener);

        if (sessionListeners.size() == 0)
        {
            IWebService webService = SecurityActivator.getWebService();
            webService.unregisterSessionListener(sessionListener);
        }
    }

    /** {@inheritDoc} */
    public List<String> getAvailablePermissions()
    {
        return PermissionTracker.getAvailablePermissions();
    }

    /**
     * SessionListener
     */
    private class SessionListener implements HttpSessionListener
    {
        /** {@inheritDoc} */
        public void sessionCreated(HttpSessionEvent sessionEvent)
        {
            if (LOGGER.isTraceEnabled())
            {
                LOGGER.trace(String.format("Session created %s", sessionEvent.getSession().getId())); //$NON-NLS-1$
            }

            HttpSession httpSession = sessionEvent.getSession();
            ZUserSession userSession = new ZUserSession(httpSession);

            for (IUserSessionListener listener : sessionListeners)
            {
                try
                {
                    listener.sessionCreated(userSession);
                }
                catch (Exception e)
                {
                    continue;
                }
            }
        }

        /** {@inheritDoc} */
        public void sessionDestroyed(HttpSessionEvent sessionEvent)
        {
            if (LOGGER.isTraceEnabled())
            {
                LOGGER.trace(String.format("Session destroyed %s", sessionEvent.getSession().getId())); //$NON-NLS-1$
            }

            HttpSession httpSession = sessionEvent.getSession();
            ZUserSession userSession = new ZUserSession(httpSession);

            for (IUserSessionListener listener : sessionListeners)
            {
                try
                {
                    listener.sessionDestroyed(userSession);
                }
                catch (Exception e)
                {
                    continue;
                }
            }

            // Remove the user from the principal map.  Even if the user is logged in
            // from two browsers, this is okay -- they will be reloaded.
            synchronized (principalMap)
            {
                Principal principal = userSession.getPrincipal();
                if (principal != null)
                {
                    principalMap.remove(principal);
                }
                else
                {
                    LOGGER.warn("Session was destroyed which contained no user.  Improper login sequence."); //$NON-NLS-1$
                }
            }
        }
    }
}
