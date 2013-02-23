package org.ziptie.zap.metro;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

/**
 * ZThreadContextFilter
 */
public class ZThreadContextFilter implements Filter
{
    /** {@inheritDoc} */
    public void init(FilterConfig filterConfig) throws ServletException
    {
    }

    /** {@inheritDoc} */
    public void destroy()
    {
    }

    /** {@inheritDoc} */
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException
    {
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        try
        {
            Thread.currentThread().setContextClassLoader(this.getClass().getClassLoader());
            chain.doFilter(req, resp);
        }
        finally
        {
            Thread.currentThread().setContextClassLoader(cl);
        }
    }
}
