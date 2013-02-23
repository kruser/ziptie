package org.ziptie.zap.metro;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Locale;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

@SuppressWarnings("deprecation")
public class Always200Response implements HttpServletResponse
{
    private HttpServletResponse delegate;

    public Always200Response(HttpServletResponse delegate)
    {
        this.delegate = delegate;
    }

    public void addCookie(Cookie arg0)
    {
        delegate.addCookie(arg0);
    }

    public void addDateHeader(String arg0, long arg1)
    {
        delegate.addDateHeader(arg0, arg1);
    }

    public void addHeader(String arg0, String arg1)
    {
        delegate.addHeader(arg0, arg1);
    }

    public void addIntHeader(String arg0, int arg1)
    {
        delegate.addIntHeader(arg0, arg1);
    }

    public boolean containsHeader(String arg0)
    {
        return delegate.containsHeader(arg0);
    }

    public String encodeRedirectURL(String arg0)
    {
        return delegate.encodeRedirectURL(arg0);
    }

    public String encodeRedirectUrl(String arg0)
    {
        return delegate.encodeRedirectUrl(arg0);
    }

    public String encodeURL(String arg0)
    {
        return delegate.encodeURL(arg0);
    }

    public String encodeUrl(String arg0)
    {
        return delegate.encodeUrl(arg0);
    }

    public void sendError(int arg0) throws IOException
    {
        delegate.sendError(arg0);
    }

    public void sendError(int arg0, String arg1) throws IOException
    {
        delegate.sendError(arg0, arg1);
    }

    public void sendRedirect(String arg0) throws IOException
    {
        delegate.sendRedirect(arg0);
    }

    public void setDateHeader(String arg0, long arg1)
    {
        delegate.setDateHeader(arg0, arg1);
    }

    public void setHeader(String arg0, String arg1)
    {
        delegate.setHeader(arg0, arg1);
    }

    public void setIntHeader(String arg0, int arg1)
    {
        delegate.setIntHeader(arg0, arg1);
    }

    public void setStatus(int arg0)
    {
    }

    public void setStatus(int arg0, String arg1)
    {
        delegate.setStatus(200, arg1);
    }

    public void flushBuffer() throws IOException
    {
        delegate.flushBuffer();
    }

    public int getBufferSize()
    {
        return delegate.getBufferSize();
    }

    public String getCharacterEncoding()
    {
        return delegate.getCharacterEncoding();
    }

    public String getContentType()
    {
        return delegate.getContentType();
    }

    public Locale getLocale()
    {
        return delegate.getLocale();
    }

    public ServletOutputStream getOutputStream() throws IOException
    {
        return delegate.getOutputStream();
    }

    public PrintWriter getWriter() throws IOException
    {
        return delegate.getWriter();
    }

    public boolean isCommitted()
    {
        return delegate.isCommitted();
    }

    public void reset()
    {
        delegate.reset();
    }

    public void resetBuffer()
    {
        delegate.resetBuffer();
    }

    public void setBufferSize(int arg0)
    {
        delegate.setBufferSize(arg0);
    }

    public void setCharacterEncoding(String arg0)
    {
        delegate.setCharacterEncoding(arg0);
    }

    public void setContentLength(int arg0)
    {
        delegate.setContentLength(arg0);
    }

    public void setContentType(String arg0)
    {
        delegate.setContentType(arg0);
    }

    public void setLocale(Locale arg0)
    {
        delegate.setLocale(arg0);
    }
}
