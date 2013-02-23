package org.ziptie.server.security;

import java.util.Arrays;
import java.util.Map;

import javax.security.auth.Subject;
import javax.security.auth.callback.Callback;
import javax.security.auth.callback.CallbackHandler;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.LoginException;

import org.mortbay.jetty.plus.jaas.callback.ObjectCallback;
import org.mortbay.jetty.plus.jaas.spi.AbstractLoginModule;
import org.mortbay.jetty.plus.jaas.spi.UserInfo;
import org.mortbay.jetty.security.Credential;
import org.ziptie.server.security.internal.SecurityActivator;

/**
 * ZiptieLoginModule
 */
public class ZiptieLoginModule extends AbstractLoginModule
{
    private static final String ADMIN_ROLE_INTERNAL = "admin"; //$NON-NLS-1$
    private static final String USER_ROLE_INTERNAL = "user"; //$NON-NLS-1$
    private Subject subject;
    private String webUserName;
    private String webCredential;

    /**
     * Constructor
     */
    public ZiptieLoginModule()
    {
    }

    /** {@inheritDoc} */
    @Override
    public UserInfo getUserInfo(String username) throws Exception
    {
        String[] roles = { (ADMIN_ROLE_INTERNAL.equals(username) ? ADMIN_ROLE_INTERNAL : USER_ROLE_INTERNAL) };

        UserInfo userInfo = null;

        // Perform lookup of user to find credential
        ISecurityServiceEx securityService = SecurityActivator.getSecurityService();
        if (securityService.validateAuthenticationToken(webUserName + ':' + webCredential))
        {
            ZPrincipal principal = securityService.getZPrincipal(username);
            if (principal != null)
            {
                userInfo = new UserInfo(username, Credential.getCredential(SecurityElf.calcMD5(webUserName, webCredential)), Arrays.asList(roles));
            }
        }
        else
        {
            ZPrincipal principal = securityService.getZPrincipal(username);
            if (principal != null)
            {
                userInfo = new UserInfo(username, Credential.getCredential(principal.getMD5Password()), Arrays.asList(roles));
            }
        }

        return userInfo;
    }

    /** {@inheritDoc} */
    @SuppressWarnings("unchecked")
    @Override
    public void initialize(Subject sub, CallbackHandler callbackHandler, Map sharedState, Map options)
    {
        this.subject = sub;

        super.initialize(subject, callbackHandler, sharedState, options);
    }

    /** {@inheritDoc} */
    @Override
    @SuppressWarnings("nls")
    public boolean login() throws LoginException
    {
        try
        {
            if (getCallbackHandler() == null)
            {
                throw new LoginException("No callback handler");
            }

            Callback[] callbacks = configureCallbacks();
            getCallbackHandler().handle(callbacks);

            webUserName = ((NameCallback) callbacks[0]).getName();
            webCredential = ((ObjectCallback) callbacks[1]).getObject().toString();

            if (webUserName == null || webCredential == null)
            {
                setAuthenticated(false);
                return isAuthenticated();
            }

            UserInfo userInfo = getUserInfo(webUserName);
            if (userInfo == null)
            {
                setAuthenticated(false);
                return isAuthenticated();
            }

            ZPrincipal principal = SecurityActivator.getSecurityService().getZPrincipal(webUserName);
            setCurrentUser(new JAASUserInfo(userInfo));
            setAuthenticated(getCurrentUser().checkCredential(SecurityElf.calcMD5(webUserName, webCredential)));

            subject.getPrincipals().add(principal);
            return isAuthenticated();
        }
        catch (UnsupportedCallbackException e)
        {
            throw new LoginException(e.toString());
        }
        catch (Exception e)
        {
            throw new LoginException(e.toString());
        }
    }

    /** {@inheritDoc} */
    @Override
    public boolean commit() throws LoginException
    {
        return super.commit();
    }
}
