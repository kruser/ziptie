package org.ziptie.zap.web.internal;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.mortbay.jetty.HandlerContainer;
import org.mortbay.jetty.handler.ErrorHandler;
import org.mortbay.jetty.security.SecurityHandler;
import org.mortbay.jetty.servlet.Context;
import org.mortbay.jetty.servlet.ServletHandler;
import org.mortbay.jetty.servlet.SessionHandler;
import org.mortbay.resource.Resource;
import org.osgi.framework.Bundle;
import org.ziptie.zap.security.ISecurityService;

/**
 * ZContext
 */
public class ZContext extends Context
{
    private Bundle bundle;

    /**
     * Constructor
     */
    public ZContext()
    {
    }

    /**
     * Constructor.
     *
     * @param options options
     */
    public ZContext(int options)
    {
        super(options);
    }

    /**
     * Constructor.
     *
     * @param parent parent container
     * @param contextPath context path
     */
    public ZContext(HandlerContainer parent, String contextPath)
    {
        super(parent, contextPath);
    }

    /**
     * Constructor.
     *
     * @param parent parent container
     * @param contextPath context path
     * @param options options
     */
    public ZContext(HandlerContainer parent, String contextPath, int options)
    {
        super(parent, contextPath, options);
    }

    /**
     * Constructor.
     *
     * @param parent parent container
     * @param contextPath context path
     * @param sessions support sessions
     * @param security use a security handler
     */
    public ZContext(HandlerContainer parent, String contextPath, boolean sessions, boolean security)
    {
        super(parent, contextPath, sessions, security);
    }

    /**
     * Constructor.
     *
     * @param parent parent container
     * @param sessionHandler session handler
     * @param securityHandler security handler
     * @param servletHandler servlet handler
     * @param errorHandler error handler
     */
    public ZContext(HandlerContainer parent, SessionHandler sessionHandler, SecurityHandler securityHandler, ServletHandler servletHandler,
            ErrorHandler errorHandler)
    {
        super(parent, sessionHandler, securityHandler, servletHandler, errorHandler);
    }

    /**
     * Constructor.
     *
     * @param parent parent container
     * @param contextPath context path
     * @param sessionHandler session handler
     * @param securityHandler security handler
     * @param servletHandler servlet handler
     * @param errorHandler error handler
     */
    public ZContext(HandlerContainer parent, String contextPath, SessionHandler sessionHandler, SecurityHandler securityHandler, ServletHandler servletHandler,
            ErrorHandler errorHandler)
    {
        super(parent, contextPath, sessionHandler, securityHandler, servletHandler, errorHandler);
    }

    /** {@inheritDoc} */
    @Override
    public void handle(String target, HttpServletRequest request, HttpServletResponse response, int dispatch) throws IOException, ServletException
    {
        ClassLoader oldCL = Thread.currentThread().getContextClassLoader();
        try
        {
            Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader());

            ISecurityService securityService = WebActivator.getSecurityService();
            if (securityService != null)
            {
                try
                {
                    HttpSession session = request.getSession(false);
                    if (session != null)
                    {
                        securityService.associateSession(session);
                    }

                    super.handle(target, request, response, dispatch);
                }
                finally
                {
                    securityService.disassociateSession();
                }
            }
            else
            {
                super.handle(target, request, response, dispatch);
            }
        }
        finally
        {
            Thread.currentThread().setContextClassLoader(oldCL);
        }
    }

    /** {@inheritDoc} */
    @Override
    public Resource getResource(String resource) throws MalformedURLException
    {
        URL url = bundle.getResource(resource);
        if (url != null)
        {
            try
            {
                return Resource.newResource(url);
            }
            catch (IOException e)
            {
                return null;
            }
        }

        return null;
    }

    protected void setBundle(Bundle bundle)
    {
        this.bundle = bundle;
    }
}
