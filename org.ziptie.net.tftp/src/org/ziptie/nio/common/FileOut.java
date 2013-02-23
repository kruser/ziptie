package org.ziptie.nio.common;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

import org.ziptie.nio.nioagent.WrapperException;


public class FileOut
{
    // -- member fields
    private final OutputStream out;
    private final Writer writer;
    private final ILogger logger;

    // -- constructors
    public FileOut(File file, final ILogger logger)
    {
        this.out = createFileOutputStream(file);
        this.writer = new OutputStreamWriter(out);
        this.logger = logger;
    }

    public FileOut(final String dir, final String filename, final ILogger logger)
    {
        this(new File(dir + File.separatorChar + filename), logger);
    }

    // -- public methods
    public void append(String s)
    {
        try
        {
            writer.write(s);
            writer.flush();
        }
        catch (IOException e)
        {
            close();
            logger.error("Failed to write to output stream. ", e);
            throw new WrapperException(e);
        }
    }

    public void write(byte[] b, int off, int len)
    {
        try
        {
            out.write(b, off, len);
            out.flush();
        }
        catch (IOException e)
        {
            close();
            logger.error("Failed to write to output stream. ", e);
            throw new WrapperException(e);
        }
    }

    public void close()
    {
        try
        {
            writer.close();
        }
        catch (IOException e)
        {
            logger.error("Failed to close output stream. ", e);
            throw new WrapperException(e);
        }
    }

    // -- private methods
    private OutputStream createFileOutputStream(File file)
    {
        try
        {
            return new FileOutputStream(file);
        }
        catch (FileNotFoundException e)
        {
            logger.error("Failed to create output stream for " + file.getPath() + ". ", e);
            throw new WrapperException(e);
        }
    }
}
