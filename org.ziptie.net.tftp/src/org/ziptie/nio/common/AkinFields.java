package org.ziptie.nio.common;

import org.ziptie.nio.common.tuple.Pair;

public class AkinFields extends Pair<Object, Object>
{

    // -- constructors
    public AkinFields(Object mine, Object theirs)
    {
        super(mine, theirs);
    }

    // -- public methods
    public Object mine()
    {
        return a;
    }

    public Object theirs()
    {
        return b;
    }

}
