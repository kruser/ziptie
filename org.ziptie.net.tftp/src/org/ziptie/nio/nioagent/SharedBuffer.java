package org.ziptie.nio.nioagent;

import java.nio.ByteBuffer;

import org.ziptie.nio.common.ILogger;

public class SharedBuffer
{

    // -- fields
    private static SharedBuffer in = null;
    private static SharedBuffer out = null;
    ByteBuffer buf;

    // -- Constructors
    private SharedBuffer()
    {
        // do nothing
    }

    // -- Public methods
    public synchronized static SharedBuffer getInboundBuffer(final ILogger logger, final Integer bufferSize)
    {
        if (null == in)
        {
            in = create(logger, bufferSize);
        }
        return in;
    }

    public synchronized static SharedBuffer getOutboundBuffer(final ILogger logger, final Integer bufferSize)
    {
        if (null == out)
        {
            out = create(logger, bufferSize);
        }
        return out;
    }

    public void use(User user)
    {
        buf.clear();
        user.use(buf);
    }

    public byte[] createByteArray()
    {
        return new byte[buf.capacity()];
    }

    // -- private methods
    private static SharedBuffer create(final ILogger logger, final int bufferSize)
    {
        SharedBuffer impl = new SharedBuffer();
        impl.buf = ByteBuffer.allocateDirect(bufferSize);
        return impl;
    }

    // -- inner classes
    public static interface User
    {

        /**
         * Callers MUST clear buffer prior to calling this method.
         * 
         * Implementors MUST not reference the buffer after this method returns
         * (i.e. must not assign the buffer to a member field).
         */
        public void use(ByteBuffer buf);

    }

}
