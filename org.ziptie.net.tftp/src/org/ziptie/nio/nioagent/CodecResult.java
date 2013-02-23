package org.ziptie.nio.nioagent;

import org.ziptie.nio.common.tuple.Quadruple;

public class CodecResult extends Quadruple<Integer, Boolean, Boolean, Long>
{

    // -- constructors
    public CodecResult(int outLen, boolean terminate, boolean ignore, long delay)
    {
        super(outLen, terminate, ignore, delay);
    }

    // -- public methods
    public int outLen()
    {
        return a;
    }

    public boolean terminate()
    {
        return b;
    }

    public boolean ignore()
    {
        return c;
    }

    public long delay()
    {
        return d;
    }

}
