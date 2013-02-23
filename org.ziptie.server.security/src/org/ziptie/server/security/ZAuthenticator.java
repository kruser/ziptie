package org.ziptie.server.security;

import java.io.IOException;
import java.security.Principal;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.mortbay.jetty.Request;
import org.mortbay.jetty.Response;
import org.mortbay.jetty.security.Authenticator;
import org.mortbay.jetty.security.UserRealm;
import org.ziptie.server.security.internal.SecurityActivator;

import sun.misc.BASE64Decoder;

/**
 * ZAuthenticator
 */
public class ZAuthenticator implements Authenticator
{
    public static final String ZAUTH = "ZAUTH"; //$NON-NLS-1$

    private static final String BASIC_AUTH_HEADER = "Authorization"; //$NON-NLS-1$

    private static final long serialVersionUID = -5001950884112251580L;

    /** {@inheritDoc} */
    public Principal authenticate(UserRealm realm, String pathInContext, Request request, Response response) throws IOException
    {
        if (request.getRequestURI().contains("services"))
        {
            return null;
        }

        Principal principal = null;

        try
        {
            request.setCharacterEncoding("UTF-8"); //$NON-NLS-1$
            String username = request.getParameter("j_username"); //$NON-NLS-1$
            String password = request.getParameter("j_password"); //$NON-NLS-1$

            HttpSession session = request.getSession(false);
            if (session != null && username == null)
            {
                principal = (Principal) session.getAttribute(Principal.class.getName());
            }

            if (request.getHeader(BASIC_AUTH_HEADER) != null)
            {
                String[] userAndToken = handleBasicAuthentication(realm, request, response);
                username = userAndToken[0];
                password = userAndToken[1];
            }

            if (principal == null)
            {
                principal = realm.authenticate(username, password, request);
                if (principal == null)
                {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
                    if (session != null)
                    {
                        session.invalidate();
                    }
                    Logger.getLogger(ZAuthenticator.class).debug(String.format("Login failed for '%s' and '%s'", username, password)); //$NON-NLS-1$
                    return null;
                }

                if (session == null)
                {
                    session = request.getSession(true);
                    SecurityActivator.getSecurityService().associateSession(session);
                }

                session.setAttribute(Principal.class.getName(), principal);
            }
        }
        finally
        {
            if (principal != null)
            {
                request.setUserPrincipal(principal);
            }
        }

        return principal;
    }

    @SuppressWarnings("nls")
    private String[] handleBasicAuthentication(UserRealm realm, Request request, Response response) throws IOException
    {
        String header = request.getHeader(BASIC_AUTH_HEADER).replace("Basic ", "");
        BASE64Decoder decoder = new BASE64Decoder();
        header = new String(decoder.decodeBuffer(header));

        return header.split(":");
    }

    /** {@inheritDoc} */
    public String getAuthMethod()
    {
        return ZAUTH;
    }
}
