package org.ziptie.net.ftp;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLConnection;

/**
 * Client is an ftp client.
 */
public final class Client
{

    private Client()
    {
        // hide constructor
    }

    /**
     * @param args arguments
     */
    public static void main(String[] args)
    {
        if (2 == args.length)
        {
            copy(args[0], args[1]);
        }
        else
        {
            System.err.println("Useage: java org.ziptie.net.ftp.Client source-url destination-url");
        }

    }

    static void copy(String src, String dst)
    {
        InputStream in = null;
        OutputStream out = null;
        try
        {
            in = getInputStream(toURI(src));
            out = getOutputStream(toURI(dst));
            transfer(in, out);
        }
        catch (RuntimeException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new RuntimeException(e);
        }
        finally
        {
            if (in != null)
            {
                try
                {
                    in.close();
                }
                catch (IOException e)
                {
                    throw new RuntimeException(e);
                }
                finally
                {
                    if (out != null)
                    {
                        try
                        {
                            out.close();
                        }
                        catch (IOException e)
                        {
                            throw new RuntimeException(e);
                        }
                    }
                }
            }
        }
    }

    private static InputStream getInputStream(URI uri) throws IOException
    {
        return openConnection(uri).getInputStream();
    }

    private static OutputStream getOutputStream(URLConnection urlCon) throws IOException
    {
        urlCon.setDoOutput(true);
        return urlCon.getOutputStream();
    }

    private static URLConnection openConnection(URI uri) throws IOException
    {
        return uri.toURL().openConnection();
    }

    private static URI toURI(String target) throws URISyntaxException
    {
        return target.contains("://") ? new URI(target) : new File(target).toURI();
    }

    private static OutputStream getOutputStream(URI uri) throws IOException
    {
        final OutputStream out;
        if ("file".equals(uri.getScheme()))
        {
            out = new FileOutputStream(new File(uri));
        }
        else
        {
            out = getOutputStream(openConnection(uri));
        }
        return out;
    }

    private static void transfer(InputStream in, OutputStream out) throws IOException
    {
        while (0 < in.available())
        {
            out.write(in.read());
        }
    }
}
