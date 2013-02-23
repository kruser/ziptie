package org.ziptie.nio.nioagent;

public class WrapperException extends RuntimeException
{

    // -- static fields
    private static final long serialVersionUID = 6518041149452794576L;

    // -- constructors
    public WrapperException(Throwable cause)
    {
        super(cause);
    }

    // -- public methods
    @Override
    public String toString()
    {
        return getCause().toString();
    }

}
