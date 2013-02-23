package org.ziptie.zap.web.internal;

import java.util.Arrays;

import javax.security.auth.callback.Callback;
import javax.security.auth.callback.NameCallback;
import javax.security.auth.callback.UnsupportedCallbackException;
import javax.security.auth.login.LoginException;

import org.mortbay.jetty.plus.jaas.callback.ObjectCallback;
import org.mortbay.jetty.plus.jaas.spi.AbstractLoginModule;
import org.mortbay.jetty.plus.jaas.spi.UserInfo;
import org.mortbay.jetty.security.Credential;

/**
 * NoopLoginModule
 */
public class NoopLoginModule extends AbstractLoginModule
{
    private Object webCredential;

    /**
     * Constructor
     */
    public NoopLoginModule()
    {
    }

    /** {@inheritDoc} */
    @Override
    public UserInfo getUserInfo(String username) throws Exception
    {
        String[] roles = { "nobody" }; //$NON-NLS-1$
        UserInfo userInfo = new UserInfo(username, Credential.getCredential(webCredential.toString()), Arrays.asList(roles));

        return userInfo;
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

            setAuthenticated(true);

            Callback[] callbacks = configureCallbacks();
            getCallbackHandler().handle(callbacks);

            String webUserName = ((NameCallback) callbacks[0]).getName();
            webCredential = ((ObjectCallback) callbacks[1]).getObject();

            if ((webUserName == null) || (webCredential == null))
            {
                setAuthenticated(false);
                return isAuthenticated();
            }

            UserInfo userInfo = getUserInfo(webUserName);

            setCurrentUser(new JAASUserInfo(userInfo));
            setAuthenticated(getCurrentUser().checkCredential(webCredential));
            return isAuthenticated();
        }
        catch (UnsupportedCallbackException e)
        {
            throw new LoginException(e.toString());
        }
        catch (Exception e)
        {
            e.printStackTrace();
            throw new LoginException(e.toString());
        }
    }
}
