package org.ziptie.nio.common;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.ziptie.nio.nioagent.WrapperException;


public class FileIn
{
    // -- member fields
    private final InputStream in;
    private final ILogger logger;
    private boolean isOpen;

    // -- constructors
    public FileIn(final File file, final ILogger logger)
    {
        this.in = createBufferedInputStream(file);
        this.logger = logger;
        this.isOpen = true;
    }

    public FileIn(final String dir, final String filename, final ILogger logger)
    {
        this(new File(dir + File.separatorChar + filename), logger);
    }

    // -- public methods
    public String readFile()
    {
        return new String(readAll());
    }

    public byte[] readAll()
    {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        int len = 1024;
        byte[] b = new byte[len];
        int nread;
        while (0 < (nread = read(b, 0, len)))
        {
            out.write(b, 0, nread);
        }
        byte[] buf = out.toByteArray();
        close(out);
        return buf;
    }

    public int read(byte[] b, int off, int maxLen)
    {
        final int numBytes;
        if (isOpen)
        {
            int len = Math.min(maxLen, available());
            numBytes = 0 < len ? readIn(b, off, len) : 0;
            if (1 > numBytes)
            {
                close();
            }
        }
        else
        {
            numBytes = 0;
        }
        return numBytes;
    }

    public void close()
    {
        if (isOpen)
        {
            closeIn();
        }
    }

    // -- private methods
    private InputStream createBufferedInputStream(File file)
    {
        return new BufferedInputStream(createFileInputStream(file));
    }

    private InputStream createFileInputStream(File file)
    {
        try
        {
            return new FileInputStream(file);
        }
        catch (FileNotFoundException e)
        {
            logger.error("Failed to create file input stream for " + file.getAbsolutePath() + ". ", e);
            throw new WrapperException(e);
        }
    }

    private int available()
    {
        try
        {
            return in.available();
        }
        catch (IOException e)
        {
            logger.error("Unable to check number of available bytes. ", e);
            close();
            throw new WrapperException(e);
        }
    }

    private int readIn(byte[] b, int off, int len)
    {
        try
        {
            return in.read(b, off, len);
        }
        catch (IOException e)
        {
            logger.error("Failed to read from file. ", e);
            close();
            throw new WrapperException(e);
        }
    }

    private boolean ready(BufferedReader reader)
    {
        try
        {
            return reader.ready();
        }
        catch (IOException e)
        {
            logger.error("Failed to read from file. ", e);
            close();
            throw new WrapperException(e);
        }
    }

    private String readLine(BufferedReader reader)
    {
        try
        {
            return reader.readLine();
        }
        catch (IOException e)
        {
            logger.error("Failed to read from file. ", e);
            close();
            throw new WrapperException(e);
        }
    }

    private void close(OutputStream out)
    {
        try
        {
            out.close();
        }
        catch (IOException e)
        {
            logger.error("Failed to read from file. ", e);
            close();
            throw new WrapperException(e);
        }
    }

    private void closeIn()
    {
        try
        {
            in.close();
        }
        catch (IOException e)
        {
            logger.error("Failed to close input stream. ", e);
            throw new WrapperException(e);
        }
        finally
        {
            isOpen = false;
        }
    }

}
